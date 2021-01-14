#!/bin/bash

addresses=192.168.1.214
gateway=192.168.1.1

# dhcp or static
BOOTPROTO=static


VERSION=$(grep "VERSION_ID" /etc/os-release | cut -f 2 -d '=')

if [ "${VERSION}"=="20.04" ];then
    echo "20.04"
    # Ubuntu 20.04.1 LTS
    config_file="/etc/netplan/00-installer-config.yaml"
elif [ "${VERSION}"=="18.04" ];then
    echo "18.04"
    # Ubuntu 18.04.2 LTS
    config_file="/etc/netplan/50-cloud-init.yaml"
else
    echo "Unknow"
    exit 
fi


# backup
if [ -f ${config_file} ];then
    mv ${config_file} ${config_file}.$(date '+%F-%H-%M-%S')
fi


if [ "${BOOTPROTO}" == "dhcp" ];then
# dhcp
cat > ${config_file} << EOF
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens33:
      dhcp4: true
  version: 2
EOF
elif [ "${BOOTPROTO}" == "static" ];then
# static
cat > ${config_file} <<EOF
# This is the network config
network:
  ethernets:
    ens33:
      dhcp4: false
      addresses: [${addresses}/24]
      gateway4: ${gateway}
      nameservers:
        addresses: [223.5.5.5, 223.6.6.6] 
  version: 2
EOF
fi

netplan apply
