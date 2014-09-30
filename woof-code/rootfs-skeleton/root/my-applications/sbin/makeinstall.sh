#!/bin/bash

#
#
#

#
#
#

CD="`pwd`"
BN="${CD##*/}"
echo "BN=$BN"
ND="${BN}-`uname -m`"
EXE_TARGETDIR="../$ND"
mkdir -p "${EXE_TARGETDIR}" #suppress warn if already exist

#exit

make install

sync
F=`find /usr -mmin -3`
E=`find /etc -mmin -3`
S=`find /sbin -mmin -3`
B=`find /bin -mmin -3`
L=`find /lib -mmin -3`
C="$F
$E
$S
$B
$L"

C=`echo "$C" |sort -u`

for i in $C ; do
[ -d "$i" ] && mkdir -p "${EXE_TARGETDIR}${i}"
[ -f "$i" ] && cp -ia "${i}" "${EXE_TARGETDIR}${i}"
[ -L "$i" ] && cp -ia "${i}" "${EXE_TARGETDIR}${i}"
done

find -name "*.log" -exec cp {} ${EXE_TARGETDIR} \;

