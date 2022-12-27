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

# something something folders
mkdir -p /var/lib/mysql
mkdir -p /var/lib/mysql-files
mkdir -p /var/lib/nginx
mkdir -p /var/log
mkdir -p /var/log/mysql
mkdir -p /var/log/nginx
# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run
rm -rf /var/tmp
mkdir -p /var/tmp
mkdir -p /var/run/mysqld

# Rotate log files larger than 512K
log_files="$(find /var/log -type f -name '*.log')"
for f in $log_files; do
    if [ $(du -b "$f" | awk '{print $1}') -ge $((512 * 1024)) ] ; then
        mv $f $f.1
    fi
done

UWSGI_SOCKET_FILE=/var/run/uwsgi.sock

# Ensure mysql tables created
# HOME=/etc/mysql /usr/bin/mysql_install_db
HOME=/etc/mysql /usr/sbin/mysqld --initialize

# Spawn mysqld
HOME=/etc/mysql /usr/sbin/mysqld --skip-grant-tables &

MYSQL_SOCKET_FILE=/var/run/mysqld/mysqld.sock
# Wait for mysql to bind its socket
wait_for mysql $MYSQL_SOCKET_FILE

# Spawn uwsgi
HOME=/var uwsgi \
        --socket $UWSGI_SOCKET_FILE \
        --plugin python3 \
        --virtualenv /opt/app-venv \
        --wsgi-file /opt/app/main.py &

# Wait for uwsgi to bind its socket
wait_for uwsgi $UWSGI_SOCKET_FILE

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"

