#!/bin/bash


function install_prometheus(){
mkdir -p /data/service/src/
wget https://github.com/prometheus/prometheus/releases/download/v2.5.0/prometheus-2.5.0.linux-amd64.tar.gz -P /data/service/src/
cd /data/service/src/
tar xf  prometheus-2.5.0.linux-amd64.tar.gz

mv /data/service/src/prometheus-2.5.0.linux-amd64 /data/service/prometheus
# 根据自身服务器，修改 prometheus.yml 

}


function install_mysqld_exporter(){
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.11.0/mysqld_exporter-0.11.0.linux-amd64.tar.gz

}


function install_node_exporter(){
wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0-rc.0/node_exporter-0.17.0-rc.0.linux-amd64.tar.gz
}
