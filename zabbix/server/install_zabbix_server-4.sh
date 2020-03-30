#!/bin/bash

ZABBIX_VERSION=zabbix-4.4.4
ZABBIX_SERVER_IP=localhost
ZABBIX_USER=zabbix
ZABBIX_DB_PASSWORD=''
ZABBIX_DOMAIN=zabbix.example.com

ZABBIX_SERVER_DIR=/data/service/zabbix/server

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
  	chmod 770 -p /data/service/zabbix
	chown zabbix:zabbix /data/service/zabbix

    addgroup --system --quiet zabbix
    adduser --quiet --system --disabled-login --ingroup zabbix --home /data/service/zabbix --no-create-home zabbix
    
    wget -O /data/service/src/${ZABBIX_VERSION}.tar.gz https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.4.4/zabbix-4.4.4.tar.gz
    
    cd /data/service/src
    tar xf ${ZABBIX_VERSION}.tar.gz
    cd ${ZABBIX_VERSION}
    
    ./configure \
    --prefix=${ZABBIX_SERVER_DIR}  \
    --enable-server \
    --with-mysql \
    -enable-ipv6 \
    --with-net-snmp \
    --with-libcurl \
    --with-libxml2
    
    make install
    cp ${ZABBIX_SERVER_DIR}/etc/zabbix_server.conf ${ZABBIX_SERVER_DIR}/etc/zabbix_server.conf.$(date +%F)


# 报警脚本
mkdir -p ${ZABBIX_SERVER_DIR}/share/zabbix/alertscripts
cp /root/sendmail.py ${ZABBIX_SERVER_DIR}/share/zabbix/alertscripts/
chown zabbix.zabbix  ${ZABBIX_SERVER_DIR}/share/zabbix/alertscripts/sendmail.py
chmod +x  ${ZABBIX_SERVER_DIR}/share/zabbix/alertscripts/sendmail.py


cat > ${ZABBIX_SERVER_DIR}/etc/zabbix_server.conf <<EOF
DBHost=${ZABBIX_SERVER_IP}
DBName=${ZABBIX_USER}
DBUser=${ZABBIX_USER}
DBPassword=${ZABBIX_DB_PASSWORD} 
ListenIP=0.0.0.0
StartPollersUnreachable=1
StartTrappers=5
StartPingers=1
StartDiscoverers=1
CacheSize=8M
StartDBSyncers=4
HistoryCacheSize=16M
TrendCacheSize=4M
ValueCacheSize=8M
Timeout=3
AlertScriptsPath=${ZABBIX_SERVER_DIR}/share/zabbix/alertscripts
ExternalScripts=${ZABBIX_SERVER_DIR}/share/zabbix/externalscripts
LogSlowQueries=3000
StartProxyPollers=1
LogFile=/tmp/zabbix_server.log
EOF


    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        # ubuntu
	cp /data/service/src/${ZABBIX_VERSION}/misc/init.d/debian/zabbix-server /etc/init.d/
	sed -i "s#DAEMON=.*#DAEMON=${ZABBIX_SERVER_DIR}/sbin/\${NAME}#g" /etc/init.d/zabbix-server
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
	# centos
	cp /data/service/src/${ZABBIX_VERSION}/misc/init.d/fedora/core/zabbix_server /etc/init.d/
	sed -i "s#BASEDIR=/usr/local#BASEDIR=${ZABBIX_SERVER_DIR}/#g" /etc/init.d/zabbix_server
    else
        echo 'unknow OS'
        exit 1
    fi


    mkdir -p /data/web/zabbix
    cp -r /data/service/src/${ZABBIX_VERSION}/frontends/php/* /data/web/zabbix/
    chown -R nginx:nginx /data/web/zabbix/
    
    echo "/data/service/mysql/lib/" >>  /etc/ld.so.conf
    ldconfig


cat > /data/service/nginx/conf/vhost/zabbix.conf <<EOF
#
    server {
        listen       80;
        server_name  ${ZABBIX_DOMAIN};

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


function load_sql(){
    # 导入数据库
    cd /data/service/src/${ZABBIX_VERSION}/database/mysql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "CREATE DATABASE IF NOT EXISTS ${ZABBIX_USER} default CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "create user '${ZABBIX_USER}'@'%' ; "
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "ALTER USER '${ZABBIX_USER}'@'%' IDENTIFIED  BY '${ZABBIX_DB_PASSWORD}'; "

    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/${ZABBIX_VERSION}/database/mysql/schema.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/${ZABBIX_VERSION}/database/mysql/images.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/${ZABBIX_VERSION}/database/mysql/data.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "grant all on zabbix.* to '${ZABBIX_USER}'@'%';"
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "FLUSH   PRIVILEGES; "
}

# load_sql
install_zabbix_server
