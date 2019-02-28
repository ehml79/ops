#!/bin/bash

# rsync 配合 svn更新

# crontab 
# * * * * * /bin/bash  /data/sh/update/rsync_update_scripts.sh
# * * * * * sleep 5 ; /bin/bash  /data/sh/update/rsync_update_scripts.sh
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


chown -R www.www /data/www && chmod -R 775 /data/www

rsync_log=/data/log/rsync_update_scripts.log
speed='--bwlimit=5000'
progress='--progress'
# 千万不能开啊
#delete='--delete'

relRsync="rsync -vzrtopg ${delete} ${speed} ${progress} --password-file=/etc/rsyncd/rsyncd.pass "

start_ctime=$(date +%s)

echo '-----' >> ${rsync_log} 
echo "$(date '+%F %T %s') ${0} ${@} 开始更新" >> ${rsync_log}
echo >> ${rsync_log} 

# 更新svn
/usr/bin/svn up /data/www  >> ${rsync_log} 

flag=push

# 接收文件
if [ ${flag} == 'recv' ];then
    #tlw-admanage	139.196.127.111	
    ${relRsync} rsync@139.196.127.111::update  /data/www/admanage  >> ${rsync_log} 2>&1
    #tlw-face	101.132.107.60	
    ${relRsync} rsync@101.132.107.60::update  /data/www/sdk  >> ${rsync_log} 2>&1
    #tlw-logselect	101.132.166.144	
    ${relRsync} rsync@101.132.166.144::update  /data/www/logselect  >> ${rsync_log} 2>&1
    #tlw-package	47.100.40.153	
    ${relRsync} rsync@47.100.40.153::update  /data/www/package  >> ${rsync_log} 2>&1
    #tlw-poster	101.132.194.206	
    ${relRsync} rsync@101.132.194.206::update  /data/www/poster  >> ${rsync_log} 2>&1
# 推送文件
elif [ ${flag} == 'push' ];then
    #tlw-admanage	139.196.127.111	
    ${relRsync} /data/www/admanage/ rsync@139.196.127.111::update  >> ${rsync_log} 2>&1
    #tlw-face	101.132.107.60	
    ${relRsync} /data/www/sdk/ rsync@101.132.107.60::update   >> ${rsync_log} 2>&1
    #tlw-logselect	101.132.166.144	
    ${relRsync} /data/www/logselect/ rsync@101.132.166.144::update  >> ${rsync_log} 2>&1
    #tlw-package	47.100.40.153	
    ${relRsync} /data/www/package/ rsync@47.100.40.153::update  >> ${rsync_log} 2>&1
    #tlw-poster	101.132.194.206	
    ${relRsync} /data/www/poster/ rsync@101.132.194.206::update  >> ${rsync_log} 2>&1
fi

end_ctime=$(date +%s)
echo >> ${rsync_log} 
echo "$(date '+%F %T %s') ${0} ${@} 更新结束 脚本用时:$((${end_ctime}-${start_ctime}))s " >> $rsync_log
