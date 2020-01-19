#!/bin/bash


install_uwsgi(){
	    
    apt -y install  python3-pip

    pip3 install uwsgi
        
    mv -f /root/uwsgi.ini  ${INSTALL_DIR}/nginx/conf/uwsgi.ini 
    mv -f /root/uwsgi_sample.conf ${INSTALL_DIR}/nginx/conf/vhost/
        
    # 生成启动脚本
    /bin/bash /root/uwsgi_restart.sh
}


config_uwsgi(){


cat > /etc/systemd/system/myproject.service << EOF
[Unit]
Description=uWSGI instance to serve myproject
After=network.target
 
[Service]
[Unit]
Description=uWSGI instance to serve myproject
After=network.target
 
[Service]
WorkingDirectory=/home/python_project/kapi
ExecStart=/home/python_project/kapi/venv/bin/uwsgi --ini /home/python_project/kapi/config.ini
ExecStop=/home/python_project/kapi/venv/bin/uwsgi --stop /home/python_project/kapi/uwsgi/uwsgi.pid
ExecReload=/home/python_project/kapi/venv/bin/uwsgi --reload /home/python_project/kapi/uwsgi/uwsgi.pid


[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload

systemctl enable kapi.service
systemctl reload kapi.service
systemctl stop kapi.service
systemctl start kapi.service

}

install_uwsgi
config_uwsgi
