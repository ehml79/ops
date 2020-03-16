#!/bin/bash

chown -R nginx.nginx /data/gittemp && chmod -R 775 /data/gittemp

rsync_log=/data/logs/rsync_update_scripts.log
#speed='--bwlimit=5000'
progress='--progress'
delete='--delete'

relRsync="rsync -vzrtopg  ${speed} ${progress} --password-file=/etc/rsyncd/rsyncd.pass"

cd /data/gittemp

for CODE_DIR in  cdn  h5sdk  m  opd  p  pc  samplewww  sdk  web
do
  
  # git clone -b master git@git.sample.com:/data/service/git/h5game.git
  
  cd /data/gittemp/${CODE_DIR}
  #git checkout dev
  git fetch --all
  git reset --hard origin/master
  git pull

  # update cdn
  if [ ${CODE_DIR} == "cdn" ];then
    ${relRsync} --exclude="*.git" --exclude="*.apk" --exclude="*.log" /data/gittemp/${CODE_DIR} rsync@192.168.0.17::web  | tee -a  ${rsync_log}
  else
    # update sdk
    ${relRsync} --exclude="*.git" --exclude="*.apk" --exclude="*.log" /data/gittemp/${CODE_DIR} rsync@192.168.0.19::web  | tee -a  ${rsync_log}
  fi

done
