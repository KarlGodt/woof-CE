#!/bin/bash

#
#
#

#
#
#

#i740_driver.c:1645: error: 'xorg' undeclared (first use in this function)
#i740_driver.c:1645: error: (Each undeclared identifier is reported only once
#i740_driver.c:1645: error: for each function it appears in.)
#i740_driver.c:1645: error: 'xf86' undeclared (first use in this function)

#xf86ShowUnusedOptions
#xorg/xf86.howUnusedOptions

files=`grep -I -r -m1 'xorg/xf86\.howUnusedOptions' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.howUnusedOptions%xf86ShowUnusedOptions%' $i
sleep 1s
done


#jstk.c:439: error: 'xorg' undeclared (first use in this function)
#jstk.c:439: error: (Each undeclared identifier is reported only once
#jstk.c:439: error: for each function it appears in.)
#jstk.c:439: error: 'xf86' undeclared (first use in this function)

#xf86CheckStrOption
#xorg/xf86.heckStrOption

files=`grep -I -r -m1 'xorg/xf86\.heckStrOption' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.heckStrOption%xf86CheckStrOption%' $i
sleep 1s
done


#synaptics.c:436: error: 'xorg' undeclared (first use in this function)
#synaptics.c:436: error: (Each undeclared identifier is reported only once
#synaptics.c:436: error: for each function it appears in.)
#synaptics.c:436: error: 'xf86' undeclared (first use in this function)

#xf86CheckIfOptionUsedByName
#xorg/xf86.heckIfOptionUsedByName

files=`grep -I -r -m1 'xorg/xf86\.heckIfOptionUsedByName' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.heckIfOptionUsedByName%xf86CheckIfOptionUsedByName%' $i
sleep 1s
done


#mouse.c:1056: error: 'xorg' undeclared (first use in this function)
#mouse.c:1056: error: (Each undeclared identifier is reported only once
#mouse.c:1056: error: for each function it appears in.)
#mouse.c:1056: error: 'xf86' undeclared (first use in this function)


#fxorg/fb.h
files=`grep -I -r -m1 'fxorg/fb\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%fxorg/fb\.h%ffb\.h%' $i
sleep 1s
done

#sis_xorg/dri.h
files=`grep -I -r -m1 'sis_xorg/dri\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%sis_xorg/dri\.h%sis_dri\.h%' $i
sleep 1s
done

#mga_xorg/sarea.h
files=`grep -I -r -m1 'mga_xorg/sarea\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%mga_xorg/sarea\.h%mga_sarea\.h%' $i
sleep 1s
done

#glint_driver.c:672: error: 'xorg' undeclared (first use in this function)
#glint_driver.c:672: error: (Each undeclared identifier is reported only once
#glint_driver.c:672: error: for each function it appears in.)
#glint_driver.c:672: error: 'xf86' undeclared (first use in this function)
#xf86CheckPciSlot
#xorg/xf86.heckPciSlot

files=`grep -I -r -m1 'xorg/xf86\.heckPciSlot' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.heckPciSlot%xf86CheckPciSlot%' $i
sleep 1s
done

#sisusb_driver.c:510: error: 'struct <anonymous>' has no member named 'sisxorg'
#sisusb_driver.c:510: error: 'fb' undeclared (first use in this function)
#sisusb_driver.c:510: error: (Each undeclared identifier is reported only once
#sisusb_driver.c:510: error: for each function it appears in.)
#sisusb_driver.c: In function 'SISUSBPreInit':
#sisusb_driver.c:917: error: 'struct <anonymous>' has no member named 'sisxorg'
#sisusb_driver.c:917: error: 'fb' undeclared (first use in this function)
#sisusb_driver.c:974: error: 'struct <anonymous>' has no member named 'sisxorg'
#sisfb_havelock
#sisxorg/fb.havelock

files=`grep -I -r -m1 'sisxorg/fb\.havelock' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%sisxorg/fb\.havelock%sisfb_havelock%' $i
sleep 1s
done

#fbdev.c:521: error: 'xorg' undeclared (first use in this function)
#fbdev.c:521: error: (Each undeclared identifier is reported only once
#fbdev.c:521: error: for each function it appears in.)
#fbdev.c:521: error: 'xf86' undeclared (first use in this function)
#xf86CheckModeForMonitor
#xorg/xf86.heckModeForMonitor
files=`grep -I -r -m1 'xorg/xf86\.heckModeForMonitor' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xorg/xf86\.heckModeForMonitor%xf86CheckModeForMonitor%' $i
sleep 1s
done

#sisxorg/fb.haveemi
#sisxorg/fb.haveemilcd
files=`grep -I -r -m1 'sisxorg/fb\.haveemi' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%sisxorg/fb\.haveemi%sisfb_haveemi%' $i
sleep 1s
done


#sisfb_heapsize
#sisxorg/fb.heapsize
files=`grep -I -r -m1 'sisxorg/fb\.heapsize' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%sisxorg/fb\.heapsize%sisfb_heapsize%' $i
sleep 1s
done


#xcb/xf86xorg/dri.h
files=`grep -I -r -m1 'xcb/xf86xorg/dri\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xcb/xf86xorg/dri\.h%X11/dri/xf86dri.h%' $i
sleep 1s
done

#xgi_xorg/dri.h
files=`grep -I -r -m1 'xgi_xorg/dri\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%xgi_xorg/dri\.h%xgi_dri\.h%' $i
sleep 1s
done

#drm/drm.handle_t
files=`grep -I -r -m1 'drm/drm\.handle_t' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%drm/drm\.handle_t%drm_handle_t%' $i
sleep 1s
done

#xorg/xf86DDC.h
#sis_xorg/dri.h
#mach64_xorg/dri.h
#xorg/xf86.howClocks

#geode_avifile-0.7/fourcc.h
#geode_fourcc.h
#geode_avifile-0.7/fourcc.h
files=`grep -I -r -m1 'geode_avifile\-0\.7/fourcc\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%geode_avifile-0\.7/fourcc\.h%geode_fourcc\.h%' $i
sleep 1s
done

#rhd_xorg/dri.h
files=`grep -I -r -m1 'rhd_xorg/dri\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%rhd_xorg/dri\.h%rhd_dri\.h%' $i
sleep 1s
done

#nsc_avifile-0.7/fourcc.h
files=`grep -I -r -m1 'nsc_avifile\-0\.7/fourcc\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%nsc_avifile-0\.7/fourcc\.h%nsc_fourcc\.h%' $i
sleep 1s
done


#radeon_xorg/dri.h
files=`grep -I -r -m1 'radeon_xorg/dri\.h' * |cut -f1 -d':'|sort -u`
for i in $files;do
echo "Repairing in $i..."
sed -i 's%radeon_xorg/dri\.h%radeon_dri\.h%' $i
sleep 1s
done
