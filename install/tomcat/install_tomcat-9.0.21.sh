#!/bin/bash


mkdir -p  /data/service/src

wget -O /data/service/src/apache-tomcat-9.0.21.tar.gz http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz

tar xf /data/service/src/apache-tomcat-9.0.21.tar.gz -C /data/service/
mv /data/service/apache-tomcat-9.0.21/ /data/service/tomcat

cat >  /root/tomcat_start.sh <<EOF
#!/bin/bash 
/bin/bash  /data/service/tomcat/bin/startup.sh
EOF 

chmod +x /root/tomcat_start.sh

cat > /root/tomcat_stop.sh <<EOF
#!/bin/bash 
/bin/bash /data/service/tomcat/bin/shutdown.sh
EOF

chmod +x /root/tomcat_stop.sh

cat > /root/tomcat_restart.sh <<EOF
#!/bin/bash 
/bin/bash /data/service/tomcat/bin/shutdown.sh && /bin/bash  /data/service/tomcat/bin/startup.sh
EOF

chmod +x /root/tomcat_restart.sh

