#!/bin/bash


wget https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz -O /data/service/src/

tar xf /data/service/src/Python-3.6.8.tar.xz

cd /data/service/src/Python-3.6.8

./configure --prefix=/data/service/python368

make 

make install

# rm /usr/bin/python3
# ln -s /data/service/python368/bin/python3 /usr/bin/python3.6

pipenv --python /data/service/python368/bin/python3

