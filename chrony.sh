#!/bin/bash



# 判断系统
if [ -f /usr/bin/apt ];then
    echo 'ubuntu'
    apt -y install  chrony
elif [ -f /usr/bin/yum ];then
    echo 'centOS'
    yum -y install  chrony
else
    echo 'unknow OS'
    exit 1
fi



systemctl start chronyd.service

systemctl enable chronyd.service

systemctl status chronyd.service
