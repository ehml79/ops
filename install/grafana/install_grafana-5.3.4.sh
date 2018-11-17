#!/bin/bash



groupadd grafana
useradd -r -g grafana -s /bin/false grafana

wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.3.4.linux-amd64.tar.gz -P /data/service/src/

tar -xf /data/service/src/grafana-5.3.4.linux-amd64.tar.gz -C /data/service/

mv /data/service/grafana-5.3.4/ /data/service/grafana
mv /data/service/grafana/conf/defaults.ini  /data/service/grafana/conf/grafana.ini

export PATH=$PATH:/data/service/grafana/bin/
echo 'export PATH=$PATH:/data/service/grafana/bin/' >> /etc/profile




# install piechart plugin
/data/service/grafana/bin/grafana-cli plugins install grafana-piechart-panel

# install zabbix plugin
/data/service/grafana/bin/grafana-cli plugins install alexanderzobnin-zabbix-app

# install percona plugin
/data/service/grafana/bin/grafana-cli plugins install percona-percona-app

