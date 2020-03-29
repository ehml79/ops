#!/bin/bash

# Ubuntu 18.04.2 LTS

addresses=192.168.217.128
gateway=192.168.217.2

config_file="/etc/netplan/50-cloud-init.yaml"

# backup
if [ -f ${config_file} ];then
    mv ${config_file} ${config_file}.$(date '+%F-%H-%M-%S')
fi


cat > ${config_file} <<EOF
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens33:
            dhcp4: no
            addresses: [${addresses}/24]
            gateway4: ${gateway}
            nameservers:
                    addresses: [223.5.5.5, 223.6.6.6] 
    version: 2
EOF

netplan apply
