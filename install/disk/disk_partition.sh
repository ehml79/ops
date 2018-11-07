#!/bin/bash

# 磁盘分区
function ubuntu_disk_partition(){
	echo -e "${RED}开始分区...${END}"

	echo "n
	p



	w
	" | fdisk /dev/vdb
	mkfs.ext4 /dev/vdb1
	cp /etc/fstab /etc/fstab.bak
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
    cp /etc/fstab /etc/fstab.bak
    mkdir /data
    echo '/dev/vdb1 /data ext3 defaults 0 0' >> /etc/fstab
    mount /dev/vdb1 /data/
    rmdir /data/lost+found/
}



# 判断系统
if [ -f /etc/os-release ];then
    echo 'ubuntu'
    ubuntu_disk_partition
elif [ -f /etc/redhat-release ];then
    echo 'centOS'
    centos_disk_partition
else
    echo 'unknow OS'
    exit 1
fi
