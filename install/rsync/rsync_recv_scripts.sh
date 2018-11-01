#!/bin/bash


rsync_user=backup

rsync_log=/data/backup/log/rsync.log



start_ctime=$(date +%s)

echo '-------------------------------------------------------------' >> ${rsync_log} 

echo "$(date '+%F %T %s') ${0} ${@} 开始同步" >> ${rsync_log}
echo >> ${rsync_log} 

rsync -vzrtopg --delete --progress --password-file=/etc/rsyncd/rsyncd.pass  --exclude "*access*" --exclude "debug" ${rsync_user}@192.168.172.129::${rsync_user}  /data/backup/192.168.172.129  >> ${rsync_log} 2>&1
end_ctime=$(date +%s)

echo >> ${rsync_log} 
echo "$(date '+%F %T %s') ${0} ${@} 同步结束 脚本用时:$((${end_ctime}-${start_ctime}))s " >> $rsync_log
