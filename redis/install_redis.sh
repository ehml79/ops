#!/bin/bash

REDIS_VERSION="redis-5.0.8"
REDIS_PASSWD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`


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
    wget -O /data/service/src/${REDIS_VERSION}.tar.gz  http://download.redis.io/releases/${REDIS_VERSION}.tar.gz 
    cd /data/service/src
    tar xf ${REDIS_VERSION}.tar.gz
    cd ${REDIS_VERSION}/
    make 
    make install PREFIX=/data/service/redis 
    mkdir /data/service/redis/{etc,rdb}
    cp /data/service/src/${REDIS_VERSION}/redis.conf /data/service/redis/etc/
     
    sed -i 's/^daemonize.*/daemonize yes/' /data/service/redis/etc/redis.conf
    sed -i 's/^bind.*/bind 0.0.0.0/' /data/service/redis/etc/redis.conf
    sed -i 's@^dir.*@dir /data/service/redis/rdb@' /data/service/redis/etc/redis.conf


    # 设置密码
    if [ -n "${REDIS_PASSWD}" ];then
        sed -i "s/^# requirepass foobared.*/requirepass ${REDIS_PASSWD}/" /data/service/redis/etc/redis.conf
    fi

    # 启动redis
    /data/service/redis/bin/redis-server /data/service/redis/etc/redis.conf
    
    
    echo "/data/service/redis/bin/redis-server /data/service/redis/etc/redis.conf" > /root/redis_start.sh
    echo "/data/service/redis/bin/redis-cli -a ${REDIS_PASSWD} shutdown" > /root/redis_stop.sh
    
    echo 'export PATH="$PATH:/data/service/redis/bin/"' > /etc/profile.d/redis.sh



}



install_redis
