#!/bin/bash

NODE=1

NODE1=localhost

JVM_SIZE=128m

mkdir -p /data/service/src/
# 下载极慢，建议提前下好  
#wget -O /data/service/src/elasticsearch-7.4.1-linux-x86_64.tar.gz  https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.1-linux-x86_64.tar.gz

cd /data/service/src/ 

tar xf  elasticsearch-7.4.1-linux-x86_64.tar.gz 

mv /data/service/src/elasticsearch-7.4.1 /data/service/elasticsearch

groupadd elasticsearch

useradd elasticsearch -g elasticsearch -s /bin/bash

mkdir -p /data/service/elasticsearch/{data,logs}

chown -R elasticsearch:elasticsearch /data/service/elasticsearch

# 更改jvm大小
sed -i "s/-Xms1g/-Xms${JVM_SIZE}/" /data/service/elasticsearch/config/jvm.options
sed -i "s/-Xmx1g/-Xmx${JVM_SIZE}/" /data/service/elasticsearch/config/jvm.options


mv /data/service/elasticsearch/config/elasticsearch.yml /data/service/elasticsearch/config/elasticsearch.yml.orig

cat > /data/service/elasticsearch/config/elasticsearch.yml <<EOF
cluster.name: es-cluster
node.name: node-${NODE}
path.data: /data/service/elasticsearch/data
path.logs: /data/service/elasticsearch/logs
bootstrap.memory_lock: true
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
cluster.initial_master_nodes: ["node-${NODE}"]
EOF


echo "vm.max_map_count=262144" >>/etc/sysctl.conf
/sbin/sysctl -p


cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 4096
* hard nproc 4096
* soft memlock unlimited
* hard memlock unlimited
EOF


echo '#!/bin/bash' > /root/elasticsearch_start.sh
echo 'su - elasticsearch -c "/data/service/elasticsearch/bin/elasticsearch -d -p /data/service/elasticsearch/elasticsearch.pid"' >> /root/elasticsearch_start.sh


echo '#!/bin/bash' > /root/elasticsearch_stop.sh
echo "kill \$(cat /data/service/elasticsearch/elasticsearch.pid)" >> /root/elasticsearch_stop.sh
