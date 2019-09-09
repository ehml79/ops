#!/bin/bash

INSTALL_DIR=/data/service
SRC_DIR=${INSTALL_DIR}/src

[ ! -d ${INSTALL_DIR} ] && mkdir -p ${INSTALL_DIR}
[ ! -d ${SRC_DIR} ] && mkdir -p ${SRC_DIR}

NGINX="nginx-1.16.1"
OPENSSL="openssl-1.1.1"
RUN_USER=nginx


Install_Nginx(){

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
    mkdir -p ${SRC_DIR}

    wget -O ${SRC_DIR}/${OPENSSL}.tar.gz https://www.openssl.org/source/${OPENSSL}.tar.gz 
    cd ${SRC_DIR}
    tar xf  ${OPENSSL}.tar.gz
    
    groupadd ${RUN_USER}
    useradd -M -s /sbin/nologin -g ${RUN_USER}  ${RUN_USER}
    wget -O ${SRC_DIR}/${NGINX}.tar.gz http://nginx.org/download/${NGINX}.tar.gz 
    cd ${SRC_DIR} ; tar xf  ${NGINX}.tar.gz
    cd ${NGINX} 

    git clone https://github.com/vozlt/nginx-module-vts.git ${SRC_DIR}/nginx-module-vts/

    ./configure --prefix=${INSTALL_DIR}/nginx \
    --user=${RUN_USER} \
    --group=${RUN_USER} \
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
    --with-openssl=../${OPENSSL} \
    --with-pcre-jit \
    --add-module=${SRC_DIR}/nginx-module-vts

    
    make  && make install

    [ ! -d  ${INSTALL_DIR}/nginx/conf/vhost/  ] && mkdir -p ${INSTALL_DIR}/nginx/conf/vhost/
#    cp ${SRC_DIR}/nginx-module-vts/share/status.template.html ${INSTALL_DIR}/nginx/html/status.html
    #sed -i '/#tcp_nopush/a\    vhost_traffic_status_dump /var/log/nginx/vts.db;'  ${INSTALL_DIR}/nginx/conf/nginx.conf
    #sed -i '/#tcp_nopush/a\    vhost_traffic_status_zone;'  ${INSTALL_DIR}/nginx/conf/nginx.conf
    #sed -i '/#tcp_nopush/a\    include vhost/*.conf;'  ${INSTALL_DIR}/nginx/conf/nginx.conf
    sed -i '/default_type/a\    vhost_traffic_status_filter_by_host on;'  ${INSTALL_DIR}/nginx/conf/nginx.conf
    sed -i '/default_type/a\    vhost_traffic_status_zone;'  ${INSTALL_DIR}/nginx/conf/nginx.conf


#cat > ${INSTALL_DIR}/nginx/conf/vhost/status.conf  <<EOF
#   server {
#       server_name example.org;
#       root ${INSTALL_DIR}/nginx/html;
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
    echo "export PATH=\$PATH:${INSTALL_DIR}/nginx/sbin" >> /etc/profile

    # install nginx-vts-exporter 
    wget -O ${SRC_DIR}/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz 
    cd ${SRC_DIR}
    tar xf nginx-vts-exporter-0.10.3.linux-amd64.tar.gz

    

}



Install_Nginx
#rm /root/$0
