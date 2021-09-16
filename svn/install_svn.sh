#!/bin/bash

project_name=proj
port=5000

svn_passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16`

apt update
apt -y install subversion

mkdir -p /data/logs
mkdir -p /data/service/svn
cd /data/service/svn

svnadmin create /data/service/svn/${project_name}


# 配置conf

cat > /data/service/svn/${project_name}/conf/authz << EOF
[groups]
developer = server

[${project_name}:/]
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
cat > /data/service/svn/${project_name}/hooks/pre-commit << EOF
#!/bin/sh
# svn hooks
# svn commit 必须提交5个字的中文字符
export LANG="en_US.UTF-8"
REPOS="\$1"
TXN="\$2"
SVNLOOK=/usr/bin/svnlook
LOGMSG=\$(\$SVNLOOK log -t "\$TXN" "\$REPOS" | wc -c)
if [ "\$LOGMSG" -lt 17 ]; then
   echo "请填写至少6个字的中文备注" 1>&2
   echo "例如：【职位】代码相关操作" 1>&2
   echo "例如：【开发】页游相关，获取页游渠道链接" 1>&2
   exit 1
fi
EOF

chmod +x /data/service/svn/${project_name}/hooks/pre-commit  


# 启动脚本

cat > /root/svn_restart.sh <<EOF
#!/bin/bash

sudo killall svnserve

/usr/bin/svnserve -d -T --listen-host=0.0.0.0 --listen-port=${port} -r /data/service/svn/${project_name} --log-file /data/logs/svn_${project_name}.log
EOF
