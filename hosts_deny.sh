#!/bin/bash


lastb | awk '{print $3}' | uniq -c | sort -r | \

while read count ips
do
    grep -q $ips /etc/hosts.deny
        if [ $? != 0 ] ; then
            if [ $count -ge 5 ] ; then
                echo "sshd: $ips" >> /etc/hosts.deny
            fi
        fi
done
