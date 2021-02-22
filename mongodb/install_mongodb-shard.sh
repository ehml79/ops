#!/bin/bash
# Unavailable

# reference https://developer.aliyun.com/article/422597?spm=a2c6h.13813017.0.dArticle738638.17671178aA0s4Q
# CentOS Linux release 7.9.2009 (Core)


# 192.168.1.147        |192.168.1.156       |192.168.1.219
# Shard11:27001 主节点  |Shard12:27001 副节点|Shard13:27001 仲裁点
# Shard21:27002 仲裁点  |Shard22:27002 主节点|Shard32:27002 副节点
# Shard31:27003 副节点  |Shard32:27003 仲裁点|Shard33:27003 主节点
# ConfigSvr:21000       |ConfigSvr:21000    |ConfigSvr:21000
# Mongos:20000          |Mongos:20000       |Mongos:20000



node1=192.168.1.147
node2=192.168.1.156
node3=192.168.1.219


# 系统全局允许分配的最大文件句柄数:
sysctl -w fs.file-max=2097152
sysctl -w fs.nr_open=2097152
echo 2097152 > /proc/sys/fs/nr_open
# 允许当前会话/进程打开文件句柄数:
ulimit -n 1048576
# 修改 ‘fs.file-max’ 设置到 /etc/sysctl.conf 文件:
echo 'fs.file-max = 1048576' >> /etc/sysctl.conf

# 修改/etc/security/limits.conf 持久化设置允许用户/进程打开文件句柄数
cat >> /etc/security/limits.conf <EOF
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 524288
* hard nproc 524288
EOF

# TCP 协议栈网络参数
# 并发连接 backlog 设置:
sysctl -w net.core.somaxconn=32768
sysctl -w net.ipv4.tcp_max_syn_backlog=16384
sysctl -w net.core.netdev_max_backlog=16384
# 可用知名端口范围:
sysctl -w net.ipv4.ip_local_port_range=80 65535
sysctl -w net.core.rmem_default=262144
sysctl -w net.core.wmem_default=262144
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.core.optmem_max=16777216
sysctl -w net.ipv4.tcp_rmem='1024 4096 16777216'
sysctl -w net.ipv4.tcp_wmem='1024 4096 16777216'
# TCP 连接追踪设置（Centos7以下才有，以上版本则不用）:
sysctl -w net.nf_conntrack_max=1000000
sysctl -w net.netfilter.nf_conntrack_max=1000000
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=30



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
configdb = configs/192.168.1.147:21000,192.168.1.156:21000,192.168.1.219:21000
 
#设置最大连接数
maxConns = 20000
EOF


# 启动三台服务器的config server
mongod -f /data/service/mongodb/conf/config.conf



mongo --port 21000

config = {
    _id : "configs",
    members : [
    {_id : 0, host : "192.168.1.147:21000" },
    {_id : 1, host : "192.168.1.156:21000" },
    {_id : 2, host : "192.168.1.219:21000" }
    ]
}



rs.initiate(config)





# 启动三台服务器的shard1 server
mongod -f /data/service/mongodb/conf/shard1.conf



mongo --port 27001

use admin


config = {
    _id : "shard1",
     members : [
         {_id : 0, host : "192.168.1.147:27001" },
         {_id : 1, host : "192.168.1.156:27001" },
         {_id : 2, host : "192.168.1.219:27001" , arbiterOnly: true }
     ]
 }


rs.initiate(config)


rs.status()


# 启动三台服务器的shard2 server
mongod -f /data/service/mongodb/conf/shard2.conf

mongo --port 27002

use admin

config = {
    _id : "shard2",
     members : [
         {_id : 0, host : "192.168.1.147:27002" , arbiterOnly: true},
         {_id : 1, host : "192.168.1.156:27002" },
         {_id : 2, host : "192.168.1.219:27002" }
     ]
 }

rs.initiate(config)

rs.status()



# 启动三台服务器的shard3 server
mongod -f /data/service/mongodb/conf/shard3.conf

mongo --port 27003

use admin

config = {
    _id : "shard3",
     members : [
         {_id : 0, host : "192.168.1.147:27003" },
         {_id : 1, host : "192.168.1.156:27003" , arbiterOnly: true},
         {_id : 2, host : "192.168.1.219:27003" }
     ]
 }

rs.initiate(config)

rs.status()



# 启动三台服务器的mongos server
mongos -f /data/service/mongodb/conf/mongos.conf

mongo --port 20000

use  admin


# 串联路由服务器与分配副本集
sh.addShard("shard1/192.168.1.147:27001,192.168.1.156:27001,192.168.1.219:27001");
sh.addShard("shard2/192.168.1.147:27002,192.168.1.156:27002,192.168.1.219:27002");
sh.addShard("shard3/192.168.1.147:27003,192.168.1.156:27003,192.168.1.219:27003");


# 查看集群状态
sh.status()



# 仲裁不能再同一台服务器上换下就可以


# 移除shard2
use admin 
db.runCommand({ listshards: 1})
db.runCommand( { removeshard: "shard2" } )
