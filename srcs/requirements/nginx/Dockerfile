# Indicate which OS the virtual machine should run on
FROM debian:bookworm

# Update and install NGINX + OpenSSL
RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		nginx \
		openssl \
		ca-certificates \
		curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate
RUN openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=annabrag.42.fr/UID=annabrag"

# Set proper permissions and create an NGINX directory to store its config files
RUN chmod 600 /etc/nginx/ssl/nginx.key && \
	chmod 644 /etc/nginx/ssl/nginx.crt && \
	mkdir -p /var/run/nginx

# Copy custom NGINX config from the host and put it into the container image
COPY ./conf/my_nginx.conf /etc/nginx/nginx.conf
COPY ./tools/docker-cleanup.sh /usr/local/bin/docker-cleanup.sh

# Set proper permissions
RUN chmod +x /usr/local/bin/docker-cleanup.sh && \
	chmod 755 /var/www/html && \
	chown -R www-data:www-data /var/www/html

# Expose HTTPS port only
EXPOSE 443

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
	CMD curl -f https://localhost:443 -k --silent --show-error || exit 1

# Start NGINX as PID 1, in foreground (no daemon mode)
CMD [ "nginx", "-g", "daemon off;" ]
