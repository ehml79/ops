#!/bin/bash


CREATE USER 'username'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON username.* TO 'username'@'%' ;
ALTER USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
flush privileges;
