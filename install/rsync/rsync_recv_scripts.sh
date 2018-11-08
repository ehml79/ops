#!/bin/bash


rsync_log=/data/backup/log/rsync.log
speed='--bwlimit=5000'
ip_list=()



start_ctime=$(date +%s)

echo '-------------------------------------------------------------' >> ${rsync_log} 

echo "$(date '+%F %T %s') ${0} ${@} 开始同步" >> ${rsync_log}
echo >> ${rsync_log} 


for remote_ip in ${ip_list[@]}
do
    rsync -vzrtopg --delete --progress ${speed} --password-file=/etc/rsyncd/rsyncd.pass  --exclude "*access*" --exclude "debug" backup@${remote_ip}::backup  /data/backup/rsync/ygd/${remote_ip}  >> ${rsync_log} 2>&1
done



end_ctime=$(date +%s)
echo >> ${rsync_log} 
echo "$(date '+%F %T %s') ${0} ${@} 同步结束 脚本用时:$((${end_ctime}-${start_ctime}))s " >> $rsync_log
