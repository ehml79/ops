#!/bin/bash

##  cron update
#* * * * *          /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep  5 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 10 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 15 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 20 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 25 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 30 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 35 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 40 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 45 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 50 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1
#* * * * * sleep 55 ; /bin/bash  /data/sh/update/main.sh >> /data/logs/main.log  2>&1

/bin/bash /data/sh/update/deploy_projectname_master.sh
