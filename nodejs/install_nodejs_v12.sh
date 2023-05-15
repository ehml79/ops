#!/bin/bash

node_version="v12.16.1"


function install_node(){

    mkdir -p /data/service/src
    
    wget -O /data/service/src/node-${node_version}-linux-x64.tar.gz  https://npmmirror.com/mirrors/node/${node_version}/node-${node_version}-linux-x64.tar.gz 
    tar xf /data/service/src/node-${node_version}-linux-x64.tar.gz -C /data/service/
    
    mv /data/service/node-${node_version}-linux-x64/  /data/service/node
    
    export PATH=$PATH:/data/service/node/bin/
    echo 'export PATH=$PATH:/data/service/node/bin/' > /etc/profile.d/node.sh
    
    # 安装cnpm
    /data/service/node/bin/npm install -g cnpm --registry=https://registry.npmmirror.com
    
    export PATH=$PATH:/data/service/node/lib/node_modules/cnpm/bin/
    echo 'export PATH=$PATH:/data/service/node/lib/node_modules/cnpm/bin/' >>/etc/profile.d/node.sh

    cnpm install -g vue-cli
    
    export PATH=$PATH:/data/service/node/lib/node_modules/vue-cli/bin/
    echo 'export PATH=$PATH:/data/service/node/lib/node_modules/vue-cli/bin/' >>/etc/profile.d/node.sh
}


install_node
