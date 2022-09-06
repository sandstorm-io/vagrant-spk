#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y gnupg
echo -e "deb http://repo.mysql.com/apt/debian/ bullseye mysql-8.0\ndeb-src http://repo.mysql.com/apt/debian/ bullseye mysql-8.0" > /etc/apt/sources.list.d/mysql.list
wget -O /tmp/RPM-GPG-KEY-mysql https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
apt-key add /tmp/RPM-GPG-KEY-mysql

apt-get update
apt-get install -y nginx mysql-server libmysqlclient-dev uwsgi uwsgi-plugin-python3 build-essential python3-dev python3-mysqldb python3-virtualenv git
# patch mysql conf to not change uid, and to use /var/tmp over /tmp
sed --in-place='' \
        --expression='s/^user\t\t= mysql/#user\t\t= mysql/' \
        --expression='s,^tmpdir\t\t= /tmp,tmpdir\t\t= /var/tmp,' \
        /etc/mysql/my.cnf
# patch mysql conf to use smaller transaction logs to save disk space
cat <<EOF > /etc/mysql/conf.d/sandstorm.cnf
[mysqld]
# Set the transaction log file to the minimum allowed size to save disk space.
innodb_log_file_size = 1048576
# Set the main data file to grow by 1MB at a time, rather than 8MB at a time.
innodb_autoextend_increment = 1
EOF
service nginx stop
service mysql stop
systemctl disable nginx
systemctl disable mysql
