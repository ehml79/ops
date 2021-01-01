#!/bin/bash

# https://hellosean1025.github.io/yapi/devops/index.html
# https://github.com/YMFE/yapi
# 初始化管理员账号成功,账号名："admin@admin.com"，密码："ymfe.org"

DOMAIN_NAME=yapi.example.com

# install nodejs
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
sudo yum install -y nodejs

# install mongo

# install nginx

mkdir /data/web/yapi
cd /data/web/yapi
git clone https://github.com/YMFE/yapi.git vendors
cat > /data/web/yapi/config.json << EOF
{
  "port": "3000",
  "adminAccount": "admin@admin.com",
  "timeout":120000,
  "db": {
    "servername": "127.0.0.1",
    "DATABASE": "yapi",
    "port": 27017,
    "user": "",
    "pass": "",
    "authSource": ""
  },
  "mail": {
    "enable": true,
    "host": "smtp.163.com",
    "port": 465,
    "from": "***@163.com",
    "auth": {
      "user": "***@163.com",
      "pass": "*****"
    }
  }
}
EOF

chmod +x /data/web/yapi/config.json

cat > /data/service/nginx/conf/vhost/yapi.conf <<EOF
#
server
{
    listen       80;
    server_name  $DOMAIN_NAME;
    charset utf-8;


    location / {
        proxy_pass  http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

}
EOF



cd vendors
npm install --production --registry https://registry.npm.taobao.org
npm run install-server
# node server/app.js

npm install pm2 -g --registry https://registry.npm.taobao.org
pm2 start "/data/web/yapi/vendors/server/app.js" --name yapi 

# pm2 info yapi
# pm2 stop yapi 
# pm2 restart yapi

# nginx -s reload


