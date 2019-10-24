#!/bin/bash

# ubuntu

mkdir -p /data/logs/


cat >> /var/spool/cron/crontabs/root  <<EOF
# mysql status
* * * * *           echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep  5 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 10 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 15 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 20 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 25 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 30 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 35 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 40 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 45 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 50 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
* * * * *  sleep 55 && echo \$(date &&  /data/service/mysql/bin/mysqladmin status) >> /data/logs/mysqlstatus.log
EOF
