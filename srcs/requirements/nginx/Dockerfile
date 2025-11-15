FROM debian:bookworm

#	Update and install NGINX + OpenSSL
RUN apt update && apt install -y \
	nginx \
	openssl \
	vim \
	curl

# 	Creates directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

#	Generate self-signed SSL certificate
RUN openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=annabrag.42.fr/UID=annabrag"

#	Set proper permissions
RUN chmod 600 /etc/nginx/ssl/nginx.key \
	&& chmod 644 /etc/nginx/ssl/nginx.crt

#	Create an NGINX directory to store its config files
RUN mkdir -p /var/run/nginx

#	Copy custom NGINX config from the host and put it into the container image
COPY ./conf/my_nginx.conf /etc/nginx/nginx.conf

RUN chmod 755 /var/www/html

#	Recursive ownership changes 
RUN chown -R www-data:www-data /var/www/html

#	Expose HTTPS port only
EXPOSE 443

#	Start NGINX in foreground (no daemon mode)
# CMD ["nginx", "-g", "daemon off;"]