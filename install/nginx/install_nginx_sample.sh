#!/bin/bash
#install nginx-1.8.1

#安装目录
INSTALL_DIR=/opt/
SRC_DIR=/opt/software

[ ! -d ${INSTALL_DIR} ] && mkdir -p ${INSTALL_DIR}
[ ! -d ${SRC_DIR} ] && mkdir -p ${SRC_DIR}

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!!"
    exit 1
fi

#安装依赖包
for Package in wget gcc gcc-c++ autoconf automake zlib zlib-devel openssl openssl-devel pcre pcre-devel
do
    yum -y install $Package
done

function Install_Nginx()
{
    #更新版本信息
    NGINX="nginx-1.8.1"
    PCRE="pcre-8.35"
    ZLIB="zlib-1.2.8"
    OPENSSL="openssl-1.0.1i"
    
    NGINXFEATURES="--prefix=${INSTALL_DIR}nginx \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --pid-path=/var/run/nginx.pid \
    --with-pcre=${SRC_DIR}/${PCRE} \
    --with-zlib=${SRC_DIR}/${ZLIB} \
    --with-openssl=${SRC_DIR}/${OPENSSL}
    "
    
    cd ${SRC_DIR}
    #下载所需安装包
    echo 'Downloading NGINX'
    if [ ! -f ${NGINX}.tar.gz ]
    then
      wget -c https://nginx.org/download/${NGINX}.tar.gz
    else
      echo 'Skipping: NGINX already downloaded'
    fi
    
    echo 'Downloading PCRE'
    if [ ! -f ${PCRE}.tar.gz ]
    then
      wget -c https://sourceforge.net/projects/pcre/files/pcre/8.35/${PCRE}.tar.gz
    else
      echo 'Skipping: PCRE already downloaded'
    fi
    
    echo 'Downloading ZLIB'
    if [ ! -f ${ZLIB}.tar.gz ]
    then
      wget -c https://zlib.net/${ZLIB}.tar.gz
    else
      echo 'Skipping: ZLIB already downloaded'
    fi
    
    echo 'Downloading OPENSSL'
    if [ ! -f ${OPENSSL}.tar.gz ]
    then
      wget -c https://www.openssl.org/source/${OPENSSL}.tar.gz
    else
      echo 'Skipping: OPENSSL already downloaded'
    fi
    
    echo '----------Unpacking downloaded archives. This process may take serveral minutes---------'
    
    echo "Extracting ${NGINX}..."
    tar xzf ${NGINX}.tar.gz
    echo 'Done.'
    
    echo "Extracting ${PCRE}..."
    tar xzf ${PCRE}.tar.gz
    echo 'Done.'
    
    echo "Extracting ${ZLIB}..."
    tar xzf ${ZLIB}.tar.gz
    echo 'Done.'
    
    echo "Extracting ${OPENSSL}..."
    tar xzf ${OPENSSL}.tar.gz
    echo 'Done.'
    
    #添加用户
    groupadd -r nginx
    useradd -r -g nginx nginx
    
    #编译
    echo '###################'
    echo 'Compile NGINX'
    echo '###################'
    cd ${SRC_DIR}/${NGINX}
    ./configure ${NGINXFEATURES}
    make
    make install
    cd ../
    
    mkdir -p ${INSTALL_DIR}/nginx/conf/vhosts

}

Install_Nginx
