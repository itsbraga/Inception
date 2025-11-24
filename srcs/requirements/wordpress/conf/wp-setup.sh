#!/bin/sh

. /usr/local/bin/colors.sh

# Stop the script on error
set -e

# Go to WordPress directory
cd /var/www/wordpress

# Configure WordPress only if not already done
if [ ! -f wp-config.php ]; then

	# Download WordPress core files if not present
	if [ ! -f wp-load.php ]; then
		printf "${PB}Downloading WordPress...${RESET}\n"
		wp core download --allow-root
	fi

	# Create wp-config.php with database credentials
	printf "${PB}Creating wp-config.php...${RESET}\n"
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="${DB_HOST}" \
		--skip-check \
		--allow-root

	# Install WordPress
	printf "${PB}Installing WordPress...${RESET}\n"
	wp core install \
		--path="${WP_PATH}" \
		--url="https://annabrag.42.fr" \
		--title="★ art&mis' website ★" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${MYSQL_ADMIN_EMAIL}" \
#		--skip-email \
		--allow-root

	# Create second user (non-admin)
	printf "${PB}Creating second user...${RESET}\n"
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root

	printf "${PG}✔ WordPress setup complete${RESET}\n"
else
	printf "${PGG}✔ WordPress already configured${RESET}\n"
fi

# Set correct ownership for www-data (PHP-FPM user)
chown -R www-data:www-data /var/www/wordpress

# Start PHP-FPM in foreground mode (PID 1)
printf "${PGG}Starting PHP-FPM...${RESET}\n"
exec php-fpm8.2 -F
