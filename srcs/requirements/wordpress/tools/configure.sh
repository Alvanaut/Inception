#!/bin/bash
set -e

cd /var/www/html

if [ ! -f wp-config.php ]; then
    until mysqladmin ping -h"${DB_HOST}" --silent 2>/dev/null; do
        echo "Waiting for MariaDB..."
        sleep 2
    done

    wp core download --allow-root

    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="$(cat /run/secrets/db_password)" \
        --dbhost="${DB_HOST}"

    wp core install --allow-root \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d= -f2)" \
        --admin_email="${WP_ADMIN_EMAIL}"

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --allow-root \
        --role=author \
        --user_pass="$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d= -f2)"
fi

exec "$@"
