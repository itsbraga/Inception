# Indicate which OS the virtual machine should run on
FROM debian:bookworm

# Update and install MariaDB server
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		mariadb-server && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy custom MariaDB config from the host and put it into the container image
COPY ./conf/my_50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy initialization tool & script
COPY ./tools/colors.sh /usr/local/bin/colors.sh
COPY ./tools/db-setup.sh /usr/local/bin/db-setup.sh

# Set proper permissions
#
#	- Setgid (2) on directories ensures files created inherit the directory's group
#	- 2755 for /var/run/mysqld: socket must be accessible by clients
#	- 2750 for /var/log/mysql: logs are sensitive, restrict access
#
RUN chmod +x /usr/local/bin/colors.sh \
		/usr/local/bin/db-setup.sh && \
	mkdir -p -m 2755 /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	mkdir -p -m 2750 /var/log/mysql && \
	chown -R mysql:mysql /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql

# Port used to communicate with WordPress container
EXPOSE 3306

# Healthcheck to verify MariaDB is responding
#
#	- start-period=60s: Allows time for bootstrap initialization
#	- mysqladmin ping: Simple check, no password needed
#	- silent: Reduces log noise
#
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
	CMD mysqladmin ping -h localhost --silent || exit 1

# Main command that MUST be executed when a container starts up
ENTRYPOINT [ "/usr/local/bin/db-setup.sh" ]
