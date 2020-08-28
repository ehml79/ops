#!/bin/bash

# server

rsync_passwd=


function install_rsync(){
    
    # 判断系统
    if [ -f /usr/bin/apt ];then
        echo 'ubuntu'
        apt -y install rsync
    elif [ -f /usr/bin/yum ];then
        echo 'centOS'
        yum -y install rsync
    else
        echo 'unknow OS'
        exit 1
    fi
    
    
    
    mkdir -p  /etc/rsyncd/
    echo "${rsync_passwd}" >  /etc/rsyncd/rsyncd.pass
    chmod 600  /etc/rsyncd/rsyncd.pass


}

function install_lsyncd(){

    apt -y install lsyncd
    mkdir /etc/lsyncd/
    mkdir -p /data/logs/lsyncd

cat > /etc/lsyncd/lsyncd.conf.lua <<EOF
settings {
  logfile = "/data/logs/lsyncd/lsyncd.log",
  statusFile = "/data/logs/lsyncd/lsyncd.status",
  inotifyMode = "CloseWrite",
  maxProcesses = 2,
}
sync {
  default.rsync,
  source = "/backup",
  target = "rsync@10.0.0.60::backup",
  delete = true,
  exclude = { ".*" },
  delay = 1,
  rsync = {
    binary = "/usr/bin/rsync",
    archive = true,
    compress = true,
    verbose = true,
    password_file = "/etc/rsyncd/rsyncd.pass",
    _extra = {"--delete"}
  }
}
EOF


systemctl start lsyncd
systemctl restart lsyncd
systemctl enable  lsyncd

}


install_rsync
install_lsyncd
