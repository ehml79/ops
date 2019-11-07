#!/bin/bash

HOST=vm2
HOSTNAME=192.168.217.129

cat >> ~/.ssh/config  << EOF
Host vm2
    Hostname 192.168.217.129
    Port 22
    User root
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes

EOF
