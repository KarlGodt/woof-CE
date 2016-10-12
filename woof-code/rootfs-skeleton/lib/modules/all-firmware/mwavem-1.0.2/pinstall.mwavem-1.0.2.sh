#!/bin/sh
#this is called by /sbin/modprobe script, when mwave.ko is fetched from
#zdrv module, but before the module is loaded.
#this script is part of mwavem-1.0.2 firmware pkg in zdrv.

if [ "`grep 'alias char-major-10-219 mwave' /etc/modprobe.conf`" = "" ];then
 echo 'alias char-major-10-219 mwave' >> /etc/modprobe.conf
 touch -t 0512010101 /etc/modprobe.conf #set modify date back before modules.dep.
fi
