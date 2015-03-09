#!/bin/bash

#sudo service nginx restart
#sudo service php5-fpm restart

/usr/sbin/php5-fpm --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf &
/usr/sbin/nginx -g "daemon off;"
