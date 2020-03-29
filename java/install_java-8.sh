#!/bin/bash

# 下载 jdk-8u211-linux-x64.tar.gz 放到目录 /data/service/src/ 下，然后执行脚本

mkdir -p /data/service/src
cd /data/service/src/

tar xf jdk-8u211-linux-x64.tar.gz -C /data/service/
mv /data/service/jdk1.8.0_211 /data/service/jdk


profiled="/etc/profile.d/java.sh"

export JAVA_HOME=/data/service/jdk/             
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

echo "export JAVA_HOME=/data/service/jdk/"  >  ${profiled}
echo "export JRE_HOME=\${JAVA_HOME}/jre"  >> ${profiled}
echo "export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH"  >> ${profiled}
echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> ${profiled}

source ${profiled}
