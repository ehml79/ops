#!/bin/bash



apt update
apt -y install subversion

mkdir -p /data/{svn,log}
cd /data/svn

svnadmin create /data/svn/repo


cat > /root/svn_restart.sh <<EOF
#!/bin/bash


sudo killall svnserve


/usr/bin/svnserve -d -T --listen-host=0.0.0.0 --listen-port=5000 -r /data/svn/repo --log-file /data/log/svn.log
EOF



