#!/bin/sh
#script executes just once, when firmware pkg installed, before module loads.

##make symlink if /dev/ttyUSB0 not already a special device file
#if [ "`file ./dev/ttyUSB0 | grep 'character special'`" = "" ];then
#    rm -f /dev/ttyUSB0
#    ln -s /dev/usb/ttyUSB0 /dev/ttyUSB0
#fi

RUNNINGPS="`ps`"
if [ "`echo "$RUNNINGPS" | grep "petget"`" != "" ];then
 /usr/sbin/fixmenus
fi
