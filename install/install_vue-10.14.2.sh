#!/bin/bash



function install_vue(){

    mkdir -p /data/service/src
    
    #wget -O /data/service/src/node-v10.14.2.tar.gz  https://nodejs.org/dist/v10.14.2/node-v10.14.2.tar.gz 
    
    wget -O /data/service/src/node-v10.14.1-linux-x64.tar.gz  https://npm.taobao.org/mirrors/node/v10.14.1/node-v10.14.1-linux-x64.tar.gz 
    tar xf /data/service/src/node-v10.14.1-linux-x64.tar.gz -C /data/service/
    
    mv /data/service/node-v10.14.1-linux-x64/  /data/service/node
    
    
    sudo ln -s /data/service/node/bin/node /usr/local/bin/node
    sudo ln -s /data/service/node/bin/npm /usr/local/bin/npm
    
    
    # 安装cnpm
    npm install -g cnpm --registry=https://registry.npm.taobao.org
    
    sudo ln -s /data/service/node/lib/node_modules/cnpm/bin/cnpm /usr/local/bin/cnpm
    
    cnpm install -g vue-cli
    
    sudo ln -s /data/service/node/lib/node_modules/vue-cli/bin/vue /usr/local/bin/vue

}


install_vue
