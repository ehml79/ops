#!/bin/bash

# install jdk

server1=192.168.1.1
server2=192.168.1.2
server3=192.168.1.3

zookeeper_version="apache-zookeeper-3.5.5"

mkdir -p /data/service/src
cd /data/service/src/

wget -O /data/service/src/${zookeeper_version}-bin.tar.gz  https://archive.apache.org/dist/zookeeper/zookeeper-3.5.5/${zookeeper_version}-bin.tar.gz

tar xf ${zookeeper_version}-bin.tar.gz -C /data/service/

mv /data/service/${zookeeper_version}-bin/ /data/service/zookeeper

# conf
mkdir -p  /data/service/zookeeper/{data,log}

cat >/data/service/zookeeper/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
clientPort=2181
dataDir=/data/service/zookeeper/data
maxClientCnxns=0
minSessionTimeout=4000
maxSessionTimeout=10000
server.1=${server1}:2888:3888
server.2=${server2}:2888:3888
server.3=${server3}:2888:3888
EOF

echo 1 > /data/service/zookeeper/data/myid

# start
/data/service/zookeeper/bin/zkServer.sh start
