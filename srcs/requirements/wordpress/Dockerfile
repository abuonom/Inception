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
