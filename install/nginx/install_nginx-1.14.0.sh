#!/bin/bash

web_user=www

install_nginx(){

    # 判断系统
    if [ -f /etc/os-release ];then
    	echo 'ubuntu'
    	apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential 
    elif [ -f /etc/redhat-release ];then
    	echo 'centOS'
    	yum -y install git pcre-devel openssl-devel
    else
    	echo 'unknow OS'
    	exit 1
    fi
    
    
    groupadd ${web_user}
    useradd -s /sbin/nologin -g ${web_user}  ${web_user}
    mkdir -p /data/service/src
    wget http://nginx.org/download/nginx-1.14.0.tar.gz  -P /data/service/src
    cd /data/service/src ; tar xf  nginx-1.14.0.tar.gz
    cd nginx-1.14.0 


    ./configure --prefix=/data/service/nginx \
    # 支持https
    --with-http_ssl_module \
    # 支持nginx状态查询
    --with-http_stub_status_module \
    # 为了支持rewrite重写功能，必须指定pcre
    --with-pcre  \
    --with-stream
    
    make  && make install

    mkdir -p /data/service/nginx/conf/vhost/
    sed -i "/worker_processes/i\user  ${web_user};"  /data/service/nginx/conf/nginx.conf
    sed -i '/#tcp_nopush/a\    include vhost/*.conf;'  /data/service/nginx/conf/nginx.conf
    


    echo 'export PATH=$PATH:/data/service/nginx/sbin' >> /etc/profile
    source /etc/profile
    export PATH=$PATH:/data/service/nginx/sbin


}



install_nginx
