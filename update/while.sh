#!/bin/bash

while true
do
	/bin/bash  /data/sh/update/rsync_update_scripts.sh
	echo `date '+%F %H:%M:%S'` >> /data/log/while.log
done
