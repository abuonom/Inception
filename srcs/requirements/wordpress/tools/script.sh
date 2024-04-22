#!/bin/bash

sleep 20

cd /var/www/wordpress

wp core download --version=6.5 --allow-root

wp config create	--allow-root \
					--dbname=$db_name \
					--dbuser=$db_user \
					--dbpass=$db_pwd \
					--dbhost=mariadb:3306 --path='/var/www/wordpress'

wp core install --url=$DOMAIN_NAME/ --title=$WP_TITLE --admin_user=$WP_ADMIN_USR --admin_password=$WP_ADMIN_PWD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root

redis_config="define( 'WP_REDIS_HOST', 'redis' );\n\
define( 'WP_REDIS_PORT', 6379 );\n\
define( 'WP_CACHE', true );"

sed -i "/^.*ABSPATH.*\$/i $redis_config" wp-config.php

wp theme install astra --activate --allow-root

wp plugin install redis-cache --activate --allow-root

wp plugin update --all --allow-root

mkdir /run/php

wp redis enable --allow-root

chown -R www-data:www-data /var/www/wordpress/wp-content/

/usr/sbin/php-fpm7.4 -F
