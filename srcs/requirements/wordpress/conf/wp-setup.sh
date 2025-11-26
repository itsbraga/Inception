#!/bin/sh

. /usr/local/bin/colors.sh

# Stop the script on any error
set -e

if [ -f /run/secrets/wp_admin_password.txt ]; then
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password.txt)
else
	printf "${BOLD}${RED}Error:${NC} Secret wp_admin_password not found\n"
	exit 1
fi

if [ -f /run/secrets/wp_admin_email.txt ]; then
	WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email.txt)
else
	printf "${BOLD}${RED}Error:${NC} Secret wp_admin_email not found\n"
	exit 1
fi

if [ -f /run/secrets/wp_user_password.txt ]; then
	WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password.txt)
else
	printf "${BOLD}${RED}Error:${NC} Secret wp_user_password not found\n"
	exit 1
fi

if [ -f /run/secrets/wp_user_email.txt ]; then
	WP_USER_EMAIL=$(cat /run/secrets/wp_user_email.txt)
else
	printf "${BOLD}${RED}Error:${NC} Secret wp_user_email not found\n"
	exit 1
fi

# Go to WordPress directory
cd /var/www/wordpress

# Configure WordPress only if not already done
if [ ! -f wp-config.php ]; then

	# Check if WordPress core file is present
	if [ ! -f wp-load.php ]; then
    		printf "${BOLD}${RED}Error:${NC} WordPress files missing\n"
    		exit 1
	fi

	# Create wp-config.php with database credentials
	printf "${PB}Creating wp-config.php...${NC}\n"
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${MYSQL_DBNAME}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="${DB_HOST}" \
		--skip-check \
		--allow-root

	# Install WordPress
	printf "${PB}Installing WordPress...${NC}\n"
	wp core install \
		--path="${WP_PATH}" \
		--url="https://annabrag.42.fr" \
		--title="⋆˙⟡&nbsp;&nbsp;&nbsp;art&mis' website&nbsp;&nbsp;&nbsp;₍^. .^₎⟆" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root

	# Create second user (non-admin)
	printf "${PB}Creating second user...${NC}\n"
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root

	printf "${PG}✔ WordPress setup complete${NC}\n"
else
	printf "${PGG}✔ WordPress already configured${NC}\n"
fi

# Set correct ownership for www-data (PHP-FPM user)
printf "${PB}Setting correct permissions...${NC}\n"
chown -R www-data:www-data /var/www/wordpress
chmod -R 750 /var/www/wordpress

# Start PHP-FPM as PID 1, in foreground mode
printf "${PGG}Starting PHP-FPM...${NC}\n"
exec php-fpm8.2 -F
