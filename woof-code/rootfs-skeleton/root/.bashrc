

#KRG. /etc/profile
. /etc/profile
#v1.0.5 need to override TERM setting in /etc/profile...
#export TERM=xterm
# ...v2.13 removed.

#export HISTFILESIZE=2000
#export HISTCONTROL=ignoredups
#...v2.13 removed.

###KRG 
path_func() {
PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R7/bin:/root/my-applications/bin:/root/my-applications/sbin"
LD_LIBRARY_PATH="/lib:/usr/lib:/usr/X11R7/lib:/root/my-applications/lib"
PKG_CONFIG_PATH="/usr/lib/pkgconfig"
export PATH LD_LIBRARY_PATH PKG_CONFIG_PATH
}

shell_func() {
PS1="ROOTput>"
PS2=": "
}

###KRG functions###

killpuphotd(){
[ -n "`ps acx | grep 'pup_event_frontend_d' | grep -v -i 'defunct'`" ] && killall pup_event_frontend_d
rm -f /tmp/pup_event_frontend*
}

pupd(){
pup_event_frontend_d
}

xm(){
aplay /usr/share/audio/2barks.au
   aplay /usr/share/audio/2barks.au
   xmessage -bg red -timeout 10 -buttons "YES:190,No:191" -fn "-misc-dejavu sans-*-*-*-*-*-*-*-*-*" 'Really powering off now ?'
   REPLY=$?
    echo $REPLY
    if [ "$REPLY" = "190" ] ; then
    echo 'REPLY is ='$REPLY
    fi
}


fins(){
echo 'Enter Name to find :'
read N
echo 'Enter Dir to search :'
read D
echo 'Maxdepth to search :'
read M
echo 'Type [bcdpflsD] :'
read T
echo 'PERM (700 for executable):'
read P
[ -z "$N" -a -n "$No" ] && N="$No"

[ -z "$D" -a -n "$Do" ] && D="$Do"
[ -z "$D" ] && D="`pwd`"
[ -z "$M" -a -n "$Mo" ] && M="$Mo"
[ -z "$M" ] && M="99"
[ -z "$T" -a -n "$To" ] && T="$To"
[ -z "$T" ] && T="[bcdpfls]"
[ -z "$P" -a -n "$Po" ] && P="$Po"
[ -z "$P" ] && P="644"
echo "$N $D $M $T $P"
#alias find="find $D -wholename /proc -prune -o -wholename /sys -prune -o -wholename /mnt -prune -o -iname *$N*"
if [ -n "$D" -a -n "$N" -a -n "$M" -a -n "P" ] ; then
find "$D" -maxdepth "$M" -wholename "/proc" -prune -o -wholename "/sys" -prune -o -wholename "/mnt" -prune -o -type "$T" -perm -"$P" -iname "*$N*"
fi
No="$N" ; Do="$D" ; Mo="$M" ; To="$T" ; P="$P" 
}



2barks() {
aplay /usr/share/audio/2barks.au
}

sndm() {
lsmod | grep snd
}

mhdai() {
modprobe -b snd-hda-intel
}

mi8x0() {
modprobe -b snd-intel8x0
}

rmudev() {
rm -f -r /dev/.udev
}

rmsnddev1() {
rm -f /dev/pcm*
rm -f /dev/midi*
rm -f /dev/mixer*
rm -f /dev/snd*
rm -f /dev/sound*
rm -f /dev/amidi*
rm -f /dev/amixer*
rm -f /dev/control*
rm -f /dev/audio*
rm -f /dev/dm*
rm -f /dev/dsp*
rm -f /dev/seq*
rm -f /dev/timer*
rm -f /dev/admmidi*
rm -f /dev/adsp
rm -f /dev/aload*
rm -f /dev/dm*
rm -f /dev/aload*
rm -f /dev/card*
rm -f /dev/music*
rm -f /dev/speaker*
}

Rs(){
[ ! "$1" ] && echo "No directory/file given" && return
DIR="$1"
. /etc/DISTRO_SPECS
DISTROFOLDER=`echo "$DISTRO_NAME" "$DISTRO_VERSION" | tr ' ' '_'`
NAME_DEV_FUNC(){
#if [ -d /proc/ide ] ; then
#DEVNAME='hdb'
#else
#DEVNAME='sda'
#fi
DEVNAME=$(basename `rdev | cut -f 1 -d ' '` 2>/dev/null)
[ ! "$DEVNAME" ] && exit
DEVNAME=${DEVNAME/[[:digit:]]/}
}
NAME_DEV_FUNC

FILTER_ROOTFS_FUNC(){
if [ "$DIR" = "/" ] ; then
#for i in /bin /boot /dev /etc /lib /proc /root /sbin /sys /var ; do
SR=`find / -maxdepth 1 -type d -o -type f -o -type l | sort`
SR=`echo "$SR" | grep -v -x -E '/|/mnt.*|/sys|/proc'` ###sed 's#/mnt##g'`
sleep 10s
for i in $SR ; do
echo
echo -e "Rsyncing \e[35m$i\e[39m ... "
date
rsync -urlR --devices --progress --delete $i /mnt/${DEVNAME}12/luci_218/
sleep 1s
echo
date
echo -e "\e[32m ... done \e[39m"
done
sleep 4s
fi
}
MAIN_FUNC(){
if [ -z "`mount | grep "^/dev/${DEVNAME}12"`" ] ; then

if [ ! -d /mnt/${DEVNAME}12 ] ; then
mkdir /mnt/${DEVNAME}12
fi

mount /dev/${DEVNAME}12 /mnt/${DEVNAME}12
rox /mnt/${DEVNAME}12/luci_218/ &

if [ "$DIR" = "/" ] ; then
FILTER_ROOTFS_FUNC
else
rsync -url --devices --exclude=/mnt/ "$DIR" /mnt/${DEVNAME}12/luci_218"`dirname $DIR`"
sleep 4s
fi

rox /mnt/${DEVNAME}12/luci_218/"`dirname $DIR`"
umount /dev/${DEVNAME}12

else

if [ -n "`ls /mnt/${DEVNAME}12/*/* 2>/dev/null`" ] ; then
rox /mnt/${DEVNAME}12/luci_218/ &

if [ "$DIR" = "/" ] ; then
FILTER_ROOTFS_FUNC
else
rsync -url --devices --exclude=/mnt/ "$DIR" /mnt/${DEVNAME}12/luci_218"`dirname $DIR`"
fi

else

echo "ERROR"
fi
fi
}
MAIN_FUNC
}



