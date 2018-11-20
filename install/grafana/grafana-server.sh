#! /usr/bin/env bash

# grafana 开始关闭脚本

NAME=grafana-server
DEFAULT=/data/service/grafana/default/$NAME
GRAFANA_USER=grafana
GRAFANA_GROUP=grafana
GRAFANA_HOME=/data/service/grafana
CONF_DIR=/data/service/grafana/conf
WORK_DIR=$GRAFANA_HOME
DATA_DIR=/data/service/grafana/data
PLUGINS_DIR=/data/service/grafana/data/plugins
LOG_DIR=/data/service/grafana/data/log
CONF_FILE=$CONF_DIR/grafana.ini
PROVISIONING_CFG_DIR=$CONF_DIR/provisioning
MAX_OPEN_FILES=10000
PID_FILE=/data/service/grafana/run/$NAME.pid
DAEMON=/data/service/grafana/bin/$NAME

DAEMON_OPTS="--pidfile=${PID_FILE} --config=${CONF_FILE} cfg:default.paths.provisioning=$PROVISIONING_CFG_DIR cfg:default.paths.data=${DATA_DIR} cfg:default.paths.logs=${LOG_DIR} cfg:default.paths.plugins=${PLUGINS_DIR}"


case "$1" in
  start)
	# Prepare environment
	/bin/mkdir -p "$LOG_DIR" "$DATA_DIR" && /bin/chown "$GRAFANA_USER":"$GRAFANA_GROUP" "$LOG_DIR" "$DATA_DIR"
	/usr/bin/touch "$PID_FILE" && /bin/chown "$GRAFANA_USER":"$GRAFANA_GROUP" "$PID_FILE"

        if [ -n "$MAX_OPEN_FILES" ]; then
		ulimit -n $MAX_OPEN_FILES
	fi

	# Start Daemon
	/sbin/start-stop-daemon --start -b --chdir "$WORK_DIR" --user "$GRAFANA_USER" -c "$GRAFANA_USER" --pidfile "$PID_FILE" --exec $DAEMON -- $DAEMON_OPTS
        ;;
  stop)
	if [ -f "$PID_FILE" ]; then
		/sbin/start-stop-daemon --stop --pidfile "$PID_FILE" \
			--user "$GRAFANA_USER" \
			--retry=TERM/20/KILL/5 >/dev/null
	fi
	;;
esac
