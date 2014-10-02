#!/bin/bash

#
#
#

#
#
#

#radeon_mergedxorg/fb.h
files=`grep -I -r -m1 'radeon_mergedxorg/fb\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%radeon_mergedxorg/fb\.h%radeon_mergedfb\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done

#nsc_xorg/fourcc.h
files=`grep -I -r -m1 'nsc_xorg/fourcc\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%nsc_xorg/fourcc\.h%nsc_fourcc\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done

#X11/dri/xf86xorg/dri.h
files=`grep -I -r -m1 'X11/dri/xf86xorg/dri\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%X11/dri/xf86xorg/dri\.h%X11/dri/xf86dri\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done

#xgi_xorg/dri.h
files=`grep -I -r -m1 'xgi_xorg/dri\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%xgi_xorg/dri\.h%xgi_dri\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done

#sis_xorg/dri.h
files=`grep -I -r -m1 'sis_xorg/dri\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%sis_xorg/dri\.h%sis_dri\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done


