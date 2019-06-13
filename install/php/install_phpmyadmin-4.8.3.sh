#!/bin/bash


mkdir -p /data/{service,web}

wget -O /data/service/src/phpMyAdmin-4.8.3-all-languages.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.tar.gz 

tar xf /data/service/src/phpMyAdmin-4.8.3-all-languages.tar.gz -C /data/web


cd /data/web/ &&  mv phpMyAdmin-4.8.3-all-languages/ phpMyAdmin



