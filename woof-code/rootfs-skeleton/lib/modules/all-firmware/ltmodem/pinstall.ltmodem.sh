#!/bin/sh
#this is called by /sbin/modprobe script, when ltmodem.ko is fetched from
#zdrv module, but before the module is loaded.

   grep "ltmodem" /etc/modprobe.conf > /dev/null 2>&1
   if [ ! $? -eq 0 ];then #=0 found.
#    echo "alias char-major-62 ltmodem" >> /etc/modprobe.conf
    echo "alias /dev/ttySV0 ltmodem" >> /etc/modprobe.conf
    #echo "alias /dev/modem ltmodem" >> /etc/modprobe.conf
    touch -t 0512010101 /etc/modprobe.conf #set modify date back before modules.dep.
   fi
