#!/bin/bash


mysql_version="mysql-8.0.15"

sudo apt -y install make cmake gcc g++ bison libncurses5-dev build-essential libssl-dev  libaio1

groupadd mysql
useradd -r -g mysql -s /bin/false mysql

mkdir -p /data/service/src/

#wget https://cdn.mysql.com//Downloads/MySQL-8.0/${mysql_version}.tar.gz -P /data/service/src/
#wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz  -P /data/service/src/

wget https://dev.mysql.com/get/Downloads/MySQL-8.0/${mysql_version}-linux-glibc2.12-x86_64.tar.xz -P /data/service/src/


cd /data/service/src
tar xf ${mysql_version}-linux-glibc2.12-x86_64.tar.xz 
mv /data/service/src/${mysql_version}-linux-glibc2.12-x86_64 /data/service/mysql
cd /data/service/mysql
bin/mysqld --initialize-insecure --user=mysql  --basedir=/data/service/mysql --datadir=/data/service/mysql/data/

# bin/mysqld_safe --user=mysql &
# killall mysqld


cp support-files/mysql.server /etc/init.d/mysqld
sed -i 's@/usr/local/mysql@/data/service/mysql@g' /etc/init.d/mysqld
systemctl enable mysqld
/etc/init.d/mysqld start

mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';"

export PATH=$PATH:/data/service/mysql/bin
echo "export PATH=$PATH:/data/service/mysql/bin" >> /etc/profile


