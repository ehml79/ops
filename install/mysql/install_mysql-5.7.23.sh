#!/bin/bash

# 安装 mysql 5.7.23

function install_mysql(){

    # 创建mysql密码文件
    if [ ! -f /data/.secret/mysql_root ];then
    	mysql_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`
	mkdir  -p /data/.secret/
    	echo ${mysql_passwd} > /data/.secret/mysql_root
        chmod 600 /data/.secret/mysql_root
    fi
    
    # 检查有没有mysql存在
    if [ -S /tmp/mysql.sock -o -S /var/lib/mysql/mysql.sock ];then
    	echo "mysql exisit ,exit "
    	exit 1
    fi
    
    if [ ! -f /data/service/src ];then
    	mkdir -p /data/service/src/ 
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
    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    
    # 下载包好慢，建议提前下载好
#    wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.23.tar.gz -P /data/service/src/
#    wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz -P  /data/service/src/
    
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

[client]
password   = ${mysql_passwd}
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
port        = 3306
socket      = /tmp/mysql.sock
datadir = /data/service/mysql/data/
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
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
max_connections = 65535
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
early-plugin-load = ""

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_data_home_dir = /data/service/mysql/data
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /data/service/mysql/data
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

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
SET PASSWORD = PASSWORD('${mysql_passwd}');
grant all privileges on *.* to root@'%' identified by '${mysql_passwd}';
EOF

}


install_mysql
