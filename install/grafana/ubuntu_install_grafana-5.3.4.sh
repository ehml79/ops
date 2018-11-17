#!/bin/bash



wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.3.4_amd64.deb
sudo dpkg -i grafana_5.3.4_amd64.deb

sudo systemctl enable grafana-server.service

sudo service grafana-server start

sudo update-rc.d grafana-server defaults


# 

curl https://packagecloud.io/gpg.key | sudo apt-key add -
sudo apt-get install -y adduser libfontconfig
sudo apt-get update
sudo apt-get -y install grafana
sudo systemctl enable grafana-server.service
systemctl start grafana-server

