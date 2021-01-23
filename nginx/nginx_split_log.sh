#!/bin/bash

# 59 23 * * * nginx_split_log.sh

logPath=/data/service/nginx/logs
dateFmt=$(date -d '-1 day' +%F-%H-%M-%S)


if [ -d ${logPath} ];then
    mv ${logPath}/access.log ${logPath}/backup/access_${dateFmt}.log
#    kill -USR1 $(cat /data/service/nginx/logs/nginx.pid)
    /data/service/nginx/sbin/nginx -s reopen
fi


find /data/service/nginx/logs/backup/ -mtime +30 -exec rm -rf {} \;
