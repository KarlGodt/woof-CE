#!/bin/bash
##### various hardware infos for puppy linux
### Karl Reimer Godt Kiel,NorthGermany 2011
####



########################################################################
#
#
#
# FAST as on June 2012
#
# /dev/hda7
# /dev/hda7:
# LABEL="/"
# UUID="429ee1ed-70a4-43a5-89f8-33496c489260"
# TYPE="ext4"
# DISTRO_NAME='LucidÂPuppy'
# DISTRO_VERSION=218
# DISTRO_MINOR_VERSION=00
# DISTRO_BINARY_COMPAT='ubuntu'
# DISTRO_FILE_PREFIX='luci'
# DISTRO_COMPAT_VERSION='lucid'
# DISTRO_KERNEL_PET='linux_kernel-2.6.33.2-tickless_smp_patched-L3.pet'
# PUPMODE=2
# SATADRIVES=''
# PUP_HOME='/'
# PDEV1='hda7'
# DEV1FS='ext4'
# LinuxÂpuppypcÂ2.6.31.14Â#1ÂMonÂJanÂ24Â21:03:21ÂGMT-8Â2011Âi686ÂGNU/Linux
# Xserver=/usr/bin/Xorg
# $LANG=en_US
# today=TueÂOctÂ25Â12:33:13ÂGMT+1Â2011
#
#
#
#
#
########################################################################

####VARS
KV=`uname -r`
DF=`date | tr ' ' '_'`
RMD="/root/my-documents/KerNEL"

#####DIR
if [ -d $RMD/$KV ]; then
F=`ls $RMD | grep $KV`
for i in $F; do
(( a++ ))
done
mv "$RMD/$KV" "$RMD/$KV.$a"
fi

[[ -d "$RMD/$KV" ]] || mkdir -p $RMD/$KV

alt_kerndir_func() {
[ -d $RMD/$KV ] && mv $RMD/$KV $RMD/$KV.`date +%d%b%Hh%M`
[ -d $RMD/$KV ] || mkdir -p $RMD/$KV
}

#####ERROR
exec 2> $RMD/$KV/errs


echo '##### *ls*'
PSMUTD=`ps | grep -E 'mutd|mutdaemon|mutforeground' | grep -v 'grep'`
elspci -l > $RMD/$KV/elspci
echo >> $RMD/$KV/elspci
mut --noserv probepci --list >> $RMD/$KV/elspci
echo >> $RMD/$KV/elspci
scanpci >> $RMD/$KV/elspci
if test -z "$PSMUTD" ; then
pidof mut && mut --exit
fi

lsmod > $RMD/$KV/lsmod

lspci > $RMD/$KV/lspci
echo >> $RMD/$KV/lspci
lspci -v >> $RMD/$KV/lspci
echo >> $RMD/$KV/lspci
lspci -vv >> $RMD/$KV/lspci

if [ "`which lsusb`" != "" ]; then
lsusb > $RMD/$KV/lsusb
echo >> $RMD/$KV/lsusb
lsusb -v >> $RMD/$KV/lsusb
echo >> $RMD/$KV/lsusb
lsusb -vv >> $RMD/$KV/lsusb
else
if [ "`busybox | grep lsusb`" != "" ] ; then
busybox lsusb > $RMD/$KV/lsusb.bb
echo >> $RMD/$KV/lsusb.bb
busybox lsusb -v > $RMD/$KV/lsusb.bb
echo >> $RMD/$KV/lsusb.bb
busybox lsusb -vv > $RMD/$KV/lsusb.bb
fi
fi


echo '##### TMP VAR'
TBL=`find /tmp -type f -name "*boot*"`
for i in $TBL ; do
if test "$i" != "/tmp/bootcnt.txt" ; then
cp $i $RMD/$KV/
fi
done

#cp /tmp/xerrs.log* $RMD/$KV/
xF=`find /tmp -maxdepth 1 -type f -name "x*"`
for i in $xF ; do
cp $i $RMD/$KV/
done
XF=`find /tmp -maxdepth 1 -type f -name "X*"`
for i in $XF ; do
cp $i $RMD/$KV/
done

cp /var/log/messages $RMD/$KV/
cp /var/log/messages.0 $RMD/$KV/

cp /var/log/Xorg.0.log $RMD/$KV/

echo '#freq scaling'
CPUF=`find /sys/devices/system/cpu/ -type f`
for i in $CPUF;do
echo $i >>$RMD/$KV/cpu_freq
cat $i >>$RMD/$KV/cpu_freq
done

echo '##### MISC into Notes'
touch $RMD/$KV/Notes
echo $KV >> $RMD/$KV/Notes
echo $DF >> $RMD/$KV/Notes
cat /proc/cmdline >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
mount >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
df >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
rdev >> $RMD/$KV/Notes
ls -l /dev/root >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
uptime >> $RMD/$KV/Notes
free >> $RMD/$KV/Notes
top -n 1 >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
echo '##### IRQ'
FP=`find /proc/irq/*/* -type d`
echo "$FP" >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
echo '##### framebuffer'
echo "/proc/fb" >> $RMD/$KV/Notes
cat /proc/fb >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
echo '##### /sys/*/names'
namef=`find /sys -type f -name 'name'`
for i in $namef; do
echo $i >> $RMD/$KV/Notes
cat $i >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
done
echo >> $RMD/$KV/Notes
echo '##### params'
echo "PARAMETERS" >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
PF=`ls /sys/module/*/parameters/*`
for i in $PF; do
echo $i >> $RMD/$KV/Notes
cat $i >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
done
echo >> $RMD/$KV/Notes
#####
echo "DRIVERS AUTOPROBE" >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
AP=`find /sys -type f -name "*autoprobe*"`
for i in $AP; do
echo $i >> $RMD/$KV/Notes
cat $i >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
done
#### Notes: drivers 1/2 of file !
echo "DRIVERS" >> $RMD/$KV/Notes
echo >> $RMD/$KV/Notes
DR=`find /sys -type d -name 'drivers'`
for i in $DR; do
echo $i >> $RMD/$KV/Notes
ls -1 -F $i/* | grep -v -E 'bind|event' >> $RMD/$KV/Notes
echo  >> $RMD/$KV/Notes
done
echo >> $RMD/$KV/Notes
dmidecode >> $RMD/$KV/Notes


echo '##### sound'

aplay /usr/share/audio/2barks.au 2>$RMD/$KV/sound
echo >> $RMD/$KV/sound
aplay -l >>$RMD/$KV/sound
echo >> $RMD/$KV/sound
aplay -L >>$RMD/$KV/sound
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
echo >> $RMD/$KV/sound
ls -lF /dev/snd* >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
udevinfo --export-db | grep sound >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
PAS=`find /proc/asound -type f`
for i in $PAS ; do
echo $i >> $RMD/$KV/sound
cat $i >> $RMD/$KV/sound
echo >> $RMD/$KV/sound
done


echo '##### drivers'
modprobe -l | wc -l > $RMD/$KV/modlist
modprobe -l >> $RMD/$KV/modlist

echo '##### graphics'
modprobe -l | grep -E 'fb|vga|agp' >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
cat /proc/fb >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
ls -lF /dev/fb* >> $RMD/$KV/graphics
ls -lF /dev/agp* >> $RMD/$KV/graphics
ls -lF /dev/console* >> $RMD/$KV/graphics
ls -l /dev/tty[0-9]* >> $RMD/$KV/graphics
ls -l /dev/vc* >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
WX=`which X`
RLFWX=`readlink -f $WX`
FRLFWX=`file $RLFWX`
echo "$WX" >> $RMD/$KV/graphics
echo "$RLFWX" >> $RMD/$KV/graphics
echo "$FRLFWX" >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
xdpyinfo >> $RMD/$KV/graphics
echo >> $RMD/$KV/graphics
F=`find /sys/class/graphics/*/*/*/*/*/* -name modes`
for i in $F; do
echo $i >> $RMD/$KV/graphics
cat $i >> $RMD/$KV/graphics
done

F=`find /sys/class/graphics/*/*/*/*/*/* -name virtual_size`
for i in $F; do
echo $i >> $RMD/$KV/graphics
cat $i >> $RMD/$KV/graphics
done

echo '#INPUT'
INPUT_1=`find /sys -iname "*input*"`
for i in $INPUT_1 ; do
MODA=`find $i -type f | grep modalias`;
for j in $MODA ; do
echo $j >> $RMD/$KV/input
cat $j >> $RMD/$KV/input
echo >> $RMD/$KV/input
done
done
echo
echo '####PROC'
P=`find /proc -maxdepth 1 -type f | grep -v -E '^/proc/k|^/proc/sysrq'`
for i in $P; do
echo $i >> $RMD/$KV/procfiles
cat $i >> $RMD/$KV/procfiles
echo >> $RMD/$KV/procfiles
done

cat_proc_func() {
PD=`find /proc  -type d  2> /dev/null | grep -v -E '^/proc/[0-9]|^/proc/self' | sed 's#/proc##'`
PD=`echo "$PD" | sed '/^$/d'`
PD=`echo "$PD" | sed 's#^#/proc#;s/[[:space:]]/;/g'`

for i in $PD; do
i=`echo "$i" | tr ';' ' '`
echo "$i";
cd "$i";
echo >> $RMD/$KV/procfiles.complete
pwd >> $RMD/$KV/procfiles.complete
echo;
F=`ls "$i" | sed 's/[[:space:]]/;/g'`;

for j in $F; do
j=`echo "$j" | tr ';' ' '`
echo "$j";

L=`file "$j" | grep empty`;
if test "`echo "$L" | grep -v -E 'dsdt|event|fadt|flush|plink_maint'`" != "" -a "$L" != ""; then
echo "$j" >> $RMD/$KV/procfiles.complete
cat "$j" >> $RMD/$KV/procfiles.complete
echo >> $RMD/$KV/procfiles.complete
fi;
done;

done

}
cat_proc_func

echo '###cgroup'
for i in /cgroup/*
 do
 echo $i >> $RMD/$KV/cgroup
 cat $i >> $RMD/$KV/cgroup
 echo >> $RMD/$KV/cgroup
 echo '*****' >> $RMD/$KV/cgroup
 echo >> $RMD/$KV/cgroup
 done

######FIN
rox $RMD/$KV &
for i in $RMD/$KV/* ; do
geany $i &
sleep 1s #10
done

exit
#####END
