#!/bin/bash
#==================================================================================================================================
# This script creates a LAMP stack at a particular folder location using the tutum/lamp docker image.
#
#
# Running the script is incredibly easy:
#
#         lamp.sh ~/MyWebsite
#
# If this is the first time calling the above command. the MyWebsite folder will be created for you and the lamp stack will be started.
#
#  MyWebsite has a number of subdirectories which are outlined below
#
#  MyWebsite/www - put all your php/html files in here. If this is the first time you are starting up the
#                  server, adminer.php will be available so you can create databases without having to log into the container or mysql manually
#
#  MyWebsite/mysql - All the databases you store are located here
#
#  MyWebsite/sql_root_pw.txt - the root password of your sql database. If are logging on as root
#
#  MyWebsite/docker_container.txt - the name of the docker container that is running this website. Don't delete this file.
#
#==================================================================================================================================


#Get the ID of the user calling the script
USER_ID=$(id -u $USER)

#Get the full path to the base directory
BASE_DIR="$(realpath -s $1)"

#make the appropriate folders if they do not exist already
mkdir -p $(realpath -s $1)/mysql
mkdir -p $(realpath -s $1)/www
mkdir -p $(realpath -s $1)/etc/mysql


#if the docker_container.txt file exist, then attempt to stop/remove the container that is
# named in the text file
if [[ "$BASE_DIR/docker_container.txt" ]]; then
	docker stop $(cat $BASE_DIR/docker_container.txt) > /dev/null
	docker rm $(cat $BASE_DIR/docker_container.txt) > /dev/null
fi

# Here is the fun part. Create a container using the tutum/lamp image.
# but what we are going to do is mount the var/lib/mysql folder to our custom folder 
# and the /app folder to our custom www folder
# the command we are going to run is sleep 100000000 so it just holds in it's state for a long time
# we'll pipe the output to the docker_container.txt so we know what the name of the container is
docker run --privileged=true  -d -e "MYSQL_PASS =root_pw" -v $(realpath $1)/mysql:/var/lib/mysql -v $(realpath $1)/www:/app -p 80:80 tutum/lamp sleep 10000000000 > $BASE_DIR/docker_container.txt

#get the name of the container that was created
DOCKER_NAME=$(cat $BASE_DIR/docker_container.txt)

#Here's where we do some sneakyness

# Change the id of the www-data user in the container to ID of our user. The www-data user that the apache  server runs
# this is so when apache is run, any files that it creates will be owned by the user, instead of root
docker exec $DOCKER_NAME usermod -u $USER_ID www-data
#add the www-data use to the root group
docker exec $DOCKER_NAME usermod -a -G root www-data

#change the permissions on some of the folders that sql needs to run so that the www-data user can read/write to it.
#we are going to run mysql server as the www-data user as well
docker exec $DOCKER_NAME chmod -R 777 /var/run/mysqld
docker exec $DOCKER_NAME chmod -R 777 /var/log/mysql

#change the shell of the www-data user to bash.
docker exec $DOCKER_NAME chsh -s /bin/bash www-data

#if the mysql database has not been created, we need to create the database.
if [[ ! -d "$BASE_DIR/mysql/mysql" ]]; then
	echo $(realpath -s $1)/mysql/mysql does not exist. Initializing SQL database
	
	#start mysql as the www-data user
	docker exec --user=www-data $DOCKER_NAME mysqld_safe

	#install the mysql database and make sure it is owned by the www-data user
	docker exec --user=www-data $DOCKER_NAME mysql_install_db --user=www-data:www-data

	#start the database engine again
	docker exec -d --user=www-data $DOCKER_NAME /start-mysqld.sh

	#create the root user using the script that already exists in the container (thanks tutum)
	docker exec $DOCKER_NAME /create_mysql_admin_user.sh

	#start apache! Apache will run as user www-data
	docker exec -d $DOCKER_NAME /start-apache2.sh
	#start mysql server as the www-data user
	docker exec -d --user=www-data $DOCKER_NAME /start-mysqld.sh

	#make some text files that hold the root password for the sql database
	echo root > $(realpath -s $1)/sql_root_pw.txt
	echo root_pw >> $(realpath -s $1)/sql_root_pw.txt

	#right now the mysql databases and apache both run as if they were the 
	#same user on the host

else
	#if the mysql database already exists, when we can simply just start the database
	# and apache
	echo $(realpath -s $1)/mysql/mysql exists. Using original.
	docker exec -d --user=www-data $DOCKER_NAME /start-mysqld.sh
	docker exec -d $DOCKER_NAME /start-apache2.sh
fi

#change the id of the www-data to the user's ID

