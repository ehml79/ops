#!/bin/bash

REDIS_VERSION="redis-5.0.8"
REDIS_PASSWD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`
REDIS_PORT=6379
SRC_DIR=/data/service/src
REDIS_CONFIG_FILE=/data/service/redis/etc/${REDIS_PORT}.conf
REDIS_DATA_DIR=/data/service/redis/data/${REDIS_PORT}

REDIS_LOG_FILE=/data/service/redis/logs/redis_${REDIS_PORT}.log
REDIS_EXECUTABLE=/data/service/redis/bin/redis-server
CLI_EXEC=/data/service/redis/bin/redis-cli


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

    mkdir -p ${SRC_DIR}/
    wget -O ${SRC_DIR}/${REDIS_VERSION}.tar.gz  http://download.redis.io/releases/${REDIS_VERSION}.tar.gz 
    cd ${SRC_DIR}
    tar xf ${REDIS_VERSION}.tar.gz
    cd ${REDIS_VERSION}/
    make 
    make install PREFIX=/data/service/redis 
    mkdir /data/service/redis/{etc,data,logs}
    mkdir ${REDIS_DATA_DIR}


    cp ${SRC_DIR}/${REDIS_VERSION}/redis.conf ${REDIS_CONFIG_FILE}
     
    sed -i "s#^port .\+#port ${REDIS_PORT}#" ${REDIS_CONFIG_FILE}
    sed -i "s#^logfile .\+#logfile ${REDIS_LOG_FILE}#" ${REDIS_CONFIG_FILE}
    sed -i "s@^dir.*@dir /data/service/redis/data/${REDIS_PORT}@" ${REDIS_CONFIG_FILE}
    sed -i "s#^pidfile .\+#pidfile /var/run/redis_${REDIS_PORT}.pid#" ${REDIS_CONFIG_FILE}
    sed -i 's/^daemonize.*/daemonize yes/' ${REDIS_CONFIG_FILE}
    sed -i 's/^bind.*/bind 0.0.0.0/' ${REDIS_CONFIG_FILE}


    # 设置密码
    if [ -n "${REDIS_PASSWD}" ];then
        sed -i "s/^# requirepass foobared.*/requirepass ${REDIS_PASSWD}/" ${REDIS_CONFIG_FILE}
    fi

    
    echo 'export PATH="$PATH:/data/service/redis/bin/"' > /etc/profile.d/redis.sh
    echo "export REDISCLI_AUTH=${REDIS_PASSWD}" >> /etc/profile.d/redis.sh

    mv redis_init_script /etc/init.d/redis_${REDIS_PORT}
    
    sed -i "s#^EXEC=.*#EXEC=${REDIS_EXECUTABLE}#" /etc/init.d/redis_${REDIS_PORT}
    sed -i "s#^CLIEXEC=.*#CLIEXEC=${CLI_EXEC}#" /etc/init.d/redis_${REDIS_PORT}
    sed -i "s#^PIDFILE=.*#PIDFILE=/var/run/redis_${REDIS_PORT}.pid#" /etc/init.d/redis_${REDIS_PORT}
    sed -i "s#^CONF=.*#CONF="/data/service/redis/etc/${REDIS_PORT}.conf"#" /etc/init.d/redis_${REDIS_PORT}
    sed -i "s#^REDISPORT=.*#REDISPORT="${REDIS_PORT}"#" /etc/init.d/redis_${REDIS_PORT}

    if command -v update-rc.d >/dev/null 2>&1; then
    	#if we're not a chkconfig box assume we're able to use update-rc.d
    	update-rc.d redis_${REDIS_PORT} defaults && echo "Success!"
    else
    	echo "No supported init tool found."
    fi

    chmod +x /etc/init.d/redis_${REDIS_PORT}
    /etc/init.d/redis_${REDIS_PORT} start

}



install_redis
