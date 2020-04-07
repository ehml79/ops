#!/bin/bash

function install_mysql(){

    mysql_version="mysql-8.0.12"
    mysql_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`

    sudo apt -y install make cmake gcc g++ bison libncurses5-dev build-essential libssl-dev  libaio1
    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    
    mkdir -p /data/service/src/
    
    wget -O /data/service/src/${mysql_version}-linux-glibc2.12-x86_64.tar.xz  https://dev.mysql.com/get/Downloads/MySQL-8.0/${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    
    
    cd /data/service/src
    tar xf ${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    mv /data/service/src/${mysql_version}-linux-glibc2.12-x86_64 /data/service/mysql


cat > /etc/my.cnf <<EOF
[client]
user = root
port = 3306
socket = /tmp/mysql.sock
#default-character-set=utf8

[mysql]
#default-character-set=utf8

[mysqld]
socket = /tmp/mysql.sock
port=3306
mysqlx_port = 33060
mysqlx_socket=/tmp/mysqlx.sock
default_authentication_plugin=mysql_native_password
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
basedir = /data/service/mysql
datadir = /data/service/mysql/data
character-set-server=utf8
#default-storage-engine=MyIsam
max_connections=100
collation-server=utf8_unicode_ci
init_connect='SET NAMES utf8'
innodb_buffer_pool_size=64M
innodb_flush_log_at_trx_commit=1
innodb_lock_wait_timeout=120
innodb_log_buffer_size=4M
innodb_log_file_size=256M
interactive_timeout=2880000
join_buffer_size=2M
key_buffer_size=32M
log_error_verbosity=1
max_allowed_packet=16M
max_heap_table_size=64M
myisam_max_sort_file_size=64G
myisam_sort_buffer_size=32M
read_buffer_size=512kb
read_rnd_buffer_size=4M
server_id=1
skip-external-locking=on
sort_buffer_size=256kb
table_open_cache=256
thread_cache_size=16
tmp_table_size=64M
wait_timeout=120
EOF

    chmod 600 /etc/my.cnf

    cd /data/service/mysql
    bin/mysqld --initialize-insecure --user=mysql  \
    --basedir=/data/service/mysql \
    --datadir=/data/service/mysql/data/     \
    --log-bin
    
    bin/mysql_ssl_rsa_setup
    # bin/mysqld_safe --user=mysql &
    # killall mysqld
    
    
    cp support-files/mysql.server /etc/init.d/mysqld
    sed -i "s@^basedir=.*@basedir=/data/service/mysql@" /etc/init.d/mysqld
    sed -i "s@^datadir=.*@datadir=/data/service/mysql/data@" /etc/init.d/mysqld
    systemctl enable mysqld
    /etc/init.d/mysqld start
    
    export PATH=$PATH:/data/service/mysql/bin
    echo 'export PATH=$PATH:/data/service/mysql/bin' > /etc/profile.d/mysql.sh
    
    # 修改密码
    /data/service/mysql/bin/mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_passwd}';"
    # /data/service/mysql/bin/mysql -uroot -e "update mysql.user set authentication_string=password('${mysql_passwd}') where user='root' ; flush privileges; "
    sed -i "/\[client\]/apassword = ${mysql_passwd}"  /etc/my.cnf

}


function config_sshd(){

    # navicat SSH 连接时提示
    # does not support diffie-hellman-group1-sha1
    # for keyexchange 或 The negotiation of encryption
    # algorithm is failed的解决方法

cat >> /etc/ssh/sshd_config <<EOF
KexAlgorithms diffie-hellman-group1-sha1,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1
Ciphers 3des-cbc,blowfish-cbc,aes128-cbc,aes128-ctr,aes256-ctr
EOF

    /usr/bin/ssh-keygen -A

    /usr/sbin/service ssh restart


}

install_mysql

# config_sshd

