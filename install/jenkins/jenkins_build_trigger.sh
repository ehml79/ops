#!/bin/bash


user=
passwd=
ip=
project=
token=


curl -X post -v -u user:passwd  http://${ip}:8080/jenkins/job/${project}/build?token=${token} 
