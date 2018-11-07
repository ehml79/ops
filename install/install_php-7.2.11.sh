#!/bin/bash

web_user=www


function install_php(){

    groupadd ${web_user}
    useradd -s /sbin/nologin -g ${web_user} ${web_user}
    # 判断系统
    if [ -f /etc/os-release ];then
        echo 'ubuntu'

        sudo apt-get -y install git libpcre3 libpcre3-dev  zlib1g-dev  \
        build-essential libxml2-dev openssl libssl-dev make curl \
        libcurl4-gnutls-dev libjpeg-dev libpng-dev  libmcrypt-dev \
        libcurl4-openssl-dev pkg-config libxml2-dev openssl  libfreetype6-dev
    elif [ -f /etc/redhat-release ];then
        echo 'centOS'
        yum install -y git gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  \
	libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel \
	libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 \
	bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs \
	e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap \
	openldap-devel nss_ldap openldap-clients openldap-servers libicu-devel \
	libxslt-devel  libfreetype6-dev   libxslt-dev
    else
        echo 'unknow OS'
        exit 1
    fi


    # http://cn2.php.net/distributions/php-7.2.11.tar.xz
    wget http://cn.php.net/distributions/php-7.2.11.tar.gz  -P /data/service/src/
    
    cd /data/service/src/
    tar xf php-7.2.11.tar.gz
    cd php-7.2.11

    ./configure --prefix=/data/service/php \
    --with-config-file-path=/data/service/php/etc \
    --with-config-file-scan-dir=/data/service/php/conf.d \
    --enable-fpm --with-fpm-user=${web_user} \
    --with-fpm-group=${web_user} --enable-mysqlnd \
    --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir --with-freetype-dir=/usr/local/freetype \
    --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr \
    --enable-xml --disable-rpath --enable-bcmath --enable-shmop \
    --enable-sysvsem --enable-inline-optimization --with-curl \
    --enable-mbregex --enable-mbstring --enable-intl \
    --enable-pcntl --enable-ftp --with-gd --with-openssl \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc \
    --enable-zip --enable-soap --with-gettext  \
    --enable-opcache --with-xsl

    make && make install

    cp /data/service/php/etc/php-fpm.conf.default  /data/service/php/etc/php-fpm.conf
    cp /data/service/src/php-7.2.11/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod +x /etc/init.d/php-fpm
    cp /data/service/src/php-7.2.11/php.ini-production /data/service/php/etc/php.ini


    sed -i 's@;pid = run/php-fpm.pid@pid = run/php-fpm.pid@' /data/service/php/etc/php-fpm.conf
    cp /data/service/php/etc/php-fpm.d/www.conf.default  /data/service/php/etc/php-fpm.d/www.conf
    # 启动 php
    /etc/init.d/php-fpm start


}


install_php
