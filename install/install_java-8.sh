#!/bin/bash


# 安装java8

function install_java8_env(){
	echo -e "${RED}开始安装java8 ...${END}"
	sudo apt-get update
	sudo apt-get install software-properties-common -y
	sudo add-apt-repository ppa:webupd8team/java -y
	sudo apt-get update
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	sudo apt-get install oracle-java8-installer -y
	# JDK8 默认选择条款
	sudo apt-get install oracle-java8-set-default
}


install_java8_env
