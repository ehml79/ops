#!/bin/bash
# Unavailable

# reference https://developer.aliyun.com/article/422597?spm=a2c6h.13813017.0.dArticle738638.17671178aA0s4Q
# CentOS Linux release 7.9.2009 (Core)


# 192.168.213.131        |192.168.213.132       |192.168.213.133
# Shard11:27001 主节点  |Shard12:27001 副节点|Shard13:27001 仲裁点
# Shard21:27002 仲裁点  |Shard22:27002 主节点|Shard32:27002 副节点
# Shard31:27003 副节点  |Shard32:27003 仲裁点|Shard33:27003 主节点
# ConfigSvr:21000       |ConfigSvr:21000    |ConfigSvr:21000
# Mongos:20000          |Mongos:20000       |Mongos:20000



node1=192.168.213.131
node2=192.168.213.132
node3=192.168.213.133



wget -O /data/service/src/mongodb-linux-x86_64-rhel70-3.6.22.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.6.22.tgz
tar xf mongodb-linux-x86_64-rhel70-3.6.22.tgz
mv mongodb-linux-x86_64-rhel70-3.6.22 /data/service/mongodb


mkdir -p /data/service/mongodb/conf
mkdir -p /data/service/mongodb/mongos/log
mkdir -p /data/service/mongodb/config/{data,log}
mkdir -p /data/service/mongodb/shard1/{data,log}
mkdir -p /data/service/mongodb/shard2/{data,log}
mkdir -p /data/service/mongodb/shard3/{data,log}


echo 'export MONGODB_HOME=/data/service/mongodb' > /etc/profile.d/mongodb.sh
echo 'export PATH=$MONGODB_HOME/bin:$PATH' >> /etc/profile.d/mongodb.sh
source /etc/profile.d/mongodb.sh



cat > /data/service/mongodb/conf/config.conf <<EOF
## 配置文件内容
pidfilepath = /data/service/mongodb/config/log/configsrv.pid
dbpath = /data/service/mongodb/config/data
logpath = /data/service/mongodb/config/log/congigsrv.log
logappend = true
 
bind_ip = 0.0.0.0
port = 21000
fork = true
 
#declare this is a config db of a cluster;
configsvr = true

#副本集名称
replSet = configs
 
#设置最大连接数
maxConns = 20000
EOF





cat > /data/service/mongodb/conf/shard1.conf << EOF
#配置文件内容
pidfilepath = /data/service/mongodb/shard1/log/shard1.pid
dbpath = /data/service/mongodb/shard1/data
logpath = /data/service/mongodb/shard1/log/shard1.log
logappend = true

bind_ip = 0.0.0.0
port = 27001
fork = true
 
#副本集名称
replSet = shard1
 
#declare this is a shard db of a cluster;
shardsvr = true
 
#设置最大连接数
maxConns = 20000
EOF




cat > /data/service/mongodb/conf/shard2.conf << EOF
#配置文件内容
pidfilepath = /data/service/mongodb/shard2/log/shard2.pid
dbpath = /data/service/mongodb/shard2/data
logpath = /data/service/mongodb/shard2/log/shard2.log
logappend = true

bind_ip = 0.0.0.0
port = 27002
fork = true
 
#副本集名称
replSet=shard2
 
#declare this is a shard db of a cluster;
shardsvr = true
 
#设置最大连接数
maxConns=20000
EOF



cat > /data/service/mongodb/conf/shard3.conf << EOF
#配置文件内容
pidfilepath = /data/service/mongodb/shard3/log/shard3.pid
dbpath = /data/service/mongodb/shard3/data
logpath = /data/service/mongodb/shard3/log/shard3.log
logappend = true

bind_ip = 0.0.0.0
port = 27003
fork = true

#副本集名称
replSet=shard3
 
#declare this is a shard db of a cluster;
shardsvr = true
 
#设置最大连接数
maxConns=20000
EOF





cat >  /data/service/mongodb/conf/mongos.conf <<EOF
#配置文件内容
pidfilepath = /data/service/mongodb/mongos/log/mongos.pid
logpath = /data/service/mongodb/mongos/log/mongos.log
logappend = true

bind_ip = 0.0.0.0
port = 20000
fork = true

#监听的配置服务器,只能有1个或者3个 configs为配置服务器的副本集名字
configdb = configs/${node1}:21000,${node2}:21000,${node3}:21000
 
#设置最大连接数
maxConns = 20000
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
    {_id : 0, host : "${node1}:21000" },
    {_id : 1, host : "${node2}:21000" },
    {_id : 2, host : "${node3}:21000" }
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


echo "config = { _id : "shard1", members : [ {_id : 0, host : "${node1}:27001" }, {_id : 1, host : "${node2}:27001" }, {_id : 2, host : "${node3}:27001" , arbiterOnly: true } ] } " |  /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet



echo "rs.initiate(config)" |  /data/service/mongodb/bin/mongo ${node1}:27001 --quiet


# rs.status()
# rs.isMaster()



# 启动三台服务器的shard2 server
ssh ${node1} "mongod -f /data/service/mongodb/conf/shard2.conf"
ssh ${node2} "mongod -f /data/service/mongodb/conf/shard2.conf"
ssh ${node3} "mongod -f /data/service/mongodb/conf/shard2.conf"

mongo --host ${node2} --port 27002



echo "config = { _id : "shard2", members : [ {_id : 0, host : "${node1}:27002" , arbiterOnly: true}, {_id : 1, host : "${node2}:27002" }, {_id : 2, host : "${node3}:27002" } ] } " |  /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet 

rs.initiate(config)

rs.status()







# 启动三台服务器的shard3 server
ssh ${node1} "mongod -f /data/service/mongodb/conf/shard3.conf"
ssh ${node2} "mongod -f /data/service/mongodb/conf/shard3.conf"
ssh ${node3} "mongod -f /data/service/mongodb/conf/shard3.conf"



mongo --host ${node3} --port  27003



echo "config = { _id : "shard3", members : [ {_id : 0, host : "${node1}:27003" , arbiterOnly: true}, {_id : 1, host : "${node2}:27003" }, {_id : 2, host : "${node3}:27003" } ] } " |  /data/service/mongodb/bin/mongo  ${node1}:21000 --quiet

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
