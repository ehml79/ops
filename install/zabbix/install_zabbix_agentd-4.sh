#!/bin/bash


zabbix_server_ip=


function install_zabbix_agentd_4(){

	mkdir -p /data/service/src/
	# ubuntu
	groupadd zabbix
	useradd -g zabbix zabbix
	wget https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.0.0/zabbix-4.0.0.tar.gz -P /data/service/src
	cd /data/service/src
	tar xf zabbix-4.0.0.tar.gz
	cd zabbix-4.0.0/
	./configure --prefix=/data/service/zabbix --enable-agent
	make install
	cp /data/service/zabbix/etc/zabbix_agentd.conf /data/service/zabbix/etc/zabbix_agentd.conf_$(date +%F)

cat >  /data/service/zabbix/etc/zabbix_agentd.conf <<EOF
LogFile=/tmp/zabbix_agentd.log
Server=${zabbix_server_ip}
ServerActive=${zabbix_server_ip}
Hostname=Zabbix server
EOF

	cp /data/service/src/zabbix-4.0.0/misc/init.d/debian/zabbix-agent /etc/init.d/
	chmod +x /etc/init.d/zabbix-agent

	sed -i "s#/usr/local#/data/service/zabbix/#g" /etc/init.d/zabbix_agentd

	/etc/init.d/zabbix_agent restart
}


install_zabbix_agentd_4
