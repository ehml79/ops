#!/bin/bash
# Percona Monitoring and Management

# Grafana
# Kibana 

wget -O /data/service/src/pmm-client-1.16.0.tar.gz https://www.percona.com/downloads/pmm/1.16.0/binary/tarball/pmm-client-1.16.0.tar.gz 

cd /data/service/src
tar xf pmm-client-1.16.0.tar.gz
cd pmm-client-1.16.0/


rm /root/$0
