#!/bin/bash

zabbix_version=zabbix-4.4.4
zabbix_server_ip=127.0.0.1
zabbix_user=zabbix
zabbix_db_password=
zabbix_domain=zabbix.example.com

function install_zabbix_server(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential libsnmp-dev libevent-dev  libmysqlclient-dev
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
    cd ${zabbix_version}
    
    ./configure \
    --prefix=/data/service/zabbix  \
    --enable-server \
    --enable-agent \
    --enable-agent2 \
    --with-mysql \
    -enable-ipv6 \
    --with-net-snmp \
    --with-libcurl \
    --with-libxml2
    
    make install
    cp /data/service/zabbix/etc/zabbix_agentd.conf /data/service/zabbix/etc/zabbix_agentd.conf.bak
    cp /data/service/zabbix/etc/zabbix_server.conf /data/service/zabbix/etc/zabbix_server.conf.bak


cat > /data/service/zabbix/etc/zabbix_agentd.conf <<EOF
LogFile=/tmp/zabbix_agentd.log
Server=127.0.0.1
ServerActive=127.0.0.1
Hostname=Zabbix server
Include=/data/service/zabbix/etc/zabbix_agentd.conf.d/*.conf
EOF


# 报警脚本
mkdir -p /data/service/zabbix/share/zabbix/alertscripts
cp /root/sendmail.py /data/service/zabbix/share/zabbix/alertscripts/
chown zabbix.zabbix  /data/service/zabbix/share/zabbix/alertscripts/sendmail.py
chmod +x  /data/service/zabbix/share/zabbix/alertscripts/sendmail.py


cat > /data/service/zabbix/etc/zabbix_server.conf <<EOF
DBHost=${zabbix_server_ip}
DBName=${zabbix_user}
DBUser=${zabbix_user}
DBPassword=${zabbix_db_password} 
ListenIP=0.0.0.0
StartPollersUnreachable=10
StartTrappers=10
StartPingers=10
StartDiscoverers=10
CacheSize=256M
StartDBSyncers=40
HistoryCacheSize=128M
TrendCacheSize=128M
ValueCacheSize=128M
Timeout=30
AlertScriptsPath=/data/service/zabbix/share/zabbix/alertscripts
ExternalScripts=/data/service/zabbix/share/zabbix/externalscripts
LogSlowQueries=10000
StartProxyPollers=50
LogFile=/tmp/zabbix_server.log
EOF


    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        # ubuntu
	cp /data/service/src/${zabbix_version}/misc/init.d/debian/zabbix-agent /etc/init.d/
	cp /data/service/src/${zabbix_version}/misc/init.d/debian/zabbix-server /etc/init.d/
	sed -i "s#DAEMON=.*#DAEMON=/data/service/zabbix/sbin/\${NAME}#g" /etc/init.d/zabbix-server
	sed -i "s#DAEMON=.*#DAEMON=/data/service/zabbix/sbin/\${NAME}#g" /etc/init.d/zabbix-agent
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
	# centos
	cp /data/service/src/${zabbix_version}/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
	cp /data/service/src/${zabbix_version}/misc/init.d/fedora/core/zabbix_server /etc/init.d/
	sed -i "s#BASEDIR=/usr/local#BASEDIR=/data/service/zabbix/#g" /etc/init.d/zabbix_server
	sed -i "s#BASEDIR=/usr/local#BASEDIR=/data/service/zabbix/#g" /etc/init.d/zabbix_agentd
    else
        echo 'unknow OS'
        exit 1
    fi


    mkdir -p /data/web/zabbix
    cp -r /data/service/src/${zabbix_version}/frontends/php/* /data/web/zabbix/
    chown -R nginx:nginx /data/web/zabbix/
    
    echo "/data/service/mysql/lib/" >>  /etc/ld.so.conf
    ldconfig


cat > /data/service/nginx/conf/vhost/zabbix.conf <<EOF
#
    server {
        listen       80;
        server_name  ${zabbix_domain};

        location / {
            root   /data/web/zabbix;
            index  index.php index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        location ~ \.php$ {
            root           /data/web/zabbix;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

    }

EOF

    nginx -s reload

    # 配置 php.ini 参数
    sed -i 's/post_max_size.*/post_max_size = 	16M/' /data/service/php/etc/php.ini
    sed -i 's/max_execution_time.*/max_execution_time = 300/' /data/service/php/etc/php.ini
    sed -i 's/max_input_time.*/max_input_time = 300/' /data/service/php/etc/php.ini
    #sed -i 's@;date.timezone.*@date.timezone = Asia/Shanghai@'  /data/service/php/etc/php.ini

    /etc/init.d/php-fpm restart



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
UserParameter=mysql.dbsize[*], /data/service/mysql/bin/mysql --defaults-file=/data/service/zabbix/etc/zabbix-my.cnf -sN -e "SELECT SUM(DATA_LENGTH + INDEX_LENGTH) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=''"
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



install_zabbix_server
#check_mysql