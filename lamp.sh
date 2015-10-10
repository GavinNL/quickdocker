#!/bin/bash

docker stop WebServer
docker rm WebServer

USER_ID=$(id -u $USER)

#echo $(realpath -s $1)
#echo $USER_ID
BASE_DIR="$(realpath -s $1)"


#rm -r $(realpath -s $1)/mysql
mkdir -p $(realpath -s $1)/mysql
mkdir -p $(realpath -s $1)/www
mkdir -p $(realpath -s $1)/etc/mysql
echo root > $(realpath -s $1)/sql_root_pw.txt
echo root_pw >> $(realpath -s $1)/sql_root_pw.txt

#chmod -R 1777 $(realpath $1)/www
#chmod -R 1777 $(realpath $1)/mysql
#chmod -R 1777 $(realpath $1)/etc/
#chmod -R 1777 $(realpath $1)
#chown -R root:root $(realpath $1)
#docker run --privileged=true --name WebServer -d -v $(realpath $1)/etc/mysql:/etc/mysql -v $(realpath $1)/mysql:/var/lib/mysql -v $(realpath $1)/www:/app -p 80:80 tutum/lamp



docker run --privileged=true --name WebServer -d -e "MYSQL_PASS=root_pw" -v $(realpath $1)/mysql:/var/lib/mysql -v $(realpath $1)/www:/app -p 80:80 tutum/lamp sleep 10000000000

docker exec WebServer usermod -u $USER_ID www-data
docker exec WebServer usermod -a -G root www-data
docker exec WebServer chmod -R 777 /var/run/mysqld
docker exec WebServer chmod -R 777 /var/log/mysql
docker exec WebServer chsh -s /bin/bash www-data

if [[ ! -d "$BASE_DIR/mysql/mysql" ]]; then
	echo $(realpath -s $1)/mysql/mysql does not exist. Creating new database
	
	docker exec --user=www-data WebServer mysqld_safe

	docker exec --user=www-data WebServer mysql_install_db --user=www-data:www-data

	docker exec -d --user=www-data WebServer /start-mysqld.sh
	docker exec WebServer /create_mysql_admin_user.sh
	docker exec -d WebServer /start-apache2.sh
	docker exec -d --user=www-data WebServer /start-mysqld.sh

else
	echo $(realpath -s $1)/mysql/mysql exists. Using original.
	docker exec -d --user=www-data WebServer /start-mysqld.sh
	docker exec -d WebServer /start-apache2.sh
fi

#change the id of the www-data to the user's ID




#docker exec WebServer ./create_mysql_admin_user.sh
#docker exec --user=www-data WebServer mysqld_safe --pid-file=/tmp/mysqld.pid
#docker exec -it WebServer /bin/bash
# mysqld_safe --pid-file=/tmp/mysqld.pid



#/etc/mysql

