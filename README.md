### Descrizione:

Questo progetto ha lo scopo di configurare una piccola infrastruttura composta da vari servizi all'interno di un ambiente di macchina virtuale utilizzando Docker Compose. L'infrastruttura include NGINX con TLSv1.2 o TLSv1.3, WordPress con php-fpm e MariaDB. Il progetto impone regole specifiche come l'utilizzo di Dockerfiles per ciascun servizio, la costruzione di container da Alpine o Debian, e garantisce il riavvio dei container in caso di crash. Inoltre, richiede di configurare volumi per il database di WordPress e i file del sito web, stabilire una docker-network per la comunicazione tra i container e configurare la risoluzione del nome di dominio per puntare all'indirizzo IP locale.

---

### Struttura del Progetto:

La struttura della directory del progetto è la seguente:

```bash
cartella_del_progetto/
│
├── srcs/
│   ├── requirements/
│   │   ├── nginx/
│   │   │   ├── conf/
|   |   |   ├── tools/
│   │   │   ├── Dockerfile
│   │   │   └── .dockerignore
│   │   ├── wordpress/
│   │   │   ├── conf/
|   |   |   ├── tools/
│   │   │   ├── Dockerfile
│   │   │   └── .dockerignore
│   │   └── mariadb/
│   │       ├── conf/
|   |       ├── tools/
│   │       ├── Dockerfile
│   │       └── .dockerignore
│   ├── docker-compose.yml
│   └── .env
│
└── Makefile
```

### Prerequisiti:

- Ambiente di macchina virtuale.
- Docker installato sulla macchina virtuale.
- Comprensione di base di Docker, Docker Compose e creazione di Dockerfile.

---

### Istruzioni di Installazione:

1. Clonare questo repository nella tua macchina virtuale.
2. Navigare fino alla directory del progetto.
3. Assicurarsi che Docker sia in esecuzione sulla macchina virtuale.
4. Eseguire `make` con i rispettivi comandi per creare le immagini Docker e configurare i container.
5. Accedere ai servizi tramite il nome di dominio configurato `login.42.fr` nel browser.

### Comandi:

- `up`: Avvia i container Docker e crea il file `.env` nella directory `srcs` con le variabili di ambiente necessarie per il progetto.
- `down`: Arresta e rimuove i container Docker insieme ai volumi associati.
- `stop`: Sospende l'esecuzione dei container Docker.
- `start`: Avvia i container Docker precedentemente sospesi.
- `status`: Visualizza lo stato di tutti i container Docker.
- `image`: Visualizza l'elenco delle immagini Docker presenti nel sistema.
- `volume`: Visualizza l'elenco dei volumi Docker presenti nel sistema.
- `logs`: Visualizza i log dei container Docker `wordpress`, `nginx` e `mariadb`.
- `modify_hosts`: Modifica il file `/etc/hosts` aggiungendo l'indirizzo IP locale associato al nome di dominio `$(USER).42.fr`.

### Utilizzo:

1. Esegui `make` per avviare i container Docker e creare il file `.env`.
2. Esegui `make clean` per arrestare e rimuovere i container Docker.
3. Esegui `make re` per rimuovere i dati dei volumi, arrestare e quindi riavviare i container Docker.
   
## Dockerfile NGINX:

```Dockerfile
#Immagine del OS dal quale partire. Penultima versione stabile
FROM debian:bullseye
#In questa riga, eseguiamo update con APT, ed installiamo nginx, vim e curl
RUN apt update && apt install nginx -y && apt install vim -y && apt install curl -y
#Creiamo una directory, dove salvare il certificato e la chiave, ed installiamo OpenSSL per generarli
RUN mkdir -p /etc/nginx/ssl && apt install openssl -y
#Il comando req, crea e processa il certificato, la flag -x509 specifica il tipo di certificato, -nodes ci permette di non impostare una psw, out e keyout ci permettono di impostare output
#-subj ci permette di compilare le informazioni richieste dal certificato all'avvio
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr/UID=login"
#Creazione folder, destinata ai config files
RUN mkdir -p /var/run/nginx
#Sostituiamo il nostro file di config, a quello di default di nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN chmod 755 /var/www/
RUN chown -R www-data:www-data /var/www/
#Modifichiamo i permessi per essere sicuri di poter accedere
RUN chmod 755 /var/www/html && chown -R www-data:www-data /var/www/html
#Lanciamo nginx in modo che il container non si interrompa
COPY /tools/nginx.sh /
RUN chmod +x /nginx.sh
CMD [ "/nginx.sh" ]
```

In questo Dockerfile definisco l'ambiente per il container NGINX. Inizio con una base Debian, quindi installo NGINX, Vim, Curl e OpenSSL. Successivamente, creiamo un certificato self-signed per abilitare HTTPS, copio il file di configurazione personalizzato per NGINX e avvio NGINX all'interno del container.

## Script NGINX.sh:

```bash
#!/bin/bash

sed -i -r "s#third#$DOMAIN_NAME#g"    /etc/nginx/nginx.conf
echo "Aspetto 20 secondi prima di configurare Nginx..."
sleep 20

echo "Imposto i permessi per /var/www/wordpress..."
chmod 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress/

echo "Modifico il file nginx.conf con il nome del server..."
echo "Avvio Nginx..."
nginx -g 'daemon off;'
```

Nello script che viene eseguito all'avvio del container NGINX. Sostituisco dinamicamente il nome del dominio nel file di configurazione di NGINX, imposto uno sleep dia 20 secondi per garantire che altre operazioni siano state completate, imposto i permessi sulla directory di WordPress e avvio NGINX in modalità daemon.

---

## Dockerfile MariaDB:

```Dockerfile
FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt-get install mariadb-server -y
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh
CMD ["/usr/local/bin/init_db.sh"]
```

Questo Dockerfile definisce l'ambiente per il container MariaDB. Parto da una base Debian, quindi aggiorna il sistema e installa il server MariaDB. Copia un file di configurazione personalizzato per MariaDB e uno script per l'inizializzazione del database al momento dell'avvio del container.

## Script init_db.sh:

```bash
#!/bin/bash

# Avvia il servizio MariaDB
service mariadb start

# Attendere che il servizio sia completamente avviato
sleep 10

# Crea un database se non esiste
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${db_name}\`;"

# Crea un utente se non esiste e imposta la password
mariadb -e "CREATE USER IF NOT EXISTS \`${db_user}\`@'localhost' IDENTIFIED BY '${db_pwd}';"

# Concedi tutti i privilegi all'utente sul database
mariadb -e "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO \`${db_user}\`@'%' IDENTIFIED BY '${db_pwd}';"

# Cambia la password per l'utente 'root'
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

# Applica immediatamente i cambiamenti di privilegi
mariadb -p1234 -e "FLUSH PRIVILEGES;"

# Arresta il servizio MariaDB in modo pulito
mariadb-admin -u root -p$SQL_ROOT_PASSWORD shutdown

# Avvia il server MariaDB in modo sicuro (questo comando potrebbe non essere necessario o corretto qui)
exec mariadbd-safe
```

Questo script Bash viene eseguito all'avvio del container MariaDB. Avvia il servizio MariaDB, attende che sia completamente avviato, quindi crea un database e un utente, assegna i privilegi, cambia la password di root e applica immediatamente i cambiamenti dei privilegi. Infine, arresta il servizio MariaDB in modo pulito e avvia il server MariaDB in modo sicuro.

## Dockerfile WordPress:

```Dockerfile
FROM debian:bullseye

RUN apt update \
 && apt upgrade -y \
 && apt install vim -y \
 && apt install curl -y \
 && apt-get -y install wget \
 && apt-get install -y php7.4 \
 php-fpm \
 php-mysql \
 mariadb-client \
 && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY /tools/wordpress.sh /

RUN chmod +x /wordpress.sh

CMD [ "/wordpress.sh" ]
```

In questo Dockerfile si definisce l'ambiente per il container WordPress. Parto da una base Debian, quindi aggiorno il sistema e installo Vim, Curl, Wget, PHP, PHP-FPM, PHP-MySQL e il client MariaDB. Scarica e installa WP-CLI per automatizzare le operazioni su WordPress. Copia il file di configurazione personalizzato per PHP-FPM e uno script per l'avvio di WordPress all'interno del container.

## Script wordpress.sh:

```bash
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
```

Questo script Bash viene eseguito all'avvio del container WordPress. Attende 40 secondi per garantire che il database MariaDB sia completamente avviato, quindi crea una directory per WordPress e scarica la versione 6.5 di WordPress utilizzando WP-CLI. Successivamente, crea un file di configurazione per WordPress utilizzando le credenziali del database fornite, installa WordPress e crea un nuovo utente. Aggiunge una configurazione per Redis, installa e attiva il tema Astra e il plugin Redis Cache, aggiorna tutti i plugin, crea una directory per PHP-FPM, abilita il Redis Cache, modifica le proprietà della directory di wp-content e avvia PHP-FPM.


### Note Importanti:

- Tutte le immagini Docker devono essere create dai Dockerfile forniti all'interno del progetto.
- Evitare l'uso di patch improvvisate o loop infiniti nei comandi o negli entrypoint.
- Assicurarsi che i volumi siano configurati correttamente per il database di WordPress e i file del sito web.
- Seguire le migliori pratiche per la creazione di Dockerfile e la configurazione dei container.
- Le variabili di ambiente dovrebbero essere utilizzate, e un file `.env` è fornito per comodità.

