#!/bin/bash

# 安装 mysql 5.7.23

function install_mysql(){

    # 检查有没有mysql存在
    if [ -S /tmp/mysql.sock -o -S /var/lib/mysql/mysql.sock ];then
    	echo "mysql exisit ,exit "
    	exit 1
    fi
    
    # 判断系统
    if [ -f /etc/os-release ];then
    	echo 'ubuntu'
    	sudo apt update &&
    	sudo apt-get -y install make cmake gcc g++ bison libncurses5-dev build-essential
    elif [ -f /etc/redhat-release ];then
    	echo 'centOS'
    	yum -y install gcc gcc-c++  ncurses-devel bison libgcrypt perl  cmake
    else
    	echo 'unknow OS'
    	exit 1
    fi

    # 创建文件夹
    if [ ! -f /data/service/src ];then
    	mkdir -p /data/service/src/ 
    fi

    # 创建mysql密码文件
    if [ ! -f /data/.secret/mysql.pass ];then
    	mysql_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`
	mkdir  -p /data/.secret/
    	echo ${mysql_passwd} > /data/.secret/mysql.pass
        chmod 600 /data/.secret/mysql.pass
    fi
    
    # 创建my.cnf 备份用
    if [ ! -f /data/.secert/my.cnf ];then
       echo "[client]" > /data/.secret/my.cnf
       echo "user = root" >> /data/.secret/my.cnf
       echo "host = localhost" >> /data/.secret/my.cnf
       echo "password = ${mysql_passwd}" >> /data/.secret/my.cnf
    fi

    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    
    # 下载包好慢，建议提前下载好
    wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.23.tar.gz -P /data/service/src/
    wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz -P  /data/service/src/
    
    cd /data/service/src/  && tar -xf mysql-5.7.23.tar.gz 
    cd mysql-5.7.23
    mkdir bld
    cd bld
    
    cmake .. -DCMAKE_INSTALL_PREFIX=/data/service/mysql \
    -DDOWNLOAD_BOOST=0  \
    -DWITH_BOOST=/data/service/src/
    
    make -j $( grep processor /proc/cpuinfo | wc -l) && make install
    
    cd /data/service/mysql/
    
    cat > /etc/my.cnf << EOF
#
[client]
password = ${mysql_passwd}
port    = 3306
socket  = /tmp/mysql.sock

[mysqld]
port    = 3306
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
socket  = /tmp/mysql.sock
basedir = /data/service/mysql
datadir = /data/service/mysql/data
character-set-server = utf8
user    = mysql
# 默认就好
#log-error = /data/service/mysql/data/iZuf60n322uwbuisp4kf48Z.err
# 默认就好
#pid-file = /data/mysql/mysql.pid
#skip-grant-tables
open_files_limit = 65535
back_log = 600
max_connections = 65535
max_connect_errors = 6000
#table_cache = 614
external-locking = FALSE
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 300
#thread_concurrency = 8
query_cache_size = 512M
query_cache_limit = 2M
query_cache_min_res_unit = 2k
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
expire_logs_days = 30
key_buffer_size = 256M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
#myisam_recover

server-id = 1
interactive_timeout = 120
wait_timeout = 120

skip-name-resolve
#master-connect-retry = 10
skip-external-locking
max_allowed_packet = 1M
table_open_cache = 64
key_buffer_size = 16M
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
performance_schema_max_table_instances = 500
explicit_defaults_for_timestamp = true
#skip-networking
expire_logs_days = 10
early-plugin-load = ""

# replicate
replicate-ignore-db = mysql
replicate-ignore-db = test
replicate-ignore-db = information_schema
slave-skip-errors = 1032,1062,126,1114,1146,1048,1396

#master-host     =   192.168.1.2
#master-user     =   username
#master-password =   password
#master-port     =  3306

#relay-log-index = /data/mysql/relaylog
#relay-log-info-file = /data/mysql/relaylog
#relay-log = /data/mysql/relaylog

default_storage_engine = InnoDB
#innodb_additional_mem_pool_size = 16M
innodb_buffer_pool_size = 512M
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


#log-slow-queries = /data/service/mysql/slow.log
#long_query_time = 10

[mysql]
prompt=(\\u@\\h) [\\d]>\\_
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

    # 有密码的mysql
    # bin/mysqld   --defaults-file=/etc/my.cnf \
    # --user=mysql   \
    # --basedir=/data/service/mysql/ \
    # --datadir=/data/service/mysql/data/   \
    # --initialize

    chmod 600 /etc/my.cnf
    chown mysql.mysql /data/service/mysql/data/ 
	
    # 没有密码的mysql
    bin/mysqld --initialize-insecure --user=mysql --basedir=/data/service/mysql/  --datadir=/data/service/mysql/data/ 
    bin/mysql_ssl_rsa_setup  
    bin/mysqld_safe   --defaults-file=/etc/my.cnf --user=mysql  & 

    
    cp support-files/mysql.server /etc/init.d/mysql.server
    systemctl enable mysql.server
    /etc/init.d/mysql.server stop
    /etc/init.d/mysql.server start

    echo 'export PATH=$PATH:/data/service/mysql/bin' >> /etc/profile
    export PATH=$PATH:/data/service/mysql/bin

# 修改密码始终不成功
#    /data/service/mysql/bin/mysql -uroot -e "update user set password=password('${mysql_passwd}') where user='root' ; flush privileges; "
    /data/service/mysql/bin/mysql -uroot -p${mysql_passwd} <<EOF
update mysql.user set authentication_string=password('${mysql_passwd}') where user="root";
FLUSH PRIVILEGES;
EOF

}


install_mysql
