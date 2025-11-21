#!/bin/sh

. /usr/local/bin/colors.sh

#	Stop the script in error case
set -e

#	Initialize MySQL data directory if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
	printf "${PB}Initializing MySQL data directory...${RESET}\n"
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

#	Start MySQL temporarily in the background
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
MYSQL_PID=$!

#	Wait for MySQL with timeout (30 seconds max)
printf "${PY}Waiting for MySQL to start...${RESET}\n"
if ! timeout 30 sh -c 'until mysqladmin ping --silent 2>/dev/null; do sleep 1; done'; then
	printf "${BOLD}${RED}Error:${RESET} MySQL failed to start\n"
	kill $MYSQL_PID 2>/dev/null || true
	exit 1
fi

printf "${PGG}✔ MySQL is ready${RESET}\n"

#	Create a table if it does not already exist, with the name of the environment variable
#	SQL_DATABASE, indicated in my .env file, which will be sent by docker-compose.yml 
mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

#	Change 'root' rights with SQL_ROOT_PASSWORD
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

#	Create a user who can manipulate the database
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

#	Grant all privileges on MYSQL_DATABASE table to MySQL_USER which password is SQL_PASSWORD
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

printf "${PG}✔ Database setup complete${RESET}\n"

#	Stop temporary MySQL instance
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

#	Wait for clean shutdown
wait $MYSQL_PID

#	Replaces the shell with 'mysqld_safe' to make MySQL the container's main process (PID 1)
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql
