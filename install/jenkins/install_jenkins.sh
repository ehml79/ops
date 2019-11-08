#!/bin/bash

# install java

DOMAIN_NAME=jenkins.example.com

apt -y  install openjdk-11-jdk-headless openjdk-11-jre-headless

# install tomcat

mkdir -p /data/service/src

# 官方源
#wget -O /data/service/jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war

# 清华源
wget -O /data/service/jenkins.war https://mirrors.tuna.tsinghua.edu.cn/jenkins/war/latest/jenkins.war

# 启动jenkins
mkdir -p /data/logs
echo '#!/bin/bash'  > /root/jenkins_start.sh
echo "nohup java -jar /data/service/jenkins.war --httpPort=8090 > /data/logs/jenkins.log 2>&1 &" >> /root/jenkins_start.sh



cat > /data/service/nginx/conf/${DOMAIN_NAME}.conf <<EOF
server {
    listen       80;
    server_name  ${DOMAIN_NAME};

    location / {
        proxy_pass http://127.0.0.1:8090;
    }
}
EOF


nginx -s reload

rm  -fr /root/$0
