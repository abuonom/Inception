
all : up

clean : down

re : vclean up

reboot : down up

vclean: down
	@rm -rf /home/manuele/data/wordpress/*
	@rm -rf /home/manuele/data/mariadb/*
up:
	@if [ ! -f srcs/.env ]; then \
	touch srcs/.env ; \
	echo DOMAIN_NAME=localhost >> srcs/.env; \
	echo CERTS_=/etc/nginx/ssl/inception.crt >> srcs/.env; \
	echo KEYS_=/etc/nginx/ssl/inception.key >> srcs/.env; \
	echo WP_TITLE=${USER}WP >> srcs/.env; \
	echo WP_ADMIN_USR=${USER} >> srcs/.env; \
	echo WP_ADMIN_PWD=1234 >> srcs/.env; \
	echo WP_ADMIN_EMAIL=${USER}@student.42roma.it >> srcs/.env; \
	echo WP_USR=${USER}2 >> srcs/.env; \
	echo WP_EMAIL=${USER}@student.42roma.it >> srcs/.env; \
	echo WP_PWD=123 >> srcs/.env; \
	echo db_name=maria >> srcs/.env; \
	echo db_user=spallettone >> srcs/.env; \
	echo db_pwd=chelevuoivinceretutte >> srcs/.env; \
	echo SQL_ROOT_PASSWORD=1234 >> srcs/.env; \
	echo USERDOCKER=${USER} >> srcs/.env; \
	fi
	@if [ ! -d /home/${USER}/data ]; then \
	mkdir /home/${USER}/data; \
	mkdir /home/${USER}/data/wordpress; \
	mkdir /home/${USER}/data/mariadb; \
	fi
	@if [ ! -d /home/${USER}/data/wordpress ]; then \
	mkdir /home/${USER}/data/wordpress; \
	fi
	@if [ ! -d /home/${USER}/data/mariadb ]; then \
	mkdir /home/${USER}/data/mariadb; \
	fi
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f srcs/docker-compose.yml down -v --rmi all

stop:
	@docker-compose -f srcs/docker-compose.yml stop

start:
	@docker-compose -f srcs/docker-compose.yml start

status:
	@docker ps -a

image:
	@docker image ls

volume:
	@docker volume ls

logs:
	@echo "\nlogs of container: -wordpress\n--------------------------------------------\n"
	@docker logs wordpress
	@echo "\nlogs of container: -nginx\n--------------------------------------------\n"
	@docker logs nginx
	@echo "\nlogs of container: -mariadb\n--------------------------------------------\n"
	@docker logs mariadb
