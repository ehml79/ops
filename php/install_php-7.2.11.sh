#!/bin/bash

web_user=nginx


function install_openssl(){
    # install openssl

    mkdir -p /data/service/src/
    wget -O /data/service/src/openssl-1.1.1.tar.gz https://www.openssl.org/source/openssl-1.1.1.tar.gz 
    cd /data/service/src
    mv openssl-1.1.1 openssl-1.1.1_`date '+%Y%M%d%H%M%S'`
    tar xf  openssl-1.1.1.tar.gz
    cd openssl-1.1.1/
    ./config -fPIC --prefix=/data/service/openssl --openssldir=/data/service/openssl
    make && make install 


    ln -s /data/service/openssl/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1
    ln -s /data/service/openssl/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1

    echo 'export PATH=$PATH:/data/service/openssl/bin/' > /etc/profile.d/openssl.sh


}


function install_php(){

    groupadd ${web_user}
    useradd -s /sbin/nologin -g ${web_user} ${web_user}
    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        sudo apt -y install git libpcre3 libpcre3-dev  
        sudo apt -y install zlib1g-dev build-essential libxml2-dev openssl 
        sudo apt -y install libssl-dev make curl libcurl4-openssl-dev 
        sudo apt -y install libjpeg-dev libpng-dev  libmcrypt-dev libcurl4-gnutls-dev 
        sudo apt -y install libxslt-dev pkg-config libxml2-dev openssl  
        sudo apt -y install libfreetype6-dev  libmcrypt-dev  libsodium-dev 
        sudo apt -y install argon2 libargon2-0 libargon2-0-dev libxml2-dev
        sudo apt -y install m4
        sudo apt -y install autoconf
    elif [ -f /usr/bin/yum ];then
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

    wget -O /data/service/src/php-7.2.11.tar.gz http://cn.php.net/distributions/php-7.2.11.tar.gz 
    
    cd /data/service/src/
    tar xf php-7.2.11.tar.gz
    cd php-7.2.11

    ./configure \
    --prefix=/data/service/php\
    --with-fpm-group=${web_user} \
    --with-fpm-user=${web_user} \
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
    --with-png-dir 
    #--with-password-argon2  \


    make && make install

    cp /data/service/php/etc/php-fpm.conf.default  /data/service/php/etc/php-fpm.conf
    cp /data/service/src/php-7.2.11/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm

    chmod +x /etc/init.d/php-fpm
    cp /data/service/src/php-7.2.11/php.ini-production /data/service/php/etc/php.ini

    #  配置 /data/service/php/etc/php-fpm.conf
    sed -i 's@;pid = run/php-fpm.pid@pid = run/php-fpm.pid@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;emergency_restart_threshold.*@emergency_restart_threshold = 10@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;emergency_restart_interval.*@emergency_restart_interval = 1m@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;process_control_timeout.*@process_control_timeout = 5s@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;daemonize.*@daemonize = yes@' /data/service/php/etc/php-fpm.conf

    # 配置 /data/service/php/etc/php-fpm.d/www.conf
    cp /data/service/php/etc/php-fpm.d/www.conf.default  /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@listen =.*@listen = 127.0.0.1:9000@' /data/service/php70/etc/php-fpm.d/www.conf
    sed -i 's@;listen.backlog.*@listen.backlog = -1@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;listen.allowed_clients.*@listen.allowed_clients = 127.0.0.1@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm =.*@pm = dynamic@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm.max_children.*@pm.max_children = 256@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm.start_servers.*@pm.start_servers = 20@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm.min_spare_servers.*@pm.min_spare_servers = 5@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm.max_spare_servers.*@pm.max_spare_servers = 35@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;pm.max_requests.*@pm.max_requests = 1024@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;pm.status_path.*@pm.status_path = /status@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;ping.path.*@ping.path = /ping@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;ping.response.*@ping.response = pong@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;request_slowlog_timeout.*@request_slowlog_timeout= 10@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;slowlog.*@slowlog = log/$pool.log.slow@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;rlimit_files.*@rlimit_files = 65535@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;rlimit_core.*@rlimit_core = 0@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;catch_workers_output.*@catch_workers_output = yes@' /data/service/php/etc/php-fpm.d/www.conf
    # .do 访问
    sed -i 's@;security.limit_extensions.*@security.limit_extensions = .php .php3 .php4 .php5 .php7 .do@' /data/service/php/etc/php-fpm.d/www.conf
    
    # 配置 /data/service/php/etc/php.ini
    mkdir -p /data/service/php/log/
    sed -i 's@; output_buffering.*@output_buffering = on@' /data/service/php/etc/php.ini
    sed -i 's@short_open_tag.*@short_open_tag = On@' /data/service/php/etc/php.ini
    sed -i 's@expose_php.*@expose_php = Off@' /data/service/php/etc/php.ini
    sed -i 's@memory_limit.*@memory_limit = 2048M@' /data/service/php/etc/php.ini
    sed -i 's@error_reporting.*@error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT@' /data/service/php/etc/php.ini
    sed -i 's@;track_errors =.*@track_errors = Off@' /data/service/php/etc/php.ini
    sed -i 's@;date.timezone.*@date.timezone = Asia/Shanghai@' /data/service/php/etc/php.ini
    sed -i 's@mail.add_x_header.*@mail.add_x_header = On@' /data/service/php/etc/php.ini
    sed -i 's@;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /data/service/php/etc/php.ini

    # sed -i 's@; max_input_vars.*@; max_input_vars = 1000@' /data/service/php/etc/php.ini
    # sed -i 's@; extension_dir.*@extension_dir = "/data/service/php/lib/php/extensions/no-debug-non-zts-20170718/"@' /data/service/php/etc/php.ini
    # sed -i 's@; Development Value.*@; Development Value: On@' /data/service/php/etc/php.ini
    # php 调试模式
    sed -i 's@; display_errors =.*@display_errors = On@' /data/service/php/etc/php.ini




    echo 'export PATH=$PATH:/data/service/php/bin/' >/etc/profile.d/php.sh
    echo 'export PATH=$PATH:/data/service/php/sbin/' >>/etc/profile.d/php.sh

    # mcrypt
    wget -O /data/service/src/mcrypt-1.0.1.tgz http://pecl.php.net/get/mcrypt-1.0.1.tgz 
    cd /data/service/src/
    tar xf mcrypt-1.0.1.tgz 
    cd mcrypt-1.0.1
    /data/service/php/bin/phpize
    ./configure --with-php-config=/data/service/php/bin/php-config
    make && sudo make install
    echo "extension=mcrypt.so" >> /data/service/php/etc/php.ini


    # igbinary
    wget -O /data/service/src/igbinary-2.0.8.tgz  http://pecl.php.net/get/igbinary-2.0.8.tgz 
    cd /data/service/src/ 
    tar xf igbinary-2.0.8.tgz   
    cd igbinary-2.0.8
    /data/service/php/bin/phpize
    ./configure --with-php-config=/data/service/php/bin/php-config
    make && sudo make install
    echo 'extension = "igbinary.so"' >> /data/service/php/etc/php.ini
 

    # redis
    wget -O /data/service/src/redis-4.2.0.tgz http://pecl.php.net/get/redis-4.2.0.tgz 
    cd /data/service/src/
    tar xf redis-4.2.0.tgz
    cd redis-4.2.0
    /data/service/php/bin/phpize
    ./configure --with-php-config=/data/service/php/bin/php-config
    make && sudo make install
    echo 'extension = "redis.so"' >> /data/service/php/etc/php.ini


    # yar
    ln -s /usr/include/x86_64-linux-gnu/curl   /usr/include
    wget -O /data/service/src/yar-2.0.6.tgz http://pecl.php.net/get/yar-2.0.6.tgz
    cd /data/service/src/
    tar xf yar-2.0.6.tgz
    cd yar-2.0.6
    /data/service/php/bin/phpize
    ./configure --with-php-config=/data/service/php/bin/php-config
    make && sudo make install
    echo 'extension = "yar.so"' >> /data/service/php/etc/php.ini


    # openssl
#    cd /data/service/src/php-7.2.11/ext/openssl
#    cp config0.m4 config.m4
#    /data/service/php/bin/phpize
#    ./configure --with-openssl -with-php-config=/data/service/php/bin/php-config
#    make
#    make install
#    echo 'extension = "openssl.so"' >> /data/service/php/etc/php.ini




    # 配置扩展
    #echo "security.limit_extensions = .php .php3 .php4 .php5 .do .html" >> /data/service/php/etc/php.ini

    # 启动 php
    /etc/init.d/php-fpm start
    /etc/init.d/php-fpm restart

}


install_openssl

install_php

