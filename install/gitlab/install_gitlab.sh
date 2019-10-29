#!/bin/bash

# Ubuntu 16.04 LTS, 18.04 LTS 
# https://about.gitlab.com/install/#ubuntu


sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates


sudo apt-get install -y postfix

# 太慢,下包装
# curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

# sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install gitlab-ce

wget --content-disposition https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/bionic/gitlab-ce_12.4.0-ce.0_amd64.deb/download.deb


sudo EXTERNAL_URL="https://gitlab.example.com" dpkg -i gitlab-ce_12.4.0-ce.0_amd64.deb


