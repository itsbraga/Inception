#!/bin/sh

. /usr/local/bin/colors.sh

# Stop the script on any error
set -e

printf "${BOLD}${PP}=== MariaDB Initialization ===${RESET}\n"

# Check if MariaDB has already been initialized
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	printf "${PY}First-time initialization detected${RESET}\n"
	printf "${PB}[1/2] Initializing MySQL data directory...${RESET}\n"
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	printf "${PB}[2/2] Configuring database (bootstrap mode)...${RESET}\n"
	mysqld --user=mysql --bootstrap << EOF

	-- Switch to the mysql system database
	USE mysql;
	FLUSH PRIVILEGES;

	-- SECURITY: Remove anonymous users (empty username)
	-- These allow connections without authentication
	DELETE FROM mysql.user WHERE User='';

	-- SECURITY: Remove test database and related privileges
	-- The test database is created by default and accessible to all
	DROP DATABASE IF EXISTS test;
	DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

	-- DATABASE CREATION: Create WordPress database
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

	-- USER CREATION: WordPress user for remote and local connections
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';

	-- PRIVILEGES: Grant full access to WordPress database for remote and local user
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%'; 
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost'; 

	-- ROOT SECURITY: Set root password
	UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';

	-- ROOT SECURITY: Remove root access from network
	-- Principle of least privilege: root should only be accessible locally
	DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

	-- Apply all changes
	FLUSH PRIVILEGES;
EOF

	printf "${PG}✔ Database setup complete${RESET}\n"
else
	printf "${PB}Database already initialized, skipping setup${RESET}\n"
fi

printf "${BOLD}${PINK}\n=== Starting MariaDB Server ===${RESET}\n"

# Start MariaDB server as PID 1
#
#	+  exec: Replace shell with mysqld for proper signal handling
#	+  --user=mysql: Run as mysql user for security
#	+  --console: Outputs logs to stdout instead of files (for 'docker logs')
#
exec mysqld --user=mysql --console
