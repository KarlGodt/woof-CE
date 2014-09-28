#!/bin/bash
#Barry Kauler 2009
#w001 now in /usr/sbin in the distro, called from /etc/rc.d/rc.update.
#w474 bugfix for 2.6.29 kernel, modules.dep different format.
#w478 old k2.6.18.1 has madwifi modules (ath_pci.ko) in /lib/modules/2.6.18.1/net.
#v423 now using busybox depmod, which generates modules.dep in "old" format.

  _TITLE_=update_netmodules
_VERSION_=1.0omega
_COMMENT_="CLI to write /etc/networkmodules file"

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_
called from /etc/rc.d/rc.update"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}

test "$KERNVER"    ||    KERNVER=`uname -r`
test "$KERNSUBVER" || KERNSUBVER=`echo -n $KERNVER | cut -f 3 -d '.' | cut -f 1 -d '-'` #29
test "$KERNMAJVER" || KERNMAJVER=`echo -n $KERNVER | cut -f 2 -d '.'` #6
DRIVERSDIR="/lib/modules/$KERNVER/kernel/drivers/net"

echo "Updating /etc/networkmodules..."

DEPFORMAT='new'
case $KERNVER in
2.*) [ $KERNSUBVER -lt 29 ] && [ $KERNMAJVER -eq 6 ] && DEPFORMAT='old';;
esac

#v423 need better test, as now using busybox depmod...
[ "`grep '^/lib/modules' /lib/modules/${KERNVER}/modules.dep`" != "" ] && DEPFORMAT='old'

if [ "$DEPFORMAT" = "old" ];then
 OFFICIALLIST=`cat /lib/modules/${KERNVER}/modules.dep | grep "^/lib/modules/$KERNVER/kernel/drivers/net/" | sed -e 's/\.gz:/:/' | cut -f 1 -d ':'`
else
 OFFICIALLIST=`cat /lib/modules/${KERNVER}/modules.dep | grep "^kernel/drivers/net/" | sed -e 's/\.gz:/:/' | cut -f 1 -d ':'`
fi

#there are a few extra scattered around... needs to be manually updated...
EXTRALIST="extra/acx.ko
extra/rt2400.ko
extra/rt2500.ko
extra/rt2570.ko
extra/rt61.ko
extra/rt73.ko
extra/acx-mac80211.ko
extra/atl2.ko
extra/rt2860sta.ko
extra/rt2870sta.ko
madwifi/ath_pci.ko
net/ath_pci.ko
linux-wlan-ng/prism2_usb.ko
linux-wlan-ng/prism2_pci.ko
linux-wlan-ng/prism2_plx.ko
r8180/r8180.ko
"
RAWLIST="$OFFICIALLIST
$EXTRALIST"

#the list has to be cutdown to genuine network interfaces only...
echo -n "" > /tmp/networkmodules
echo "$RAWLIST" |
while read oneRAW
do
 [ "$oneRAW" = "" ] && continue #precaution
 oneBASE=`basename $oneRAW .ko`
 modprobe -vn $oneBASE >/dev/null 2>&1
 oneINFO=`modinfo $oneBASE | tr '\t' ' ' | tr -s ' '`
 oneTYPE=`echo "$oneINFO" | grep '^alias:' | head -n 1 | cut -f 2 -d ' ' | cut -f 1 -d ':'`
 oneDESCR=`echo "$oneINFO" | grep '^description:' | head -n 1 | cut -f 2 -d ':'`
 if [ "$oneTYPE" = "pci" -o "$oneTYPE" = "pcmcia" -o "$oneTYPE" = "usb" ];then
  echo "Adding $oneBASE"
  echo -e "$oneBASE \"$oneTYPE: $oneDESCR\"" >> /tmp/networkmodules
 fi
 #v408 add b43legacy.ko...
 if [ "$oneTYPE" = "ssb" ];then
  echo "Adding $oneBASE"
  echo -e "$oneBASE \"$oneTYPE: $oneDESCR\"" >> /tmp/networkmodules
 fi
done

sort -u /tmp/networkmodules > /etc/networkmodules

###end###
# Very End of this file 'usr/sbin/updatenetmoduleslist.sh' #
###END###
