#!/bin/bash


your_authorized_keys=


sudo apt-get install git

sudo adduser --disabled-password git 

mkdir -p /data/service/git

cd /data/service/git

sudo git init --bare repo.git

sudo chown -R git:git repo.git


# 更改 git shell
sed -i '/^git/s@/bin/bash@/usr/bin/git-shell@' /etc/passwd


mkdir -p /home/git/.ssh


echo "${your_authorized_keys}"  >>  /home/git/.ssh/authorized_keys
