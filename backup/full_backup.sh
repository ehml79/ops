#!/bin/bash


for i in bin  boot  data  dev  etc  home  lib  lib64    media  mnt  opt   root  run  sbin  srv  sys  tmp  usr  var
do
    rsync -av /$i 192.168.1.135:/data/backup/192.168.1.153/
done


