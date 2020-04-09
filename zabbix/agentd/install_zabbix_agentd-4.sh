#!/bin/bash

ZABBIX_VERSION=zabbix-4.4.4
ZABBIX_SERVER_IP=localhost

ZABBIX_DB_HOST=localhost
ZABBIX_DB_USER=zabbix
ZABBIX_DB_PASSWORD=''

ZABBIX_AGENTD_DIR=/data/service/zabbix/agent

function install_zabbix_agentd(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential libsnmp-dev libevent-dev
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        yum -y install git pcre-devel openssl-devel  net-snmp-devel libevent-devel
    else
        echo 'unknow OS'
        exit 1
    fi


    mkdir -p /data/service/{src,zabbix}
    chown zabbix:zabbix /data/service/zabbix

    addgroup --system --quiet zabbix
    adduser --quiet --system --disabled-login --ingroup zabbix --home /data/service/zabbix --no-create-home zabbix
    
#    wget -O /data/service/src/${ZABBIX_VERSION}.tar.gz https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.4.4/zabbix-4.4.4.tar.gz 
    
    cd /data/service/src
    tar xf ${ZABBIX_VERSION}.tar.gz
    cd ${ZABBIX_VERSION}/
    
    ./configure \
    --prefix=${ZABBIX_AGENTD_DIR} \
    --enable-agent 

# 需要go支持
#    --enable-agent2

    make install
    cp ${ZABBIX_AGENTD_DIR}/etc/zabbix_agentd.conf ${ZABBIX_AGENTD_DIR}/etc/zabbix_agentd.conf.$(date +%F)

cat >  ${ZABBIX_AGENTD_DIR}/etc/zabbix_agentd.conf <<EOF
LogFile=/tmp/zabbix_agentd.log
Server=${ZABBIX_SERVER_IP}
ServerActive=${ZABBIX_SERVER_IP}
Hostname=Zabbix server
Include=${ZABBIX_AGENTD_DIR}/etc/zabbix_agentd.conf.d/*.conf
EOF

    # server agent in same instance
    if [ -d  /data/service/zabbix/server ];then
	sed -i "s#Server=.*#Server=127.0.0.1#g" ${ZABBIX_AGENTD_DIR}/etc/zabbix_agentd.conf 
    fi


    if [ -f /usr/bin/apt ];then
        # ubuntu
        cp /data/service/src/${ZABBIX_VERSION}/misc/init.d/debian/zabbix-agent /etc/init.d/
        chmod +x /etc/init.d/zabbix-agent
        sed -i "s#DAEMON=.*#DAEMON=${ZABBIX_AGENTD_DIR}/sbin/\${NAME}#g" /etc/init.d/zabbix-agent
        /etc/init.d/zabbix-agent restart
    elif [ -f /usr/bin/yum ];then
        # centos
        cp /data/service/src/${ZABBIX_VERSION}/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
        chmod +x /etc/init.d/zabbix-agentd
        sed -i "s#BASEDIR=/usr/local#BASEDIR=${ZABBIX_AGENTD_DIR}/#g" /etc/init.d/zabbix_agentd
        /etc/init.d/zabbix_agentd restart
    else
        echo 'unknow OS'
        exit 1

    fi
}

function check_mysql(){

cat > ${ZABBIX_AGENTD_DIR}/etc/zabbix-my.cnf <<EOF
[client]
host=${ZABBIX_DB_HOST}
user='${ZABBIX_DB_USER}'
password='${ZABBIX_DB_PASSWORD}'
EOF

    chmod 600 ${ZABBIX_AGENTD_DIR}/etc/zabbix-my.cnf
    chown zabbix.zabbix ${ZABBIX_AGENTD_DIR}/etc/zabbix-my.cnf

    mv /root/userparameter_mysql.conf  /data/service/zabbix/agent/etc/zabbix_agentd.conf.d/userparameter_mysql.conf



}


install_zabbix_agentd
#check_mysql
