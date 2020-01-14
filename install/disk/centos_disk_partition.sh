#!/bin/bash
# 阿里云ECS 磁盘分区

function centos_disk_partition(){
    echo -e "${RED}开始分区...${END}"
    
    echo "n
    p
    1 
    
    
    w
    " | fdisk /dev/vdb
    partx /dev/vdb
    mkfs.ext4 /dev/vdb1
    cp /etc/fstab /etc/fstab.$(date +%F)
    mkdir /data
    echo '/dev/vdb1 /data ext4 defaults 0 0' >> /etc/fstab
    mount /dev/vdb1 /data/
    rmdir /data/lost+found/
}

centos_disk_partition
