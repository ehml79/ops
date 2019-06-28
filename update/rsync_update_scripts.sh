#!/bin/bash

# rsync 配合 svn更新

# crontab
# * * * * *            /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep  5 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 10 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 15 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 20 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 25 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 30 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 35 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 40 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 45 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 50 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 55 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh


chown -R www.www /data/svn && chmod -R 775 /data/svn
rsync_log=/data/log/rsync_update_scripts.log
#speed='--bwlimit=5000'
progress='--progress'
delete='--delete'

relRsync="rsync -vzrtopg  ${speed} ${progress} --password-file=/etc/rsyncd/rsyncd.pass"

# 更新svn
line_number=$(/usr/bin/svn up /data/svn/repo | wc -l)

# 判断svn有没有新提交
if [ ${line_number}  -gt 2 ];then

    # 分割空格
    echo  | tee -a  ${rsync_log} 
    echo  | tee -a  ${rsync_log} 

    start_ctime=$(date +%s)
    echo "$(date '+%F %T %s') ${0} ${@} 开始更新" | tee -a  ${rsync_log}

    ${relRsync} --exclude="*.apk" --exclude="*.log" /data/svn/repo/www/ rsync@192.168.0.7::www  | tee -a  ${rsync_log} 

    end_ctime=$(date +%s)
    echo "$(date '+%F %T %s') ${0} ${@} 结束更新 脚本用时:$((${end_ctime}-${start_ctime}))s " | tee -a  ${rsync_log}
else
	echo "No file to update ..."
fi
