#!/bin/bash

pid_num=\`ps aux | grep "uwsgi.ini" | grep -v grep |awk '{print \$2}' | head -1\`

if [ -n "${pid_num}" ];then
    kill -9 ${pid_num}
    sleep 1
fi

#
#uwsgi --ini ${INSTALL_DIR}/nginx/conf/uwsgi.ini
# development
uwsgi --py-auto-reload=1 --ini ${INSTALL_DIR}/nginx/conf/uwsgi.ini