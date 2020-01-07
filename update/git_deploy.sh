#!/bin/bash


CODE_DIR=/data/gittemp/sample
WEB_DIR=/data/web/sample

cd /data/gittemp

# git clone -b master git@192.168.0.1:/data/service/git/sample.git

cd ${CODE_DIR}

#git checkout dev
git fetch --all
git reset --hard origin/master
git pull

rsync -av --exclude="*.git" ${CODE_DIR}/ ${WEB_DIR}/
chown -R nginx.nginx ${CODE_DIR}/ ${WEB_DIR}/
chmod -R 755 ${CODE_DIR}/ ${WEB_DIR}/
