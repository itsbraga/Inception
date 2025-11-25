# Indicate which OS the virtual machine should run on
FROM debian:bookworm

# Create directories for WordPress and PHP-FPM
RUN mkdir -p /var/www/wordpress /run/php

# Set working directory
WORKDIR /var/www/wordpress

# Update and install PHP-FPM and necessaries
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		php8.2-fpm \
		php8.2-mysql \
		php8.2-gd \
		php8.2-xml \
		php8.2-mbstring \
		php8.2-curl \
		mariadb-client \
		ca-certificates \
		curl \
		netcat-openbsd && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000 (instead of socket)
RUN sed -i "s|^listen = .*|listen = 0.0.0.0:9000|" /etc/php/8.2/fpm/pool.d/www.conf && \
	sed -i "s|^;clear_env = .*|clear_env = no|" /etc/php/8.2/fpm/pool.d/www.conf

# Copy WordPress setup file and tools
COPY ./tools/colors.sh /usr/local/bin/colors.sh
COPY ./tools/docker-cleanup.sh /usr/local/bin/docker-cleanup.sh
COPY ./conf/wp-setup.sh /usr/local/bin/wp-setup.sh

# Give execution rights to everyone
RUN chmod +x /usr/local/bin/colors.sh \
	/usr/local/bin/docker-cleanup.sh \
	/usr/local/bin/wp-setup.sh 

# Expose PHP-FPM port to communicate with NGINX
EXPOSE 9000

# Verify if PHP-FPM is listening on port 9000
HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=3 \
	CMD nc -z localhost 9000 || exit 1

# Defines the main command that MUST be executed when a container starts up
ENTRYPOINT [ "/usr/local/bin/wp-setup.sh" ]
