#!/bin/bash

run_user=www
nginx_install_dir=/data/service/nginx


install_nginx(){

    # 判断系统
    if [ -f /etc/os-release ];then
    	echo 'ubuntu'
    	apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential  python3-pip 
    elif [ -f /etc/redhat-release ];then
    	echo 'centOS'
    	yum -y install wget gcc-c++ git pcre-devel openssl-devel 
    else
    	echo 'unknow OS'
    	exit 1
    fi
    # install uwsgi
    pip3 install uwsgi

   
    # install openssl

    wget https://www.openssl.org/source/openssl-1.1.1.tar.gz -P /data/service/src
    cd /data/service/src
    tar xf  openssl-1.1.1.tar.gz
    
    groupadd ${run_user}
    useradd -M -s /sbin/nologin -g ${run_user}  ${run_user}
    mkdir -p /data/service/src
    mkdir -p /data/www
    wget http://nginx.org/download/nginx-1.14.0.tar.gz  -P /data/service/src
    cd /data/service/src ; tar xf  nginx-1.14.0.tar.gz
    cd nginx-1.14.0 


    ./configure --prefix=${nginx_install_dir} \
    --user=${run_user} \
    --group=${run_user} \
    --with-pcre  \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_realip_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-openssl=../openssl-1.1.1 \
    --with-pcre-jit 


    
    make  && make install

    mkdir -p /data/service/nginx/conf/vhost/
    # 生成nginx.conf 配置文件
#    sed -i "/worker_processes/i\user  ${run_user};"  /data/service/nginx/conf/nginx.conf
#    sed -i '/#tcp_nopush/a\    include vhost/*.conf;'  /data/service/nginx/conf/nginx.conf
    cat > /data/service/nginx/conf/nginx.conf << EOF
#
user ${run_user} ${run_user};

worker_processes 8;
worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;

error_log  /data/service/nginx/logs/error.log  notice;

pid        /data/service/nginx/logs/nginx.pid;

worker_rlimit_nofile 65535;

events {
        use epoll;
        worker_connections 65535;
}

http {

        include       mime.types;
        default_type  application/octet-stream;

        log_format  main        '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                                '\$status \$body_bytes_sent "\$http_referer" '
                                '"\$http_user_agent" \$http_x_forwarded_for "\$request_body"';

        access_log  /data/service/nginx/logs/access.log  main;

        charset  utf-8;
        server_names_hash_bucket_size 128;
        client_header_buffer_size 32k;
        large_client_header_buffers 4 32k;
        client_max_body_size 30m;
        sendfile on;
        tcp_nopush     on;
        keepalive_timeout 60;
        tcp_nodelay on;
        server_tokens off;
        client_body_buffer_size 512k;

        #proxy_connect_timeout   5;
        #proxy_send_timeout      60;
        #proxy_read_timeout      5;
        #proxy_buffer_size       16k;
        #proxy_buffers           4 64k;
        #proxy_busy_buffers_size 128k;
        #proxy_temp_file_write_size 128k;

        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_buffer_size 64k;
        fastcgi_buffers 4 64k;
        fastcgi_busy_buffers_size 128k;
        fastcgi_temp_file_write_size 128k;

        gzip on;
        gzip_min_length  1k;
        gzip_buffers     4 16k;
        gzip_http_version 1.1;
        gzip_comp_level 2;
        gzip_types       text/plain application/x-javascript text/css application/xml;
        gzip_vary on;


        #limit_zone  crawler  \$binary_remote_addr  10m; server

        server{
                listen          80;
                server_name     _;
                return          404;
        }

        include vhost/*.conf;

}
EOF

# 生成 uwsgi 配置文件
    cat > /data/service/nginx/conf/uwsgi.ini <<EOF
[uwsgi]
uid = ${run_user}
gid = ${run_user}
# 指定项目目录，在配置多站点时，不要启用
chdir = /data/www
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
 
cat > /data/service/nginx/conf/vhost/uwsgi_sample.conf <<EOF
        server{
                listen       80;
                server_name example.com;
                index index.html index.php index.htm;
                root  /data/www/example.com;

                access_log  /data/service/nginx/logs/access_example.com.log main;

                if (-d $request_filename){
                        rewrite ^/(.*)([^/])\$ http://\$host/\$1\$2/ permanent;
                }

                # error_page   500 502 503 504 404 403 http://localhost;

                location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
                        expires 30d;
                }

                location ~ .*\.(js|css)?$ {
                        expires 6h;
                }


                location ~ .*\.(php)?$
                {
                        fastcgi_pass  127.0.0.1:9000;
                        #fastcgi_pass  unix:/tmp/uwsgi.sock;

                        fastcgi_index index.php;
                        include fcgi.conf;
                }
        }
EOF


#  uwsgi 默认配置文件
cat > /data/service/nginx/conf/vhost/uwsgi_sample.conf <<EOF
#
server {
        listen       80;
        server_name  192.168.172.128;
        index  index.html index.htm;
        client_max_body_size 35m;
        location / {
            include  uwsgi_params;
            uwsgi_pass  127.0.0.1:9090;
            uwsgi_param UWSGI_SCRIPT demosite.wsgi;    #指定加载的模块
            uwsgi_param UWSGI_CHDIR /data/www;  #指定项目目录
        }
    }

EOF


cat > /data/service/nginx/conf/fcgi.conf <<EOF
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx;

fastcgi_param  QUERY_STRING       \$query_string;
fastcgi_param  REQUEST_METHOD     \$request_method;
fastcgi_param  CONTENT_TYPE       \$content_type;
fastcgi_param  CONTENT_LENGTH     \$content_length;

fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
fastcgi_param  REQUEST_URI        \$request_uri;
fastcgi_param  DOCUMENT_URI       \$document_uri;
fastcgi_param  DOCUMENT_ROOT      \$document_root;
fastcgi_param  SERVER_PROTOCOL    \$server_protocol;

fastcgi_param  REMOTE_ADDR        \$remote_addr;
fastcgi_param  REMOTE_PORT        \$remote_port;
fastcgi_param  SERVER_ADDR        \$server_addr;
fastcgi_param  SERVER_PORT        \$server_port;
fastcgi_param  SERVER_NAME        \$server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
EOF


    echo 'export PATH=$PATH:/data/service/nginx/sbin' >> /etc/profile
    . /etc/profile
    export PATH=$PATH:/data/service/nginx/sbin

# 生成启动脚本
cat > /root/uwsgi_restart.sh <<EOF

#!/bin/bash


pid_num=\`ps aux | grep "uwsgi.ini" | grep -v grep |awk '{print \$2}' | head -1\`


if [ -n "\${pid_num}" ];then
    kill -9 \${pid_num}
    sleep 1
fi

#
#uwsgi --ini /data/service/nginx/conf/uwsgi.ini
# development
uwsgi --py-auto-reload=1 --ini /data/service/nginx/conf/uwsgi.ini
EOF


}



install_nginx
