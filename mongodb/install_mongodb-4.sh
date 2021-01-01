#!/bin/bash

MONGODB_VERSION=4.4.2
MONGODB_PASSWORD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`



function install_mongodb(){

    mkdir -p /data/service/src/

    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        # Ubuntu 18.04
        sudo apt-get -y install libcurl4 openssl
        wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
        cd /data/service/src
        tar xf mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
        mv mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION} /data/service/mongodb
        SYSTEM_DIR=/lib/systemd/system/mongodb.service 
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        # centOS 7
        sudo yum -y install libcurl openssl wget
        wget -O /data/service/src/mongodb-linux-x86_64-rhel70-4.4.2.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.4.2.tgz
        cd /data/service/src
        tar xf mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz
        mv mongodb-linux-x86_64-rhel70-${MONGODB_VERSION} /data/service/mongodb
        SYSTEM_DIR=/usr/lib/systemd/system/mongodb.service
    else
        echo 'unknow OS'
        exit 1
    fi
 
    mkdir -p /data/service/mongodb/{etc,data}
    touch /data/service/mongodb/mongodb.log

    mv  /root/mongod.conf  /data/service/mongodb/etc/mongod.conf 
    

cat  > ${SYSTEM_DIR} << EOF
[Unit]
 
Description=mongodb 
After=network.target remote-fs.target nss-lookup.target
 
[Service]
Type=forking
ExecStart=/data/service/mongodb/bin/mongod --config /data/service/mongodb/etc/mongod.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/data/service/mongodb/bin/mongod --shutdown --config /data/service/mongodb/etc/mongod.conf
PrivateTmp=true
  
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable mongodb
sudo systemctl start mongodb


    echo /data/service/mongodb/bin/mongo 127.0.0.1/admin --eval \"db.createUser\(\{user:\'root\',pwd:\'$MONGODB_PASSWORD\',roles:[\'userAdminAnyDatabase\']\}\)\" | bash
    
    echo $MONGODB_PASSWORD > /data/service/mongodb/etc/mongodb.secret

    echo 'export PATH=$PATH:/data/service/mongodb/bin/' > /etc/profile.d/mongodb.sh
    export PATH=$PATH:/data/service/mongodb/bin/

}



install_mongodb
