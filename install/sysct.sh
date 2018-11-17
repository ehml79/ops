#!/bin/bash



net.core.somaxconn = 2048
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_max_syn_backlog = 262144 

net.ipv4.tcp_fin_timeout = 10

net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1

sysctl -p
