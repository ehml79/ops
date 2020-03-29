#!/bin/bash


your_domain=domain


function install_prometheus(){
    mkdir -p /data/service/src/
    #wget -O /data/service/src/prometheus-2.15.2.linux-amd64.tar.gz  https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.linux-amd64.tar.gz 
    cd /data/service/src/
    tar xf  prometheus-2.15.2.linux-amd64.tar.gz
    
    mv /data/service/src/prometheus-2.15.2.linux-amd64 /data/service/prometheus
    cp /data/service/prometheus/prometheus.yml /data/service/prometheus/prometheus.yml_`date '+%Y%M%d%H%M%S'`
    
    # 启动脚本
    mkdir -p /data/service/prometheus/log 
    cat > /root/prometheus_restart.sh <<EOF
#!/bin/bash

process_name=prometheus
ulimit -SHn 65535

kill \$(ps aux|grep -w ${process_name}|grep -wv grep| grep -v sh | awk '{print $2}')

/data/service/prometheus/prometheus \
--config.file="/data/service/prometheus/prometheus.yml" \
--storage.tsdb.path="/data/service/prometheus/data" \
--storage.tsdb.retention=60d  >> /data/service/prometheus/log/prometheus.log 2>&1 &
EOF

# 根据自身服务器，修改 prometheus.yml 
}


function create_nginx_conf(){
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


install_prometheus
