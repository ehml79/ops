#!/bin/bash

sudo apt-get update
sudo apt-get -y install libzip-dev bison autoconf build-essential pkg-config git-core\
   libltdl-dev libbz2-dev libxml2-dev libxslt1-dev libssl-dev libicu-dev libpspell-dev\
   libenchant-dev libmcrypt-dev libpng-dev libjpeg8-dev libfreetype6-dev libmysqlclient-dev\
   libreadline-dev libcurl4-openssl-dev librecode-dev libsqlite3-dev libonig-dev

wget https://www.php.net/distributions/php-7.4.1.tar.bz2


./configure --prefix=/usr/local/php7 \



--with-config-file-scan-dir=/usr/local/php7/etc/php.d \
--with-config-file-path=/usr/local/php7/etc \

--enable-mbstring \
--enable-zip \
--enable-bcmath \
--enable-pcntl \
--enable-ftp \
--enable-xml \
--enable-shmop \
--enable-soap \
--enable-intl \
--with-openssl \
--enable-exif \
--enable-calendar \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-opcache \
--enable-fpm \
--enable-session \
--enable-sockets \
--enable-mbregex \
--enable-wddx \
--enable-gd-jis-conv \
--with-curl \
--with-iconv \
--with-gd \
--with-xmlrpc \
--with-openssl \
--with-jpeg-dir=/usr \
--with-png-dir=/usr \
--with-zlib-dir=/usr \
--with-freetype-dir=/usr \
--with-pdo-mysql=mysqlnd \
--with-gettext=/usr \
--with-zlib=/usr \
--with-bz2=/usr \
--with-recode=/usr \
--with-mysqli=mysqlnd
