#!/bin/bash

# Crea la directory /var/www/ e /var/www/html per utilizzarla dopo nel container nginx
# e per configurare WordPress
mkdir /var/www/
mkdir /var/www/html

# Sposta nella directory /var/www/html
cd /var/www/html

# Rimuovi tutti i file nella directory corrente per una pulizia (se necessario)
rm -rf *

# Scarica wp-cli, uno strumento da riga di comando per la gestione di WordPress
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Rendi wp-cli eseguibile
chmod +x wp-cli.phar

# Sposta wp-cli.phar in una directory nel PATH per poterlo usare come 'wp'
mv wp-cli.phar /usr/local/bin/wp

# Scarica l'ultima versione di WordPress utilizzando wp-cli
wp core download --allow-root

# Rinomina il file di configurazione di esempio di WordPress per usarlo come file di configurazione attivo
mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Sposta il file di configurazione personalizzato wp-config.php nella directory di WordPress
mv /wp-config.php /var/www/html/wp-config.php

# Sostituisci le credenziali del database nel file di configurazione wp-config.php
# sostituendo 'db1', 'user', 'pwd' con i rispettivi valori delle variabili
sed -i -r "s/db1/$db_name/1"   wp-config.php
sed -i -r "s/user/$db_user/1"  wp-config.php
sed -i -r "s/pwd/$db_pwd/1"    wp-config.php

# Installa WordPress utilizzando wp-cli con dettagli specificati nelle variabili d'ambiente
wp core install --url=$DOMAIN_NAME/ --title=$WP_TITLE --admin_user=$WP_ADMIN_USR --admin_password=$WP_ADMIN_PWD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

# Crea un nuovo utente WordPress con il ruolo di autore
wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root

# Installa e attiva il tema 'astra' di WordPress
wp theme install astra --activate --allow-root

# Installa e attiva il plugin 'redis-cache'
wp plugin install redis-cache --activate --allow-root

# Aggiorna tutti i plugin di WordPress alla loro ultima versione
wp plugin update --all --allow-root

# Modifica il file di configurazione di PHP-FPM per ascoltare sulla porta 9000
# invece che su un socket unix
sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 9000/g' /etc/php/7.3/fpm/pool.d/www.conf

# Crea la directory /run/php necessaria per PHP-FPM
mkdir /run/php

# Abilita il plugin Redis di WordPress per l'utilizzo della cache
wp redis enable --allow-root

# Avvia il processo PHP-FPM in primo piano (foreground)
/usr/sbin/php-fpm7.3 -F
