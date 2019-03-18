#!/bin/bash


zabbix_server_ip=127.0.0.1
zabbix_db_password=password

function install_zabbix_server_4(){

    # 判断系统
    if [ -f /etc/os-release ];then
        echo 'ubuntu'
        apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential libsnmp-dev libevent-dev
    elif [ -f /etc/redhat-release ];then
        echo 'centOS'
        yum -y install git pcre-devel openssl-devel  net-snmp-devel libevent-devel 
    else
        echo 'unknow OS'
        exit 1
    fi

    groupadd zabbix
    useradd -g zabbix zabbix
    mkdir -p /data/service/src/ 
    wget https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.0.0/zabbix-4.0.0.tar.gz -P /data/service/src
    
    cd /data/service/src
    tar xf zabbix-4.0.0.tar.gz
    cd zabbix-4.0.0
    ./configure --prefix=/data/service/zabbix  \
    --enable-server --enable-agent \
    --with-mysql=/data/service/mysql/bin/mysql_config \
    -enable-ipv6 \
    --with-net-snmp --with-libcurl \
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

cat > /data/service/zabbix/etc/zabbix_agentd.conf.d/userparameter_mysql.conf <<EOF
UserParameter=mysql.ping,HOME=/data/service/mysql/bin/mysqladmin ping 2>/dev/null | grep -c alive
UserParameter=mysql.status[*],/data/service/zabbix/share/zabbix/externalscripts/check_mysql \$1
UserParameter=mysql.version,/data/service/mysql/bin/mysql -V
EOF

cat > /data/service/zabbix/etc/zabbix_server.conf <<EOF
DBHost=${zabbix_server_ip}
DBName=zabbix
DBUser=zabbix
DBPassword=${zabbix_db_password} 
DBSocket=/tmp/mysql.sock
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
AlertScriptsPath=/etc/zabbix/alertscripts      
ExternalScripts=/etc/zabbix/externalscripts    
LogSlowQueries=10000
StartProxyPollers=50
LogFile=/tmp/zabbix_server.log
EOF


    # 判断系统
    if [ -f /etc/os-release ];then
        echo 'ubuntu'
        # ubuntu
	cp /data/service/src/zabbix-4.0.0/misc/init.d/debian/zabbix-agent /etc/init.d/
	cp /data/service/src/zabbix-4.0.0/misc/init.d/debian/zabbix-server /etc/init.d/
	sed -i "s#DAEMON=.*#DAEMON=/data/service/zabbix/sbin/\${NAME}#g" /etc/init.d/zabbix-server
	sed -i "s#DAEMON=.*#DAEMON=/data/service/zabbix/sbin/\${NAME}#g" /etc/init.d/zabbix-agent
    elif [ -f /etc/redhat-release ];then
        echo 'centOS'
	# centos
	cp /data/service/src/zabbix-4.0.0/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
	cp /data/service/src/zabbix-4.0.0/misc/init.d/fedora/core/zabbix_server /etc/init.d/
	sed -i "s#BASEDIR=/usr/local#BASEDIR=/data/service/zabbix/#g" /etc/init.d/zabbix_server
	sed -i "s#BASEDIR=/usr/local#BASEDIR=/data/service/zabbix/#g" /etc/init.d/zabbix_agentd
    else
        echo 'unknow OS'
        exit 1
    fi



    mkdir -p /data/web/zabbix
    cp -r /data/service/src/zabbix-4.0.0/frontends/php/* /data/web/zabbix/
    chown -R nginx:nginx /data/web/zabbix/
    
    echo "/data/service/mysql/lib/" >>  /etc/ld.so.conf
    ldconfig


    # 导入数据库
    cd /data/service/src/zabbix-4.0.0/database/mysql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "create database zabbix default charset utf8"
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/zabbix-4.0.0/database/mysql/schema.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/zabbix-4.0.0/database/mysql/images.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password zabbix < /data/service/src/zabbix-4.0.0/database/mysql/data.sql
    /data/service/mysql/bin/mysql  --defaults-file=/etc/my.cnf --connect-expired-password -e "grant all on zabbix.* to 'zabbix'@'localhost' identified by '${zabbix_db_password}';"


cat > /data/service/nginx/conf/vhost/zabbix.conf <<EOF
#
    server {
        listen       80;
        server_name  zabbix.example.com;

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
    sed -i 's@;date.timezone.*@date.timezone = Asia/Shanghai@'  /data/service/php/etc/php.ini

    /etc/init.d/php-fpm restart



}


install_zabbix_server_4
