#!/bin/bash

# install jdk

node=1

server1=192.168.1.1
server2=192.168.1.2
server3=192.168.1.3

zookeeper_version="apache-zookeeper-3.5.5"
ZK_PATH=/data/service/zookeeper

mkdir -p /data/service/src
cd /data/service/src/

wget -O /data/service/src/${zookeeper_version}-bin.tar.gz  https://archive.apache.org/dist/zookeeper/zookeeper-3.5.5/${zookeeper_version}-bin.tar.gz

tar xf ${zookeeper_version}-bin.tar.gz -C /data/service/

mv /data/service/${zookeeper_version}-bin/ ${ZK_PATH}

# conf
mkdir -p  ${ZK_PATH}/data

cat >${ZK_PATH}/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
clientPort=2181
dataDir=${ZK_PATH}/data
maxClientCnxns=0
minSessionTimeout=4000
maxSessionTimeout=10000
server.1=${server1}:2888:3888
server.2=${server2}:2888:3888
server.3=${server3}:2888:3888
EOF

echo ${node} > ${ZK_PATH}/data/myid


cat > /root/zookeeper.sh <<EOF
#!/bin/bash

ZK_PATH=${ZK_PATH}

case \$1 in
         start) /bin/bash  \${ZK_PATH}/bin/zkServer.sh start;;
         stop)  /bin/bash  \${ZK_PATH}/bin/zkServer.sh stop;;
         status) /bin/bash  \${ZK_PATH}/bin/zkServer.sh status;;
         restart) /bin/bash \${ZK_PATH}/bin/zkServer.sh restart;;
         *)  echo "require start|stop|status|restart"  ;;
esac

EOF


# start
/bin/bash /root/zookeeper.sh start
