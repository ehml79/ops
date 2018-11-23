#!/bin/bash

function install_mysqld_exporter(){

    mkdir -p /data/service/src/
    wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.11.0/mysqld_exporter-0.11.0.linux-amd64.tar.gz -P /data/service/src/
    
    cd /data/service/src/
    
    tar xf mysqld_exporter-0.11.0.linux-amd64.tar.gz -C /data/service
    mv /data/service/mysqld_exporter-0.11.0.linux-amd64/ /data/service/mysqld_exporter
    
    # mysql grant
    
    GRANT REPLICATION CLIENT, PROCESS ON *.* TO 'exporter'@'localhost' identified by 'password';
    GRANT SELECT ON performance_schema.* TO 'exporter'@'localhost';
    flush privileges;
    
    mkdir -p /data/.secret/
cat >> /data/.secret/my.cnf < EOF
[client]
user=exporter
password=password
EOF

    chmod 600 /data/.secret/my.cnf
    
    # 启动脚本
    mkdir -p /data/service/mysqld_exporter/log/
    /data/service/mysqld_exporter/mysqld_exporter --config.my-cnf="/data/.secret/my.cnf"  >>/data/service/mysqld_exporter/log/mysqld_exporter.log  2>&1 &


}

