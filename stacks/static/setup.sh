#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx
# Set up nginx conf
unlink /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/sandstorm-static <<EOF
server {
    listen 8000 default_server;
    listen [::]:8000 default_server ipv6only=on;

    server_name localhost;
    root /opt/app;
}
EOF
ln -s /etc/nginx/sites-available/sandstorm-static /etc/nginx/sites-enabled/sandstorm-static
# patch nginx conf to not bother trying to setuid, since we're not root
# also patch errors to go to stderr, and logs nowhere.
sed --in-place='' \
        --expression 's/^user www-data/#user www-data/' \
        --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
        --expression 's/^\s*error_log.*/error_log stderr;/' \
        --expression 's/^\s*access_log.*/access_log off;/' \
        /etc/nginx/nginx.conf
service nginx stop
systemctl disable nginx
