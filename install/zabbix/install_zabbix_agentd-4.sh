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
Include=/data/service/zabbix/etc/zabbix_agentd.conf.d/*.conf
EOF

mkdir -p /data/.secret/
cat > /data/.secret/zabbix-my.cnf <<EOF
[client]
host=localhost
user='root'
password='password'
EOF

    chmod 600 /data/.secret/zabbix-my.cnf 
    chown zabbix.zabbix /data/.secret/zabbix-my.cnf 

cat > /data/service/zabbix/etc/zabbix_agentd.conf.d/userparameter_mysql.conf <<EOF
UserParameter=mysql.ping,HOME=/data/service/mysql/bin/mysqladmin ping 2>/dev/null | grep -c alive
UserParameter=mysql.status[*],/data/service/zabbix/share/zabbix/externalscripts/check_mysql \$1
UserParameter=mysql.version,/data/service/mysql/bin/mysql -V
EOF

mkdir -p /data/service/zabbix/share/zabbix/externalscripts/
cat > /data/service/zabbix/share/zabbix/externalscripts/check_mysql << EOF
#!/bin/bash
# 主机地址/IP
MYSQL_HOST='localhost'
# 端口
MYSQL_PORT='3306'
# 数据连接
MYSQL_CONN="/data/service/mysql/bin/mysqladmin --defaults-file=/data/.secret/zabbix-my.cnf"

# 参数是否正确
if [ \$# -ne "1" ];then
    echo "arg error!"
fi

# 获取数据
case \$1 in
    Uptime)
        result=`\${MYSQL_CONN} status|cut -f2 -d":"|cut -f1 -d"T"`
        echo \$result
        ;;
    Com_update)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_update"|cut -d"|" -f3`
        echo \$result
        ;;
    Slow_queries)
        result=`\${MYSQL_CONN} status |cut -f5 -d":"|cut -f1 -d"O"`
        echo \$result
        ;;
    Com_select)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_select"|cut -d"|" -f3`
        echo \$result
                ;;
    Com_rollback)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_rollback"|cut -d"|" -f3`
                echo \$result
                ;;
    Questions)
        result=`\${MYSQL_CONN} status|cut -f4 -d":"|cut -f1 -d"S"`
                echo \$result
                ;;
    Com_insert)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_insert"|cut -d"|" -f3`
                echo \$result
                ;;
    Com_delete)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_delete"|cut -d"|" -f3`
                echo \$result
                ;;
    Com_commit)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_commit"|cut -d"|" -f3`
                echo \$result
                ;;
    Bytes_sent)
        result=`\${MYSQL_CONN} extended-status |grep -w "Bytes_sent" |cut -d"|" -f3`
                echo \$result
                ;;
    Bytes_received)
        result=`\${MYSQL_CONN} extended-status |grep -w "Bytes_received" |cut -d"|" -f3`
                echo \$result
                ;;
    Com_begin)
        result=`\${MYSQL_CONN} extended-status |grep -w "Com_begin"|cut -d"|" -f3`
                echo \$result
                ;;

        *)
        echo "Usage:\$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|C
om_begin)"
        ;;
esac
EOF

    chown zabbix.zabbix  /data/service/zabbix/share/zabbix/externalscripts/check_mysql 
    chmod +x  /data/service/zabbix/share/zabbix/externalscripts/check_mysql 

    if [ -f /etc/os-release ];then
        # ubuntu
        cp /data/service/src/zabbix-4.0.0/misc/init.d/debian/zabbix-agent /etc/init.d/
        chmod +x /etc/init.d/zabbix-agent
        sed -i "s#/usr/local#/data/service/zabbix/#g" /etc/init.d/zabbix_agent
        /etc/init.d/zabbix_agent restart
    else [ -f /etc/redhat-release ];then
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
