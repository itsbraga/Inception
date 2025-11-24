# Indicates which OS the virtual machine should run on
FROM debian:bookworm

# Update and install MariaDB server
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		mariadb-server && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB config from the host and put it into the container image
COPY conf/my_50-server.cnf /etc/mysql/mariadb.conf.d/my_50-server.cnf

# Copy initialization tool & script
COPY tools/colors.sh /usr/local/bin/colors.sh
COPY tools/init-db.sh /usr/local/bin/init-db.sh

# Set proper permissions
#
#	Beyond classic permissions (rwx), Unix has 3 special bits
#	Bit position:	  4			2			1
#			Setuid*		     Setgid**		   Sticky bit***
#
#		(*)   runs with owner rights
#		(**)  runs with group rights or group inheritance (directory)
#		(***) deletion protection (directories)
#
#	mkdir -m 2750	: only mysql user and its group can read
#	/var/run/mysqld : directory for MariaDB socket
#
RUN chmod +x /usr/local/bin/colors.sh /usr/local/bin/init-db.sh && \
	mkdir -p -m 2755 /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	mkdir -p -m 2750 /var/log/mysql && \
	chown -R mysql:mysql /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql

# Port used to communicate with WordPress container
EXPOSE 3306

HEALTHCHECK --interval=10s --timeout=1s --retries=3 --start-period=30s \
	CMD mysqladmin -h localhost -u root -p${MYSQL_ROOT_PASSWORD} ping 2>&1 | grep -qE "mysqld is alive"; if [ $? -eq 0 ]; then exit 0; else exit 1; fi

# Defines the main command that MUST be executed when a container starts up
ENTRYPOINT [ "/usr/local/bin/init-db.sh" ]
