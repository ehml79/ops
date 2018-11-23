#! /usr/bin/env bash

# grafana 开始关闭脚本

NAME=grafana-server
GRAFANA_USER=grafana
GRAFANA_GROUP=grafana
GRAFANA_HOME=/data/service/grafana
CONF_DIR=/data/service/grafana/conf
DATA_DIR=/data/service/grafana/data
LOG_DIR=/data/service/grafana/data/log
CONF_FILE=$CONF_DIR/grafana.ini
MAX_OPEN_FILES=10000
PID_FILE=/data/service/grafana/run/$NAME.pid

case "$1" in
  start)
	# Prepare environment
	/bin/mkdir -p "$LOG_DIR" "$DATA_DIR" && /bin/chown "$GRAFANA_USER":"$GRAFANA_GROUP" "$LOG_DIR" "$DATA_DIR"
	/usr/bin/touch "$PID_FILE" && /bin/chown "$GRAFANA_USER":"$GRAFANA_GROUP" "$PID_FILE"

        if [ -n "$MAX_OPEN_FILES" ]; then
		ulimit -n $MAX_OPEN_FILES
	fi

	# Start Daemon
        /data/service/grafana/bin/grafana-server -config  ${CONF_FILE}  -homepath  ${GRAFANA_HOME}  -pidfile ${PID_FILE} >> /dev/null  2>&1  &
        ;;
  stop)
	if [ -f "$PID_FILE" ]; then
		/bin/kill  $(cat $PID_FILE )
	fi
	;;
esac
