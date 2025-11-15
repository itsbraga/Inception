#	Indicates which OS the virtual machine should run on
FROM debian:bookworm

#	Update and install MariaDB server
RUN apt-get update \
	&& apt-get install -y \
		mariadb-server \
		vim \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

#	Copy custom MariaDB config from the host and put it into the container image
COPY conf/my_50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#	Copy initialization script
# COPY tools/init_db.sh /usr/local/bin/init_db.sh

#	Set proper permissions
#
#	Beyond classic permissions (rwx), Unix has 3 special bits
#	Bit position:	  4			2		  1
#					Setuid*	 Setgid**  Sticky bit***
#
#			(*)   runs with owner rights
#			(**)  runs with group rights or group inheritance (directory)
#			(***) deletion protection (directories)
#
#		mkdir -m 2750	: only mysql user et its group can read
#		/var/run/mysqld : directory for MariaDB socket
RUN chmod +x /usr/local/bin/init_db.sh \
	&& mkdir -p -m 2755 /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& mkdir -p -m 2750 /var/log/mysql \
	&& chown -R mysql:mysql /var/log/mysql \
	&& chown -R mysql:mysql /var/lib/mysql

#	Port used to communicate with WordPress container
EXPOSE 3306

#	Defines the main command that MUST be executed when a container starts up
# ENTRYPOINT [ "/usr/local/bin/init_db.sh" ]