#!/bin/bash

#
#
#

#
#
#



files=`grep -I -r -m1 'shadowxorg/fb\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%shadowxorg/fb\.h%xorg/shadowfb\.h%;s%xorg/xorg/%xorg/%' $i
sleep 1s
done


#mach64_xorg/dri.h
files=`grep -I -r -m1 'mach64_xorg/dri\.h' *|cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%mach64_xorg/dri\.h%mach64_dri\.h%' $i
sleep 1s
done

#xorg/xorg
#files=`grep -I -r -m1 'xorg/xorg/' *|cut -f1 -d':'|sort -u`

#for i in $files;do
#echo "Repairing in $i..."
#sed -i 's%xorg/xorg/%xorg/%' $i
#sleep 1s
#done

#xorg/xorg/dri.h
#files=`grep -I -r -m1 'xorg/xorg/dri\.h' *|cut -f1 -d':'|sort -u`

#for i in $files;do
#echo "Repairing in $i..."
#sed -i 's%xorg/xorg/dri\.h%xorg/dri\.h%' $i
#sleep 1s
#done

#mga_xorg/xorg/dri.h
#files=`grep -I -r -m1 'mga_xorg/xorg/dri\.h' * |cut -f1 -d':'|sort -u`

#for i in $files;do
#echo "Repairing in $i..."
#sed -i 's%mga_xorg/xorg/dri\.h%mga_dri\.h%' $i
#sleep 1s
#done

#mga_xorg/dri.h
files=`grep -I -r -m1 'mga_xorg/dri\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%mga_xorg/dri\.h%mga_dri\.h%' $i
sleep 1s
done

#savage_xorg/vbe.h
files=`grep -I -r -m1 'savage_xorg/vbe\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%savage_xorg/vbe\.h%savage_vbe\.h%' $i
sleep 1s
done


#savage_xorg/dri.h:
files=`grep -I -r -m1 'savage_xorg/dri\.h' * |cut -f1 -d':'|sort -u`

for i in $files;do
echo "Repairing in $i..."
sed -i 's%savage_xorg/dri\.h%savage_dri\.h%' $i
sleep 1s
done

#xf86Xxorg/input.h
files=`grep -I -r -m1 'xf86Xxorg/input\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xf86Xxorg/input\.h%xorg/xf86Xinput\.h%' $i
sleep 1s
done

#xf86OSKbd.h
#files=`grep -r -m1 'xf86OSKbd\.h' * |cut -f1 -d':'|sort -u`
#for i in $files;do
#echo "Repairing in $i..."
#sed -i 's%xf86OSKbd\.h%xorg/xf86OSKbd\.h%' $i
#sleep 1s
#done

#tdfx_xorg/dri.h
files=`grep -I -r -m1 'tdfx_xorg/dri\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%tdfx_xorg/dri\.h%tdfx_dri\.h%' $i
sleep 1s
done

#xorg/xf86OSsys/mouse.h
files=`grep -I -r -m1 'xorg/xf86OSsys/mouse\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86OSsys/mouse\.h%xorg/xf86OSmouse\.h%' $i
sleep 1s
done

#radeon_xorg/sarea.h
files=`grep -I -r -m1 'radeon_xorg/sarea\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%radeon_xorg/sarea\.h%radeon_sarea\.h%' $i
sleep 1s
done

#radeon_driver.c:5474: error: 'xorg' undeclared (first use in this function)
#radeon_driver.c:5474: error: 'xf86' undeclared (first use in this function)
#xf86_hide_cursors
#xorg/xf86.hide_cursors
files=`grep -I -r -m1 'xorg/xf86\.hide_cursors' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.hide_cursors%xf86_hide_cursors%' $i
sleep 1s
done


#alp_driver.c:705: error: 'xorg' undeclared (first use in this function)
#alp_driver.c:705: error: (Each undeclared identifier is reported only once
#alp_driver.c:705: error: for each function it appears in.)
#alp_driver.c:705: error: 'xf86' undeclared (first use in this function)

#xf86CheckPciMemBase
#xorg/xf86.heckPciMemBase
files=`grep -I -r -m1 'xorg/xf86\.heckPciMemBase' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.heckPciMemBase%xf86CheckPciMemBase%' $i
sleep 1s
done

#xorg/xorg/fb.h

#mxorg/fb.h
files=`grep -I -r -m1 'mxorg/fb\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%mxorg/fb\.h%mfb\.h%' $i
sleep 1s
done


#generic.c:689: error: 'xorg' undeclared (first use in this function)
#generic.c:689: error: (Each undeclared identifier is reported only once
#generic.c:689: error: for each function it appears in.)
#generic.c:689: error: 'xf86' undeclared (first use in this function)
#xf86ShowClocks
#xorg/xf86.howClocks
files=`grep -I -r -m1 'xorg/xf86\.howClocks' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.howClocks%xf86ShowClocks%' $i
sleep 1s
done

#mga_xorg/sarea.h



