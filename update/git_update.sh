#!/bin/bash

REPO_DIR="/data/www/emall"

mkdir -p /data/logs
echo `date '+%F %T'` >> /data/logs/$0.log

cd  ${REPO_DIR}

git fetch --all >> /data/logs/$0.log 2>&1
git reset --hard origin/master  >> /data/logs/$0.log 2>&1
git pull >> /data/logs/$0.log 2>&1

