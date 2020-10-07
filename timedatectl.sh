#!/bin/bash


mv /usr/share/zoneinfo/Asia/Singapore /etc/localtime

# timedatectl set-timezone Asia/Singapore

timedatectl set-local-rtc 1

systemctl restart cron.service