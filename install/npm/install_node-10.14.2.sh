#!/bin/bash


node_version=node-v10.16.3


function install_node(){

    mkdir -p /data/service/src
    
    wget -O /data/service/src/${node_version}-linux-x64.tar.gz  https://npm.taobao.org/mirrors/node/v10.14.1/${node_version}-linux-x64.tar.gz 
    tar xf /data/service/src/${node_version}-linux-x64.tar.gz -C /data/service/
    
    mv /data/service/${node_version}-linux-x64/  /data/service/node
    
    echo 'export PATH=$PATH:/data/service/node/bin/' >>/etc/profile
    
    # 安装cnpm
    /data/service/node/bin/npm install -g cnpm --registry=https://registry.npm.taobao.org
    
    echo 'export PATH=$PATH:/data/service/node/lib/node_modules/cnpm/bin/' >>/etc/profile

    cnpm install -g vue-cli
    
    echo 'export PATH=$PATH:/data/service/node/lib/node_modules/vue-cli/bin/' >>/etc/profile
    

}


install_node
