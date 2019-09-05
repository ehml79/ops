#!/bin/bash

# for ubuntu

#  install
sudo apt -y install ansible

# test
ansible all -m ping
