#!/bin/bash

VERSION=4.2.5



function install_mongodb(){

    mkdir -p /data/service/src/

    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        # Ubuntu 18.04
        sudo apt-get -y install libcurl4 openssl
        wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu1804-${VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-${VERSION}.tgz
        cd /data/service/src
        tar xf mongodb-linux-x86_64-ubuntu1804-${VERSION}.tgz
        mv mongodb-linux-x86_64-ubuntu1804-${VERSION} /data/service/mongodb
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        # centOS 7
        sudo yum -y install libcurl openssl
        wget -O  /data/service/src/mongodb-linux-s390x-rhel72-${VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-s390x-rhel72-${VERSION}.tgz
        cd /data/service/src
        tar xf mongodb-linux-s390x-rhel72-${VERSION}.tgz
        mv mongodb-linux-s390x-rhel72-${VERSION} /data/service/mongodb
    else
        echo 'unknow OS'
        exit 1
    fi
 
    mkdir -p /data/service/mongodb/data
    touch /data/service/mongodb/mongodb.log
    
    /data/service/mongodb/bin/mongod --dbpath=/data/service/mongodb/data/  --logpath=/data/service/mongodb/mongodb.log -logappend --bind_ip 0.0.0.0 -port=27017   --fork 
    
    echo 'export PATH=$PATH:/data/service/mongodb/bin/' > /etc/profile.d/mongodb.sh
    export PATH=$PATH:/data/service/mongodb/bin/
}


install_mongodb
