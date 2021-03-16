#!/bin/bash


lastb | awk '{print $3}' | uniq -c | sort -r | \

while read counts ips
do
    grep -q ${ips} /etc/hosts.deny
        if [ $? != 0 ] ; then
            if [ ${counts} -ge 5 ] ; then
                echo "sshd: ${ips}" >> /etc/hosts.deny
            fi
        fi
done
