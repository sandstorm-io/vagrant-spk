#!/bin/bash
set -euo pipefail

mkdir -p /var/lib/nginx
mkdir -p /var/log/nginx
# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run

# Start nginx.
/usr/sbin/nginx -g "daemon off;"
