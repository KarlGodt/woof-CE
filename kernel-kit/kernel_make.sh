#!/bin/sh

DATE_START="`date`"
if [ -e make-errs.log ] ; then
max=0
rotates=`ls -1 make-errs.log.[0-9]* |cut -f3 -d.`
for r in $rotates ; do
[ "$r" -gt $max ] && max=$r
done
for n in `seq $max -1 0` ; do
[ -e make-errs.log.$n ] && mv make-errs.log.$n make-errs.log.$((n+1))
done
mv make-errs.log make-errs.log.0
fi

make menuconfig
make_menu_config_returns=$?
echo "$DATE_START"
echo "`date`"
[ "$make_menu_config_returns" -eq 0 ] || exit $make_menu_config_returns
CONFIG_LOCALVERSION="MY-version-appending"
CONFIG_LOCALVERSION=`grep -m1 '^CONFIG_LOCALVERSION=' .config |sed 's|.*="||;s|"$||'`
[ "$CONFIG_LOCALVERSION" ] || CONFIG_LOCALVERSION="`date`"

# Linux/i386 3.4.9 Kernel Configuration
VERSION=`grep -m1 'Kernel Configuration' .config |rev |cut -f3 -d ' ' |rev`

cp .config DOTconfig-"$VERSION"-"$CONFIG_LOCALVERSION"
echo VERSION=$VERSION CONFIG_LOCALVERSION=$CONFIG_LOCALVERSION
read -p "Do you want to make the kernel now ? [y|AnyKey][Enter] : " Make_it
[ "$Make_it" ] || Make_it=y
echo Make_it=$Make_it
if [ "$Make_it" != 'y' -a "$Make_it" != 'Y' ] ; then
exit 0
fi

#exit
DATE_START="`date`"
make
make_returns=$?
echo "$DATE_START"
echo "`date`"
[ "$make_returns" -eq 0 ] || exit $make_returns

if [ -e /boot/vmlinuz ] ; then
mv /boot/vmlinuz /boot/vmlinuz-"`date`"
fi

if [ -e /boot/System.map ] ; then
mv /boot/System.map /boot/System.map-"`date`"
fi

make install
make_install_returns=$?
[ "$make_install_returns" -eq 0 ] || exit $make_install_returns
sleep 1
sync
mv /boot/vmlinuz /boot/vmlinuz-"$VERSION"-"$CONFIG_LOCALVERSION"
cp /boot/System.map /boot/System.map-"$VERSION"-"$CONFIG_LOCALVERSION"

if [ -e /lib/firmware ] ; then
mv /lib/firmware /lib/firmware-"`date`"
fi

make firmware_install
make_firmware_install_returns=$?
[ "$make_firmware_install_returns" -eq 0 ] || exit $make_firmware_install_returns
sleep 1
sync
echo "$VERSION"-"$CONFIG_LOCALVERSION" >/lib/firmware/"$VERSION"-"$CONFIG_LOCALVERSION".version
mv /lib/firmware /lib/firmware-"$VERSION"-"$CONFIG_LOCALVERSION"

make modules_install
make_modules_install_returns=$?
[ "$make_modules_install_returns" -eq 0 ] || exit $make_modules_install_returns
sleep 1
sync

make headers_install
make_headers_install_returns=$?
[ "$make_headers_install_returns" -eq 0 ] || exit $make_headers_install_returns
sleep 1
sync

