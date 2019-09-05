#!/bin/bash

# for ubuntu

#  install
sudo apt -y install  sshpass  python-minimal ansible

# config
sed -i 's@#host_key_checking@host_key_checking@' /etc/ansible/ansible.cfg

# test
ansible all -m ping
