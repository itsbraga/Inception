#!/bin/sh

. /usr/local/bin/colors.sh

# Stop the script on any error
set -e

printf "${BOLD}${PP}=== MariaDB Initialization ===${RESET}\n"

# Check if MariaDB has already been initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
	printf "${PY}First-time initialization detected${RESET}\n"

	printf "${PB}[1/2] Initializing MySQL data directory...${RESET}\n"
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	printf "${PB}[2/2] Configuring database (bootstrap mode)...${RESET}\n"
	mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve << EOF

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

FLUSH PRIVILEGES;
EOF
	
	printf "${PG}✔ Database setup complete${RESET}\n"
else
	printf "${PB}Database already initialized, skipping setup${RESET}\n"
fi

printf "${BOLD}${PINK}=== Starting MariaDB Server ===${RESET}\n"

# Start MariaDB server as PID 1
#
#	* exec: Replace shell with mysqld for proper signal handling
#	* --user=mysql: Run as mysql user for security
#	* --console: Outputs logs to stdout instead of files (for 'docker logs')
#
exec mysqld --user=mysql --console 
