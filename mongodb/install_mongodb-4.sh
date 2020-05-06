#!/bin/bash

MONGODB_VERSION=4.2.5
MONGODB_PASSWORD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`



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
 
    mkdir -p /data/service/mongodb/{etc,data}
    touch /data/service/mongodb/mongodb.log


cat > /data/service/mongodb/etc/mongod.conf << EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/mongodb.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1
  unixDomainSocket:
    enabled: false

security:
  authorization: enabled

#operationProfiling:
#replication:
#sharding:
EOF
    
    #/data/service/mongodb/bin/mongod --dbpath=/data/service/mongodb/data/  --logpath=/data/service/mongodb/mongodb.log --auth  -logappend --bind_ip 0.0.0.0 -port=27017   --fork 
    /data/service/mongodb/bin/mongod  -f /data/service/mongodb/etc/mongod.conf  
    echo /data/service/mongodb/bin/mongo 127.0.0.1/admin --eval \"db.createUser\(\{user:\'root\',pwd:\'$MONGODB_PASSWORD\',roles:[\'userAdminAnyDatabase\']\}\)\" | bash
    
    echo $MONGODB_PASSWORD > /data/service/mongodb/etc/mongodb.secret

    echo 'export PATH=$PATH:/data/service/mongodb/bin/' > /etc/profile.d/mongodb.sh
    export PATH=$PATH:/data/service/mongodb/bin/
}


install_mongodb
