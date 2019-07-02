#!/bin/bash



function install_vue(){

    mkdir -p /data/service/src
    
    #wget -O /data/service/src/node-v10.14.2.tar.gz  https://nodejs.org/dist/v10.14.2/node-v10.14.2.tar.gz 
    
    wget -O /data/service/src/node-v10.14.1-linux-x64.tar.gz  https://npm.taobao.org/mirrors/node/v10.14.1/node-v10.14.1-linux-x64.tar.gz 
    tar xf /data/service/src/node-v10.14.1-linux-x64.tar.gz -C /data/service/
    
    mv /data/service/node-v10.14.1-linux-x64/  /data/service/node
    
    echo 'export PATH=$PATH:/data/service/node/bin/' >>/etc/profile
    
    # 安装cnpm
    npm install -g cnpm --registry=https://registry.npm.taobao.org
    
    echo 'export PATH=$PATH:/data/service/node/lib/node_modules/cnpm/bin/' >>/etc/profile

    cnpm install -g vue-cli
    
    echo 'export PATH=$PATH:/data/service/node/lib/node_modules/vue-cli/bin/' >>/etc/profile
    

}


install_vue
