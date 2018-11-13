#!/bin/bash


function install_mongodb(){
    mkdir -p /data/service/src/
    wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.4.tgz -P /data/service/src/ 
    cd /data/service/src
    tar xf mongodb-linux-x86_64-4.0.4.tgz
    cd mongodb-linux-x86_64-4.0.4/
    mv mongodb-linux-x86_64-4.0.4 /data/service/mongodb
    mkdir -p /data/service/mongodb/data
    touch /data/service/mongodb/mongodb.log
    
    /data/service/mongodb/bin/mongod --dbpath=/data/service/mongodb/data/  --logpath=/data/service/mongodb/mongodb.log -logappend -port=27017 --fork
    
    echo "PATH=$PATH:/data/service/mongodb/bin/" >>/etc/profile
    export PATH=$PATH:/data/service/mongodb/bin/
}


install_mongodb
