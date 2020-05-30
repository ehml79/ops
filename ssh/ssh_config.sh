#!/bin/bash

HOST=vm3
HOSTNAME=192.168.217.130

cat >> ~/.ssh/config  << EOF
Host ${HOST}
    Hostname ${HOSTNAME}
    Port 22
    User root
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    StrictHostKeyChecking no

    ControlPath ~/.ssh/master-%r@%h:%p
    ControlMaster auto
    ControlPersist yes

EOF
