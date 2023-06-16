#!/bin/bash


function download_package(){

wget http://mirrors.aliyun.com/anaconda/archive/Anaconda3-2023.03-1-Linux-x86_64.sh

bash Anaconda3-2023.03-1-Linux-x86_64.sh

}

function set_anaconda(){

cat > .condarc  <<EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - http://mirrors.aliyun.com/anaconda/pkgs/main
  - http://mirrors.aliyun.com/anaconda/pkgs/r
  - http://mirrors.aliyun.com/anaconda/pkgs/msys2
custom_channels:
  conda-forge: http://mirrors.aliyun.com/anaconda/cloud
  msys2: http://mirrors.aliyun.com/anaconda/cloud
  bioconda: http://mirrors.aliyun.com/anaconda/cloud
  menpo: http://mirrors.aliyun.com/anaconda/cloud
  pytorch: http://mirrors.aliyun.com/anaconda/cloud
  simpleitk: http://mirrors.aliyun.com/anaconda/cloud
EOF


conda clean -i

}


download_package

set_anaconda
