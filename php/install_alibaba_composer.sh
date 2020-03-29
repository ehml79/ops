#!/bin/bash


apt -y install unzip  wget

wget https://mirrors.aliyun.com/composer/composer.phar -O  /usr/bin/composer

chmod +x /usr/bin/composer

# 更改阿里镜像
/usr/bin/composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

