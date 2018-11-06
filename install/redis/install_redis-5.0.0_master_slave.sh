#!/bin/bash

# redis 单机主从

function install_redis(){
    apt -y install make  build-essential libjemalloc-dev 
    mkdir -p /data/service/src/
    
#    wget http://download.redis.io/releases/redis-5.0.0.tar.gz  -P /data/service/src/
    cd /data/service/src
    tar xf redis-5.0.0.tar.gz
    cd redis-5.0.0/
    make 
    make install PREFIX=/data/service/redis 
    mkdir /data/service/redis/etc
    cp /data/service/src/redis-5.0.0/redis.conf /data/service/redis/etc/redis_6379.conf
    cp /data/service/src/redis-5.0.0/redis.conf /data/service/redis/etc/redis_6380.conf
     
    sed -i 's/^daemonize.*/daemonize yes/' /data/service/redis/etc/redis_6379.conf
    sed -i 's/^bind.*/bind 127.0.0.1/' /data/service/redis/etc/redis_6379.conf

    sed -i 's/^daemonize.*/daemonize yes/' /data/service/redis/etc/redis_6380.conf
    sed -i 's/^bind.*/bind 127.0.0.1/' /data/service/redis/etc/redis_6380.conf
    sed -i 's/^port.*/port 6380/' /data/service/redis/etc/redis_6380.conf
    # 有需要改成服务器IP
    sed -i '/pidfile/aslaveof 127.0.0.1 6379' /data/service/redis/etc/redis_6380.conf



    # 启动redis master
    /data/service/redis/bin/redis-server  /data/service/redis/etc/redis_6379.conf

    # 启动redis slave
    /data/service/redis/bin/redis-server  /data/service/redis/etc/redis_6380.conf 
    
    
    echo "/data/service/redis/bin/redis-server /data/service/redis/etc/redis_6379.conf" > /root/redis_master_start.sh
    echo "/data/service/redis/bin/redis-cli -p 6379 shutdown" > /root/redis_master_stop.sh

    echo "/data/service/redis/bin/redis-server /data/service/redis/etc/redis_6380.conf" > /root/redis_slave_start.sh
    echo "/data/service/redis/bin/redis-cli -p 6380 shutdown" > /root/redis_slave_stop.sh
    
    export PATH="$PATH:/data/service/redis/bin/"



}



install_redis
