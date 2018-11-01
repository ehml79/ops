#!/bin/bash


apt -y install rsync
mkdir -p /etc/rsyncd
touch /etc/rsyncd/{rsyncd.conf,rsyncd.motd,rsyncd.secrets}

echo "backup:rsync_password"  /etc/rsyncd/rsyncd.secrets
chmod 600 /etc/rsyncd/rsyncd.secrets

cat > cat /etc/rsyncd/rsyncd.conf << EOF
uid = nobody
gid = nobody
use chroot = no
max connections = 10
strict modes = yes
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log

[backup]
path = /data/backup
comment = backup file
ignore errors
read only = no
write only = no
hosts allow = 192.168.172.128
hosts deny = *
list = false
uid = root
gid = root
auth users = backup
secrets file = /etc/rsyncd/rsyncd.secrets
EOF

# 启动

rsync --daemon --config=/etc/rsyncd/rsyncd.conf
