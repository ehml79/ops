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
speed='--bwlimit=5000'
progress='--progress'
delete='--delete'

relRsync="rsync -vzrtopg  ${speed} ${progress} --password-file=/etc/rsyncd/rsyncd.pass "

start_ctime=$(date +%s)

echo '-----' >> ${rsync_log} 
echo "$(date '+%F %T %s') ${0} ${@} 开始更新" >> ${rsync_log}
echo >> ${rsync_log} 

# 更新svn
/usr/bin/svn up /data/svn/repo  >> ${rsync_log} 

flag=push

# 接收文件
if [ ${flag} == 'recv' ];then
    ${relRsync} rsync@192.168.0.1::www  /data/svn/repo/www/  >> ${rsync_log} 2>&1
# 推送文件
elif [ ${flag} == 'push' ];then
    ${relRsync} /data/svn/repo/www/ rsync@192.168.0.1::www  >> ${rsync_log} 2>&1
fi

end_ctime=$(date +%s)
echo >> ${rsync_log} 
echo "$(date '+%F %T %s') ${0} ${@} 更新结束 脚本用时:$((${end_ctime}-${start_ctime}))s " >> $rsync_log
