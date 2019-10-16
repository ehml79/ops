#!/bin/bash

# install java
# install tomcat

wget -O /data/service/src/jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war 
mv  /data/service/src/jenkins.war  /data/service/tomcat/webapps
# 启动tomcat
# 访问url


# 启动jenkins
mkdir -p /data/log
echo "nohup java -jar /data/service/jenkins.war --httpPort=8080 > /data/log/jenkins.log 2>&1 &" > /root/jenkins_start.sh

