#!/bin/bash
# reference https://www.cnblogs.com/hukey/p/11512062.html


mongodb_host=192.168.1.243
mongodb_port=27017

backup_dir='/data/backup/mongodb/full'
 
echo -e "\033[31;1m*****[ Mongodb ] 全库恢复脚本*****\033[0m"

echo -e "\033[32;1m[ 选择要恢复全库的日期 ] \033[0m"
for backfile in `ls $backup_dir`; do
    echo $backfile
done
 
read -p ">>>" date_bak
 
if [[ $date_bak == "" ]] || [[ $date_bak == '.' ]] || [[ $date_bak == '..' ]]; then
    echo -e "\033[31;1m输入不能为特殊字符.\033[0m"
    exit 1
fi
 
 
if [ -d $backup_dir/$date_bak ];then
    read -p "请确认是否恢复全库备份[y/n]:" choice
 
    if [ "$choice" == "y" ];then
        echo -e "\033[32;1m正在恢复全库备份，请稍后...\033[0m"
        /data/service/mongodb-database-tools/bin/mongorestore --host ${mongodb_host} --port ${mongodb_port} --oplogReplay --gzip $backup_dir/$date_bak/
        if [ $? -eq 0 ];then
            echo -e "\033[32;1m--------全库恢复成功.--------\033[0m"
        else
            echo -e "\033[31;1m恢复失败,请手动检查!\033[0m"
            exit 3
        fi
    else
        exit 2
    fi
else
    echo "\033[31;1m输入信息错误.\033[0m"
    exit 1
fi
