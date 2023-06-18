#!/bin/bash

# https://github.com/nodesource/distributions

# 判断系统
if [ -f /usr/bin/apt ];then
    echo 'ubuntu'
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
elif [ -f /usr/bin/yum ];then
    echo 'centOS'
    curl -sL https://rpm.nodesource.com/setup_20.x | bash -
    sudo yum -y install nodejs
else
    echo 'Unknow OS'
fi
