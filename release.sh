#! /bin/bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-yes}"

function assert_github_token_and_release_tool_present() {
  echo "**** Checking environment for GitHub token. ****"
  export | grep -q GITHUB_TOKEN= || (echo "Aiee, you should set a GITHUB_TOKEN environment variable." ; exit 1)

  echo "**** Checking path for GitHub release tool. ****"
  which github-release >/dev/null || (echo "Aiee, you need a github-release tool in the PATH."; exit 1)
}

function assert_git_state_is_clean() {
  if [ "x$(git status --porcelain)" != "x" ]; then
    echo "Please commit changes to git before releasing." >&2
    exit 1
  fi

  echo "**** Checking that you did a git push already... ****"
  local ORIGIN_MASTER_GIT_REVISION="$(git rev-parse origin/master)"
  local CURRENT_HEAD_GIT_REVISION="$(git rev-parse HEAD)"
  if [[ "$ORIGIN_MASTER_GIT_REVISION" == "$CURRENT_HEAD_GIT_REVISION" ]]; then
    echo "     success."
  else
    echo "     fail. Please do a git push and re-run this script."
    exit 1
  fi
}

function get_release_name() {
  # We use the current Sandstorm release number as vagrant-spk release number for simplicity. This
  # does mean it might be hard to hae two vagrant-spk releases in a short time period.
  #
  # As for what these version numbers *mean* and how this gets calculated, see the sandstorm
  # repository's release.sh.
  local CHANNEL=dev

  echo "**** Determining next build number for $CHANNEL channel ****"

  local LAST_BUILD=$(curl -fs https://install.sandstorm.io/$CHANNEL)

  # Import the BRANCH_NUMBER from the sandstorm git repo.
  . ../sandstorm/branch.conf

  if (( LAST_BUILD / 1000 > BRANCH_NUMBER )); then
    echo "ERROR: $CHANNEL has already moved past this branch!" >&2
    echo "  I refuse to replace it with an older branch." >&2
    exit 1
  fi

  local BASE_BUILD=$(( BRANCH_NUMBER * 1000 ))
  local BUILD=$(( BASE_BUILD > LAST_BUILD ? BASE_BUILD : LAST_BUILD ))
  local BUILD_MINOR="$(( $BUILD % 1000 ))"

  # DISPLAY_VERSION gets used in the git tag description, so we make it global.
  DISPLAY_VERSION="${BRANCH_NUMBER}.${BUILD_MINOR}"

  # TAG_NAME gets used as the git tag name, so we make it global.
  TAG_NAME="v${DISPLAY_VERSION}"
}

function assert_changelog_present() {
  # Verify that the changelog has been updated.
  EXPECTED_CHANGELOG="### $TAG_NAME ($(date '+%Y-%m-%d'))"
  if [ "$(head -n 1 CHANGELOG.md)" != "$EXPECTED_CHANGELOG" ]; then
    echo "Changelog not updated. First line should be:" >&2
    echo "$EXPECTED_CHANGELOG" >&2
    exit 1
  fi
}

function build_windows_exe() {
  # The Windows EXE filename is always vagrant-spk-setup.exe locally, and when we upload it to
  # GitHub as a release artifact, we rename it to use $TAG_NAME in the filename to indicate the
  # version.
  WINDOWS_EXE=windows-support/dist/innosetup/vagrant-spk-setup.exe

  echo "**** Building Windows EXE ****"
  (cd windows-support && make)
}

function tag_and_push() {
  echo "**** Tagging this commit ****"

  # The git tag stores the version number as a normal-looking version number, like 0.75 for build 75
  # within branch 0, or 2.121 for build 121 within branch 2.
  GIT_REVISION="$(git rev-parse HEAD)"

  if [[ "$DRY_RUN" == "yes" ]] ; then
    echo "Not tagging yet, but this would be vagrant-spk ${DISPLAY_VERSION}"
    echo ""
  else
    git tag "$TAG_NAME" "$GIT_REVISION" -m "Release vagrant-spk ${DISPLAY_VERSION}"
  fi

  echo "**** Pushing build $BUILD ****"
  if [[ "$DRY_RUN" == "yes" ]]; then
    echo "Not pushing $BUILD yet. Re-run with DRY_RUN=no in the environment."
    echo ""
  else
    git push origin "$TAG_NAME"
  fi
}

function create_github_release() {
  echo "**** Creating GitHub release for $BUILD ****"

  if [[ "$DRY_RUN" == "yes" ]] ; then
    echo "Not creating GitHub release yet. Re-run with DRY_RUN=no in the environment."
    echo ""
  else
    github-release release --draft --tag "$TAG_NAME" -u sandstorm-io -r vagrant-spk -d "$(python -c 's = open("CHANGELOG.md").read(); print s[:s.index("\n### ")-1]')"
    github-release upload -u sandstorm-io -r vagrant-spk -t "$TAG_NAME" -n "vagrant-spk-setup-$TAG_NAME.exe" --file "$WINDOWS_EXE"
  fi
}

function main() {
  assert_github_token_and_release_tool_present
  assert_git_state_is_clean
  get_release_name
  assert_changelog_present
  build_windows_exe
  tag_and_push
  create_github_release
}

main
