#!/bin/bash

rsync_passwd=


function rsync_recv(){
    
    # 判断系统
    if [ -f /etc/os-release ];then
        echo 'ubuntu'
        apt -y install rsync
    elif [ -f /etc/redhat-release ];then
        echo 'centOS'
        yum -y install rsync
    else
        echo 'unknow OS'
        exit 1
    fi
    
    
    
    mkdir -p  /etc/rsyncd/
    echo "${rsync_passwd}" >  /etc/rsyncd/rsyncd.pass
    chmod 600  /etc/rsyncd/rsyncd.pass


}



rsync_recv
