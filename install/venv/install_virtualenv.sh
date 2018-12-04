#!/bin/bash


apt -y install virtualenv
mkdir -p /data/venv/{venv27,venv35}
virtualenv -p python2.7 /data/venv/venv27
virtualenv -p python3.5 /data/venv/venv35
