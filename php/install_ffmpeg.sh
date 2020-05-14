#!/bin/bash

# ffmpeg

mkdir -p /data/service/src

wget -O /data/service/src/ffmpeg-4.2.2.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2
cd /data/service/src/
tar xf ffmpeg-4.2.2.tar.bz2
cd ffmpeg-4.2.2
./configure --prefix=/data/service/ffmpeg --enable-shared --disable-static --disable-doc --enable-ffplay --disable-x86asm
make && sudo make install
echo "include /data/service/ffmpeg/lib" > /etc/ld.so.conf.d/ffmpeg.conf
/sbin/ldconfig


echo 'export FFMPEG_HOME=/data/service/ffmpeg' > /etc/profile.d/ffmpeg.sh
echo 'export PATH=$PATH:$FFMPEG_HOME/bin'  >> /etc/profile.d/ffmpeg.sh
echo 'export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/data/service/ffmpeg/lib/pkgconfig' >> /etc/profile.d/ffmpeg.sh
