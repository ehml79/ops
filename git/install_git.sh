#!/bin/bash


projetc_name=repo
your_authorized_keys=""


function install_git(){

    sudo apt-get -y install git expect
    
    sudo adduser --quiet --disabled-password git 
    
    mkdir -p /data/service/git
    
    cd /data/service/git
    
    sudo git init --bare ${projetc_name}.git
    
    sudo chown -R git:git ${projetc_name}.git
    
    # 更改 git shell
    sed -i '/^git/s@/bin/bash@/usr/bin/git-shell@' /etc/passwd
    
    mkdir -p /home/git/.ssh
    
    echo "${your_authorized_keys}"  >>  /home/git/.ssh/authorized_keys
    echo "${your_authorized_keys}"  >>  /root/.ssh/authorized_keys
}

function git_deploy(){

# 生成 git key
expect <<EOF
spawn ssh-keygen -t rsa -C "git"

expect {
    "*id_rsa):" {
        send "/home/git/.ssh/id_rsa\n";
        exp_continue
        }

    "*(y/n)?" {
        send "y\n"
        exp_continue
        }

    "*passphrase):" {
        send "\n"
        exp_continue
    }

    "*again:" {
        send "\n"
    }
}
expect eof
EOF

    chown -R git.git /home/git/.ssh

    cat /home/git/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys


# 生成 root key
expect <<EOF
spawn ssh-keygen -t rsa -C "root"

expect {
    "*id_rsa):" {
        send "/root/.ssh/id_rsa\n";
        exp_continue
        }

    "*(y/n)?" {
        send "y\n"
        exp_continue
        }

    "*passphrase):" {
        send "\n"
        exp_continue
    }

    "*again:" {
        send "\n"
    }
}
expect eof
EOF

    cat  /root/.ssh/id_rsa.pub >> /home/git/.ssh/authorized_keys

    mkdir -p /data/gittemp/
    cd /data/gittemp/

    git clone git@localhost:/data/service/git/${projetc_name}.git
    
    mv /root/post-receive  /data/service/git/${projetc_name}.git/hooks/post-receive 

    chown git.git /data/service/git/${projetc_name}.git/hooks/post-receive 
    chmod +x /data/service/git/${projetc_name}.git/hooks/post-receive
}


install_git
git_deploy
