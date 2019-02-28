#!/bin/bash


apt -y install libevent-dev


wget http://www.memcached.org/files/memcached-1.5.12.tar.gz -P /data/service/src/

cd /data/service/src

tar xf memcached-1.5.12.tar.gz

cd memcached-1.5.12/


./configure --prefix=/data/service/memcached

make && make test && sudo make install


cat  > /root/memcached_start  << EOF
#!/bin/bash
ulimit -SHn 65535
/data/service/memcached/bin/memcached -d -m 64 -c 4096 -p 11210 -u www -t 10
/data/service/memcached/bin/memcached -d -m 256 -c 4096 -p 11211 -u www -t 10
EOF
