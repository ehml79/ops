#!/bin/bash


rsync_user=rsync
rsync_passwd=
rsync_hosts_allow=


function rsync_send(){

    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        apt -y install rsync
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        yum -y install rsync
    else
        echo 'unknow OS'
        exit 1
    fi


    
    mkdir -p /etc/rsyncd
    mkdir -p /data/logs/rsync
    
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
auth users = rsync
pid file = /data/logs/rsync/rsyncd.pid
lock file = /data/logs/rsync/rsync.lock
log file = /data/logs/rsync/rsyncd.log
secrets file = /etc/rsyncd/rsyncd.secrets

[backup]
path = /data/backup
comment = backup file

[web]
path = /data/web
comment = web
EOF


cat > /root/rsyncd_restart.sh <<EOF
#!/bin/bash
pid_file=/var/run/rsyncd.pid
rsync_daemon='rsync --daemon --config=/etc/rsyncd/rsyncd.conf'

if [ -f \${pid_file} ];then
    kill \`cat \${pid_file}\`
    sleep 1
    \${rsync_daemon}
else
    \${rsync_daemon}
fi
EOF

    
    # 启动
    rsync --daemon --config=/etc/rsyncd/rsyncd.conf
}

rsync_send
