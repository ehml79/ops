#!/bin/bash

function install_node_exporter(){
    mkdir -p /data/service/src/
#    wget -O /data/service/src/node_exporter-0.18.1.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
    cd /data/service/src/
    tar xf node_exporter-0.18.1.linux-amd64.tar.gz -C /data/service/
    mv /data/service/node_exporter-0.18.1.linux-amd64/ /data/service/node_exporter
    
    # 启动脚本
    mkdir -p /data/service/node_exporter/log
    cat > /root/node_exporter-restart.sh << EOF
#!/bin/bash

process_name=node_exporter

kill \$(ps aux|grep -w \${process_name} | grep -wv grep| grep -v sh | awk '{print \$2}')
ulimit -SHn 65535
/data/service/node_exporter/node_exporter  >> /data/service/node_exporter/log/node_exporter.log 2>&1 &
EOF
}

install_node_exporter
