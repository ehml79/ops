#!/bin/bash


apt -y install rsync
mkdir -p  /etc/rsyncd/
echo "rsync_password" >  /etc/rsyncd/rsyncd.pass
chmod 600  /etc/rsyncd/rsyncd.pass


