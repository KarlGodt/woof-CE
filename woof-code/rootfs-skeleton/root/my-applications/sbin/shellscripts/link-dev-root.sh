#!/bin/sh

root_link_func(){
#if test ! -L /dev/root ; then
rm -f /dev/root
RD=`cat /tmp/bootkernel.log | grep -i 'Mounted root'`
echo "$RD"
if [ -z "$RD" ] ; then #&& 
rootdevice=`rdev | cut -d ' ' -f1 | cut -f3 -d '/'`
echo $rootdevice
[ -z "$rootdevice" ] && return
ln -s $rootdevice /dev/root
else
device=`echo "$RD" | grep -o -i 'device .*' | cut -f 2 -d ' '`
echo $device
MAJ=`echo $device | cut -f 1 -d ':'`
echo $MAJ
Min=`echo $device | cut -f 2 -d ':' | sed 's#\.$##'`
echo $Min
#does not work for MAJ=Min rootdevice=`grep -w $MAJ /proc/partitions | grep -w $Min | tr -s [[:blank:]] | cut -f 5 -d ' '` 
CATPROCPART=`cat /proc/partitions | sed "1,2 d" | sed 's#^[[:blank:]]*##g' | tr -s ' '`
rootdevice=`echo "$CATPROCPART" | grep -w "^$MAJ $Min" | cut -f 4 -d ' '`
echo $rootdevice
[ -z "$rootdevice" ] && return
ln -s $rootdevice /dev/root
fi
}
root_link_func