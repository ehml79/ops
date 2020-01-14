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
    cp /data/service/zabbix/etc/zabbix_agentd.conf /data/service/zabbix/etc/zabbix_agentd.conf.$(date +%F)
    cp /data/service/zabbix/etc/zabbix_server.conf /data/service/zabbix/etc/zabbix_server.conf.$(date +%F)


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
AlertScriptsPath=/data/service/zabbix/share/zabbix/alertscripts
ExternalScripts=/data/service/zabbix/share/zabbix/externalscripts
LogSlowQueries=3000
StartProxyPollers=1
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




install_zabbix_server
