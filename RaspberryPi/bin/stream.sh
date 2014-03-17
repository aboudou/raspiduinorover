#!/bin/sh

DIR=$(cd $(dirname "$0"); pwd)

case "$1" in
  start)

    # Mount RAM cache
    /bin/mount /dev/ram1 /ramcache

    # Start raspimjpeg which will capture frames from camera module
    #   and save them to the ramdisk with the following settings:
    # - 640x360 picture size (16/9 ratio)
    # - 15% JPEG quality
    # - save 1 frame every 5 frames (equals 30/5 = 6fps)
    # These settings give a 1500 kbs stream
    #
    # About raspimjpeg: http://www.raspberrypi.org/forums/viewtopic.php?t=61771
    "${DIR}"/raspimjpeg -w 640 -h 360 -d 5 -q 15 -of /ramcache/pic.jpg &

    # Start mjpeg_streamer
    #
    # mjpeg_streamer was build following these settings:
    # http://blog.miguelgrinberg.com/post/how-to-build-and-run-mjpg-streamer-on-the-raspberry-pi
    # Follow steps 1 to 6
    LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/mjpg_streamer -i "input_file.so -f /ramcache -n pic.jpg" -o "output_http.so -w /usr/local/www" &

    ;;

  stop)

    /usr/bin/killall mjpg_streamer
    /usr/bin/killall raspimjpeg
    sleep 2
    /bin/umount /ramcache

   ;;

  *)

    echo "Usage: $0 {start|stop}" >&2
    exit 1

    ;;
esac

exit 0
