#!/bin/bash

#
#
#

#
#
#

DIRES=`ls -1F | grep '\-i686/$'`

for i in $DIRES;do
echo "$i"
n0=`echo "$i" |sed 's%-i686/$%%;s%\.%%g;s%%%g;s%-[0-9]*$%%'`
echo "$n0"
drivername=`echo "$n0" |rev |cut -f1 -d'-' |rev`
echo "drivername='$drivername'"
#[ "$drivername" = "joystick" ] && drivername='js_x_drv'
if [ ! "`find ./$i \( -type f -o -type l \) -name "*${drivername}*"`" ] ;then
if [ "$drivername" = "jamstudio" ];then
drivername='js_x'
elif [ "$drivername" = "keyboard" ];then
drivername='kbd'
fi
echo "drivername='$drivername'"
fi
echo '---'
find ./$i \( -type f -o -type l \) -not -name "*${drivername}*" |grep -v '\.log$'
echo '---'

files=`find ./$i \( -type f -o -type l \) |grep -v "/${drivername}" | grep -v '\.log$'`
echo "$files"
k=''
read -p "OK to remove ?" k
echo "k='$k'"
if [ "$k" == "y" ];then
echo "OK .. removing..."
for j in `echo $files`; do
echo " Removing $j..."
rm $j ;done
echo "...removed"
fi
echo "NEXT..."
done
