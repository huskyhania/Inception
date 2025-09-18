#!/bin/sh

echo "[ vvv ] Setting up MariaDB directory..."
chmod -R 755 /var/lib/mysql

mkdir -p /run/mysqld

chown -R mysql:mysql /var/lib/mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[ vvv ] Initializing MariaDB system tables..."
	mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql >/dev/null

	echo "[ vvv ] Creating WordPress database and user..."
	mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
CREATE DATABASE $WORDPRESS_DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
ALTER USER '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'%';
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'localhost' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
ALTER USER '$WORDPRESS_DB_USER'@'localhost' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

else
	echo "[ vvv ] MariaDB already installed. Database and users configured."
fi

echo "[ vvv ] Starting MariaDB server..."
exec mysqld --defaults-file=/etc/my.cnf.d/mariadb_config
