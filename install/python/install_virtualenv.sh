#!/bin/bash


apt -y  install virtualenv

mkdir /data/venv

cd /data/venv/

virtualenv -p /usr/bin/python3 --no-site-packages py3

