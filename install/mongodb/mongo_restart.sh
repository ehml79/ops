#!/bin/bash



mongodb_daemon="/data/service/mongodb/bin/mongod  \
--dbpath=/data/service/mongodb/data/  \
--logpath=/data/service/mongodb/mongodb.log \
-logappend  \
--bind_ip 0.0.0.0  \
-port=27017    \
--fork"


if [ -S ${mongo_file} ];then
    killall mongod
    sleep 1
    ${mongodb_daemon}
else
    ${mongodb_daemon}
fi

