#!/bin/bash


kill -9 $(cat /var/run/uwsgi.pid)
#uwsgi --ini  /data/service/nginx/conf/uwsgi.ini

#sudo uwsgi --http 127.0.0.1:5000 --wsgi-file /data/web/py/run.py --processes 1 --threads 1
sudo uwsgi --http 127.0.0.1:5000 --wsgi-file /data/web/py/test.py --processes 1 --threads 1

