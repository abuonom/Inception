#Immagine del OS dal quale partire. Penultima versione stabile
FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt-get install mariadb-server -y
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh
CMD ["/usr/local/bin/init_db.sh"]
