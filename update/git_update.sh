#!/bin/bash


mkdir -p /data/logs
echo `date '+%F %T'` >> /data/logs/$0.log


cd  /data/www/emall

git fetch --all
git reset --hard origin/master
git pull

