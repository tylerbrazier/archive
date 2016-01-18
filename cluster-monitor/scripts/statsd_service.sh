#!/bin/bash

# Wrapper for statsd that lets you start|stop|status.
# Note that the log will be stored in the home dir of the user who runs this.

thisdir=$(cd $(dirname $0); pwd)
statsdjs="${thisdir}/../packages/statsd/stats.js"
configjs="${thisdir}/../configs/statsd_config.js"
log="${HOME}/statsd.log"
cmd="/usr/bin/nodejs ${statsdjs} ${configjs} >${log} 2>&1 &"
# To determine if statsd is running, we just `ps -e | grep ${process}` so
# this variable should have leading and trailing spaces so we don't find
# this script or any other process that includes the text *statsd*.
process=" statsd "

# for debugging
#cmd="python -c \"while True: pass\" &"
#process="python"

is_running() {
  # 0: running
  # 1: not running
  return $(ps -e | grep "${process}" 1>/dev/null 2>&1)
}

case "$1" in
  start)
    if is_running; then
      echo "Did not start. statsd is already running."
      exit 1
    else
      echo "Executing: ${cmd}"
      eval $cmd
    fi
    ;;
  stop)
    if is_running; then
      echo "Stopping statsd"
      kill $(ps -e | grep "${process}" | sed 's/^ *//' | cut -d" " -f1)
    else
      echo "statsd is not running."
      exit 1
    fi
    ;;
  status)
    if is_running; then
      echo "statsd is running."
      exit 0
    else
      echo "statsd is not running."
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 <start|stop|status>"
    exit 1
    ;;
esac
