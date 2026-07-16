#!/bin/bash
set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    service mariadb start

    until mysqladmin ping --silent 2>/dev/null; do
        echo "Waiting for MariaDB..."
        sleep 2
    done

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';"
    mysql -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p"$(cat /run/secrets/db_root_password)" shutdown
fi

exec "$@" --user=mysql
