#!/bin/bash

run_user=www
nginx_install_dir=/data/service/nginx

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
    
    # install openssl

    wget https://www.openssl.org/source/openssl-1.1.1.tar.gz -P /data/service/src
    cd /data/service/src
    tar xf  openssl-1.1.1.tar.gz
    
    groupadd ${run_user}
    useradd -M -s /sbin/nologin -g ${run_user}  ${run_user}
    mkdir -p /data/service/src
    wget http://nginx.org/download/nginx-1.14.0.tar.gz  -P /data/service/src
    cd /data/service/src ; tar xf  nginx-1.14.0.tar.gz
    cd nginx-1.14.0 


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
    --with-pcre-jit 


    
    make  && make install

    mkdir -p /data/service/nginx/conf/vhost/
    sed -i "/worker_processes/i\user  ${run_user};"  /data/service/nginx/conf/nginx.conf
    sed -i '/#tcp_nopush/a\    include vhost/*.conf;'  /data/service/nginx/conf/nginx.conf
    


    echo 'export PATH=$PATH:/data/service/nginx/sbin' >> /etc/profile
    source /etc/profile
    . /etc/profile
    export PATH=$PATH:/data/service/nginx/sbin


}



install_nginx
