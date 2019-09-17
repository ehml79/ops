#!/bin/bash

# 单机svn更新脚本

project_name=proj
port=3389
svn_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`


apt update
apt -y install subversion expect

mkdir -p /data/log
mkdir -p /data/service/svn
cd /data/service/svn

svnadmin create /data/service/svn/${project_name}

# 配置svn conf
cat > /data/service/svn/${project_name}/conf/authz << EOF
[groups]
developer = server

[/]
@developer = rw
EOF

# 配置passwd
cat >  /data/service/svn/${project_name}/conf/passwd << EOF
[users]
server = ${svn_passwd}
EOF

# 配置 svnserve.conf
sed -i 's/.*anon-access = .*/anon-access = none/g' /data/service/svn/${project_name}/conf/svnserve.conf
sed -i 's/.*auth-access =.*/auth-access = write/g' /data/service/svn/${project_name}/conf/svnserve.conf
sed -i 's/.*password-db = .*/password-db = passwd/g' /data/service/svn/${project_name}/conf/svnserve.conf
sed -i 's/.*authz-db =.*/authz-db = authz/'g  /data/service/svn/${project_name}/conf/svnserve.conf


# 配置hooks
cat > /data/service/svn/${project_name}/hooks/post-commit << EOF
#!/bin/sh

REPOS="\$1"
REV="\$2"
TXN_NAME="\$3"

#"\$REPOS"/hooks/mailer.py commit "\$REPOS" \$REV "\$REPOS"/mailer.conf

/usr/bin/ssh -o ConnectTimeout=3 -o ConnectionAttempts=5 -o PasswordAuthentication=no -o StrictHostKeyChecking=no  root@127.0.0.1 "/bin/bash  /data/sh/update/rsync_update_scripts.sh"
echo `date '+%F %H:%M:%S'` \$1 \$2 \$3 \$REPOS \$REV >> /data/log/post-commit.log
EOF

chmod +x /data/service/svn/${project_name}/hooks/post-commit  

# 启动脚本

cat > /root/svn_restart.sh <<EOF
#!/bin/bash

sudo killall svnserve

/usr/bin/svnserve -d -T --listen-host=0.0.0.0 --listen-port=${port} -r /data/service/svn/${project_name} --log-file /data/log/svn_${project_name}.log
EOF


# 生成key
expect <<EOF
spawn ssh-keygen -t rsa
expect {
"*id_rsa):" {
send "\n";
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

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# 更新脚本
mkdir -p /data/sh/update

cat  > /data/sh/update/rsync_update_scripts.sh << EOF
#!/bin/bash

chown -R www.www /data/svn && chmod -R 775 /data/svn

svn up /data/svn/

rsync -vzrtopg  --exclude="*.svn" --exclude="*.apk" --exclude="*.log" /data/svn/ /data/www/
EOF
