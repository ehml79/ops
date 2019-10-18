#!/bin/bash

# MySQL 5.7
# Ubuntu 18.04 (bionic)

if [ -f ${1} ];then
    echo Error : bash ${0} RDS_BACKUP_FILE.tar.gz
    exit 0
fi



TEMP_DIR=/data/temp

mkdir -p ${TEMP_DIR}

# 判断系统
if [ -f /usr/bin/apt ];then
    echo 'ubuntu'
    sudo apt update &&
    sudo dpkg -i https://www.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.15/binary/debian/bionic/x86_64/percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb
elif [ -f /usr/bin/yum ];then
    echo 'centOS'
    yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    yum -y install percona-xtrabackup-24
else
    echo 'unknow OS'
    exit 1
fi

tar xf ${1} -C ${TEMP_DIR}/

# 恢复
innobackupex --defaults-file=${TEMP_DIR}/backup-my.cnf --apply-log ${TEMP_DIR} 

sed -i '/innodb_log_checksum_algorithm/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/innodb_fast_checksum/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/innodb_log_block_size/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/innodb_doublewrite_file/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/rds_encrypt_data/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/innodb_encrypt_algorithm/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/redo_log_version/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/master_key_id/d' ${TEMP_DIR}/backup-my.cnf
sed -i '/server_uuid/d' ${TEMP_DIR}/backup-my.cnf
echo "skip-grant-tables" >> ${TEMP_DIR}/backup-my.cnf 

chown -R mysql:mysql  ${TEMP_DIR}

/etc/init.d/mysql.server stop

/data/service/mysql/bin/mysqld_safe --defaults-file=${TEMP_DIR}/backup-my.cnf --user=mysql --datadir=${TEMP_DIR} &

# 导出sql
EACH_DATABASE=$(mysql -e "show databases" | grep -v Database | grep -v information_schema | grep -v mysql | grep -v performance_schema | grep -v sys)
for DB_NAME in ${EACH_DATABASE} 
do
    /data/service/mysql/bin/mysqldump ${DB_NAME} > /root/${DB_NAME}.sql
done
