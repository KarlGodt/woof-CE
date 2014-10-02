#!/bin/bash

#
#
#

#
#
#

#fxorg/fb.h
files=`grep -I -r -m1 'fxorg/fb\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%fxorg/fb\.h%ffb\.h%' $i
sleep 1s
done
