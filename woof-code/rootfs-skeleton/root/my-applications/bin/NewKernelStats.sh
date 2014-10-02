#!/bin/bash

#TODO filenames with spaces :
#/proc/irq/18/SiS
#SI7012
#
#sed 's/[[:space:]]/·/g' ;
#echo "$j" | tr '·' '[[:space:]]' :
#/proc/irq/18/SiS[	SI7012
#
#sed 's/[[:space:]]/;/g' ;
#echo "$j" | tr ';' '[[:space:]]' :
#/proc/irq/18/SiS[SI7012

KV=`uname -r`
DF=`date | tr ' ' '_'`
RMD="/root/my-documents/KerNEL"
. /etc/DISTRO_SPECS

##+++2011-11-07
SYSTEM=`dmidecode -t 0 | grep -i -E 'vendor|version|release'`
SYSTEM="$SYSTEM
`dmidecode -t 1 | grep -i -E 'manufacturer|version|product'`"
SYSTEM="$SYSTEM
`dmidecode -t 2 | grep -i -E 'manufacturer|version|product'`"
##+++2011-11-07

if [ -d $RMD/$KV ]; then # && mv $RMD/$KV $RMD/$KV.bac
F=`ls $RMD | grep $KV`
for i in $F; do
(( a++ ))
done
mv $RMD/$KV $RMD/$KV.$a
fi

[ ! -d $RMD/$KV ] && mkdir -p $RMD/$KV

exec 2>$RMD/$KV/errs.log

PSMUTD=`ps | grep -E 'mutd|mutdaemon|mutforeground' | grep -v 'grep'`
elspci -l > $RMD/$KV/elspci
echo >> $RMD/$KV/elspci
mut --noserv probepci --list >> $RMD/$KV/elspci
echo >> $RMD/$KV/elspci
scanpci -V 5 >> $RMD/$KV/elspci 2>&1
echo >> $RMD/$KV/elspci
scanpci -v >> $RMD/$KV/elspci
if test -z "$PSMUTD" ; then
mut --exit 1>/dev/null
fi

dmidecode > $RMD/$KV/dmidecode  ##++20111-11-07

lsmod > $RMD/$KV/lsmod

LSMOD=`lsmod | cut -f 1 -d ' '`
echo 'LOADED BUILDIN MODULES:' > $RMD/$KV/allmodules
BM=`ls -1 /sys/module/ | grep -v "$LSMOD" | tr '\n' ' '`  ##+2011-11-07 ls to ls -1
NBM=`echo "$BM" | wc -w`
echo "$NBM" >> $RMD/$KV/allmodules
echo "$BM" >> $RMD/$KV/allmodules
echo >> $RMD/$KV/allmodules
echo >> $RMD/$KV/allmodules
modprobe -l | wc -l >> $RMD/$KV/allmodules
echo >> $RMD/$KV/allmodules
modprobe -l >> $RMD/$KV/allmodules


lspci > $RMD/$KV/lspci
echo >> $RMD/$KV/lspci
lspci -v >> $RMD/$KV/lspci
echo >> $RMD/$KV/lspci
lspci -vv >> $RMD/$KV/lspci
echo >> $RMD/$KV/lspci

LSUSB=`which lsusb`
[ "$LSUSB" = "" ] && LSUSB=`which lsusb-FULL`
[ "$LSUSB" = "" ] && LSUSB="busybox lsusb"
if [ "$LSUSB" = "busybox lsusb" ] ; then
$LSUSB > $RMD/$KV/lsusb
else
exec $LSUSB  > $RMD/$KV/lsusb &
sleep 1
echo >> $RMD/$KV/lsusb
exec $LSUSB -v >> $RMD/$KV/lsusb &
sleep 3
echo >> $RMD/$KV/lsusb
exec $LSUSB -vv >> $RMD/$KV/lsusb &
fi


cp /tmp/bootkernel*.log $RMD/$KV/
cp /tmp/bootsysinit* $RMD/$KV/
cp /tmp/boot.* $RMD/$KV/

cp /tmp/pup_eve* $RMD/$KV/
cp /tmp/udev* $RMD/$KV/


cp /tmp/xerrs* $RMD/$KV/
cp /tmp/xorg* $RMD/$KV/
cp /var/log/Xorg.0.log $RMD/$KV/

cp /var/log/messages $RMD/$KV/
cp /var/log/messages.0 $RMD/$KV/

touch $RMD/$KV/Notes
echo "$SYSTEM" > $RMD/$KV/Notes
echo $KV >> $RMD/$KV/Notes
echo $DF >> $RMD/$KV/Notes
cat /proc/cmdline >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
echo '$HOME='$HOME >> $RMD/$KV/Notes
echo '________________________________________' >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
uptime >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
free >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
top -n1 >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
echo '________________________________________' >> $RMD/$KV/Notes

######
echo '/proc/fb :' >> $RMD/$KV/graphics
cat /proc/fb >> $RMD/$KV/graphics
echo '________________________________________' >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
F=`find /sys/class/graphics/*/*/*/*/*/* -name modes |sort`
for i in $F; do
echo $i >> $RMD/$KV/graphics
cat $i >> $RMD/$KV/graphics
done
echo '________________________________________' >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
F=`find /sys/class/graphics/*/*/*/*/*/* -name virtual_size |sort`
for i in $F; do
echo $i >> $RMD/$KV/graphics
cat $i >> $RMD/$KV/graphics
done
echo '________________________________________' >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics

X=`which X`
RLX=`readlink -f $X`
LSX=`ls -l $X`
echo "$X" "$RLX" >> $RMD/$KV/graphics
echo "$LSX" >> $RMD/$KV/graphics
file "$RLX" >> $RMD/$KV/graphics
echo '________________________________________' >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics

xdpyinfo >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
ddcprobe >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
xwininfo -root >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
Xvesa -listmodes 2>> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
echo '________________________________________' >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
modprobe -l | grep -E 'vga|fb|agp|drm|i2c' >> $RMD/$KV/graphics

#####
df > $RMD/$KV/drives
echo >> $RMD/$KV/drives
mount >> $RMD/$KV/drives
echo >> $RMD/$KV/drives
BD=`ls -1 /sys/class/block`
for i in $BD; do
ls -l /dev/$i >> $RMD/$KV/drives
done
echo >> $RMD/$KV/drives
ls -l /dev/root >> $RMD/$KV/drives
echo >> $RMD/$KV/drives
cat /proc/partitions >> $RMD/$KV/drives
echo >> $RMD/$KV/drives

echo >> $RMD/$KV/Notes
FP=`find /proc/irq/*/* -type d | sort`
echo "$FP" >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
cat /proc/interrupts >> $RMD/$KV/Notes
echo '________________________________________' >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes

PF=`ls /sys/module/*/parameters/*`
for i in $PF; do
echo $i >> $RMD/$KV/Notes
PERM=`ls -l $i | cut -b 2`
if [ "$PERM" != "r" ] ; then
chmod +r $i
cat $i >> $RMD/$KV/Notes
chmod -r $i
else
cat $i >> $RMD/$KV/Notes
fi
echo >> $RMD/$KV/Notes
done

##### sound
aplay /usr/share/audio/2barks.au 2>$RMD/$KV/sound
echo >> $RMD/$KV/sound
aplay -l >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
aplay -L >> $RMD/$KV/sound
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
ls -lF /dev/card* >> $RMD/$KV/sound
ls -lF /dev/control* >> $RMD/$KV/sound
ls -lF /dev/a* >> $RMD/$KV/sound
ls -lF /dev/mid* >> $RMD/$KV/sound
ls -lF /dev/mix* >> $RMD/$KV/sound
ls -lF /dev/music* >> $RMD/$KV/sound
ls -lF /dev/pcm* >> $RMD/$KV/sound
ls -lF /dev/seq* >> $RMD/$KV/sound
ls -lF /dev/sound* >> $RMD/$KV/sound
ls -lF /dev/speak* >> $RMD/$KV/sound
ls -lF /dev/timer* >> $RMD/$KV/sound
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
ls -lF /dev/snd* >> $RMD/$KV/sound
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
udevinfo --export-db | grep sound >> $RMD/$KV/sound
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound

D=`find /sys -type d -name "*sound*" -o -name "*snd*" |sort`
for i in $D ; do
echo $i >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
ls -lF $i >> $RMD/$KV/sound
ls -lF $i/* >> $RMD/$KV/sound
echo >> $RMD/$KV/sound

F=`find $i -type f | grep -v -E '/power/|event|note\.gnu\.build-id' |sort`
for j in $F ; do
echo $j >> $RMD/$KV/sound
cat $j >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
done
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
done
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound

PAS=`find /proc/asound -type f |sort`
for i in $PAS ; do
echo $i >> $RMD/$KV/sound
cat $i >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
done
echo '________________________________________' >> $RMD/$KV/sound
echo >> $RMD/$KV/sound

#for i in $D ; do
#echo $i >> $RMD/$KV/sound
#ls -lF $i >> $RMD/$KV/sound
#ls -lF $i/* >> $RMD/$KV/sound
#echo >> $RMD/$KV/sound
#done
echo >> $RMD/$KV/sound

####PROC
P=`find /proc -maxdepth 1 -type f | grep -v -E '^/proc/k|^/proc/sysrq' |sort`
for i in $P; do
echo $i >> $RMD/$KV/procfiles
cat $i >> $RMD/$KV/procfiles
echo '________________________________________' >> $RMD/$KV/procfiles
echo >> $RMD/$KV/procfiles
done

cat_proc_func() {
PD=`find /proc  -type d  2> /dev/null | grep -v -E '^/proc/[0-9]|^/proc/self' | sed 's#/proc##' | sort`
PD=`echo "$PD" | sed '/^$/d'`
PD=`echo "$PD" | sed 's#^#/proc#' | sed 's/[[:space:]]/;/g'`

for i in $PD; do
i=`echo "$i" | tr ';' ' '`
echo "$i";
cd "$i";
echo >> $RMD/$KV/procfiles.complete
echo 'Directory '`pwd` >> $RMD/$KV/procfiles.complete
echo >> $RMD/$KV/procfiles.complete
F=`ls "$i" | sed '/^$/d' | sed 's/[[:space:]]/;/g'`;

if [ -n "$F" ] ; then

for j in $F; do
j=`echo "$j" | tr ';' ' '`
echo 'Content of '"$i/$j"' :' >> $RMD/$KV/procfiles.complete
echo '****************************************' >> $RMD/$KV/procfiles.complete
PWDIR=`pwd`

[ -n "`echo "$PWDIR" | grep '/proc/bus/pnp'`" ] && continue

L=`file "$j" | grep empty`;


if test "$L" != "" && test "`echo "$L" | grep -v -E 'dsdt|event|fadt'`" != "" ; then

cat "$j" >> $RMD/$KV/procfiles.complete
echo '****************************************' >> $RMD/$KV/procfiles.complete
echo '________________________________________' >> $RMD/$KV/procfiles.complete
echo >> $RMD/$KV/procfiles.complete

else
if [ -d "$i/$j" ] ; then
echo 'Is a directory ...' >> $RMD/$KV/procfiles.complete
elif [ -f "$i/$j" ] ; then
echo 'File not readable by this script ...' >> $RMD/$KV/procfiles.complete
fi
echo '________________________________________' >> $RMD/$KV/procfiles.complete
echo >> $RMD/$KV/procfiles.complete
fi
done
else
echo 'Directory seems to be empty ...' >> $RMD/$KV/procfiles.complete
echo '________________________________________' >> $RMD/$KV/procfiles.complete
echo >> $RMD/$KV/procfiles.complete
fi


echo '________________________________________' >> $RMD/$KV/procfiles.complete
echo >> $RMD/$KV/procfiles.complete
done

}
cat_proc_func


######FIN
rox $RMD/$KV &
for i in $RMD/$KV/* ; do
geany $i &
sleep 1s #10
done

exit
#####END


