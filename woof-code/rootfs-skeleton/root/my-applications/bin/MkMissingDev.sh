#!/bin/bash

Version='1.0 Macpup_O2-Puppy_Linux_431 KRG'

echo "$0 $Version START"

for p in $@;do
case "$1" in
h|H|-h|-H|-help|--help)
echo "USAGE :
$0 [ /path/to/dev ] {params]
Script cd to given dev directory ie . /mnt/sdb1/dev
and restores device nodes deleted by the udevd binary
started at boot up from busybox init -> /etc/rc.d/rc.sysinit .
If no path given , defaults to /dev .

Valid parameters:
C) -codecheck set -n
D) -debug  set -x
v) -verbose some diagnostig output
V) -version show version info
"
exit 0;;
C|-C|-codecheck|--codecheck) set -n;shift;;
D|-D|-debug|--debug) set -x;shift;;
v|-v|-verbose|--verbose) ME_VERB=1;shift;;
V|-V|-version|--version) echo -e "\n$0:\nVersion '$Version\nTry --help for moe info\n";exit 0;;
*|"") :;;
esac;done

check_frugal_full_func() {
CatProcPart=`cat /proc/partitions |tr -s ' ' | sed '1,2 d'`

RootDiskFreeFrugal=`df | grep -w '/' | grep 'rootfs'`
MountFrugal=`mount | grep '/initrd/mnt/dev_save' | cut -f 1 -d ' '`
[ ! "$MountFrugal" ] && MountFrugal=`mount | grep '/initrd/mnt/dev_ro2' | cut -f 1 -d ' '`

RootDiskReadlinkDevRoot=`readlink /dev/root`
RootDiskFreeFullInstall=`df | grep -w '/' | tr -s ' ' | cut -f 1 -d ' '`
MountFull=`mount | grep -w '/'`

if [ "$ME_VERB" ];then
echo "CatProcPart       :
'$CatProcPart'
RootDiskFreeFrugal      :'$RootDiskFreeFrugal'
MountFrugal             :'$MountFrugal'
RootDiskReadlinkDevRoot :'$RootDiskReadlinkDevRoot'
RootDiskFreeFullInstall :'$RootDiskFreeFullInstall'
MountFull               :'$MountFull'"
fi
}

check_frugal_full_func

check_extended_dev_func() {

if [ -n "$RootDiskFreeFrugal" ] && [ -n "$MountFrugal" ]; then ## frugal install
SimpleDeviceName=`echo $MountFrugal | sed 's#/dev/##'`
MainDriveName=${SimpleDeviceName:0:3}
RootDevice=`echo "$CatProcPart" | grep -w $SimpleDeviceName`
MainDevice=`echo "$CatProcPart" | grep -w $MainDriveName`
else
if [ -n "$RootDiskFreeFullInstall" ] && [ -n "$MountFull" ]; then ## full install
SimpleDeviceName=`echo $RootDiskFreeFullInstall | sed 's#/dev/##'`
MainDriveName=${SimpleDeviceName:0:3}
RootDevice=`echo "$CatProcPart" | grep -w $SimpleDeviceName`
MainDevice=`echo "$CatProcPart" | grep -w $MainDriveName`
fi
fi
  if [ "$ME_VERB" ];then
echo "SimpleDeviceName='$SimpleDeviceName'
MainDriveName='$MainDriveName'
RootDevice='$RootDevice'"
           fi
sleep 2

if test "`echo $RootDevice | grep '^259'`" != "" ; then
echo "Normal DEVICE MAKER, but found extended MAJOR for DISK"
#echo "exiting now"
[ "`which MkMissing259Dev.sh`" ] && exec MkMissing259Dev.sh
#MkMissing259Dev.sh
exit
fi

if test "`echo $MainDriveName | grep '^259'`" != "" ; then
echo "Normal DEVICE MAKER, but found extended MAJOR mismatch for DISK"
echo "exiting now"
exit
fi
}

check_extended_dev_func

STARTDIR=`pwd`

PARAM="/dev"
if test "`echo $STARTDIR | grep '/dev'`" != "" ; then
# opened terminal @ ..../dev
PARAM="$STARTDIR"
cd "$PARAM"
fi
[ "$1" ] && PARAM="$1" # called like MkMissingDev.sh /mnt/sdaNR/dev
if [ -n "$1" ] ; then
if [ "`echo $PARAM | grep '/dev'`" = "" ]; then
echo "invalid PATH , no '/dev' in '$1'" && exit
elif [ ! -d "$1" ] ; then
echo "PATH $1 seems not to exist"
exit
elif [ -e "$1" ] && [ "$1" = "$PARAM" ] ; then
cd "$PARAM"
else
if [ -e "$1" ] ; then
[ -n "$1" ] && cd "$PARAM"
fi
fi
else
if [ -z "$1" ] ; then
PARAM="/dev"
cd /dev
fi
fi



if test "`pwd | grep '/dev'`" = "" ; then
cd /dev
fi

#cd `pwd`
WD=`pwd`
DN=`dirname $WD`
if test "`echo $DN | grep 'mnt'`" != "" ; then
PRFIX="$DN"
else
PRFIX=""
fi
#ls -l /dev/sd*
J=0
for I in a b c d e f g h i; do

if test ! -b $PRFIX/dev/sd$I ; then
mknod $PRFIX/dev/sd$I b 8 $J
fi
#if test ! -b $PRFIX/dev/hd$I ; then
#mknod $PRFIX/dev/hd$I b 8 $J
#fi

J=`expr $J + 16`
done

J=0
for K in a b c d e f g h i; do
for L in {1..15} ; do
M=`expr $J + $L`

if test ! -b $PRFIX/dev/sd$K$L ; then
mknod $PRFIX/dev/sd$K$L b 8 $M
fi
#if test ! -b $PRFIX/dev/hd$K$L ; then
#mknod $PRFIX/dev/hd$K$L b 8 $M
#fi
done

J=`expr $J + 16`
done

for i in 0 1 2 3 ; do

if test ! -b $PRFIX/dev/sr$i; then
mknod $PRFIX/dev/sr$i b 11 $i
fi
done

J=0
for I in a b ;do
if test ! -b $PRFIX/dev/hd$I ; then
mknod $PRFIX/dev/hd$I b 3 $J
fi
J=`expr $J + 64`
done

J=0
for I in c d ;do
if test ! -b $PRFIX/dev/hd$I ; then
mknod $PRFIX/dev/hd$I b 22 $J
fi
J=`expr $J + 64`
done

J=0
for K in a b; do
for L in {1..15} ; do
M=`expr $J + $L`
if test ! -b $PRFIX/dev/hd$K$L ; then
mknod $PRFIX/dev/hd$K$L b 3 $M
fi
done
J=`expr $J + 64`
done

J=0
for K in c d; do
for L in {1..15} ; do
M=`expr $J + $L`
if test ! -b $PRFIX/dev/hd$K$L ; then
mknod $PRFIX/dev/hd$K$L b 22 $M
fi
done
J=`expr $J + 64`
done


i=0
I=0
J=0
K=0
L=0

cd $STARTDIR
echo "$0 END"


