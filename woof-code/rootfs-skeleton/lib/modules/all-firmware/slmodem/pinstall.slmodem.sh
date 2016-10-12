#!/bin/sh
#this script is executed from /sbin/modprobe.
#it executes if a module to be loaded by modprobe is copied from
#zdrv_xxx.sfs and has an associated firmware package.
#thus, this script will execute while Puppy is running, immediately
#after all the firmware files are copied off zdrv_xxx.sfs.

#echo "Writing '/dev/ttySL0' to /etc/modemdevice..."
#echo -n "/dev/ttySL0" > /etc/modemdevice
#ln -sf ttySL0 /dev/modem

if [ "`cat /etc/modprobe.conf | grep "slamr"`" = "" ];then
 #echo "Updating /etc/modprobe.conf..."
 echo 'alias char-major-242 slamr' >> /etc/modprobe.conf
 echo 'install slamr modprobe --ignore-install ungrab-winmodem ; modprobe --ignore-install slamr' >> /etc/modprobe.conf
 echo 'alias char-major-243 slusb' >> /etc/modprobe.conf
 #touch -t 0512010101 /etc/modprobe.conf #set modify date back before modules.dep.
fi

#i don't think need this, as modprobe will do this...
##touch all the drivers to copy them from zdrv...
#touch /lib/modules/2.6.18.1/extra/slamr.ko
#touch /lib/modules/2.6.18.1/extra/slusb.ko
