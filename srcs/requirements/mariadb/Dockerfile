FROM debian:bookworm

#	Update and install MariaDB server
RUN apt update && apt install -y \
	mariadb-server \
	vim \
	curl

#	Copy custom MariaDB config from the host and put it into the container image
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#	Copy initialization script
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod -x /usr/local/bin/init_db.sh

#	Create directory for MariaDB socket
RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld

EXPOSE 3306