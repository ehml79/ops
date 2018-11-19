#!/bin/bash

/data/service/grafana/bin/grafana-server  --config=/data/service/grafana/conf/grafana.ini  cfg:default.paths.logs=/data/service/grafana/data/log cfg:default.paths.data=/data/service/grafana/data  &
