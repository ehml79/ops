#!/bin/bash


# git clone -b master git@192.168.0.217:/data/service/git/deploy_projectname_master.git

cd /data/gittemp/deploy_projectname_master

#git checkout dev
git fetch --all 
git reset --hard origin/master
git pull

#rm -fr /data/web/deploy_projectname_master/
rsync -av --exclude="*.git" /data/gittemp/deploy_projectname_master/ /data/web/deploy_projectname_master/
chown -R nginx.nginx /data/gittemp/deploy_projectname_master/ /data/web/deploy_projectname_master/
chmod -R 775 /data/gittemp/deploy_projectname_master/ /data/web/deploy_projectname_master/
chmod -R 775 /data/gittemp/deploy_projectname_master/ /data/web/deploy_projectname_master/
