#!/bin/bash
# ---------------------------
# 1) Validate MariaDB environment variables
# ---------------------------
mariadb_env=("$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" "$MYSQL_USER" "$MYSQL_USER_PASSWORD")
for var in "${mariadb_env[@]}"; do
	if [ -z "$var" ]; then
		echo "Error: One or more required environment variables are not set."
		exit 1
	fi
done

# Initialize database only if missing
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
	echo "Initializing database..."
	SQL_FILE="/tmp/init_db.sql"
	cat >"$SQL_FILE" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	# Start MariaDB in background for initialization
	mysqld_safe --skip-networking &
	PID=$!

	# Wait until MariaDB is ready
	until mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; do
		echo "Waiting for MariaDB to start..."
		sleep 1
	done

	# Run initialization
	mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <"$SQL_FILE"
	rm -f "$SQL_FILE"

	# Stop temporary server
	mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
	wait $PID
	echo "Database initialized."
fi

# Start MariaDB in foreground (PID 1) and bind to all interfaces so other containers can connect
exec mysqld_safe --bind-address=0.0.0.0