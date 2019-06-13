#!/bin/bash


mkdir -p  /data/service/src

wget -O /data/service/src/apache-tomcat-9.0.13.tar.gz http://mirrors.hust.edu.cn/apache/tomcat/tomcat-9/v9.0.13/bin/apache-tomcat-9.0.13.tar.gz 

tar xf /data/service/src/apache-tomcat-9.0.13.tar.gz -C /data/service/
mv /data/service/apache-tomcat-9.0.13/ /data/service/tomcat


echo "bash  /data/service/tomcat/bin/startup.sh" > /root/tomcat_start.sh
echo " bash /data/service/tomcat/bin/shutdown.sh" > /root/tomcat_stop.sh
