#!/bin/bash

function install_mysql8(){

    mysql_version="mysql-8.0.18"
    mysql_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`

    sudo apt -y install make cmake gcc g++ bison libncurses5-dev build-essential libssl-dev  libaio1
    
    groupadd mysql
    useradd -r -g mysql -s /bin/false mysql
    
    mkdir -p /data/service/src/
    
    wget -O /data/service/src/${mysql_version}-linux-glibc2.12-x86_64.tar.xz  https://dev.mysql.com/get/Downloads/MySQL-8.0/${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    
    
    cd /data/service/src
    tar xf ${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
    mv /data/service/src/${mysql_version}-linux-glibc2.12-x86_64 /data/service/mysql


cat > /etc/my.cnf <<EOF
[client]
user = root
port = 3306
socket = /tmp/mysql.sock
EOF

    chmod 600 /etc/my.cnf

    cd /data/service/mysql
    bin/mysqld --initialize-insecure --user=mysql  --basedir=/data/service/mysql --datadir=/data/service/mysql/data/     --log-bin
    
    # bin/mysqld_safe --user=mysql &
    # killall mysqld
    
    
    cp support-files/mysql.server /etc/init.d/mysqld
    sed -i 's@/usr/local/mysql@/data/service/mysql@g' /etc/init.d/mysqld
    systemctl enable mysqld
    /etc/init.d/mysqld start
    
    export PATH=$PATH:/data/service/mysql/bin
    echo 'export PATH=$PATH:/data/service/mysql/bin' >> /etc/profile
    
    # 修改密码
    /data/service/mysql/bin/mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_passwd}';"
    # /data/service/mysql/bin/mysql -uroot -e "update mysql.user set authentication_string=password('${mysql_passwd}') where user='root' ; flush privileges; "
    sed -i "/\[client\]/apassword = ${mysql_passwd}"  /etc/my.cnf

}


function config_sshd(){

    # navicat SSH 连接时提示
    # does not support diffie-hellman-group1-sha1
    # for keyexchange 或 The negotiation of encryption
    # algorithm is failed的解决方法

cat >> /etc/ssh/sshd_config <<EOF
KexAlgorithms diffie-hellman-group1-sha1,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1
Ciphers 3des-cbc,blowfish-cbc,aes128-cbc,aes128-ctr,aes256-ctr
EOF

    /usr/bin/ssh-keygen -A

    /usr/sbin/service ssh restart


}

install_mysql8

# config_sshd


rm /root/$0
