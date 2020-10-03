#!/bin/bash

# 59 23 * * * nginx_cut_log.sh

logPath=/data/service/nginx/logs
dateFmt=$(date -d '-1 day' +%F-%H-%M-%S)


if [ -d ${logPath} ];then
    mv ${logPath}/access.log ${logPath}/access_${dateFmt}.log
    kill -USR1 $(cat /data/service/nginx/logs/nginx.pid)
fi

