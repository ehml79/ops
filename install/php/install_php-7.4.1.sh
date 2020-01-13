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
	mkdir -p /data/service/php/log/

    #  配置 /data/service/php/etc/php-fpm.conf
    sed -i 's@;pid = run/php-fpm.pid@pid = run/php-fpm.pid@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;emergency_restart_threshold.*@emergency_restart_threshold = 10@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;emergency_restart_interval.*@emergency_restart_interval = 1m@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;process_control_timeout.*@process_control_timeout = 5s@' /data/service/php/etc/php-fpm.conf
    sed -i 's@;daemonize.*@daemonize = yes@' /data/service/php/etc/php-fpm.conf
    
    # 调优的地方
    sed -i "s#pm.max_children.*#pm.max_children = 20#" /data/service/php/etc/php-fpm.conf
    sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 20#" /data/service/php/etc/php-fpm.conf
    sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 10#" /data/service/php/etc/php-fpm.conf
    sed -i "s#pm.start_servers.*#pm.start_servers = 10#" /data/service/php/etc/php-fpm.conf
    

    # 配置 /data/service/php/etc/php-fpm.d/www.conf
    cp /data/service/php/etc/php-fpm.d/www.conf.default  /data/service/php/etc/php-fpm.d/www.conf
    sed -i "s@user =.*@user = ${run_user}@" /data/service/php/etc/php-fpm.d/www.conf
    sed -i "s@group =.*@group = ${run_user}@" /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@listen =.*@listen = 127.0.0.1:9000@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;listen.backlog.*@listen.backlog = -1@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@;listen.allowed_clients.*@listen.allowed_clients = 127.0.0.1@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm =.*@pm = dynamic@' /data/service/php/etc/php-fpm.d/www.conf
    sed -i 's@pm.max_children.*@pm.max_children = 20@' /data/service/php/etc/php-fpm.d/www.conf
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
    cp /data/service/src/php-7.4.1/php.ini-production /data/service/php/etc/php.ini
    
    # sed -i 's@; max_input_vars.*@; max_input_vars = 1000@' /data/service/php/etc/php.ini
    # sed -i 's@; extension_dir.*@extension_dir = "/data/service/php/lib/php/extensions/no-debug-non-zts-20170718/"@' /data/service/php/etc/php.ini
    # sed -i 's@; Development Value.*@; Development Value: On@' /data/service/php/etc/php.ini

    # php 调试模式
	sed -i 's@; output_buffering.*@output_buffering = on@' /data/service/php/etc/php.ini
	sed -i 's@^short_open_tag = Off@short_open_tag = On@' /data/service/php/etc/php.ini
	sed -i 's@expose_php.*@expose_php = Off@' /data/service/php/etc/php.ini
	sed -i 's@memory_limit.*@memory_limit = 1024M@' /data/service/php/etc/php.ini
	sed -i 's@error_reporting.*@error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT@' /data/service/php/etc/php.ini
	sed -i 's@;track_errors =.*@track_errors = Off@' /data/service/php/etc/php.ini
	sed -i 's@;date.timezone.*@date.timezone = PRC@' /data/service/php/etc/php.ini
	sed -i 's@mail.add_x_header.*@mail.add_x_header = On@' /data/service/php/etc/php.ini
	sed -i 's@;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /data/service/php/etc/php.ini

	sed -i 's@^post_max_size.*@post_max_size = 100M@' /data/service/php/etc/php.ini
	sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /data/service/php/etc/php.ini
	sed -i 's@^max_execution_time.*@max_execution_time = 600@' /data/service/php/etc/php.ini
	sed -i 's@^disable_functions.*@disable_functions =  passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,popen,openlog,syslog,fsocket@g' /data/service/php/etc/php.ini

	sed -i 's@; display_errors =.*@display_errors = On@' /data/service/php/etc/php.ini
	sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' /data/service/php/etc/php.ini
	sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' /data/service/php/etc/php.ini
	sed -i 's@^request_order.*@request_order = "CGP"@' /data/service/php/etc/php.ini



    # php extension conf
    mkdir -p /data/service/php/etc/conf.d

cat > /data/service/php/etc/conf.d/opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=512
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=100000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
;opcache.save_comments=0
opcache.consistency_checks=0
;opcache.optimization_level=0
EOF

}

function install_extension(){
	/data/service/php/bin/pecl channel-update pecl.php.net
	
	
    
	/data/service/php/bin/pecl install igbinary
    # # igbinary
    # wget -O /data/service/src/igbinary-3.1.0.tgz  http://pecl.php.net/get/igbinary-3.1.0.tgz 
    # cd /data/service/src/ 
    # tar xf igbinary-3.1.0.tgz   
    # cd igbinary-3.1.0
    # /data/service/php/bin/phpize
    # ./configure --with-php-config=/data/service/php/bin/php-config
    # make && sudo make install
    # echo 'extension = "igbinary.so"' >> /data/service/php/etc/php.ini

	/data/service/php/bin/pecl install redis
    #  # redis
    # wget -O /data/service/src/redis-5.1.1.tgz http://pecl.php.net/get/redis-5.1.1.tgz 
    # cd /data/service/src/
    # tar xf redis-5.1.1.tgz
    # cd redis-5.1.1
    # /data/service/php/bin/phpize
    # ./configure --with-php-config=/data/service/php/bin/php-config
    # make && sudo make install
    # echo 'extension = "redis.so"' >> /data/service/php/etc/php.ini

}


install_php
install_extension