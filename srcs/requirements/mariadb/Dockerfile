# Indicates which OS the virtual machine should run on
FROM debian:bookworm

# Update and install MariaDB server
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		mariadb-server && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB config from the host and put it into the container image
COPY ./conf/my_50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy initialization tool & script
COPY ./tools/colors.sh /usr/local/bin/colors.sh
COPY ./tools/docker-cleanup.sh /usr/local/bin/docker-cleanup.sh
COPY ./tools/db-setup.sh /usr/local/bin/db-setup.sh

# Set proper permissions
#
#	mkdir -m 2750	: only mysql user and its group can read
#	/var/run/mysqld : directory for MariaDB socket
#
RUN chmod +x /usr/local/bin/colors.sh /usr/local/bin/docker-cleanup.sh /usr/local/bin/db-setup.sh && \
	mkdir -p -m 2755 /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	mkdir -p -m 2750 /var/log/mysql && \
	chown -R mysql:mysql /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql

# Port used to communicate with WordPress container
EXPOSE 3306

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
	CMD mysqladmin -h localhost -u root -p"${MYSQL_ROOT_PASSWORD}" ping --silent || exit 1

# Defines the main command that MUST be executed when a container starts up
ENTRYPOINT [ "/usr/local/bin/db-setup.sh" ]
