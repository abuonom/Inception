#!/bin/bash

echo "Aspetto 20 secondi prima di configurare Nginx..."
sleep 20

echo "Imposto i permessi per /var/www/wordpress..."
chmod 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress/

echo "Avvio Nginx..."
nginx -g 'daemon off;'
