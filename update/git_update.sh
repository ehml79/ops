#!/bin/bash

REPO_DIR="/data/www/emall"
LOG_FILE="/data/logs/git_update.sh.log"

mkdir -p /data/logs
echo `date '+%F %T'` >> ${LOG_FILE}

cd  ${REPO_DIR}

git fetch --all >> ${LOG_FILE} 2>&1
git reset --hard origin/master  >> ${LOG_FILE} 2>&1
git pull >> ${LOG_FILE} 2>&1

