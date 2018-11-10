#!/bin/bash

# install java
# install tomcat

wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war -P /data/server/src
mv  /data/server/src/jenkins.war  /data/service/tomcat/webapps
# 启动tomcat
# 访问url
