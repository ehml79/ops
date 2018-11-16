#!/bin/bash


mkdir -p /data/{service,web}

wget https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.tar.gz -P /data/service/src

tar xf /data/service/src/phpMyAdmin-4.8.3-all-languages.tar.gz -C /data/web


cd /data/web/ &&  mv phpMyAdmin-4.8.3-all-languages/ phpMyAdmin



