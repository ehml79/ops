#!/bin/bash

run_user=www
nginx_install_dir=/data/service/nginx

install_nginx(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
    	echo 'ubuntu'
    	apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential 
    elif [ -f /usr/bin/yum ];then
    	echo 'centOS'
    	yum -y install git pcre-devel openssl-devel wget gcc-c++
    else
    	echo 'unknow OS'
    	exit 1
    fi
    
    # install openssl

    wget -O /data/service/src/openssl-1.1.1.tar.gz https://www.openssl.org/source/openssl-1.1.1.tar.gz 
    cd /data/service/src
    tar xf  openssl-1.1.1.tar.gz
    
    groupadd ${run_user}
    useradd -M -s /sbin/nologin -g ${run_user}  ${run_user}
    mkdir -p /data/service/src
    wget -O /data/service/src/nginx-1.14.0.tar.gz http://nginx.org/download/nginx-1.14.0.tar.gz 
    cd /data/service/src ; tar xf  nginx-1.14.0.tar.gz
    cd nginx-1.14.0 

    git clone https://github.com/vozlt/nginx-module-vts.git /data/service/src/nginx-module-vts/

    ./configure --prefix=${nginx_install_dir} \
    --user=${run_user} \
    --group=${run_user} \
    --with-pcre  \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_realip_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-openssl=../openssl-1.1.1 \
    --with-pcre-jit \
    --add-module=/data/service/src/nginx-module-vts

    
    make  && make install

    mkdir -p /data/service/nginx/conf/vhost/
#    cp /data/service/src/nginx-module-vts/share/status.template.html /data/service/nginx/html/status.html
    #sed -i '/#tcp_nopush/a\    vhost_traffic_status_dump /var/log/nginx/vts.db;'  /data/service/nginx/conf/nginx.conf
    #sed -i '/#tcp_nopush/a\    vhost_traffic_status_zone;'  /data/service/nginx/conf/nginx.conf
    #sed -i '/#tcp_nopush/a\    include vhost/*.conf;'  /data/service/nginx/conf/nginx.conf
    sed -i '/default_type/a\    vhost_traffic_status_filter_by_host on;'  /data/service/nginx/conf/nginx.conf
    sed -i '/default_type/a\    vhost_traffic_status_zone;'  /data/service/nginx/conf/nginx.conf
    

#cat > /data/service/nginx/conf/vhost/status.conf  <<EOF
#   server {
#       server_name example.org;
#       root /data/service/nginx/html;
#
#       # Redirect requests for / to /status.html
#       location = / {
#           return 301 /status.html;
#       }
#
#       location = /status.html {}
#
#       # Everything beginning /status (except for /status.html) is
#       # processed by the status handler
#       location /status {
#           vhost_traffic_status_display;
#           vhost_traffic_status_display_format json;
#       }
#   }
#EOF

    # install nginx-vts-exporter 
    wget -O /data/service/src/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz 
    cd /data/service/src
    tar xf nginx-vts-exporter-0.10.3.linux-amd64.tar.gz

    

}



install_nginx
