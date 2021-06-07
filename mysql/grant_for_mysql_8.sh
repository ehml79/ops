#!/bin/bash

# mysql 8.0

dbname=test
username=test

password=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`

echo $username > /root/$username.md
echo $password >> /root/$username.md

mysql << EOF
CREATE DATABASE $dbname ;

CREATE USER "$username"@'%' IDENTIFIED BY "$password";

# CREATE USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
# CREATE USER "$username"@'%' IDENTIFIED WITH caching_sha2_password BY "$password";

GRANT ALL PRIVILEGES ON $username.* TO $username@'%' ;

# ALTER USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
# ALTER USER "$username"@'%' IDENTIFIED WITH caching_sha2_password BY "$password";

# SHOW GRANTS FOR "$username"@'%' ;

FLUSH PRIVILEGES
EOF
