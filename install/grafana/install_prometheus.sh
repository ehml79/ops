#!/bin/bash


your_domain=domain


function install_prometheus(){
    mkdir -p /data/service/src/
    wget https://github.com/prometheus/prometheus/releases/download/v2.5.0/prometheus-2.5.0.linux-amd64.tar.gz -P /data/service/src/
    cd /data/service/src/
    tar xf  prometheus-2.5.0.linux-amd64.tar.gz
    
    mv /data/service/src/prometheus-2.5.0.linux-amd64 /data/service/prometheus
    cp /data/service/prometheus/prometheus.yml /data/service/prometheus/prometheus.yml_`date '+%Y%M%d%H%M%S'`
    
    # 启动脚本
    mkdir -p /data/service/prometheus/log 
    /data/service/prometheus/prometheus --config.file="/data/service/prometheus/prometheus.yml"  >> /data/service/prometheus/log/prometheus.log 2>&1 & 
    
    # 根据自身服务器，修改 prometheus.yml 

    # 生成nginx 访问地址
    cat > /data/service/nginx/conf/vhost/prometheus.conf <<EOF
#
server {
        listen       80;
        server_name  ${your_domain};

        charset utf-8;

        location / {
            default_type text/html;
            proxy_pass http://127.0.0.1:9090;
        }

}
EOF

}

