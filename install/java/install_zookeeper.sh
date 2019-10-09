#!/bin/bash

# install jdk

mkdir -p /data/service/src
cd /data/service/src/

wget -O /data/service/src/apache-zookeeper-3.5.5-bin.tar.gz  https://archive.apache.org/dist/zookeeper/zookeeper-3.5.5/apache-zookeeper-3.5.5-bin.tar.gz

tar xf apache-zookeeper-3.5.5-bin.tar.gz -C /data/service/

mv /data/service/apache-zookeeper-3.5.5-bin/ /data/service/zookeeper

# conf
mkdir -p  /data/service/zookeeper/{data,log}

cat >/data/service/zookeeper/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper
clientPort=2181
dataDir=/data/service/zookeeper/data
dataLogDir=/data/service/zookeeper/log
maxClientCnxns=0
minSessionTimeout=4000
maxSessionTimeout=10000
server.1=127.0.0.1:2888:3888
EOF

# start
/data/service/zookeeper/bin/zkServer.sh start
