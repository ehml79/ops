#!/bin/bash


rsync_user=backup
rsync_passwd=
rsync_hosts_allow=


function rsync_send(){

    if [ -f /etc/os-release ];then
        echo 'ubuntu'
        apt -y install rsync
    elif [ -f /etc/redhat-release ];then
        echo 'centOS'
        yum -y install rsync
    else
        echo 'unknow OS'
        exit 1
    fi


    
    mkdir -p /etc/rsyncd
    
    echo "${rsync_user}:${rsync_passwd}" > /etc/rsyncd/rsyncd.secrets
    chmod 600 /etc/rsyncd/rsyncd.secrets
    
cat >  /etc/rsyncd/rsyncd.conf << EOF
uid = root
gid = root
use chroot = no
max connections = 200
strict modes = yes
ignore errors
read only = no
write only = no
hosts allow = ${rsync_hosts_allow}
hosts deny = *
list = false
auth users = backup
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
secrets file = /etc/rsyncd/rsyncd.secrets

[backup]
path = /data/backup
comment = backup file
EOF
    
    # 启动
    
    rsync --daemon --config=/etc/rsyncd/rsyncd.conf
}

rsync_send
