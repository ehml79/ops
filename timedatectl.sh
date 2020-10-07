#!/bin/bash


timedatectl set-timezone Asia/Singapore

timedatectl set-local-rtc 1

systemctl restart cron.service