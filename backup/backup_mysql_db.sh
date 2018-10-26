#!/bin/bash

# vars
#export MYSQL_PWD=$(cat /data/save/mysql_root)
# 备份mysql数据脚本

date=$(date +%F)
time=$(date +%H-%M-%S)
backup_dir=/data/backup/database/${date}/${time}
backup_log=/data/backup/log/backup_mysql_db.log
echo "${date} ${time} 开始备份" >> $backup_log



# 建立备份目录
if [ ! -e ${backup_dir} ];then
    mkdir -p ${backup_dir}
fi
# 删除以前备份

# 备份 
/data/service/mysql/bin/mysql --defaults-extra-file=/data/service/mysql/my57.cnf   -uroot  -A -N  -e  "show databases" | while read line
do
    db_names=$(echo $line | grep -v Database | grep -v information_schema | grep -v performance_schema | grep -v sys | grep -v mysql  )
    for db_name in  ${db_names}
    do
        echo ${db_name}
        # 备份数据
        /data/service/mysql/bin/mysqldump  --defaults-extra-file=/data/service/mysql/my57.cnf  -uroot  --opt --single-transaction   --databases ${db_name}  > ${backup_dir}/${db_name}.sql
        # 备份表结构
        /data/service/mysql/bin/mysqldump  --defaults-extra-file=/data/service/mysql/my57.cnf  -uroot  --opt --single-transaction   --databases -d ${db_name}  > ${backup_dir}/${db_name}_struc.sql
        # 备份TXT
        #mkdir -p ${backup_dir}/${db_name}
        #/data/service/mysql/bin/mysqldump  --defaults-extra-file=/data/service/mysql/my57.cnf  -uroot  --opt --single-transaction   -T${backup_dir}/${db_name} ${db_name}
    done
done
echo "${date} ${time} 备份结束" >> $backup_log
