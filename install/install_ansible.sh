#!/bin/bash

# for ubuntu

#  install
sudo apt -y install  sshpass ansible

# test
ansible all -m ping
