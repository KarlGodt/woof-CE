#!/bin/bash

#
#
#

#
#
#

files=`grep -I -r -m1 'xorg\-server\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg-server\.h%xorg/xorg-server\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done
