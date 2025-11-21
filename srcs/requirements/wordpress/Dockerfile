# Indicates which OS the virtual machine should run on
FROM debian:bookworm

# Update and install PHP-FPM and necessaries
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		wget \
		php7.3 php-fpm php-mysql \
		mariadb-client \
		vim \
		curl && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install WP-CLI (tool to configure WordPress via command line)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
	chmod +x /usr/local/bin/wp

# Create WordPress and PHP directory for pid file && set proper permissions for www-data (PHP-FPM user)
RUN mkdir -p /var/www/wordpress /run/php && \
	chown -R www-data:www-data /var/www/wordpress && \
	chmod -R 755 /var/www/wordpress

# Download WordPress directory
RUN wget https://wordpress.org/wordpress-6.8.2.tar.gz -P /tmp && \
	tar -xzf /tmp/wordpress-6.8.2.tar.gz -C /var/www && \
	rm /tmp/wordpress-6.8.2.tar.gz

# Configure PHP-FPM to listen on port 900 (instead of socket)
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

# Copy WordPress setup file
COPY conf/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod -x /usr/local/bin/wp-setup.sh

# Expose PHP-FPM port to communicate with NGINX
EXPOSE 9000

# Set working directory
WORKDIR /var/www/wordpress

# Defines the main command that MUST be executed when a container starts up
ENTRYPOINT [ "/usr/local/bin/wp-setup.sh" ]
