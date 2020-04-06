#!/bin/bash


GIT_TEMP=/data/gittemp/
WEB_DIR=/data/web/
BRANCH=master

for CODE_DIR in $(ls ${GIT_TEMP})
do
  
  # git clone -b master git@git.sample.com:/data/service/git/h5game.git
  
  cd ${GIT_TEMP}/${CODE_DIR}
  #git checkout ${BRANCH}
  git fetch --all
  git reset --hard origin/${BRANCH}
  git pull

done

chown -R nginx.nginx ${GIT_TEMP} 
chmod -R 700 ${GIT_TEMP}
rsync -av --exclude="*.git" ${GIT_TEMP}   ${WEB_DIR}
