#!/bin/bash

RUN_USER=nginx
NGINX="nginx-1.16.1"

INSTALL_DIR=/data/service
SRC_DIR=${INSTALL_DIR}/src

[ ! -d ${INSTALL_DIR} ] && mkdir -p ${INSTALL_DIR}
[ ! -d ${SRC_DIR} ] && mkdir -p ${SRC_DIR}

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!!"
    exit 1
fi

install_nginx(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
    	echo 'ubuntu'
    	apt -y install  git \
        libpcre3 \
        libpcre3-dev \
        zlib1g-dev \
        openssl \
        libssl-dev \
        build-essential \
        python3-pip \
        libgd-dev \
        libgeoip-dev \
        libgoogle-perftools-dev \
        libatomic-ops-dev \
        libxml2-dev \
	    libxslt1-dev
    elif [ -f /usr/bin/yum ];then
    	echo 'centOS'
    	yum -y install wget \
        gcc-c++ \
        git \
        pcre-devel \
        openssl-devel
    else
    	echo 'unknow OS'
    	exit 1
    fi
    
    # install nginx
    cd ${SRC_DIR}
    [ ! -d /data/web ] && mkdir -p /data/web
    if [ ! -f ${NGINX} ];then
        wget -O ${SRC_DIR}/${NGINX}.tar.gz http://nginx.org/download/${NGINX}.tar.gz 
    fi

    tar xf  ${NGINX}.tar.gz
    cd ${NGINX} 

    groupadd ${RUN_USER}
    useradd -M -s /sbin/nologin -g ${RUN_USER}  ${RUN_USER}

    ./configure --prefix=${INSTALL_DIR}/nginx \
    --user=${RUN_USER} \
    --group=${RUN_USER} \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-http_geoip_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    --with-google_perftools_module \
    --with-compat \
    --with-pcre \
    --with-libatomic
#    --with-http_xslt_module=dynamic \
#    --with-http_image_filter_module=dynamic \
#    --with-http_geoip_module=dynamic \
#    --with-stream=dynamic \
#    --with-stream_geoip_module=dynamic \

    make  && make install

    [ ! -d  ${INSTALL_DIR}/nginx/conf/vhost/  ] && mkdir -p ${INSTALL_DIR}/nginx/conf/{vhost,stream,cert}

    mv -f /root/nginx.conf ${INSTALL_DIR}/nginx/conf/
    mv -f /root/fastcgi_sample.conf ${INSTALL_DIR}/nginx/conf/vhost/

    echo "export PATH=\$PATH:${INSTALL_DIR}/nginx/sbin" > /etc/profile.d/nginx.sh

}


install_nginx

