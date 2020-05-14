#!/bin/bash

# ffmpeg

wget -O /data/service/src/ffmpeg-4.2.2.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2
cd /data/service/src/
tar xf ffmpeg-4.2.2.tar.bz2
cd ffmpeg-4.2.2
./configure --prefix=/data/service/ffmpeg --enable-shared --disable-static --disable-doc --enable-ffplay --disable-x86asm
make && sudo make install
echo "include /data/service/ffmpeg" >> /etc/ld.so.conf
/sbin/ldconfig
