#!/bin/bash

function install_mysql8012(){

    mysql_version="mysql-8.0.12"
    mysql_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`

    sudo apt -y install make cmake gcc g++ bison libncurses5-dev build-essential libssl-dev  libaio1
    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    
    mkdir -p /data/service/src/
    
    wget -O /data/service/src/${mysql_version}-linux-glibc2.12-x86_64.tar.xz  https://dev.mysql.com/get/Downloads/MySQL-8.0/${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    
    
    cd /data/service/src
    tar xf ${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    mv /data/service/src/${mysql_version}-linux-glibc2.12-x86_64 /data/service/mysql8012


cat > /etc/my8012.cnf <<EOF
[client]
password =  123456
user = root
port = 3307
socket = /tmp/mysql8012.sock
default-character-set=utf8

[mysql]
default-character-set=utf8

[mysqld]
socket = /tmp/mysql8012.sock
port=3307
mysqlx_port = 33070
mysqlx_socket=/tmp/mysqlx8012.sock
default_authentication_plugin=mysql_native_password
basedir = /data/service/mysql8012
datadir = /data/service/mysql8012/data
character-set-server=utf8
default-storage-engine=MyIsam
max_connections=100
collation-server=utf8_unicode_ci
init_connect='SET NAMES utf8'
innodb_buffer_pool_size=64M
innodb_flush_log_at_trx_commit=1
innodb_lock_wait_timeout=120
innodb_log_buffer_size=4M
innodb_log_file_size=256M
interactive_timeout=120
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

    chmod 600 /etc/my8012.cnf

    cd /data/service/mysql8012
    bin/mysqld --initialize-insecure --user=mysql  \
    --basedir=/data/service/mysql8012 \
    --datadir=/data/service/mysql8012/data/     \
    --log-bin
    
    # bin/mysqld_safe --user=mysql &
    # killall mysqld
    
    
    cp support-files/mysql.server /etc/init.d/mysql8012
    sed -i 's@/usr/local/mysql@/data/service/mysql8012@g' /etc/init.d/mysql8012
    systemctl enable mysql8012
    /etc/init.d/mysql8012 start
    
    export PATH=$PATH:/data/service/mysql8012/bin
    echo 'export PATH=$PATH:/data/service/mysql8012/bin' >> /etc/profile
    
    # 修改密码
    /data/service/mysql8012/bin/mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_passwd}';"
    # /data/service/mysql8012/bin/mysql -uroot -e "update mysql.user set authentication_string=password('${mysql_passwd}') where user='root' ; flush privileges; "
    sed -i "/\[client\]/apassword = ${mysql_passwd}"  /etc/my8012.cnf

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

install_mysql8012

# config_sshd


rm /root/$0
