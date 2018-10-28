#!/bin/bash

# vars
# 备份mysql数据脚本

date=$(date +%F)
time=$(date +%H-%M-%S)
backup_dir=/data/backup/database/${date}/${time}
backup_log=/data/backup/log/backup_mysql_db.log
mycnf="--defaults-extra-file=/data/service/mysql/my57.cnf"
umysqldump="/data/service/mysql/bin/mysqldump"
umysql="/data/service/mysql/bin/mysql"


# 建立备份目录
if [ ! -e ${backup_dir} ];then
    mkdir -p ${backup_dir}
fi

# 删除以前备份

# 备份 
function mysqlbackup(){
${umysql} ${mycnf}  -uroot  -A -N  -e  "show databases" | while read line
    do
        # 排除不需要备份的表
        db_names=$(echo $line | grep -v Database | grep -v information_schema | grep -v performance_schema | grep -v sys | grep -v mysql  )
        for db_name in  ${db_names}
        do
            #echo ${db_name}
            # 备份所有数据
            ${umysqldump}  ${mycnf}  -uroot  --opt --single-transaction   --databases ${db_name}  > ${backup_dir}/${db_name}.sql
            # 备份所有表结构
            ${umysqldump}  ${mycnf}  -uroot  --opt --single-transaction   --databases -d ${db_name}  > ${backup_dir}/${db_name}_struc.sql
            # 备份单表
            mkdir -p ${backup_dir}/${db_name}
            ${umysql} ${mycnf}   -uroot  -A -N  -e  "use ${db_name}; show tables" | while read line
            do
                table_name=$(echo $line )
                #echo ${table_name}
                ${umysqldump}  ${mycnf}  -uroot  --opt --single-transaction    ${db_name} ${table_name}  > ${backup_dir}/${db_name}/${table_name}.sql
            done
    
        done
    done
}

function compress(){
    cd /data/backup/database/${date}
    tar -czf ${time}.tar.gz ${time}
    rm -fr ${time}
}


echo "$(date '+%F %T %s') 开始备份" >> $backup_log
mysqlbackup
compress
echo "$(date '+%F %T %s') 备份结束" >> $backup_log
