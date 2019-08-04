#!/bin/bash

redis_passwd=""


function install_redis(){
    # 判断系统
    if [ -f /usr/bin/apt ];then
        apt -y install make  build-essential libjemalloc-dev
    elif [ -f /usr/bin/yum ];then
	    yum -y install  gcc gcc-c++
    else
	    echo 'unknow OS'
	    exit 1
    fi

    mkdir -p /data/service/src/
    wget -O /data/service/src/redis-5.0.0.tar.gz  http://download.redis.io/releases/redis-5.0.0.tar.gz 
    cd /data/service/src
    tar xf redis-5.0.0.tar.gz
    cd redis-5.0.0/
    make 
    make install PREFIX=/data/service/redis 
    mkdir /data/service/redis/etc
    cp /data/service/src/redis-5.0.0/redis.conf /data/service/redis/etc/
     
    sed -i 's/^daemonize.*/daemonize yes/' /data/service/redis/etc/redis.conf
    sed -i 's/^bind.*/bind 127.0.0.1/' /data/service/redis/etc/redis.conf

    # 设置密码
    if [ -n "${redis_passwd}" ];then
        sed -i "s/^# requirepass foobared.*/requirepass ${redis_passwd}/" /data/service/redis/etc/redis.conf
    fi

    # 启动redis
    /data/service/redis/bin/redis-server /data/service/redis/etc/redis.conf
    
    
    echo "/data/service/redis/bin/redis-server /data/service/redis/etc/redis.conf" > /root/redis_start.sh
    echo "/data/service/redis/bin/redis-cli -a ${redis_passwd} shutdown" > /root/redis_stop.sh
    
    echo 'export PATH="$PATH:/data/service/redis/bin/"' >>/etc/profile



}



install_redis
