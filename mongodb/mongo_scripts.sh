#!/bin/bash



# mongo单机连接方式
mongo -uuser -ppassword  1.1.1.1:27017/admin


# mongo集群连接方式
mongo mongodb://1.1.1.1:27017,2.2.2.2:27017/admin  -uuser -ppassword


# mongo删库
mongo dbname --host 1.1.1.1:27017 -authenticationDatabase admin -u username -p 'password' --eval 'db.dropDatabase();'