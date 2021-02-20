#!/bin/bash

# for Ubuntu 20.04 LTS
# for Ubuntu 18.04 LTS
# for CentOS Linux 7 (Core)

MONGODB_VERSION=3.6.22
MONGODB_PASSWORD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`


function ubuntu2004(){
    echo "20.04"
    wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz
    tar xf mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz
    mv mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION} /data/service/mongodb
}

function ubuntu1804(){
    echo "18.04"
    wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
    tar xf mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
    mv mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION} /data/service/mongodb
}

function centos7(){
    echo 'centOS'
    wget -O /data/service/src/mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz
    tar xf mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz
    mv mongodb-linux-x86_64-rhel70-${MONGODB_VERSION} /data/service/mongodb
}



function install_mongodb(){

    mkdir -p /data/service/src/
    cd /data/service/src
    VERSION=$(grep "VERSION_ID" /etc/os-release | cut -f 2 -d '=')

    # 判断系统
    if [ -f /usr/bin/apt ];then

        sudo apt-get -y install libcurl4 openssl
        SYSTEM_DIR=/lib/systemd/system/mongod.service 

        if [ "${VERSION}"=="20.04" ];then
            # for Ubuntu 20.04
	    ubuntu2004
        elif [ "${VERSION}"=="18.04" ];then
            # for Ubuntu 18.04
            ubuntu1804 
        else
            echo "Unknow"
            exit
        fi

    elif [ -f /usr/bin/yum ];then

        sudo yum -y install libcurl openssl wget
        SYSTEM_DIR=/usr/lib/systemd/system/mongod.service

        if [ "${VERSION}"=="7" ];then
            # centOS 7
	    centos7
        else
            echo "Unknow"
            exit
        fi

    else
        echo 'unknow OS'
        exit 1
    fi
 
    mkdir -p /data/service/mongodb/{etc,data}
    mkdir -p /data/service/mongodb/{etc,data/rs1,data/rs2,data/rs3}

    touch /data/service/mongodb/mongodb.log

    # 创建副本集认证文件
    mkdir -p /data/service/mongodb/keyFile 
    echo 'MongoDB Encrypting File' > /data/service/mongodb/keyFile/mongodb.key
    sudo chmod 400 /data/service/mongodb/keyFile/mongodb.key


cat >  /data/service/mongodb/etc/mongod.conf  << EOF
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
  dbPath: /data/service/mongodb/data
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongod.pid

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
  unixDomainSocket:
    enabled: false

#security:
#  authorization: enabled

#operationProfiling:
replication:
  oplogSizeMB: 20
  replSetName: rs0

#sharding:
EOF


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


install_mongodb
