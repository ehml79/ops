#!/bin/bash

# for Ubuntu 20.04 LTS
# for Ubuntu 18.04 LTS
# for CentOS Linux 7 (Core)

function ubuntu2004(){
    echo "20.04"
    wget -O /data/service/src/mongodb-database-tools-ubuntu2004-x86_64-100.3.0.tgz  https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2004-x86_64-100.3.0.tgz 
    tar xf mongodb-database-tools-ubuntu2004-x86_64-100.3.0.tgz
    mv mongodb-database-tools-ubuntu2004-x86_64-100.3.0 /data/service/mongodb-database-tools

}

function ubuntu1804(){
    echo "18.04"
    wget -O /data/service/src/mongodb-database-tools-ubuntu1804-x86_64-100.3.0.tgz  https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu1804-x86_64-100.3.0.tgz
    tar xf mongodb-database-tools-ubuntu1804-x86_64-100.3.0.tgz
    mv mongodb-database-tools-ubuntu1804-x86_64-100.3.0 /data/service/mongodb-database-tools
}

function centos7(){
    echo 'centOS 7'
    wget -O /data/service/src/mongodb-database-tools-rhel70-x86_64-100.3.0.tgz  https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.3.0.tgz
    tar xf mongodb-database-tools-rhel70-x86_64-100.3.0.tgz
    mv mongodb-database-tools-rhel70-x86_64-100.3.0 /data/service/mongodb-database-tools
}

function install_tools(){

    VERSION=$(grep "VERSION_ID" /etc/os-release | cut -f 2 -d '=')
    cd /data/service/src

    # 判断系统
    if [ -f /usr/bin/apt ];then
        # Ubuntu
        sudo apt-get -y install libcurl4 openssl

        if [ "${VERSION}"=="20.04" ];then
            # for Ubuntu 20.04
	    ubuntu2004
        elif [ "${VERSION}"=="18.04" ];then
            # for Ubuntu 18.04
	    ubuntu1804
        else
            echo "Unknow Version"
            exit
        fi

    elif [ -f /usr/bin/yum ];then
        # centOS 
        sudo yum -y install libcurl openssl wget

        if [ "${VERSION}"=="7" ];then
	    centos7
        else
            echo "Unknow Version"
            exit
        fi

    else
        echo 'Unknow OS'
        exit 1
    fi

    echo 'export PATH=$PATH:/data/service/mongodb-database-tools/bin' > /etc/profile.d/mongodb-database-tools.sh
    export PATH=$PATH:/data/service/mongodb-database-tools/bin
}


install_tools
