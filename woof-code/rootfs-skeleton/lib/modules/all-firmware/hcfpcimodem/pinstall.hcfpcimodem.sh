#!/bin/sh
#Extract nvm directory into /etc/hcfpcimodem, if not present.
if [ ! -d /etc/hcfpcimodem/nvm ];then
 cd /etc/hcfpcimodem
 tar -xzf /tmp/nvm-`uname -r`.tar.gz
fi

#Start with empty modprobe.conf include file and conflict protection.
echo -n > /etc/modprobe_includes/modem-hcfpcimodem.conf
[ -s /tmp/.modconflicts-`uname -r` ] && sed -e 's%^\([a-z0-9_\-]*\)\(.*\)%install \1 /bin/true # temporarily disabled by hcfpci - conflicts with\2%' /tmp/.modconflicts-`uname -r` >> /etc/modprobe_includes/modem-hcfpcimodem.conf

#Edit config script to avoid device instances 1-7, avoid setting /dev/modem link, create modprobe.conf include file.
if [ -e /usr/sbin/hcfpciconfig ];then
 echo "/usr/sbin/hcfpciconfig found and being modified."
 sed -i -e 's%^#\!/bin/bash$%#\!/bin/bash\n#Edited by Puppy Linux during extraction of firmware for modem initialization.%' \
 -e 's%while \[ $u -lt 8 \]; do%while [ $u -le 0 ]; do%' \
 -e 's%[\ \	]*echo \"alias /dev/modem%#echo \"alias /dev/modem%' \
 -e 's%/etc/modprobe\.conf%/etc/modprobe_includes/modem-hcfpcimodem.conf%' \
 -e 's%if \[ -d /etc/udev/rules\.d \]; then%if [ -f /etc/udev/rules.d ]; then%' \
 -e 's%if \[ ! -e /dev/modem \]; then%if [ ! true ]; then%' \
 /usr/sbin/hcfpciconfig
 sync
 
 #Use edited config script to create devices.
 /usr/sbin/hcfpciconfig --serial
fi

#Append 'include' statement to modprobe.conf
[ -s /etc/modprobe_includes/modem-hcfpcimodem.conf ] && echo "include /etc/modprobe_includes/modem-hcfpcimodem.conf" >> /etc/modprobe.conf || rm -f /etc/modprobe_includes/modem-hcfpcimodem.conf
