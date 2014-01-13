#!/bin/sh
# 
# Start / Shutdown script for RaspiDuinoRover
#

DIR=$(cd $(dirname "$0"); pwd)

case "$1" in
  start)

    # Start MJPEG Streaming
    "${DIR}"/bin/stream.sh start

    # Start RaspDuinoRover
    `which python` "${DIR}"/server.py &

    ;;
  stop)
    if [ -f /var/run/raspiduinorover.pid ]
    then
       # Stop RaspiDuinoRover
      `which kill` -HUP `cat /var/run/raspiduinorover.pid`
      `which rm` /var/run/raspiduinorover.pid
    fi

    # Stop MJPEG Streaming
    "${DIR}"/bin/stream.sh stop
  
    ;;

  *)
    echo "Usage: $0 {start|stop}" >&2
    exit 1

    ;;

esac

exit 0
