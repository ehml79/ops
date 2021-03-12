#!/bin/bash


count=$(lastb | awk '{print $3}' | sort -rn | uniq -c |head -1 | awk '{print $1}')
ip=$(lastb | awk '{print $3}' | sort -rn | uniq -c |head -1 | awk '{print $2}')

if [ $count -gt 3 ];then
    echo $ip
    echo "sshd: ${ip}" >> /etc/hosts.deny
fi
