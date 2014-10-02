#!/bin/bash

#
#
#

#
#
#

if [ ! "$1" ];then
#remove xorg prefix
files=`grep -I -r -m1 'xorg/xf86OSKbd\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86OSKbd\.h%xf86OSKbd\.h%' $i
sleep 1s
done

else
#add xorg prefix

files=`grep -I -r -m1 'xf86OSKbd\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%xf86OSKbd\.h%xorg/xf86OSKbd\.h%;s%xorg/xorg%xorg%' $i
sleep 1s
done

files=`grep -I -r -m1 'xf86Keymap\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%xf86Keymap\.h%xorg/xf86OSKbd\.h%;s%xorg/xorg%xorg%' $i
sleep 1s
done

fi


