#!/bin/bash


apt -y  install virtualenv

mkdir /data/venv

cd /data/venv/

virtualenv -p /usr/bin/python3 --no-site-packages py3

# 启动虚拟环境
source /data/venv/py3/bin/activate

# 退出虚拟环境
deactivate　

# 删除虚拟环境
rm /data/venv/py3
