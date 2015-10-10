# quickdocker

## ftp.sh

A quick way to host an ftp site to send files to friends.

Usage:

ftp.sh homer /path/to/folder/you/want/to/share

this creates the ftp server and creates a user/password as homer/homer

## lamp.sh

Creates a LAMP web stack to run your website. Simply run:

lamp.sh /path/to/empty/folder

and it will create a www and mysql subdirectories where your webserver will reside.  The www folder is where you put all your web files

The SQL login is root, with no password. (will need to figure out something with this)

Bugs:
Copying the folder that gets created to another location and running 

lamp.sh /path/to/new/location

Seems give problems with the mysql connection.


## ventrilo.sh

Quickly create a ventrilo server for you and your buddies
