#!/bin/bash


PUB_KEY=""

SSHD_CONFIG="/etc/ssh/sshd_config"

echo ${PUB_KEY} >> /root/.ssh/authorized_keys

sed -i 's@^#PubkeyAuthentication.*@PubkeyAuthentication yes@g'  ${SSHD_CONFIG}
sed -i 's@^PubkeyAuthentication.*@PubkeyAuthentication yes@g'  ${SSHD_CONFIG}

sed -i 's@^#PermitRootLogin.*@PermitRootLogin prohibit-password@g' ${SSHD_CONFIG}
sed -i 's@^PermitRootLogin.*@PermitRootLogin prohibit-password@g' ${SSHD_CONFIG}

sed -i 's@^#PasswordAuthentication.*@PasswordAuthentication no@g' ${SSHD_CONFIG}
sed -i 's@^PasswordAuthentication.*@PasswordAuthentication no@g' ${SSHD_CONFIG}

/etc/init.d/ssh restart

