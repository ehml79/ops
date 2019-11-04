#!/bin/bash

# Ubuntu 16.04 LTS, 18.04 LTS 
# https://about.gitlab.com/install/#ubuntu

DOMAIN_NAME="gitlab.limao98.net"
NGINX_USER="www"

## 信任 GitLab 的 GPG 公钥
#curl https://packages.gitlab.com/gpg.key 2> /dev/null | sudo apt-key add - &>/dev/null
#
## 配置清华源
#echo "deb https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu bionic main"  > /etc/apt/sources.list.d/gitlab_gitlab-ce.list
#
#sudo apt-get update
#sudo apt-get install -y curl openssh-server ca-certificates
#
#sudo apt-get install -y postfix
## 选择“Internet Site”并按Enter键。
#
#sudo apt-get install gitlab-ce

# config
#cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.`date +%F`

# 配置域名
sed -i "s@^external_url .*@external_url 'https://${DOMAIN_NAME}'@" /etc/gitlab/gitlab.rb

# 使用外部nginx
sed -i "s/^# nginx\['enable'\] =.*/nginx\['enable'\] = false/"  /etc/gitlab/gitlab.rb
sed -i "s/^# web_server\['external_users'\] = .*/web_server\['external_users'\] = \['${NGINX_USER}'\]/"  /etc/gitlab/gitlab.rb
sed -i "s/^# gitlab_rails\['trusted_proxies'\] = .*/gitlab_rails\['trusted_proxies'\] = \[\'127.0.0.1']/" /etc/gitlab/gitlab.rb 


sed -i "s/^# gitlab_workhorse\['listen_network'\] = .*/gitlab_workhorse['listen_network'] = \"tcp\"/" /etc/gitlab/gitlab.rb
sed -i "s/^# gitlab_workhorse\['listen_addr'\] = .*/gitlab_workhorse['listen_addr'] = \"127.0.0.1:8181\"/"  /etc/gitlab/gitlab.rb



#gitlab-ctl reconfigure
#
#
#
#cat > /data/service/nginx/conf/${DOMAIN_NAME}.conf <<EOF
#server {
#    listen       80;
#    server_name  ${DOMAIN_NAME};
#
#    location / {
#        proxy_pass http://127.0.0.1:8181/git;
#    }
#}
#EOF
