#!/bin/bash


mkdir -p /data/service/src/

wget -O /data/service/src/kibana-7.4.1-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/kibana/kibana-7.4.1-linux-x86_64.tar.gz

cd /data/service/src/

tar xf kibana-7.4.1-linux-x86_64.tar.gz

mv /data/service/src/kibana-7.4.1-linux-x86_64 /data/service/kibana

mv /data/service/kibana/config/kibana.yml /data/service/kibana/config/kibana.yml.orig

cat > /data/service/kibana/config/kibana.yml  <<EOF
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://192.168.217.128:9200"]
kibana.index: ".kibana"
elasticsearch.username: "kibana"
elasticsearch.password: "pass"
EOF



echo '#!/bin/bash' > /root/kibana_start.sh
echo "nohup /data/service/kibana/bin/kibana --allow-root >> /data/service/kibana/logs/kibana.log 2>&1 & " >> /root/kibana_start.sh
