#!/bin/bash
# for Ubuntu 20.04 LTS
# for Ubuntu 18.04 LTS
# for CentOS Linux 7 (Core)


MONGODB_VERSION=3.6.22


function ubuntu2004(){
    echo 'ubuntu'
    sudo apt-get -y install libcurl4 openssl
    wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz
    tar xf mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION}.tgz
    mv mongodb-linux-x86_64-ubuntu2004-${MONGODB_VERSION} /data/service/mongodb

}

function ubuntu1804(){
    echo 'ubuntu'
    sudo apt-get -y install libcurl4 openssl
    wget -O  /data/service/src/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
    tar xf mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION}.tgz
    mv mongodb-linux-x86_64-ubuntu1804-${MONGODB_VERSION} /data/service/mongodb

}

function centos7(){
    echo 'centOS'
    sudo yum -y install libcurl openssl wget
    wget -O /data/service/src/mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz
    tar xf mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}.tgz
    mv mongodb-linux-x86_64-rhel70-${MONGODB_VERSION} /data/service/mongodb
}



function install_mongodb(){


mkdir -p /data/service/src/
cd /data/service/src


# 判断系统
if [ -f /usr/bin/apt ];then
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
    # centOS 7
    centos7
else
    echo 'unknow OS'
    exit 1
fi

mkdir -p /data/service/mongodb
mkdir -p /data/service/mongodb/conf
mkdir -p /data/service/mongodb/data/{rs1,rs2,rs3}




cat > /data/service/mongodb/conf/rs1.conf <<EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/rs1.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/rs1
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/service/mongodb/rs1.pid

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



cat > /data/service/mongodb/conf/rs2.conf <<EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/rs2.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/rs2
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/service/mongodb/rs2.pid

# network interfaces
net:
  port: 27018
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



cat > /data/service/mongodb/conf/rs3.conf <<EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/rs3.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/rs3
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/service/mongodb/rs3.pid

# network interfaces
net:
  port: 27019
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


echo 'export MONGODB_HOME=/data/service/mongodb' > /etc/profile.d/mongodb.sh
echo 'export PATH=$MONGODB_HOME/bin:$PATH' >> /etc/profile.d/mongodb.sh
source /etc/profile.d/mongodb.sh


/data/service/mongodb/bin/mongod -f /data/service/mongodb/conf/rs1.conf
/data/service/mongodb/bin/mongod -f /data/service/mongodb/conf/rs2.conf
/data/service/mongodb/bin/mongod -f /data/service/mongodb/conf/rs3.conf



/bin/echo 'rs.status()' |  /data/service/mongodb/bin/mongo  localhost:27017 --quiet

/bin/echo 'rs.initiate({"_id":"rs0","members":[ {"_id":1,"host":"localhost:27017"}, {"_id":2,"host":"localhost:27018"}, {"_id":3,"host":"localhost:27019"} ]})' |  /data/service/mongodb/bin/mongo  localhost:27017 --quiet

/bin/echo 'rs.isMaster()' |  /data/service/mongodb/bin/mongo  localhost:27017 --quiet

# /data/service/mongodb/bin/mongo localhost:27017/admin --eval "db.stats()"

# /bin/echo 'db.stats()' |  /data/service/mongodb/bin/mongo  localhost:27017 --quiet

# mongo --port 27017
# mongo --port 27018
# mongo --port 27019


}

install_mongodb
