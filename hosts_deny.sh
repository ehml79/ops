#!/bin/bash


count=$(lastb | awk '{print $3}' | sort -rn | uniq -c |head -1 | awk '{print $1}')
ip=$(lastb | awk '{print $3}' | sort -rn | uniq -c |head -1 | awk '{print $2}')

if [ $count -gt 10 ];then
    echo $ip
    grep $ip /etc/hosts.deny
    if [ $? -eq 1 ];then
        echo "sshd: ${ip}" >> /etc/hosts.deny
    fi
fi
