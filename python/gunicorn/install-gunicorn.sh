#!/bin/bash
# for Ubuntu 18.04.3 LTS

project_name=blogproject

/data/venv/py3/bin/pip install gunicorn
/data/venv/py3/bin/pip install gevent


cat > /lib/systemd/system/gunicorn.service <<EOF
[Unit]
Description=gunicorn
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/data/web/blog
ExecStart=/data/venv/py3/bin/gunicorn -c gunicorn_conf.py ${project_name}.wsgi:application
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable gunicorn
sudo systemctl start gunicorn



mkdir -p /data/logs/gunicorn

cat > /data/web/blog/gunicorn_conf.py <<EOF
import multiprocessing

bind = '127.0.0.1:8000'
workers = multiprocessing.cpu_count() * 2 + 1

backlog = 2048
worker_class = "gevent"
worker_connections = 1000
daemon = False
debug = True
proc_name = '${project_name}'
pidfile = '/data/logs/gunicorn/gunicorn.pid'
errorlog = '/data/logs/gunicorn/gunicorn.log'
EOF



cat > /data/service/nginx/conf/vhost/${project_name}.conf <<EOF
server {
    listen 80;
    server_name blog.example.com;
    charset utf-8;

    location /static {
        alias /data/web/blog/blog/static;
    }

    location / {
        proxy_set_header Host \$host;
        proxy_pass http://127.0.0.1:8000;
	proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
nginx -s reload
