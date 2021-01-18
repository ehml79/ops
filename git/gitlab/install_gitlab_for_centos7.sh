#!/bin/bash

# CentOS Linux release 7.9.2009 (Core)

sudo yum install -y curl policycoreutils-python openssh-server perl
sudo systemctl enable sshd
sudo systemctl start sshd

# sudo firewall-cmd --permanent --add-service=http
# sudo firewall-cmd --permanent --add-service=https
# sudo systemctl reload firewalld


sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-13.7.1-ce.0.el7.x86_64.rpm
rpm -ivh gitlab-ce-13.7.1-ce.0.el7.x86_64.rpm

# curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash


# sudo EXTERNAL_URL="https://gitlab.example.com" yum install -y gitlab-ee

# config
cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.`date +%F`

# 配置域名
sed -i "s@^external_url .*@external_url 'https://${DOMAIN_NAME}'@" /etc/gitlab/gitlab.rb

# 限制普通用户创建组
sed -i "s@# gitlab_rails\['gitlab_default_can_create_group'\].*@gitlab_rails['gitlab_default_can_create_group'] = false@" /etc/gitlab/gitlab.rb

gitlab-ctl reconfigure
gitlab-ctl start

