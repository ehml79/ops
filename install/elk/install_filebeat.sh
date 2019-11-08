#!/bin/bash


mkdir -p /data/service/src/

wget -O /data/service/src/filebeat-7.4.1-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.1-linux-x86_64.tar.gz

cd /data/service/src/

tar xf filebeat-7.4.1-linux-x86_64.tar.gz

mv /data/service/src/filebeat-7.4.1-linux-x86_64 /data/service/filebeat

mv /data/service/filebeat/filebeat.yml /data/service/filebeat/filebeat.yml.orig


cat >/data/service/filebeat/filebeat.yml <<EOF

EOF


echo '#!/bin/bash' > /root/filebeat_start.sh
echo "nohup /data/service/filebeat/filebeat -c /data/service/filebeat/filebeat.yml >> /data/service/filebeat/logs/filebeat.log 2>&1 & " >>  /root/filebeat_start.sh
