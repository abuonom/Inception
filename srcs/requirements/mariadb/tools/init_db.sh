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
