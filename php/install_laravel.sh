#!/bin/bash

# nginx php mysql composer

web_user=nginx

mkdir -p /data/web

cd /data/web

# 通过 Composer 安装 Laravel 安装器
composer global require "laravel/installer"

# 通过 Composer Create-Project
composer create-project --prefer-dist laravel/laravel blog

chown -R ${web_user}.${web_user} /data/web
