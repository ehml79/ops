#!/bin/bash

# 磁盘分区
function ubuntu_disk_partition(){
	echo -e "${RED}开始分区...${END}"

	echo "n
	p



	w
	" | fdisk /dev/vdb
	mkfs.ext4 /dev/vdb1
	cp /etc/fstab /etc/fstab.$(date +%F)
	mkdir /data
	echo '/dev/vdb1 /data ext4 barrier=0 0 0' >> /etc/fstab
	mount /dev/vdb1 /data/
    rmdir /data/lost+found/
}


function centos_disk_partition(){
    echo -e "${RED}开始分区...${END}"
    
    echo "n
    p
    1 
    
    
    w
    " | fdisk /dev/vdb
    mkfs.ext4 /dev/vdb1
    cp /etc/fstab /etc/fstab.$(date +%F)
    mkdir /data
    echo '/dev/vdb1 /data ext4 defaults 0 0' >> /etc/fstab
    mount /dev/vdb1 /data/
    rmdir /data/lost+found/
}



# 判断系统
if [ -f /usr/bin/apt ];then
    echo 'ubuntu'
    ubuntu_disk_partition
elif [ -f /usr/bin/yum ];then
    echo 'centOS'
    centos_disk_partition
else
    echo 'unknow OS'
    exit 1
fi
