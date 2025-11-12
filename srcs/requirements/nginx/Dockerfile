FROM debian:bookworm

RUN apt update && apt install nginx -y

# Install tools
RUN apt install vim -y && apt install curl -y

# Creates a private RSA key and TSL certificate
RUN mkdir -p /etc/nginx/ssl
RUN apt install openssl -y
RUN openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=annabrag.42.fr/UID=annabrag"
RUN chmod 600 /etc/nginx/ssl/inception.key

# Create an NGINX directory to store its config files
RUN mkdir -p /var/run/nginx

# Copy the customized config file from the host and put it into the container image
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Sets config on the image that indicates a port the image would like to expose
#EXPOSE 9000
