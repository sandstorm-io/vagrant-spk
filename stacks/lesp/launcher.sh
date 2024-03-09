#!/bin/bash

set -euo pipefail

wait_for() {
    local service=$1
    local file=$2
    while [ ! -e "$file" ] ; do
        echo "waiting for $service to be available at $file."
        sleep .1
    done
}

# Create a bunch of folders under the clean /var that php and nginx expect to exist
mkdir -p /var/lib/nginx
mkdir -p /var/lib/php/sessions
mkdir -p /var/log
mkdir -p /var/log/nginx
# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run/php

# Rotate log files larger than 512K
log_files="$(find /var/log -type f -name '*.log')"
for f in $log_files; do
    if [ $(du -b "$f" | awk '{print $1}') -ge $((512 * 1024)) ] ; then
        mv $f $f.1
    fi
done

# Spawn php
/usr/sbin/php-fpm8.2 --nodaemonize --fpm-config /etc/php/8.2/fpm/php-fpm.conf &
# Wait until php has bound its socket, indicating readiness
wait_for php-fpm8.2 /var/run/php/php8.2-fpm.sock

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
