#!/bin/bash


function install_mongodb(){
    mkdir -p /data/service/src/
    wget -O  /data/service/src/mongodb-linux-x86_64-4.0.9.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.9.tgz 
    cd /data/service/src
    tar xf mongodb-linux-x86_64-4.0.9.tgz 
    mv mongodb-linux-x86_64-4.0.9 /data/service/mongodb
    mkdir -p /data/service/mongodb/data
    touch /data/service/mongodb/mongodb.log
    
    /data/service/mongodb/bin/mongod --dbpath=/data/service/mongodb/data/  --logpath=/data/service/mongodb/mongodb.log -logappend --bind_ip 0.0.0.0 -port=27017   --fork 
    
    echo 'export PATH=$PATH:/data/service/mongodb/bin/' >>/etc/profile
    export PATH=$PATH:/data/service/mongodb/bin/
}


install_mongodb
