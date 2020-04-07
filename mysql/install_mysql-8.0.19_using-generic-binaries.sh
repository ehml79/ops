#!/bin/bash

function install_mysql(){

    mysql_version="mysql-8.0.19"
    mysql_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`
    mysql_port=3306

    sudo apt -y install make cmake gcc g++ bison libncurses5-dev build-essential libssl-dev  libaio1
    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    
    mkdir -p /data/service/src/
    
    wget -O /data/service/src/${mysql_version}-linux-glibc2.12-x86_64.tar.xz  https://dev.mysql.com/get/Downloads/MySQL-8.0/${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    
    
    cd /data/service/src
    tar xf ${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    mv /data/service/src/${mysql_version}-linux-glibc2.12-x86_64 /data/service/mysql


cat > /etc/my.cnf <<EOF
#
[client]
user = root
host=localhost
port = ${mysql_port}
socket = /tmp/mysql.sock


[mysqld]
port    = ${mysql_port}
mysqlx_port = 33060
socket  = /tmp/mysql.sock
mysqlx_socket=/tmp/mysqlx.sock
basedir = /data/service/mysql
datadir = /data/service/mysql/data
user    = mysql
# 默认就好
#log-error = /data/service/mysql/data/iZuf60n322uwbuisp4kf48Z.err
# 默认就好
#pid-file = /data/mysql/mysql.pid
#skip-grant-tables
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
open_files_limit = 65535
back_log = 600
max_connections = 65535
max_connect_errors = 6000
#table_cache = 614
external-locking = FALSE
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
#thread_concurrency = 8
#default-storage-engine = innodb
thread_stack = 192K
transaction_isolation = READ-COMMITTED
tmp_table_size = 246M
max_heap_table_size = 246M
long_query_time = 3
log-slave-updates
#log-bin = /data/service/mysql/data/binlog


log-bin = mysql-bin
binlog_format = MIXED
#binlog_cache_size = 4M
#max_binlog_cache_size = 8M
#max_binlog_size = 1G
key_buffer_size = 256M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
#myisam_recover

server-id = 1
interactive_timeout = 2880000
wait_timeout = 2880000

skip-name-resolve
#master-connect-retry = 10
skip-external-locking
table_open_cache = 64
key_buffer_size = 16M
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
tmp_table_size = 16M
performance_schema_max_table_instances = 500
explicit_defaults_for_timestamp = true
#skip-networking
early-plugin-load = ""

# replicate
replicate-ignore-db = mysql
replicate-ignore-db = test
replicate-ignore-db = information_schema
slave-skip-errors = 1032,1062,126,1114,1146,1048,1396

#master-host     =   192.168.1.2
#master-user     =   username
#master-password =   password
#master-port     =  ${mysql_port}

#relay-log-index = /data/mysql/relaylog
#relay-log-info-file = /data/mysql/relaylog
#relay-log = /data/mysql/relaylog

default_storage_engine = InnoDB
#innodb_additional_mem_pool_size = 16M
#innodb_buffer_pool_size = 512M
innodb_buffer_pool_size = 2G
innodb_log_file_size = 128M
innodb_lock_wait_timeout = 120
innodb_file_per_table = 1
innodb_log_buffer_size = 16M
innodb_data_file_path = ibdata1:256M:autoextend
innodb_flush_log_at_trx_commit = 2
innodb_log_files_in_group = 3
#innodb_file_io_threads = 4
innodb_thread_concurrency = 8
innodb_max_dirty_pages_pct = 90

innodb_data_home_dir = /data/service/mysql/data
innodb_log_group_home_dir = /data/service/mysql/data

slow_query_log = ON
#log-slow-queries = /data/service/mysql/slow.log
long_query_time = 1

[mysql]
prompt="MySQL [\d]> "
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

[mysqldump]
quick
max_allowed_packet = 32M

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

