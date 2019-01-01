#!/bin/bash



pid_file=/var/run/rsyncd.pid
rsync_daemon='rsync --daemon --config=/etc/rsyncd/rsyncd.conf'


if [ -f ${pid_file} ];then
    kill `cat ${pid_file}`
    sleep 1
    ${rsync_daemon}
else
    ${rsync_daemon}
fi
