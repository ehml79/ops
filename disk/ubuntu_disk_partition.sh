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

ubuntu_disk_partition
