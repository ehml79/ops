#!/bin/bash

# install java
# install tomcat

wget -O /data/service/src/jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war 
mv  /data/service/src/jenkins.war  /data/service/tomcat/webapps
# 启动tomcat
# 访问url
