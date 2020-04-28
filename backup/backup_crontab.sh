#!/bin/bash

# vars
# 备份代码文件
start_ctime=$(date +%s)
date=$(date +%F)
ctime=$(date +%H-%M-%S)
back_cron_conf_dir=/data/backup/crontab_conf
backup_dir=/data/backup/crontab_conf/${date}/${ctime}
backup_log=/data/logs/backup_crontab.log
keep_day=7

# 减锁，执行脚本
chattr -R -i ${back_cron_conf_dir}

# 建立备份目录
if [ ! -e ${backup_dir} ];then
    mkdir -p ${backup_dir}
fi

# 建立备份日志目录
if [ ! -e /data/logs ];then
    mkdir -p /data/logs
fi

# 删除旧备份
function clean_backup(){
    find ${back_cron_conf_dir} -mtime +${keep_day} -exec rm -fr {} \;
}


function backup_crontab(){
    crontab -l > ${backup_dir}/crontab.txt
}


echo "$(date '+%F %T %s') ${0} ${@} 清理旧备份" >> ${backup_log}
clean_backup
echo "$(date '+%F %T %s') ${0} ${@} 开始备份" >> ${backup_log}
backup_crontab
end_ctime=$(date +%s)
echo "$(date '+%F %T %s') ${0} ${@} 备份结束 脚本用时:$((${end_ctime}-${start_ctime}))s " >> $backup_log

# 加锁,防误删
chattr -R +i ${back_cron_conf_dir}
