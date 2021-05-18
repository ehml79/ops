#!/bin/bash

# 判断系统
if [ -f /usr/bin/apt ];then
    apt -y install python3-pip
elif [ -f /usr/bin/yum ];then
    yum -y install python3-pip
else
    echo 'unknow OS'
    exit 1
fi

pip3 install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/

pip3 install ansible  -i https://mirrors.aliyun.com/pypi/simple/

mkdir /etc/ansible

mv {ansible.cfg,hosts} /etc/ansible

mkdir -p /root/ansible/roles/temp/{defaults,handlers,tasks,templates,vars}
