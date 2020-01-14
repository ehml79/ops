#!/bin/bash

zabbix_version=zabbix-4.4.4
zabbix_server_ip=192.168.0.218

zabbix_db_host=localhost
zabbix_db_user=zabbix
zabbix_db_password=


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


    mkdir -p /data/service/src
    mkdir 770 -p /data/service/zabbix
    chown zabbix:zabbix /data/service/zabbix

    addgroup --system --quiet zabbix
    adduser --quiet --system --disabled-login --ingroup zabbix --home /data/service/zabbix --no-create-home zabbix
    
    wget -O /data/service/src/${zabbix_version}.tar.gz https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.4.4/zabbix-4.4.4.tar.gz 
    
    cd /data/service/src
    tar xf ${zabbix_version}.tar.gz
    cd ${zabbix_version}/
    
    ./configure \
    --prefix=/data/service/zabbix \
    --enable-agent \
    --enable-agent2

    make install
    cp /data/service/zabbix/etc/zabbix_agentd.conf /data/service/zabbix/etc/zabbix_agentd.conf.$(date +%F)

cat >  /data/service/zabbix/etc/zabbix_agentd.conf <<EOF
LogFile=/tmp/zabbix_agentd.log
Server=${zabbix_server_ip}
ServerActive=${zabbix_server_ip}
Hostname=Zabbix server
Include=/data/service/zabbix/etc/zabbix_agentd.conf.d/*.conf
EOF


    if [ -f /usr/bin/apt ];then
        # ubuntu
        cp /data/service/src/${zabbix_version}/misc/init.d/debian/zabbix-agent /etc/init.d/
        chmod +x /etc/init.d/zabbix-agent
        sed -i "s#DAEMON=.*#DAEMON=/data/service/zabbix/sbin/\${NAME}#g" /etc/init.d/zabbix-agent
        /etc/init.d/zabbix-agent restart
    elif [ -f /usr/bin/yum ];then
        # centos
        cp /data/service/src/${zabbix_version}/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
        chmod +x /etc/init.d/zabbix-agentd
        sed -i "s#BASEDIR=/usr/local#BASEDIR=/data/service/zabbix/#g" /etc/init.d/zabbix_agentd
        /etc/init.d/zabbix_agentd restart
    else
        echo 'unknow OS'
        exit 1

    fi
}

function check_mysql(){

cat > /data/service/zabbix/etc/zabbix-my.cnf <<EOF
[client]
host=${zabbix_db_host}
user='${zabbix_db_user}'
password='${zabbix_db_password}'
EOF

    chmod 600 /data/service/zabbix/etc/zabbix-my.cnf
    chown zabbix.zabbix /data/service/zabbix/etc/zabbix-my.cnf

cat > /data/service/zabbix/etc/zabbix_agentd.conf.d/userparameter_mysql.conf <<EOF
UserParameter=mysql.ping[*], /data/service/mysql/bin/mysqladmin --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf ping
UserParameter=mysql.get_status_variables[*], /data/service/mysql/bin/mysql --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf -sNX -e "show global status"
UserParameter=mysql.version[*], /data/service/mysql/bin/mysqladmin --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf -s  version
UserParameter=mysql.db.discovery[*], /data/service/mysql/bin/mysql --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf -sN -e "show databases"
UserParameter=mysql.dbsize[*], /data/service/mysql/bin/mysql --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf -sN -e "SELECT SUM(DATA_LENGTH + INDEX_LENGTH) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='\$3'"
UserParameter=mysql.replication.discovery[*], /data/service/mysql/bin/mysql --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf  -sNX -e "show slave status"
UserParameter=mysql.slave_status[*], /data/service/mysql/bin/mysql --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf -sNX -e "show slave status"

EOF

    # 导入数据库
    cd /data/service/src/${zabbix_version}/database/mysql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "CREATE DATABASE IF NOT EXISTS zabbix default CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "create user 'zabbix'@'%' ; "
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "ALTER USER 'zabbix'@'%' IDENTIFIED  BY '${zabbix_db_password}'; "

    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/${zabbix_version}/database/mysql/schema.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/${zabbix_version}/database/mysql/images.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/${zabbix_version}/database/mysql/data.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "grant all on zabbix.* to 'zabbix'@'%';"
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "FLUSH   PRIVILEGES; "


}


install_zabbix_agentd
#check_mysql
