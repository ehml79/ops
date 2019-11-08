#!/bin/bash

# install java

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
echo "nohup java -jar /data/service/jenkins.war --httpPort=80 > /data/logs/jenkins.log 2>&1 &" >> /root/jenkins_start.sh


rm  -fr /root/$0
