#!/bin/bash

mkdir -p /data/service/src/

wget -O /data/service/src/protobuf-all-3.9.1.tar.gz  https://github.com/protocolbuffers/protobuf/releases/download/v3.9.1/protobuf-all-3.9.1.tar.gz

cd /data/service/src
tar xf  protobuf-all-3.9.1.tar.gz
cd protobuf-3.9.1
./configure --prefix=/data/service/protobuf
make && make install

echo "export PATH=\$PATH:/data/service/protobuf/bin/" > /etc/profile.d/protobuf.sh
