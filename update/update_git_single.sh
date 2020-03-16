#!/bin/bash

for dir in  dir1 dir2 dir3
do 
    echo ${dir}
    cd  ${dir}
    git fetch --all
    git reset --hard origin/master
    git pull
done

chown -R www.www /data/gittemp/
rsync -av --exclude="*.git" /data/gittemp/  /data/www/
