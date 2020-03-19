#!/bin/bash

apt -y install make automake libtool pkg-config libaio-dev

apt -y install libmysqlclient-dev libssl-dev

mkdir -p /data/service/src

cd /data/service/src

git clone https://github.com/akopytov/sysbench.git

cd sysbench/

./autogen.sh

./configure --prefix=/data/service/sysbench

make -j

make install

echo 'export PATH=$PATH:/data/service/sysbench/bin/' > /etc/profile.d/sysbench.sh

