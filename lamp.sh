#!/bin/bash
docker stop WebServer
docker rm WebServer

#mkdir -p $(realpath $1)/mysql
#mkdir -p $(realpath $1)/www
#mkdir -p $(realpath $1)/etc/mysql
#chmod -R 777 $(realpath $1)/www
#chmod -R 777 $(realpath $1)/mysql
#chmod -R 777 $(realpath $1)/etc/
#chmod -R 777 $(realpath $1)
#chown -R root:root $(realpath $1)
docker run --privileged=true --name WebServer -d -v $(realpath $1)/etc/mysql:/etc/mysql -v $(realpath $1)/mysql:/var/lib/mysql -v $(realpath $1)/www:/app -p 80:80 tutum/lamp

#/etc/mysql
