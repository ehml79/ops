#!/bin/bas


trusted_host="mirrors.aliyun.com"


mkdir -p  /root/.pip

cat > /root/.pip/pip.conf <<EOF
## Note, this file is written by cloud-init on first boot of an instance
## modifications made here will not survive a re-bundle.
###
[global]
index-url=https://${trusted_host}/pypi/simple/

[install]
trusted-host=${trusted_host}
EOF
