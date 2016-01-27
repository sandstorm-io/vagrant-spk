#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx php5-fpm php5-sqlite php5-cli php5-curl git php5-dev
rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/sandstorm-php <<EOF
server {
    listen 8000 default_server;
    listen [::]:8000 default_server ipv6only=on;

    # Allow arbitrarily large bodies - Sandstorm can handle them, and requests
    # are authenticated already, so there's no reason for apps to add additional
    # limits by default.
    client_max_body_size 0;

    # Prevent nginx from adding compression; this interacts badly with Sandstorm
    # WebSession due to https://github.com/sandstorm-io/sandstorm/issues/289
    gzip off;

    server_name localhost;
    root /opt/app;
    location / {
        index index.php;
        try_files \$uri \$uri/ =404;
    }
    location ~ \\.php\$ {
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
ln -sf /etc/nginx/sites-available/sandstorm-php /etc/nginx/sites-enabled/sandstorm-php
service nginx stop
service php5-fpm stop
systemctl disable nginx
systemctl disable php5-fpm
# patch /etc/php5/fpm/pool.d/www.conf to not change uid/gid to www-data
sed --in-place='' \
        --expression='s/^listen.owner = www-data/;listen.owner = www-data/' \
        --expression='s/^listen.group = www-data/;listen.group = www-data/' \
        --expression='s/^user = www-data/;user = www-data/' \
        --expression='s/^group = www-data/;group = www-data/' \
        /etc/php5/fpm/pool.d/www.conf
# patch /etc/php5/fpm/php-fpm.conf to not have a pidfile
sed --in-place='' \
        --expression='s/^pid =/;pid =/' \
        /etc/php5/fpm/php-fpm.conf
# patch /etc/php5/fpm/pool.d/www.conf to no clear environment variables
# so we can pass in SANDSTORM=1 to apps
sed --in-place='' \
        --expression='s/^;clear_env = no/clear_env=no/' \
        /etc/php5/fpm/pool.d/www.conf
# patch nginx conf to not bother trying to setuid, since we're not root
# also patch errors to go to stderr, and logs nowhere.
sed --in-place='' \
        --expression 's/^user www-data/#user www-data/' \
        --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
        --expression 's/^\s*error_log.*/error_log stderr;/' \
        --expression 's/^\s*access_log.*/access_log off;/' \
        /etc/nginx/nginx.conf
# Add a conf snippet providing what sandstorm-http-bridge says the protocol is as var fe_https
cat > /etc/nginx/conf.d/50sandstorm.conf << EOF
    # Trust the sandstorm-http-bridge's X-Forwarded-Proto.
    map \$http_x_forwarded_proto \$fe_https {
        default "";
        https on;
    }
EOF
# Adjust fastcgi_params to use the patched fe_https
sed --in-place='' \
        --expression 's/^fastcgi_param *HTTPS.*$/fastcgi_param  HTTPS               \$fe_https if_not_empty;/' \
        /etc/nginx/fastcgi_params
