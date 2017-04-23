#!/bin/bash
set -euo pipefail

# In order to import other packages in your own source tree, you'll have to
# set this to the import url for the root of your repository. for example:
#
# pkgpath=github.com/me/my-apps-repo
pkgpath=

export GOPATH=$HOME/go

if [ -n "$pkgpath" ] && [ ! -L "$GOPATH/src/$pkgpath" ] ; then
	ln -s /opt/app "$GOPATH/src/$pkgpath"
fi

cd /opt/app
go get -v -d ./...
go build -v -i
exit 0
