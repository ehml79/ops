#!/bin/bash

# nginx php mysql composer
cd /data/www

# 通过 Composer 安装 Laravel 安装器
composer global require "laravel/installer"

# 通过 Composer Create-Project
composer create-project --prefer-dist laravel/laravel blog

chown -R www.www /data/www
