#!/bin/bash

run_user=www
nginx_install_dir=/data/service/nginx

install_nginx(){

    # 判断系统
    if [ -f /usr/bin/apt ];then
    	echo 'ubuntu'
    	apt -y install  git libpcre3 libpcre3-dev  zlib1g-dev openssl libssl-dev  build-essential 
    elif [ -f /usr/bin/yum ];then
    	echo 'centOS'
    	yum -y install wget gcc-c++ git pcre-devel openssl-devel
    else
    	echo 'unknow OS'
    	exit 1
    fi
    
    # install openssl

    wget -O /data/service/src/openssl-1.1.1.tar.gz  https://www.openssl.org/source/openssl-1.1.1.tar.gz
    cd /data/service/src
    tar xf  openssl-1.1.1.tar.gz
    
    groupadd ${run_user}
    useradd -M -s /sbin/nologin -g ${run_user}  ${run_user}
    mkdir -p /data/service/src
    wget -O /data/service/src/nginx-1.14.0.tar.gz  http://nginx.org/download/nginx-1.14.0.tar.gz 
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

worker_processes auto;
#worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;

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

mv /root/sample.conf /data/service/nginx/conf/vhost/
    

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


}



install_nginx
