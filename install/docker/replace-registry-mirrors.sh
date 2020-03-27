#!/bin/bash

# 更换源

cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF



/etc/init.d/docker restart

