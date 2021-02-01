#!/bin/bash

# 0 0 * * * nginx_split_log.sh

logPath=/data/service/nginx/logs
backupPath=/data/service/nginx/logs/backup
dateFmt=$(date -d '-1 day' +%F-%H-%M-%S)


if [ ! -d ${backupPath} ];then
    mkdir -p ${backupPath}
fi


if [ -d ${logPath} ];then
    mv ${logPath}/access.log ${backupPath}/access_${dateFmt}.log
#    kill -USR1 $(cat /data/service/nginx/logs/nginx.pid)
    /data/service/nginx/sbin/nginx -s reopen
fi


find ${backupPath} -mtime +30 -exec rm -rf {} \;
