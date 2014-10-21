#!/bin/ash

source /etc/rc.d/f4puppy5

source .config

UNAME=`awk '/^# Linux\/i386 .* Kernel Configuration/ {print $3}' .config`
test "$UNAME" || _exit 10 "No Uname .."
test "${UNAME//[[:digit:].]/}" && _exit 11 "UNAME '$UNAME' Wrong letters .."

UNAME_R="${UNAME}${CONFIG_LOCALVERSION}"

#bash-3.00# make kernelversion
#3.7.10
#bash-3.00# make kernelrelease
#3.7.10-KRG-i486-smp-pae-lzo

cp -a .config DOTconfig-$UNAME_R

make install

cp -a /boot/vmlinuz     /boot/vmlinuz-$UNAME_R
cp -a /boot/System.map  /boot/System.map-$UNAME_R


make modules_install  #INSTALL_MOD_PATH  #(default: /)


cp -a  DOTconfig-$UNAME_R          /lib/modules/$UNAME_R/ || _exit 13 "/lib/modules/$UNAME_R/ probs ..."
cp -a  /boot/vmlinuz-$UNAME_R      /lib/modules/$UNAME_R/ || _exit 14 "/lib/modules/$UNAME_R/ probs ..."
cp -a  /boot/System.map-$UNAME_R   /lib/modules/$UNAME_R/ || _exit 15 "/lib/modules/$UNAME_R/ probs ..."

mv /lib/firmware /lib/firmware-"`date +%F-%T`"

make firmware_install   #INSTALL_FW_PATH
                        ##(default: $(INSTALL_MOD_PATH)/lib/firmware)

cp -a /lib/firmware                     /lib/modules/$UNAME_R/ || _exit 20  "firmware probs ..."
mv    /lib/modules/$UNAME_R/firmware    /lib/modules/$UNAME_R/firmware-$UNAME_R || _exit 21 "firmware probs ..."

make headers_install  #INSTALL_HDR_PATH

cp -a  usr/include                   /lib/modules/$UNAME_R/ || _exit 23  "header probs ..."
mv    /lib/modules/$UNAME_R/include  /lib/modules/$UNAME_R/include-$UNAME_R
