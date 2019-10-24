#!/bin/bash

# ubuntu

mkdir -p /data/logs/


cat >> /var/spool/cron/crontabs/root  <<EOF
# backup code file
0 2 * * * /bin/bash /data/sh/backup/backup_code_file.sh

# backup crontab file
0 3 * * * /bin/bash /data/sh/backup/backup_crontab.sh

# backup nginx conf
0 4 * * * /bin/bash /data/sh/backup/backup_nginx.sh

# backup mysql database
0 5 * * * /bin/bash /data/sh/backup/backup_mysql_db.sh
EOF
