#!/bin/bash


while true
do
    #git clone -b dev  git@172.16.1.145:root/test.git
    
    cd /root/test
    
    git fetch --all 
    git reset --hard origin/dev  pull
    git pull
    
    rsync /root/test/ /data/www/emall/
done
