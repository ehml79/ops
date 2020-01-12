#!/bin/bash

RUN_USER=nginx
NGINX="nginx-1.16.1"

INSTALL_DIR=/data/service
SRC_DIR=${INSTALL_DIR}/src

[ ! -d ${INSTALL_DIR} ] && mkdir -p ${INSTALL_DIR}
[ ! -d ${SRC_DIR} ] && mkdir -p ${SRC_DIR}

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!!"
    exit 1
fi


install_nginx(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
    	echo 'ubuntu'
    	apt -y install  git \
        libpcre3 \
        libpcre3-dev \
        zlib1g-dev \
        openssl \
        libssl-dev \
        build-essential \
        python3-pip \
        libgd-dev \
        libgeoip-dev \
        libgoogle-perftools-dev \
        libatomic-ops-dev
    elif [ -f /usr/bin/yum ];then
    	echo 'centOS'
    	yum -y install wget \
        gcc-c++ \
        git \
        pcre-devel \
        openssl-devel
    else
    	echo 'unknow OS'
    	exit 1
    fi
    
    # install nginx
    cd ${SRC_DIR}
    [ ! -d /data/web ] && mkdir -p /data/web
    if [ ! -f ${NGINX} ];then
        wget -O ${SRC_DIR}/${NGINX}.tar.gz http://nginx.org/download/${NGINX}.tar.gz 
    fi

    tar xf  ${NGINX}.tar.gz
    cd ${NGINX} 

    groupadd ${RUN_USER}
    useradd -M -s /sbin/nologin -g ${RUN_USER}  ${RUN_USER}

    ./configure --prefix=${INSTALL_DIR}/nginx \
    --user=${RUN_USER} \
    --group=${RUN_USER} \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-google_perftools_module \
    --with-compat \
    --with-pcre \
    --with-libatomic

    make  && make install

    [ ! -d  ${INSTALL_DIR}/nginx/conf/vhost/  ] && mkdir -p ${INSTALL_DIR}/nginx/conf/{vhost,tcp,cert}

    mv -f /root/nginx.conf ${INSTALL_DIR}/nginx/conf/
    mv -f /root/fastcgi_sample.conf ${INSTALL_DIR}/nginx/conf/vhost/

    echo "export PATH=\$PATH:${INSTALL_DIR}/nginx/sbin" > /etc/profile.d/nginx.sh

}

config_uwsgi(){

# install uwsgi
pip3 install uwsgi

# 生成 uwsgi 配置文件
    cat > ${INSTALL_DIR}/nginx/conf/uwsgi.ini <<EOF
[uwsgi]
uid = ${RUN_USER}
gid = ${RUN_USER}
# 指定项目目录，在配置多站点时，不要启用
chdir = /data/web
# 加载demosite/wsgi.py这个模块，在配置多站点时，不要启用
module = test
master = true
processes = 2
# 设置socket的监听队列大小（默认：100）
listen = 120
#socket = /tmp/uwsgi.sock
socket = 127.0.0.1:9090
pidfile = /var/run/uwsgi.pid
# 当服务器退出的时候自动删除unix socket文件和pid文件。
vacuum = true
# 允许用内嵌的语言启动线程。这将允许你在app程序中产生一个子线程
enable-threads = true
# 设置用于uwsgi包解析的内部缓存区大小为64k。默认是4k。
buffer-size = 32768
# 设置在平滑的重启（直到接收到的请求处理完才重启）一个工作子进程中，等待这个工作结束的最长秒数。
# 这个配置会使在平滑地重启工作子进程中，如果工作进程结束时间超过了8秒就会被强行结束（忽略之前已经接收到的请求而直接结束）
reload-mercy = 8
# 为每个工作进程设置请求数的上限。当一个工作进程处理的请求数达到这个值，
# 那么该工作进程就会被回收重用（重启）。你可以使用这个选项来默默地对抗内存泄漏
max-requests = 5000
#通过使用POSIX/UNIX的setrlimit()函数来限制每个uWSGI进程的虚拟内存使用数。
# 这个配置会限制uWSGI的进程占用虚拟内存不超过256M。如果虚拟内存已经达到256M，
# 并继续申请虚拟内存则会使程序报内存错误，本次的http请求将返回500错误。
limit-as = 256
#一个请求花费的时间超过了这个harakiri超时时间，那么这个请求都会被丢弃，
# 并且当前处理这个请求的工作进程会被回收再利用（即重启）
harakiri = 60
# 使进程在后台运行，并将日志打到指定的日志文件或者udp服务器
daemonize = /var/log/uwsgi.log
# 进程个数
workers=5
# 指定IP端口
#http=0.0.0.0:80
# 指定静态文件
#static-map=/static=/opt/proj/teacher/static
# 序列化接受的内容，如果可能的话
thunder-lock=true
# 设置缓冲
post-buffering=4096

EOF

# 生成启动脚本
cat > /root/uwsgi_restart.sh <<EOF

#!/bin/bash

pid_num=\`ps aux | grep "uwsgi.ini" | grep -v grep |awk '{print \$2}' | head -1\`

if [ -n "\${pid_num}" ];then
    kill -9 \${pid_num}
    sleep 1
fi

#
#uwsgi --ini ${INSTALL_DIR}/nginx/conf/uwsgi.ini
# development
uwsgi --py-auto-reload=1 --ini ${INSTALL_DIR}/nginx/conf/uwsgi.ini
EOF

mv -f /root/uwsgi_sample.conf ${INSTALL_DIR}/nginx/conf/vhost/

}

config_uwsgi
install_nginx

