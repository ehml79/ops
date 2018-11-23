#!/bin/bash

function install_node_exporter(){
    mkdir -p /data/service/src/
    wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0-rc.0/node_exporter-0.17.0-rc.0.linux-amd64.tar.gz -P /data/service/src/
    cd /data/service/src/
    tar xf node_exporter-0.17.0-rc.0.linux-amd64.tar.gz -C /data/service/
    mv /data/service/node_exporter-0.17.0-rc.0.linux-amd64/ /data/service/node_exporter
    
    # 启动脚本
    mkdir -p /data/service/node_exporter/log
    /data/service/node_exporter/node_exporter  >> /data/service/node_exporter/log/node_exporter.log 2>&1 &

}
