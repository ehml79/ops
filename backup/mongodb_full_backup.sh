#!/bin/bash
 
host='192.168.1.243'
port='27017'

backup_dir='/data/backup/mongodb/full'
cur_time=$(date "+%Y%m%d")
 
if [ ! -d "${backup_dir}/${cur_time}" ];then
    mkdir -p "${backup_dir}/${cur_time}"
fi
 

echo "=========================$(date) backup all mongodb back start  ${cur_time}========="

/data/service/mongodb-database-tools/bin/mongodump --host $host --port $port --oplog --gzip --out ${backup_dir}/${cur_time}
if [ $? -eq 0 ];then
    echo "The MongoDB BackUp Successfully!"
else
    echo "The MongoDB BackUp Failure"
fi
 
 
 
backup_time=$(date -d '-7 days' "+%Y%m%d")
if [ -d "${backup_dir}/${backup_time}/" ];then
    rm -rf "${backup_dir}/${backup_time}/"
    echo "=======${backup_dir}/${backup_time}/===删除完毕=="
fi
 
echo "========================= $(date) backup all mongodb back end ${cur_time}========="
