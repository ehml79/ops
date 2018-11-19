#！/bin/bash
# 自动部署proftpd，先上传文件proftpd_config.tgz(包含proftpd-1.3.4rc2.tar.gz ， proftpd.conf)到/root

FRed="\E[31;40m"; FGreen="\E[32;40m"; FBlue="\E[34;40m"; St0="\033[1m"; St1="\033[1;5m"; Ed="\033[0m"
_TAR_dir=`pwd`

if [ $# != 2 ] ; then
  echo  -e  ${FRed}"Usage: `basename $0` [ftp_user] [ftp_dir]"${Ed}
  exit
fi


#安装编译环境
GCCNUM=`rpm -q gcc | grep gcc | wc -l`
  if [ $GCCNUM -eq 0 ]; then
      echo "NO GCC error!"
#      exit
  fi

# 编译安装proftpd
cd ${_TAR_dir}
# wget ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.6.tar.gz 
wget ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.4rc2.tar.gz
tar -zxvf ./proftpd-1.3.4rc2.tar.gz
cd proftpd-1.3.4rc2
 ./configure
make
make install
make clean

# 修改配置配置文件
rm /usr/local/etc/proftpd.conf -rf
cp ${_TAR_dir}/proftpd.conf  /usr/local/etc/   # 替换原有配置文件


# 添加开机启动，并启动proftpd
cd ${_TAR_dir}/proftpd-1.3.4rc2
cp ./contrib/dist/rpm/proftpd.init.d  /etc/rc.d/init.d/proftpd
chmod +x /etc/rc.d/init.d/proftpd
chkconfig proftpd on
service proftpd start


# 添加用户和组
groupadd ftpgroup
mkdir -p $2
adduser -s /sbin/nologin -d $2 -g ftpgroup $1    # 不能login的ftp用户，指定目录

#产生ftp用户随机密码。
MATRIX="ABCD3423NOPQRSTUVWXYZ21324234vwxyz0123456789"
LENGTH="16"
while [ "${n:=1}" -le "$LENGTH" ]
do
        FTP_PW="$FTP_PW${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
done

echo "$FTP_PW" | passwd $1 --stdin
echo "$1  $FTP_PW" >> /root/FTPpwd.dat
chown -R $1:ftpgroup $2   #设置发布的ftp目录的权限


echo -e ${FGreen}${St0}"\n Proftpd is installed complite!!!"${Ed}

