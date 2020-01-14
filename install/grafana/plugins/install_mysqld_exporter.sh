#!/bin/bash


exporter_password=

function install_mysqld_exporter(){

    mkdir -p /data/service/src/
    wget -O /data/service/src/mysqld_exporter-0.12.1.linux-amd64.tar.gz  https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz 
    
    cd /data/service/src/
    
    tar xf mysqld_exporter-0.12.1.linux-amd64.tar.gz -C /data/service
    mv /data/service/mysqld_exporter-0.12.1.linux-amd64/ /data/service/mysqld_exporter
    
    # mysql grant
    
    CREATE USER 'exporter'@'127.0.0.1' IDENTIFIED BY "${exporter_password}" WITH MAX_USER_CONNECTIONS 3;
    GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
    flush privileges;
    
    mkdir -p /data/.secret/
cat > /data/.secret/exporter-my.cnf << EOF
[client]
user=exporter
password=${exporter_password}
EOF

    chmod 600 /data/.secret/exporter-my.cnf
    
    # 启动脚本
    mkdir -p /data/service/mysqld_exporter/log/
    cat >/root/mysqld_exporter-restart.sh<<EOF
#!/bin/bash

process_name=mysqld_exporter

kill \$(ps aux|grep -w \${process_name}|grep -wv grep| grep -v sh | awk '{print \$2}')   
ulimit -SHn 65535
/data/service/mysqld_exporter/mysqld_exporter --config.my-cnf="/data/.secret/exporter-my.cnf"  >>/data/service/mysqld_exporter/log/mysqld_exporter.log  2>&1 &
EOF

}

