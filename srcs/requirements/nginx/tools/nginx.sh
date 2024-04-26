#!/bin/bash

echo "Aspetto 20 secondi prima di configurare Nginx..."
sleep 20

echo "Imposto i permessi per /var/www/wordpress..."
chmod 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress/

echo "Modifico il file nginx.conf con il nome del server..."
sed -i "s/NOMESERVER/$USER.42.fr/g" /etc/nginx/nginx.conf
echo "Avvio Nginx..."
nginx -g 'daemon off;'
