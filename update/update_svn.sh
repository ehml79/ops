#!/bin/bash

# rsync 配合 svn更新
chown -R nginx.nginx /data/svn && chmod -R 700 /data/svn

rsync_log=/data/logs/rsync_update_scripts.log
#speed='--bwlimit=5000'
progress='--progress'
delete='--delete'

relRsync="rsync -vzrtopg  ${speed} ${progress} --password-file=/etc/rsyncd/rsyncd.pass"

# 更新svn
line_number=$(/usr/bin/svn up /data/svn/repo | wc -l)

# 判断svn有没有新提交
if [ ${line_number}  -gt 2 ];then

    # 分割空格
    echo  >> ${rsync_log} 
    echo  >> ${rsync_log} 

    start_ctime=$(date +%s)
    echo "$(date '+%F %T %s') ${0} ${@} 开始更新" >> ${rsync_log}

    # sdk 
    ${relRsync} --exclude="*.svn" --exclude="*.apk" --exclude="*.log" /data/svn/repo/sdk/ rsync@192.168.0.3::sdk  | tee -a  ${rsync_log}

    end_ctime=$(date +%s)
    echo "$(date '+%F %T %s') ${0} ${@} 结束更新 脚本用时:$((${end_ctime}-${start_ctime}))s " >> $rsync_log
else
	echo "No file to update ..."
fi
