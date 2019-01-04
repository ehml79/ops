#!/bin/bash



function install_redis(){
    # 判断系统
    if [ -f /etc/os-release ];then
        apt -y install make  build-essential libjemalloc-dev
    elif [ -f /etc/redhat-release ];then
	    yum -y install  gcc gcc-c++
    else
	    echo 'unknow OS'
	    exit 1
    fi

    mkdir -p /data/service/src/
    wget http://download.redis.io/releases/redis-5.0.0.tar.gz  -P /data/service/src/
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
    sed -i 's/^requirepass.*/requirepass yourpassword/' /data/service/redis/etc/redis.conf

    # 启动redis
    /data/service/redis/bin/redis-server /data/service/redis/etc/redis.conf
    
    
    echo "/data/service/redis/bin/redis-server /data/service/redis/etc/redis.conf" > /root/redis_start.sh
    echo "/data/service/redis/bin/redis-cli shutdown" > /root/redis_stop.sh
    
    export PATH="$PATH:/data/service/redis/bin/"



}



install_redis
