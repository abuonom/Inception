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
