#!/bin/bash


user=
passwd=
ip=
project=
token=
verbose="-v"
method=post


curl -X ${method} ${verbose} -u ${user}:${passwd}  http://${ip}:8080/jenkins/job/${project}/build?token=${token} 
