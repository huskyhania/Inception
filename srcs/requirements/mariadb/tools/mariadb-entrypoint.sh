#!/bin/sh

ROOT_PASSWORD_FILE="/run/secrets/mysql_root_password"
if [ -f "$ROOT_PASSWORD_FILE" ]; then
  MYSQL_ROOT_PASSWORD="$(cat "$ROOT_PASSWORD_FILE")"
else
  echo "[ERROR] Root password secret not found!"
  exit 1
fi

if [ -f /run/secrets/db_password ]; then
    export DB_PASSWORD="$(cat /run/secrets/db_password)"
fi


echo "Setting up MariaDB directory..."
chmod -R 755 /var/lib/mysql

mkdir -p /run/mysqld

chown -R mysql:mysql /var/lib/mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB system tables..."
	mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql >/dev/null

	echo "Creating WordPress database and user..."
	mariadbd --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
CREATE DATABASE $DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
EOF

else
	echo "MariaDB already installed. Database and users configured."
fi

echo "Starting MariaDB server..."
exec mariadbd --defaults-file=/etc/my.cnf.d/custom.cnf
