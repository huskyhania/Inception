#!/bin/sh

# safety measure - exits in case of errors
set -e

echo "[ vvv ] Setting up WordPress..."

WEB_ROOT="/var/www/html"
WP_CLI="/usr/local/bin/wp"
PHP_INI="/etc/php83/php.ini"

mkdir -p "$WEB_ROOT"
cd "$WEB_ROOT"

# download wp-cli if not previously installed
if [ ! -x /usr/local/bin/wp ]; then
    echo "[ vvv ] Downloading WP-CLI..."
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
    chmod +x "$WP_CLI"
fi

# allow wp-cli to run as root
export WP_CLI_ALLOW_ROOT=1

# set memory limit for PHP
echo "memory_limit = 512M" >> $PHP_INI

# wait for mariadb to be ready (up to 5 minutes)
echo "[vvv] Checking if MariaDB is running before WordPress setup..."
SUCCESS=0
for i in $(seq 1 30); do
    if mariadb-admin ping --protocol=tcp --host=mariadb -u"$DB_USER" --password="$DB_PASSWORD"; then
        echo "[ vvv ] MariaDB is ready."
        SUCCESS=1
        break
    fi
    echo "[ vvv ] Waiting for MariaDB..."
    sleep 10
done

if [ $SUCCESS -ne 1 ]; then
    echo "[ vvv ] MariaDB remained unavailable for over 5 minutes."
    exit 1
fi

# install wordpress if not already installed
if [ ! -f "$WEB_ROOT/wp-config.php"  ]; then
    echo "[ vvv ] Download and configuration of WordPress..."
    wp core download

    wp config create \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=$DB_HOST \
        --force

    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email \
        --path="$WEB_ROOT"

    echo "[ vvv ] Creating WordPress user..."
    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --user_pass="$WORDPRESS_USER_PASSWORD" || true

else
    echo "[ vvv ] WordPress is already installed and configured."
fi

# Ensure ownership and permissions
chown -R www-data:www-data "$WEB_ROOT"

find "$WEB_ROOT" -type d -exec chmod 755 {} \;
find "$WEB_ROOT" -type f -exec chmod 644 {} \;

echo "[ vvv ] Running PHP-FPM in the foreground..."
exec php-fpm83 -F
