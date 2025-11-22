#!/bin/bash

# ---------------------------
# 1) Validate WordPress env
# ---------------------------
wordpress_env=(
	"$WORDPRESS_DB_HOST"
	"$WORDPRESS_DB_PORT"
	"$WORDPRESS_SITE_TITLE"
	"$WORDPRESS_ADMIN_USER"
	"$WORDPRESS_ADMIN_PASSWORD"
	"$WORDPRESS_ADMIN_EMAIL"
	"$MYSQL_DATABASE"
	"$MYSQL_USER"
	"$MYSQL_USER_PASSWORD"
)

for var in "${wordpress_env[@]}"; do
	if [ -z "$var" ]; then
		echo "Error: Required environment variable is missing"
		exit 1
	fi
done

# ---------------------------
# 2) Install WP-CLI if missing
# ---------------------------
if [ ! -f /usr/local/bin/wp ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

# ---------------------------
# 3) Prepare directories
# ---------------------------
[ ! -d /run/php ] && mkdir -p /run/php
[ ! -d /var/www/html ] && mkdir -p /var/www/html
cd /var/www/html

# ---------------------------
# 4) Initialize WordPress
# ---------------------------
if [ ! -f wp-config.php ]; then
	wp core download --allow-root
	wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_USER_PASSWORD" --dbhost="$WORDPRESS_DB_HOST:$WORDPRESS_DB_PORT" --allow-root
	wp core install --url="https://${DOMAIN_NAME}" --title="$WORDPRESS_SITE_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --allow-root
	wp user create "$MYSQL_USER" "${MYSQL_USER}@${DOMAIN_NAME}" --role=author --user_pass="$MYSQL_USER_PASSWORD" --allow-root
fi

# # change listen address to 9000 and bind to all interfaces
sed -i 's/listen = .*/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf

# ---------------------------
# 7) Start PHP-FPM
# ---------------------------
exec php-fpm7.4 -F
