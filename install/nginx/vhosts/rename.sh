#!/bin/bash
# 批量更改域名

old_domain=old.com

new_domain=new.com

vhost_dir=/data/service/nginx/conf/vhost


for old in $(ls ${vhost_dir})
do
	pre=$(echo ${old} | awk -F. '{print $1}')
	mv ${vhost_dir}/${old} ${vhost_dir}/${pre}.${new_domain}.conf
	echo ${pre}.${new_domain}.conf
done



sed -i "s/${old_domain}/${new_domain}/g"   ${vhost_dir}/*
