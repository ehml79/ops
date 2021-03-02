#!/bin/bash
# Unavailable

# reference https://developer.aliyun.com/article/422597?spm=a2c6h.13813017.0.dArticle738638.17671178aA0s4Q
# CentOS Linux release 7.9.2009 (Core)


# 192.168.217.131        |192.168.217.132       |192.168.217.133
# Shard11:27001 主节点  |Shard12:27001 副节点|Shard13:27001 仲裁点
# Shard21:27002 仲裁点  |Shard22:27002 主节点|Shard32:27002 副节点
# Shard31:27003 副节点  |Shard32:27003 仲裁点|Shard33:27003 主节点
# ConfigSvr:21000       |ConfigSvr:21000    |ConfigSvr:21000
# Mongos:20000          |Mongos:20000       |Mongos:20000



node1=192.168.217.131
node2=192.168.217.132
node3=192.168.217.133



wget -O /data/service/src/mongodb-linux-x86_64-rhel70-3.6.22.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.6.22.tgz
tar xf mongodb-linux-x86_64-rhel70-3.6.22.tgz
mv mongodb-linux-x86_64-rhel70-3.6.22 /data/service/mongodb


mkdir -p /data/service/mongodb/conf
mkdir -p /data/service/mongodb/mongos/
mkdir -p /data/service/mongodb/config/data
mkdir -p /data/service/mongodb/shard1/data
mkdir -p /data/service/mongodb/shard2/data
mkdir -p /data/service/mongodb/shard3/data


echo 'export MONGODB_HOME=/data/service/mongodb' > /etc/profile.d/mongodb.sh
echo 'export PATH=$MONGODB_HOME/bin:$PATH' >> /etc/profile.d/mongodb.sh
source /etc/profile.d/mongodb.sh



cat > /data/service/mongodb/conf/config.conf <<EOF
systemLog:
  destination: file
  path: /data/service/mongodb/config/config.log
  logAppend: true 
processManagement:
  fork: true
  pidFilePath: /data/service/mongodb/config/config.pid
net:
  bindIp: 0.0.0.0
  port: 21000
  maxIncomingConnections: 20000
storage:
  dbPath: /data/service/mongodb/config/data
  journal:
    enabled: true
    commitIntervalMs: 500
  directoryPerDB: true
  syncPeriodSecs: 300
  engine: wiredTiger
replication:
  oplogSizeMB: 10000
  replSetName: configs
sharding:
  clusterRole: configsvr
EOF





cat > /data/service/mongodb/conf/shard1.conf << EOF
systemLog:
  destination: file
  path: /data/service/mongodb/shard1/shard1.log
  logAppend: true
processManagement:
  fork: true
  pidFilePath: /data/service/mongodb/shard1/shard1.pid
net:
  bindIp: 0.0.0.0
  port: 27001
  maxIncomingConnections: 20000
storage:
  dbPath: /data/service/mongodb/shard1/data
  journal: 
    enabled: true
    commitIntervalMs: 500
  directoryPerDB: true
  syncPeriodSecs: 300
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 103
      statisticsLogDelaySecs: 0
      journalCompressor: snappy
      directoryForIndexes: false
    collectionConfig:
      blockCompressor: snappy
    indexConfig:
      prefixCompression: true
replication:
  oplogSizeMB: 10000
  replSetName: shard1
sharding:
  clusterRole: shardsvr
EOF




cat > /data/service/mongodb/conf/shard2.conf << EOF
systemLog:
  destination: file
  path: /data/service/mongodb/shard2/shard2.log
  logAppend: true
processManagement:
  fork: true
  pidFilePath: /data/service/mongodb/shard2/shard2.pid
net:
  bindIp: 0.0.0.0
  port: 27002
  maxIncomingConnections: 20000
storage:
  dbPath: /data/service/mongodb/shard2/data
  journal: 
    enabled: true
    commitIntervalMs: 500
  directoryPerDB: true
  syncPeriodSecs: 300
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 103
      statisticsLogDelaySecs: 0
      journalCompressor: snappy
      directoryForIndexes: false
    collectionConfig:
      blockCompressor: snappy
    indexConfig:
      prefixCompression: true
replication:
  oplogSizeMB: 10000
  replSetName: shard2
sharding:
  clusterRole: shardsvr
EOF



cat > /data/service/mongodb/conf/shard3.conf << EOF
systemLog:
  destination: file
  path: /data/service/mongodb/shard3/shard3.log
  logAppend: true
processManagement:
  fork: true
  pidFilePath: /data/service/mongodb/shard3/shard3.pid
net:
  bindIp: 0.0.0.0
  port: 27003
  maxIncomingConnections: 20000
storage:
  dbPath: /data/service/mongodb/shard3/data
  journal: 
    enabled: true
    commitIntervalMs: 500
  directoryPerDB: true
  syncPeriodSecs: 300
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 103
      statisticsLogDelaySecs: 0
      journalCompressor: snappy
      directoryForIndexes: false
    collectionConfig:
      blockCompressor: snappy
    indexConfig:
      prefixCompression: true
replication:
  oplogSizeMB: 10000
  replSetName: shard3
sharding:
  clusterRole: shardsvr
EOF





cat >  /data/service/mongodb/conf/mongos.conf <<EOF
systemLog:
  destination: file
  path: /data/service/mongodb/mongos/mongos.log
  logAppend: true
processManagement:
  fork: true
  pidFilePath: /data/service/mongodb/mongos/mongos.pid
net:
  bindIp: 0.0.0.0
  port: 10051
  maxIncomingConnections: 20000
sharding:
  configDB: configs/192.168.217.131:21000,192.168.217.132:21000,192.168.217.133:21000
EOF







# 启动三台服务器的config server
ssh ${node1} "mongod -f /data/service/mongodb/conf/config.conf"
ssh ${node2} "mongod -f /data/service/mongodb/conf/config.conf"
ssh ${node3} "mongod -f /data/service/mongodb/conf/config.conf"



mongo --host ${node1} --port 21000

/bin/echo 'rs.status()' |  /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet


cat > /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet <<EOF
config = {
    _id : "configs",
    members : [
    {_id : 0, host : "192.168.217.131:21000" },
    {_id : 1, host : "192.168.217.132:21000" },
    {_id : 2, host : "192.168.217.133:21000" }
    ]
}

EOF

echo "config = { _id : "configs", members : [ {_id : 0, host : "${node1}:21000" }, {_id : 1, host : "${node2}:21000" }, {_id : 2, host : "${node3}:21000" } ] } "  |  /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet



echo "rs.initiate(config)"  |  /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet









# 启动三台服务器的shard1 server
ssh ${node1} "mongod -f /data/service/mongodb/conf/shard1.conf"
ssh ${node2} "mongod -f /data/service/mongodb/conf/shard1.conf"
ssh ${node3} "mongod -f /data/service/mongodb/conf/shard1.conf"




mongo --host ${node1} --port 27001


config = {
    _id : "shard1",
     members : [
         {_id : 0, host : "192.168.217.131:27001" },
         {_id : 1, host : "192.168.217.132:27001" },
         {_id : 2, host : "192.168.217.133:27001" , arbiterOnly: true }
     ]
 }


rs.initiate(config)


rs.status()







# 启动三台服务器的shard2 server
ssh ${node1} "mongod -f /data/service/mongodb/conf/shard2.conf"
ssh ${node2} "mongod -f /data/service/mongodb/conf/shard2.conf"
ssh ${node3} "mongod -f /data/service/mongodb/conf/shard2.conf"

mongo --host ${node2}  --port  27002



config = {
    _id : "shard2",
     members : [
         {_id : 0, host : "192.168.217.131:27002" },
         {_id : 1, host : "192.168.217.132:27002" , arbiterOnly: true},
         {_id : 2, host : "192.168.217.133:27002" }
     ]
 }

rs.initiate(config)

rs.status()







# 启动三台服务器的shard3 server
ssh ${node1} "mongod -f /data/service/mongodb/conf/shard3.conf"
ssh ${node2} "mongod -f /data/service/mongodb/conf/shard3.conf"
ssh ${node3} "mongod -f /data/service/mongodb/conf/shard3.conf"



mongo --host ${node3} --port 27003



config = {
    _id : "shard3",
     members : [
         {_id : 0, host : "192.168.217.131:27003" , arbiterOnly: true},
         {_id : 1, host : "192.168.217.132:27003" },
         {_id : 2, host : "192.168.217.133:27003" }
     ]
 }

rs.initiate(config)

rs.status()






# 启动三台服务器的mongos server
ssh ${node1} "mongos -f /data/service/mongodb/conf/mongos.conf"
ssh ${node2} "mongos -f /data/service/mongodb/conf/mongos.conf"
ssh ${node3} "mongos -f /data/service/mongodb/conf/mongos.conf"




mongo --port 20000

use  admin


# 串联路由服务器与分配副本集
sh.addShard("shard1/${node1}:27001,${node2}:27001,${node3}:27001");
sh.addShard("shard2/${node1}:27002,${node2}:27002,${node3}:27002");
sh.addShard("shard3/${node1}:27003,${node2}:27003,${node3}:27003");


# 查看集群状态
sh.status()



# 仲裁不能再同一台服务器上换下就可以


# 移除shard2
use admin 
db.runCommand({ listshards: 1})
db.runCommand( { removeshard: "shard2" } )
