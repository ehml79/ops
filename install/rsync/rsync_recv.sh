#!/bin/bash


apt -y install rsync
mkdir -p  /etc/rsyncd/
echo "uRHultBQJFPBmkdP" >  /etc/rsyncd/rsyncd.pass
chmod 600  /etc/rsyncd/rsyncd.pass


echo "rsync -vzrtopg --delete --progress --password-file=/etc/rsyncd/rsyncd.pass  --exclude "*access*" --exclude "debug" backup@192.168.172.129::backup  /data/backup/192.168.172.129"  > /data/sh/backup/rsync.sh
