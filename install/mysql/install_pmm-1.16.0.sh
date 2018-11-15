#!/bin/bash
# Percona Monitoring and Management

# Grafana
# wget https://www.percona.com/downloads/pmm/1.16.0/binary/tarball/pmm-client-1.16.0.tar.gz
# Kibana 

wget https://www.percona.com/downloads/pmm/1.16.0/binary/tarball/pmm-client-1.16.0.tar.gz -P /data/service/src

cd /data/service/src
tar xf pmm-client-1.16.0.tar.gz
cd pmm-client-1.16.0/


