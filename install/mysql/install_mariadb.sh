#!/bin/bash

mariadb_version=mariadb-10.4.7

function install_mariadb(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        sudo apt -y install   build-essential  cmake  gcc g++ bison libncurses5-dev build-essential libgnutls-dev
    
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        yum -y install install bison bison-devel zlib-devel libcurl-devel \
        libarchive-devel boost-devel gcc gcc-c++ cmake libevent-devel \
        gnutls-devel libaio-devel openssl-devel ncurses-devel libxml2-devel 
    
    else
        echo 'unknow OS'
        exit 1
    fi
    
    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    mkdir -p /data/service/src
    
    
    # 相当慢了....
    wget -O  /data/service/src/${mariadb_version}.tar.gz https://mirrors.tuna.tsinghua.edu.cn/mariadb//${mariadb_version}/source/${mariadb_version}.tar.gz 
    cd /data/service/src ; tar xf  ${mariadb_version}.tar.gz
    cd ${mariadb_version}/
    mkdir build-mariadb
    cd build-mariadb
    cmake .. -DCMAKE_INSTALL_PREFIX=/data/service/mariadb  \
    -DCMAKE-USER=mysql  \
    -DCMAKE-GROUP=mysql \
    -DMYSQL_DATADIR=/data/service/mysql \
    -DWITHOUT_TOKUDB=1
    
    make
    sudo make install
    
    
    chown -R mysql /data/service/mariadb/
    cd /data/service/mariadb/
    scripts/mysql_install_db --user=mysql
    /data/service/mariadb/bin/mysqld_safe --user=mysql &
    bin/mysqladmin -u root password '123456'
    
    cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = /data/service/mariadb
datadir = /data/service/mariadb/data
pid-file = /data/service/mariadb/data/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4

skip-name-resolve
#skip-networking
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 500M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7

log_error = /data/service/mariadb/data/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /data/service/mariadb/data/mysql-slow.log

performance_schema = 0

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 500M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF
    
    cp /data/service/mariadb/support-files/mysql.server /etc/init.d/
    systemctl enable mysql.server
    /etc/init.d/mysql.server start

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





install_mariadb

config_sshd
