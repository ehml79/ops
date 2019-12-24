#!/bin/bash


zabbix_server_ip=1.1.1.1
zabbix_db_host=localhost
zabbix_db_user=root
zabbix_db_password=


function install_zabbix_agentd_4(){

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


    mkdir -p /data/service/src/
    # ubuntu
    groupadd zabbix
    useradd -g zabbix zabbix
    wget -O /data/service/src/zabbix-4.0.0.tar.gz https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.0.0/zabbix-4.0.0.tar.gz 
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
Include=/data/service/zabbix/etc/zabbix_agentd.conf.d/*.conf
EOF

mkdir -p /data/.secret/
cat > /data/.secret/zabbix-my.cnf <<EOF
[client]
host=${zabbix_db_host}
user='${zabbix_db_user}'
password='${zabbix_db_password}'
EOF

    chmod 600 /data/.secret/zabbix-my.cnf 
    chown zabbix.zabbix /data/.secret/zabbix-my.cnf 

cat > /data/service/zabbix/etc/zabbix_agentd.conf.d/userparameter_mysql.conf <<EOF
UserParameter=mysql.ping,/data/service/mysql/bin/mysqladmin  --defaults-file=/data/.secret/zabbix-my.cnf ping 2>/dev/null |grep -c alive
UserParameter=mysql.status[*],/data/service/zabbix/share/zabbix/externalscripts/check_mysql \$1
UserParameter=mysql.version,/data/service/mysql/bin/mysql -V
EOF

    mkdir -p /data/service/zabbix/share/zabbix/externalscripts/
    cp /root/check_mysql /data/service/zabbix/share/zabbix/externalscripts/check_mysql 

    chown zabbix.zabbix  /data/service/zabbix/share/zabbix/externalscripts/check_mysql 
    chmod +x  /data/service/zabbix/share/zabbix/externalscripts/check_mysql 

    if [ -f /usr/bin/apt ];then
        # ubuntu
        cp /data/service/src/zabbix-4.0.0/misc/init.d/debian/zabbix-agent /etc/init.d/
        chmod +x /etc/init.d/zabbix-agent
        sed -i "s#/usr/local#/data/service/zabbix#g" /etc/init.d/zabbix-agent
        /etc/init.d/zabbix-agent restart
    elif [ -f /usr/bin/yum ];then
        # centos
        cp /data/service/src/zabbix-4.0.0/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
        chmod +x /etc/init.d/zabbix-agentd
        sed -i "s#/usr/local#/data/service/zabbix/#g" /etc/init.d/zabbix_agentd
        /etc/init.d/zabbix_agentd restart
    else
        echo 'unknow OS'
        exit 1

    fi
}


install_zabbix_agentd_4
