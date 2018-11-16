#!/bin/bash

web_user=www


function install_openssl(){
    # install openssl

#    wget https://www.openssl.org/source/openssl-1.1.1.tar.gz -P /data/service/src
    cd /data/service/src
    tar xf  openssl-1.1.1.tar.gz
    cd openssl-1.1.1/
    ./config -fPIC --prefix=/data/service/openssl --openssldir=/data/service/openssl
    make && make install 


    ln -s /data/service/openssl/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1
    ln -s /data/service/openssl/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1

    echo 'export PATH=$PATH:/data/service/openssl/bin/' >>/etc/profile


}


function install_php(){

    groupadd ${web_user}
    useradd -s /sbin/nologin -g ${web_user} ${web_user}
    # 判断系统
    if [ -f /etc/os-release ];then
        echo 'ubuntu'
        sudo apt -y install git libpcre3 libpcre3-dev  \
        zlib1g-dev build-essential libxml2-dev openssl \
        libssl-dev make curl libcurl4-openssl-dev \
        libjpeg-dev libpng-dev  libmcrypt-dev libcurl4-gnutls-dev \
        libxslt-dev pkg-config libxml2-dev openssl  \
        libfreetype6-dev  libmcrypt-dev  libsodium-dev \
        argon2 libargon2-0 libargon2-0-dev
    elif [ -f /etc/redhat-release ];then
        echo 'centOS'
        yum install -y git gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  \
	libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel \
	libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 \
	bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs \
	e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap \
	openldap-devel nss_ldap openldap-clients openldap-servers libicu-devel \
	libxslt-devel  libfreetype6-dev   libxslt-dev libmcrypt-devel
    else
        echo 'unknow OS'
        exit 1
    fi


    # http://cn2.php.net/distributions/php-7.2.11.tar.xz
#    wget http://cn.php.net/distributions/php-7.2.11.tar.gz  -P /data/service/src/
    
    cd /data/service/src/
    tar xf php-7.2.11.tar.gz
    cd php-7.2.11

    ./configure \
    --prefix=/data/service/php \
    --with-fpm-group=www \
    --with-fpm-user=www \
    --with-config-file-path=/data/service/php/etc \
    --with-config-file-scan-dir=/data/service/php/etc \
    --with-curl=shared,/usr \
    --with-freetype-dir=/usr/local/freetype \
    --with-sodium=/usr/local \
    --with-libxml-dir=/usr \
    --with-iconv-dir=/usr/local \
    --with-libxml-dir=/usr \
    --with-openssl=/data/service/openssl \
    --enable-fpm \
    --enable-bcmath \
    --enable-mysqlnd \
    --enable-ftp \
    --with-pdo-mysql=mysqlnd \
    --with-gd \
    --enable-xml \
    --enable-zip \
    --enable-mbstring \
    --enable-shmop \
    --with-curl \
    --with-xsl \
    --with-mhash \
    --with-iconv-dir \
    --with-gettext \
    --enable-mbregex \
    --with-zlib \
    --enable-pcntl \
    --enable-sockets \
    --enable-soap \
    --enable-inline-optimization \
    --enable-intl \
    --enable-opcache \
    --with-xmlrpc \
    --with-mysqli=mysqlnd \
    --with-jpeg-dir \
    --enable-sysvsem \
    --disable-rpath \
    --with-png-dir \
    --disable-rpath \
    --disable-debug \
    --disable-fileinfo \
    --enable-exif \
    #--with-password-argon2  \
    --with-png-dir 

    exit

    make && make install

    cp /data/service/php/etc/php-fpm.conf.default  /data/service/php/etc/php-fpm.conf
    cp /data/service/src/php-7.2.11/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod +x /etc/init.d/php-fpm
    cp /data/service/src/php-7.2.11/php.ini-production /data/service/php/etc/php.ini


    sed -i 's@;pid = run/php-fpm.pid@pid = run/php-fpm.pid@' /data/service/php/etc/php-fpm.conf
    cp /data/service/php/etc/php-fpm.d/www.conf.default  /data/service/php/etc/php-fpm.d/www.conf



   # mcrypt
   # wget http://pecl.php.net/get/mcrypt-1.0.1.tgz  -P  /data/service/src/
   # cd /data/service/src/
   # tar xf mcrypt-1.0.1.tgz 
   # cd mcrypt-1.0.1
   # /data/service/php/bin/phpize
   # ./configure
   # make && sudo make install
   # echo "extension=mcrypt.so" >> /data/service/php/etc/php.ini
    echo "security.limit_extensions = .php .php3 .php4 .php5 .do .html" >> /data/service/php/etc/php.ini

    # 启动 php
    /etc/init.d/php-fpm start
    /etc/init.d/php-fpm restart

}


install_openssl

install_php
