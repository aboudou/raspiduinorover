#!/bin/sh

DIR=$(cd $(dirname "$0"); pwd)

case "$1" in
  start)

    # Things to do when stream is started

    ;;

  stop)

    # Things to do when stream is stopped

    ;;
 
  *)

    echo "Usage: $0 {start|stop}" >&2
    exit 1

    ;;
esac

exit 0
