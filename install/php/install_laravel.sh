#!/bin/bash

# nginx php mysql composer

# 通过 Composer 安装 Laravel 安装器
composer global require "laravel/installer"

# 通过 Composer Create-Project
composer create-project --prefer-dist laravel/laravel blog

chown -R www.www /data/www
