#!/bin/bash

echo $1 > temp.txt
echo $1 >> temp.txt
echo $(realpath $2)
docker run --privileged=true -v $(realpath $2):/home/ftpusers/$1 -d -p 3784:21 --name ftp_server stilliard/pure-ftpd

#docker exec ftp_server /bin/bash 'cat > temp.txt' < temp.txt
cat temp.txt | docker exec -i ftp_server pure-pw useradd $1 -u ftpuser -d /home/ftpusers/$1
docker exec ftp_server pure-pw mkdb

