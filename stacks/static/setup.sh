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
sed --in-place='' \
        --expression 's/^user www-data/#user www-data/' \
        --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
        /etc/nginx/nginx.conf
service nginx stop
systemctl disable nginx
