#!/bin/sh
[ ! -d /etc/dgcmodem ] && mkdir /etc/dgcmodem
 
#Start with empty modprobe.conf include file.
echo -n > /etc/modprobe_includes/modem-dgcmodem.conf
[ -s /tmp/.modconflicts-`uname -r` ] && sed -e 's%^\([a-z0-9_\-]*\)\(.*\)%install \1 /bin/true # temporarily disabled by dgc - conflicts with\2%' /tmp/.modconflicts-`uname -r` >> /etc/modprobe_includes/modem-dgcmodem.conf

#Edit config script to avoid device instances 1-7, avoid setting /dev/modem link, create modprobe.conf include file.
if [ -e /usr/sbin/dgcconfig ];then
 echo "/usr/sbin/dgcconfig found and being modified."
 sed -i -e 's%^#\!/bin/bash$%#\!/bin/bash\n#Edited by Puppy Linux during extraction of firmware for modem initialization.%' \
 -e 's%while \[ $u -lt 8 \]; do%while [ $u -le 0 ]; do%' \
 -e 's%[\ \	]*echo \"alias /dev/modem%#echo \"alias /dev/modem%' \
 -e 's%/etc/modprobe\.conf%/etc/modprobe_includes/modem-dgcmodem.conf%' \
 -e 's%if \[ -d /etc/udev/rules\.d \]; then%if [ -f /etc/udev/rules.d ]; then%' \
 -e 's%if \[ ! -e /dev/modem \]; then%if [ ! true ]; then%' \
 /usr/sbin/dgcconfig
 sync
 
 #Use edited config script to create devices.
 /usr/sbin/dgcconfig --serial
fi

#Append 'include' statement to modprobe.conf
[ -s /etc/modprobe_includes/modem-dgcmodem.conf ] && echo "include /etc/modprobe_includes/modem-dgcmodem.conf" >> /etc/modprobe.conf || rm -f /etc/modprobe_includes/modem-dgcmodem.conf
