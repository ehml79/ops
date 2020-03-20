#!/bin/bash

# 单机svn更新脚本

DOMAIN_NAME=''
RUN_USER=nginx

PROJECT_NAME=proj
SVN_PORT=50000
SVN_PASSWD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`

# 安装svn
apt update
apt -y install subversion expect

mkdir -p /data/logs
mkdir -p /data/service/svn
mkdir -p /data/svn
cd /data/service/svn

svnadmin create /data/service/svn/${PROJECT_NAME}

# 配置svn conf
cat > /data/service/svn/${PROJECT_NAME}/conf/authz << EOF
[groups]
developer = server

[/]
@developer = rw
EOF

# 配置passwd
cat >  /data/service/svn/${PROJECT_NAME}/conf/passwd << EOF
[users]
server = ${SVN_PASSWD}
EOF

# 配置 svnserve.conf
sed -i 's/.*anon-access = .*/anon-access = none/g' /data/service/svn/${PROJECT_NAME}/conf/svnserve.conf
sed -i 's/.*auth-access =.*/auth-access = write/g' /data/service/svn/${PROJECT_NAME}/conf/svnserve.conf
sed -i 's/.*password-db = .*/password-db = passwd/g' /data/service/svn/${PROJECT_NAME}/conf/svnserve.conf
sed -i 's/.*authz-db =.*/authz-db = authz/'g  /data/service/svn/${PROJECT_NAME}/conf/svnserve.conf


# 配置hooks
cat > /data/service/svn/${PROJECT_NAME}/hooks/post-commit << EOF
#!/bin/sh

REPOS="\$1"
REV="\$2"
TXN_NAME="\$3"

#"\$REPOS"/hooks/mailer.py commit "\$REPOS" \$REV "\$REPOS"/mailer.conf

/usr/bin/ssh -o ConnectTimeout=3 -o ConnectionAttempts=5 -o PasswordAuthentication=no -o StrictHostKeyChecking=no  root@127.0.0.1 "/bin/bash  /data/sh/update/rsync_update_scripts.sh"
echo `date '+%F %H:%M:%S'` \$1 \$2 \$3 \$REPOS \$REV >> /data/logs/post-commit.log
EOF

chmod +x /data/service/svn/${PROJECT_NAME}/hooks/post-commit  

# 启动脚本
cat > /root/svn_restart.sh <<EOF
#!/bin/bash

sudo killall svnserve

/usr/bin/svnserve -d -T --listen-host=0.0.0.0 --listen-port=${SVN_PORT} -r /data/service/svn/${PROJECT_NAME} --log-file /data/logs/svn_${PROJECT_NAME}.log
EOF

/bin/bash  /root/svn_restart.sh 

# check out svn
cd /data/svn 
svn  --username "server"  --password  "${SVN_PASSWD}"  --non-interactive co  svn://127.0.0.1:${SVN_PORT}/



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

chown -R ${RUN_USER}.${RUN_USER} /data/svn && chmod -R 700 /data/svn

svn --username "server"  --password  "${SVN_PASSWD}"   up  /data/svn/

rsync -vzrtopg  --exclude="*.svn" --exclude="*.apk" --exclude="*.log" /data/svn/ /data/web/
EOF

/bin/bash /data/sh/update/rsync_update_scripts.sh


# nginx conf
cat > /data/service/nginx/conf/vhost/${DOMAIN_NAME}.conf <<EOF
#
server
{
        listen       80;
        server_name  ${DOMAIN_NAME};
        index index.php index.html index.htm;
        root  /data/web/web_pc;
        charset utf-8;

        location ~/.svn/ {
                return 404;
        }

        location / {
        if (!-e \$request_filename) {
                rewrite  ^(.*)$  /index.php?s=\$1  last;
                break;
        }
                index index.html index.htm index.php;
        }

        location ~ .*\.php$
        {
                fastcgi_pass  127.0.0.1:9000;
                fastcgi_index index.php;
                include fcgi.conf;
                access_log  /data/service/nginx/logs/${DOMAIN_NAME}.access.log;
                error_log  /data/service/nginx/logs/${DOMAIN_NAME}.err.log;
        }

}

EOF

nginx -s reload
