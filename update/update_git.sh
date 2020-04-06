#!/bin/bash


#rsync_log=/data/logs/update_git.log
#speed='--bwlimit=5000'
progress='--progress'
delete='--delete'

relRsync="rsync -vzrtopg  ${speed} ${progress} --password-file=/etc/rsyncd/rsyncd.pass"

GIT_TEMP=/data/gittemp
BRANCH=master


for CODE_DIR in $(ls ${GIT_TEMP})
do
  
  # git clone -b master git@git.sample.com:/data/service/git/h5game.git
  
  cd ${GIT_TEMP}/${CODE_DIR}
  #git checkout ${BRANCH}
  git fetch --all
  git reset --hard origin/${BRANCH}
  git pull

  chown -R nginx.nginx ${GIT_TEMP} 
  chmod -R 700 ${GIT_TEMP}

  # update cdn
  if [ ${CODE_DIR} == "cdn" ];then
    ${relRsync} --exclude="*.git" --exclude="*.apk" --exclude="*.log" ${GIT_TEMP}/${CODE_DIR} rsync@192.168.0.17::web  | tee -a  ${rsync_log}
  else
    # update sdk
    ${relRsync} --exclude="*.git" --exclude="*.apk" --exclude="*.log" ${GIT_TEMP}/${CODE_DIR} rsync@192.168.0.19::web  | tee -a  ${rsync_log}
  fi

done
