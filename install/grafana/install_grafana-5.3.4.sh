#!/bin/bash

wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.3.4.linux-amd64.tar.gz -P /data/service/src/

tar -xf /data/service/src/grafana-5.3.4.linux-amd64.tar.gz -C /data/service/

mv /data/service/grafana-5.3.4/ /data/service/grafana

export PATH=$PATH:/data/service/grafana/bin/
echo 'export PATH=$PATH:/data/service/grafana/bin/' >> /etc/profile

# install piechart plugin
grafana-cli plugins install grafana-piechart-panel

# install zabbix plugin
grafana-cli plugins install alexanderzobnin-zabbix-app

# install percona plugin
grafana-cli plugins install percona-percona-app

