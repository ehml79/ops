#!/bin/bash

# for Ubuntu 20.04 LTS
# for Ubuntu 18.04 LTS

MONGODB_VERSION=4.4.2
MONGODB_PASSWORD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`



function install_mongodb(){

    mkdir -p /data/service/src/
    cd /data/service/src

    # 判断系统
    if [ -f /usr/bin/apt ];then
        # Ubuntu 18.04
        echo 'ubuntu'
        sudo apt-get -y install libcurl4 openssl
        wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
        tar xf mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
        mv mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION} /data/service/mongodb

        SYSTEM_DIR=/lib/systemd/system/mongod.service 
    elif [ -f /usr/bin/yum ];then
        # centOS 7
        echo 'centOS'
        sudo yum -y install libcurl openssl wget
        wget -O /data/service/src/mongodb-linux-x86_64-rhel70-4.4.2.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.4.2.tgz
        tar xf mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz
        mv mongodb-linux-x86_64-rhel70-${MONGODB_VERSION} /data/service/mongodb

        SYSTEM_DIR=/usr/lib/systemd/system/mongod.service
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

sudo systemctl enable mongod
sudo systemctl start mongod


#    echo /data/service/mongodb/bin/mongo 127.0.0.1/admin --eval \"db.createUser\(\{user:\'root\',pwd:\'$MONGODB_PASSWORD\',roles:[\'userAdminAnyDatabase\']\}\)\" | bash
#    echo $MONGODB_PASSWORD > /data/service/mongodb/etc/mongodb.secret

    echo 'export PATH=$PATH:/data/service/mongodb/bin/' > /etc/profile.d/mongodb.sh
    export PATH=$PATH:/data/service/mongodb/bin/

}

# mongo -u usernamd -p password --port 27017 --host localhost
# mongo localhost:27017/dbname  -u username -p password

function install_tools(){

    VERSION=$(grep "VERSION_ID" /etc/os-release | cut -f 2 -d '=')
    cd /data/service/src
    
    if [ "${VERSION}"=="20.04" ];then
        # for Ubuntu 20.04 
        echo "20.04"
        wget -O /data/service/src/mongodb-database-tools-ubuntu2004-x86_64-100.3.0.tgz  https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2004-x86_64-100.3.0.tgz 
        tar xf mongodb-database-tools-ubuntu2004-x86_64-100.3.0.tgz
        mv mongodb-database-tools-ubuntu2004-x86_64-100.3.0 /data/service/mongodb-database-tools
    elif [ "${VERSION}"=="18.04" ];then
        # for Ubuntu 18.04 
        echo "18.04"
        wget -O /data/service/src/mongodb-database-tools-ubuntu1804-x86_64-100.3.0.tgz  https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu1804-x86_64-100.3.0.tgz
        tar xf mongodb-database-tools-ubuntu1804-x86_64-100.3.0.tgz
        mv mongodb-database-tools-ubuntu1804-x86_64-100.3.0 /data/service/mongodb-database-tools
    else
        echo "Unknow"
        exit
    fi


    echo 'export PATH=$PATH:/data/service/mongodb-database-tools/bin' > /etc/profile.d/mongodb-database-tools.sh
    export PATH=$PATH:/data/service/mongodb-database-tools/bin
}



install_mongodb
install_tools
