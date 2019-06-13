#!/bin/bash

# install java
# install tomcat

wget -O /data/server/src/jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war 
mv  /data/server/src/jenkins.war  /data/service/tomcat/webapps
# 启动tomcat
# 访问url
