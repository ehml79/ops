#！/bin/bash
# 阿里云ECS 磁盘分区

function disk_partition(){
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

disk_partition
