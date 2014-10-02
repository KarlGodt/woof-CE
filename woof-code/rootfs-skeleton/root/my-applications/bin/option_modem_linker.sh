#!/bin/sh
#linker for option module

#
#
#

[ ! -f /etc/ppp/peers/gprsmm ] && exit

OPTION_TTYs=`dmesg | grep -B 1 -A 1 'option'`
echo "$OPTION_TTYs"
if [ "$OPTION_TTYs" ] ; then

TTYs=`echo "$OPTION_TTYs" | grep -o -e 'ttyUSB[0-9]*'`
echo "$TTYs"
TTY=`echo "$TTYs" | head -n1`
echo "$TTY"

fi

currentDevice=`grep -n -o -m1 -e '^/dev/ttyUSB[0-9]*' /etc/ppp/peers/gprsmm`
echo currentDevice=$currentDevice
sedLine=`echo "$currentDevice" | cut -f 1 -d ':'`
echo sedLine=$sedLine
currentDevice=`echo "$currentDevice" | cut -f 2 -d ':' | tr -d '[[:blank:]]'`
echo currentDevice=$currentDevice
if [ -z "$currentDevice" ] ; then
echo "/dev/$TTY" >> /etc/ppp/peers/gprsmm
else
if [ "$currentDevice" != "/dev/$TTY" ] ; then
sed -i "$sedLine s:$currentDevice:/dev/$TTY:" /etc/ppp/peers/gprsmm
fi
fi
