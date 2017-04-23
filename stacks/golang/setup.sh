#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail

# The version of golang in the main repo is *ancient* (1.3.x); let's get
# ourselves a newer version:

echo 'deb http://httpredir.debian.org/debian/ jessie-backports main' >> \
	/etc/apt/sources.list.d/backports.list
apt-get update
apt-get -t jessie-backports install -y golang

# Needed for fetching most dependencies:
apt-get install -y git

exit 0
