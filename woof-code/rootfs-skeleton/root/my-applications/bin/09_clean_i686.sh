#!/bin/bash

#
#
#

#
#
#

dires=`ls -1 | grep '\-i686$'`

for i in $dires;do
echo $i
if [ -e $i/usr/lib/xorg ];then
rm -rf $i/usr/lib/xorg
fi

if [ -e $i/usr/share/applications ];then
rm -rf $i/usr/share/applications
fi

if [ -e $i/usr/local ];then
rm -rf $i/usr/local
fi

if [ -e $i/usr/X11 ];then
rm -rf $i/usr/X11
fi

if [ -e $i/usr/X11R6 ];then
rm -rf $i/usr/X11R6
fi

done
