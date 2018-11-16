#!/bin/bash


function install_openssl(){
    # install openssl

    wget https://www.openssl.org/source/openssl-1.1.1.tar.gz -P /data/service/src
    cd /data/service/src
    tar xf  openssl-1.1.1.tar.gz
    cd openssl-1.1.1/
    ./config -fPIC --prefix=/data/service/openssl --openssldir=/data/service/openssl
    make && make install 


    ln -s /data/service/openssl/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1
    ln -s /data/service/openssl/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.1.1

    echo 'export PATH=$PATH:/data/service/openssl/bin/' >>/etc/profile


}

install_openssl
