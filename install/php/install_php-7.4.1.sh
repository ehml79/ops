#!/bin/bash

run_user=nginx

function install_php(){

    groupadd ${web_user}
    useradd -s /sbin/nologin -g ${web_user} ${web_user}
    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
		sudo apt update
		sudo apt -y install \
		libzip-dev \
		bison \
		autoconf \
		build-essential \
		pkg-config git-core \
		libltdl-dev \
		libbz2-dev \
		libxml2-dev \
		libxslt1-dev \
		libssl-dev \
		libicu-dev \
		libpspell-dev \
		libenchant-dev \
		libmcrypt-dev \
		libpng-dev \
		libjpeg8-dev \
		libfreetype6-dev \
		libmysqlclient-dev \
		libreadline-dev \
		libcurl4-openssl-dev \
		librecode-dev \
		libsqlite3-dev \
		libonig-dev \
		libsodium-dev \
		libargon2-0-dev 
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        yum install -y \
        git \
        gcc \
        gcc-c++  \
        make \
        zlib \
        zlib-devel \
        pcre pcre-devel  \
		libjpeg \
		libjpeg-devel \
		libpng \
		libpng-devel \
		freetype \
		freetype-devel \
		libxml2 \
		libxml2-devel \
		glibc \
		glibc-devel \
		glib2 \
		glib2-devel \
		bzip2 \
		bzip2-devel \
		ncurses \
		ncurses-devel \
		curl \
		curl-devel \
		e2fsprogs \
		e2fsprogs-devel \
		krb5 \
		krb5-devel \
		openssl \
		openssl-devel \
		openldap \
		openldap-devel \
		nss_ldap \
		openldap-clients \
		openldap-servers \
		libicu-devel \
		libxslt-devel  \
		libfreetype6-dev   \
		libxslt-dev \
		libmcrypt-devel
    else
        echo 'unknow OS'
        exit 1
    fi

wget -O /data/service/src/php-7.4.1.tar.bz2  https://www.php.net/distributions/php-7.4.1.tar.bz2
    cd /data/service/src/
    tar xf php-7.4.1.tar.bz2
    cd php-7.4.1

./configure \
--prefix=/data/service/php \
--enable-fpm \
--with-fpm-group=${run_user} \
--with-fpm-user=${run_user} \
--with-config-file-scan-dir=/data/service/php/etc/conf.d \
--with-config-file-path=/data/service/php/etc \
--disable-debug \
--disable-rpath \
--enable-bcmath \
--enable-calendar \
--enable-exif \
--enable-ftp \
--enable-gd \
--enable-gd-jis-conv \
--enable-inline-optimization \
--enable-intl \
--enable-maintainer-zts \
--enable-mbregex \
--enable-mbstring \
--enable-mysqlnd \
--with-pdo-mysql \
--with-mysqli \
--enable-opcache \
--enable-pcntl \
--enable-session \
--enable-shmop \
--enable-soap \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-xml \
--with-bz2= \
--with-curl \
--with-freetype \
--with-gettext \
--with-iconv \
--with-jpeg \
--with-mhash \
--with-openssl \
--with-password-argon2 \
--with-pear \
--with-sodium \
--with-xmlrpc \
--with-xsl \
--with-zip \
--with-zlib


make && make install 

    cp /data/service/php/etc/php-fpm.conf.default  /data/service/php/etc/php-fpm.conf
    cp /data/service/src/php-7.4.1/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm

    chmod +x /etc/init.d/php-fpm
    cp /data/service/src/php-7.4.1/php.ini-production /data/service/php/etc/php.ini


	/data/service/php/bin/pecl channel-update pecl.php.net
	/data/service/php/bin/pecl install igbinary
	/data/service/php/bin/pecl install redis
    
    # igbinary
    wget -O /data/service/src/igbinary-3.1.0.tgz  http://pecl.php.net/get/igbinary-3.1.0.tgz 
    cd /data/service/src/ 
    tar xf igbinary-3.1.0.tgz   
    cd igbinary-3.1.0
    /data/service/php/bin/phpize
    ./configure --with-php-config=/data/service/php/bin/php-config
    make && sudo make install
    echo 'extension = "igbinary.so"' >> /data/service/php/etc/php.ini


        # redis
    wget -O /data/service/src/redis-5.1.1.tgz http://pecl.php.net/get/redis-5.1.1.tgz 
    cd /data/service/src/
    tar xf redis-5.1.1.tgz
    cd redis-5.1.1
    /data/service/php/bin/phpize
    ./configure --with-php-config=/data/service/php/bin/php-config
    make && sudo make install
    echo 'extension = "redis.so"' >> /data/service/php/etc/php.ini