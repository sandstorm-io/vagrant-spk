#! /bin/bash

set -euo pipefail

echo "**** Checking environment for configuration. ****"
export | grep -q GITHUB_TOKEN= || (echo "Aiee, you should set a GITHUB_TOKEN environment variable." ; exit 1)

if [ "x$(git status --porcelain)" != "x" ]; then
  echo "Please commit changes to git before releasing." >&2
  exit 1
fi

CHANNEL=dev

echo "**** Determining next build number for $CHANNEL channel ****"

LAST_BUILD=$(curl -fs https://install.sandstorm.io/$CHANNEL)

. ../sandstorm/branch.conf

if (( LAST_BUILD / 1000 > BRANCH_NUMBER )); then
  echo "ERROR: $CHANNEL has already moved past this branch!" >&2
  echo "  I refuse to replace it with an older branch." >&2
  exit 1
fi

BASE_BUILD=$(( BRANCH_NUMBER * 1000 ))
BUILD=$(( BASE_BUILD > LAST_BUILD ? BASE_BUILD : LAST_BUILD ))
BUILD_MINOR="$(( $BUILD % 1000 ))"
DISPLAY_VERSION="${BRANCH_NUMBER}.${BUILD_MINOR}"
TAG_NAME="v${DISPLAY_VERSION}"

# Verify that the changelog has been updated.
EXPECTED_CHANGELOG="### $TAG_NAME ($(date '+%Y-%m-%d'))"
if [ "$(head -n 1 CHANGELOG.md)" != "$EXPECTED_CHANGELOG" ]; then
  echo "Changelog not updated. First line should be:" >&2
  echo "$EXPECTED_CHANGELOG" >&2
  exit 1
fi

# The Windows EXE stores the version number as an integer, e.g. 75 for
# build 75 within branch 0. See Sandstorm's release.sh for more
# information.
WINDOWS_EXE=windows-support/dist/innosetup/vagrant-spk-setup.exe

echo "**** Building Windows EXE ****"
(cd windows-support && make)

echo "**** Tagging this commit ****"

# The git tag stores the version number as a normal-looking version
# number, like 0.75 for build 75 within branch 0, or 2.121 for build
# 121 within branch 2.

GIT_REVISION="$(git rev-parse HEAD)"
git tag "$TAG_NAME" "$GIT_REVISION" -m "Release vagrant-spk ${DISPLAY_VERSION}"

echo "**** Now is your chance to interrupt the process if you need! ^D to continue, ^C to stop ****"
cat

echo "**** Pushing build $BUILD ****"

git push origin "$TAG_NAME"
github-release release --draft --tag "$TAG_NAME" -u sandstorm-io -r vagrant-spk -d "$(python -c 's = open("CHANGELOG.md").read(); print s[:s.index("\n### ")-1]')"
github-release upload -u sandstorm-io -r vagrant-spk -t "$TAG_NAME" -n "vagrant-spk-setup-$TAG_NAME.exe" --file "$WINDOWS_EXE"
