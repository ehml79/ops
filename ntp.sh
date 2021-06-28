#!/bin/bash


# 判断系统
if [ -f /usr/bin/apt ];then
    echo 'ubuntu'
    apt install ntpdate
elif [ -f /usr/bin/yum ];then
    echo 'centOS'
    centos_disk_partition
    yum -y install ntp
else
    echo 'unknow OS'
    exit 1
fi


ntpdate ntp.aliyun.com
