
all : up

clean : down

re : volumeclean up

reboot : down up

volumeclean: down
	@sudo rm -rf /home/${USER}/data/wordpress/*
	@sudo rm -rf /home/${USER}/data/mariadb/*
up:
	@if [ -f srcs/.env ]; then \
	rm srcs/.env ; \
	fi
	@if [ ! -f srcs/.env ]; then \
	touch srcs/.env ; \
	sudo echo DOMAIN_NAME=${USER}.42.fr >> srcs/.env; \
	sudo echo CERTS_=/etc/nginx/ssl/inception.crt >> srcs/.env; \
	sudo echo KEYS_=/etc/nginx/ssl/inception.key >> srcs/.env; \
	sudo echo WP_TITLE=${USER}WP >> srcs/.env; \
	sudo echo WP_ADMIN_USR=${USER} >> srcs/.env; \
	sudo echo WP_ADMIN_PWD=1234 >> srcs/.env; \
	sudo echo WP_ADMIN_EMAIL=${USER}@student.42roma.it >> srcs/.env; \
	sudo echo WP_USR=${USER}2 >> srcs/.env; \
	sudo echo WP_EMAIL=${USER}@student.42roma.it >> srcs/.env; \
	sudo echo WP_PWD=123 >> srcs/.env; \
	sudo echo db_name=maria >> srcs/.env; \
	sudo echo db_user=spallettone >> srcs/.env; \
	sudo echo db_pwd=chelevuoivinceretutte >> srcs/.env; \
	sudo echo SQL_ROOT_PASSWORD=1234 >> srcs/.env; \
	sudo echo USERDOCKER=${USER} >> srcs/.env; \
	fi
	@if [ ! -d /home/${USER}/data ]; then \
	sudo mkdir /home/${USER}/data; \
	sudo mkdir /home/${USER}/data/wordpress; \
	sudo mkdir /home/${USER}/data/mariadb; \
	fi
	@if [ ! -d /home/${USER}/data/wordpress ]; then \
	sudo mkdir /home/${USER}/data/wordpress; \
	fi
	@if [ ! -d /home/${USER}/data/mariadb ]; then \
	sudo mkdir /home/${USER}/data/mariadb; \
	fi
	@sudo docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@sudo docker-compose -f srcs/docker-compose.yml down -v --rmi all

stop:
	@sudo docker-compose -f srcs/docker-compose.yml stop

start:
	@sudo docker-compose -f srcs/docker-compose.yml start

status:
	@sudo docker ps -a

image:
	@sudo docker image ls

volume:
	@sudo docker volume ls

logs:
	@sudo echo "\nlogs of container: -wordpress\n--------------------------------------------\n"
	@sudo docker logs wordpress
	@sudo echo "\nlogs of container: -nginx\n--------------------------------------------\n"
	@sudo docker logs nginx
	@sudo echo "\nlogs of container: -mariadb\n--------------------------------------------\n"
	@sudo docker logs mariadb

modify_hosts:
	@sudo echo "Modifica del file /etc/hosts..."
	@sudo sed -i '1s/^.*$$/127.0.0.1https:\/\/$(USER).42.fr\//' /etc/hosts
	@sudo echo "Fatto."
