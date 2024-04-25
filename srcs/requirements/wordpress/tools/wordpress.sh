#!/bin/bash

echo "Attendi 40 secondi per il database..."
sleep 40

echo "Creazione della directory /var/www/wordpress..."
mkdir -p /var/www/wordpress
cd /var/www/wordpress

echo "Download di WordPress..."
wp core download --version=6.5 --allow-root

echo "Creazione del file di configurazione di WordPress..."
wp config create --allow-root \
                 --dbname=$db_name \
                 --dbuser=$db_user \
                 --dbpass=$db_pwd \
                 --dbhost=mariadb:3306 --path='/var/www/wordpress'

echo "Installazione di WordPress..."
wp core install --url=$DOMAIN_NAME/ --title=$WP_TITLE \
                --admin_user=$WP_ADMIN_USR --admin_password=$WP_ADMIN_PWD \
                --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

echo "Creazione di un nuovo utente WordPress..."
wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root

echo "Aggiunta configurazione Redis..."
redis_config="define( 'WP_REDIS_HOST', 'redis' );\n\
define( 'WP_REDIS_PORT', 6379 );\n\
define( 'WP_CACHE', true );"
sed -i "/^.*ABSPATH.*\$/i $redis_config" wp-config.php

echo "Installazione e attivazione del tema Astra..."
wp theme install astra --activate --allow-root

echo "Installazione e attivazione del plugin Redis Cache..."
wp plugin install redis-cache --activate --allow-root

echo "Aggiornamento di tutti i plugin..."
wp plugin update --all --allow-root

echo "Creazione della directory /run/php..."
mkdir /run/php

echo "Abilitazione del Redis Cache..."
wp redis enable --allow-root

echo "Modifica della proprietà della directory /var/www/wordpress/wp-content..."
chown -R www-data:www-data /var/www/wordpress/wp-content/

echo "Avvio di PHP-FPM..."
/usr/sbin/php-fpm7.4 -F
