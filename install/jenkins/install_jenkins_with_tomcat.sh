#!/bin/bash

# install java

apt -y  install openjdk-8-jdk-headless openjdk-8-jre-headless


# install tomcat

mkdir -p /data/service/src
wget -O /data/service/src/jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war 
mv  /data/service/src/jenkins.war  /data/service/tomcat/webapps
# 启动tomcat
# 访问url


# 启动jenkins
mkdir -p /data/logs
echo "#!/bin/bash"
echo "nohup java -jar /data/service/jenkins.war --httpPort=8080 > /data/logs/jenkins.log 2>&1 &" > /root/jenkins_start.sh

