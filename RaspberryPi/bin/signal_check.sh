#!/bin/sh

/sbin/iwconfig "$1" 2> /dev/null | /bin/grep -v "no " | /bin/grep Signal | /usr/bin/awk -F " " '{print $4}' | /usr/bin/awk -F "=" '{print $2}' | /usr/bin/awk -F "/" '{print $1}'
