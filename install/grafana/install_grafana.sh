#!/bin/bash



apt -y install lrzsz
groupadd grafana
useradd -r -g grafana -s /bin/false grafana
mkdir -p /data/service/src/

wget -O /data/service/src/grafana-6.5.2.linux-amd64.tar.gz  https://dl.grafana.com/oss/release/grafana-6.5.2.linux-amd64.tar.gz

tar -xf /data/service/src/grafana-6.5.2.linux-amd64.tar.gz -C /data/service/

mv /data/service/grafana-6.5.2/ /data/service/grafana

#cp conf/grafana.ini  /data/service/grafana/conf/grafana.ini

mkdir -p /data/service/grafana/default

cp default/grafana-server /data/service/grafana/default/

mkdir /data/service/grafana/run
chown -R grafana.grafana /data/service/grafana


# 启动脚本
cp grafana-server.sh /root/grafana-server.sh




# install piechart plugin
/data/service/grafana/bin/grafana-cli --pluginsDir /data/service/grafana/data/plugins/ plugins install grafana-piechart-panel

# install zabbix plugin
/data/service/grafana/bin/grafana-cli --pluginsDir /data/service/grafana/data/plugins/ plugins install alexanderzobnin-zabbix-app

# install percona plugin
/data/service/grafana/bin/grafana-cli --pluginsDir /data/service/grafana/data/plugins/ plugins install percona-percona-app



