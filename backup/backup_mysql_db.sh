#!/bin/bash

# vars
# 备份mysql数据脚本

start_ctime=$(date +%s)
date=$(date +%F)
ctime=$(date +%H-%M-%S)
backup_database_dir=/data/backup/database
backup_dir=${backup_database_dir}/${date}/${ctime}
backup_log=/data/logs/backup_mysql_db.log
mycnf="--defaults-extra-file=/etc/my.cnf"
umysqldump="/data/service/mysql/bin/mysqldump"
umysql="/data/service/mysql/bin/mysql"
keep_day=7

# 减锁，执行脚本
chattr -R -i ${backup_database_dir}

# 建立备份目录
if [ ! -e ${backup_dir} ];then
    mkdir -p ${backup_dir}
fi

# 建立备份日志目录
if [ ! -e /data/backup/log ];then
    mkdir -p /data/backup/log
fi

# 删除旧备份
function clean_backup(){
    find ${backup_database_dir} -mtime +${keep_day} -exec rm -fr {} \;
}

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
# 压缩备份
function compress(){
    cd ${backup_database_dir}/${date}
    tar -czf ${ctime}.tar.gz ${ctime}
    # 数据大小
    backup_size=$(du -sh ${ctime} | awk '{print $1}')
    tar_size=$(du -sh ${ctime}.tar.gz | awk '{print $1}')
    rm -fr ${ctime}
}


echo "$(date '+%F %T %s') ${0} ${@} 清理旧备份" >> $backup_log
clean_backup
echo "$(date '+%F %T %s') ${0} ${@} 开始备份" >> $backup_log
mysqlbackup
compress
end_ctime=$(date +%s)
echo "$(date '+%F %T %s') ${0} ${@} 备份结束 脚本用时:$((${end_ctime}-${start_ctime}))s 数据:${backup_size} 压缩后:${tar_size}" >> $backup_log

# 加锁,防误删
chattr -R +i  ${backup_database_dir}
