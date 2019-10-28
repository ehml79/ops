#!/bin/bash

# 0, 1, 2
BROKER_ID=0

zookeeper_server1=192.168.217.128
zookeeper_server2=192.168.217.129
zookeeper_server3=192.168.217.130


KAFKA_VERSION="kafka_2.12-2.3.1"

mkdir -p /data/service/src

wget -O /data/service/src/${KAFKA_VERSION}.tgz http://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.3.1/${KAFKA_VERSION}.tgz

cd /data/service/src 

tar xf ${KAFKA_VERSION}.tgz

mv /data/service/src/${KAFKA_VERSION} /data/service/kafka

mkdir -p /data/service/kafka/logs


# 配置
KAFKA_CONFI=/data/service/kafka/config/server.properties

sed -i "s@broker.id=.*@broker.id=${BROKER_ID}@" /data/service/kafka/config/server.properties 
sed -i "s@log.dirs=.*@log.dirs=/data/service/kafka/logs/kafka-logs@"  /data/service/kafka/config/server.properties
sed -i "s@zookeeper.connect=.*@zookeeper.connect=${zookeeper_server1}:2181,${zookeeper_server2}:2181,${zookeeper_server3}:2181@" /data/service/kafka/config/server.properties

echo "export PATH=\$PATH:/data/service/kafka/bin" >> /etc/profile


# 启动

echo '#!/bin/bash' > /root/kafka_start.sh
echo "/data/service/kafka/bin/kafka-server-start.sh -daemon /data/service/kafka/config/server.properties" >> /root/kafka_start.sh

/bin/bash /root/kafka_start.sh

echo '#!/bin/bash' > /root/kafka_stop.sh
echo "/data/service/kafka/bin/kafka-server-stop.sh" >> /root/kafka_stop.sh
