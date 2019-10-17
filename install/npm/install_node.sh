#!/bin/bash



function install_npm(){

    mkdir -p /data/service/src
    
    wget -O /data/service/src/node-v10.14.1-linux-x64.tar.gz  https://npm.taobao.org/mirrors/node/v10.14.1/node-v10.14.1-linux-x64.tar.gz 
    tar xf /data/service/src/node-v10.14.1-linux-x64.tar.gz -C /data/service/
    
    mv /data/service/node-v10.14.1-linux-x64/  /data/service/node
    
    echo 'export PATH=$PATH:/data/service/node/bin/' >>/etc/profile
}


install_npm
