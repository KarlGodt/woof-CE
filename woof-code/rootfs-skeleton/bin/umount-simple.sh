#!/bin/bash
# Karl Reimer Godt July 2013




[ "$*" ] || exec busybox umount

sync
MOUNTEDSB=`tac /proc/mounts`

ARGS=`set | grep -E 'ARGV|ARGC'`
ARGSV=`echo "$ARGS" | grep -m1 ARGV | grep -o '(.*)$' | sed 's|^(||;s|)$||' `
ARGSC=`echo "$ARGS" | grep -m1 ARGC |cut -f2 -d'"'`
c=$ARGSC

while read p
do
echo $p
p="${p#*=}"
p="${p/#\"/}"
p="${p/%\"/}"
echo $p
P[$c]="$p"
(( c-- ))
done<<EOI
$(echo "$ARGSV" | sed 's|" \[|"\n\[|g')
EOI

echo "${P[@]}"

for k in `seq 1 1 $ARGSC`
do
case "${P[$k]}"
in
/*)
if [ -d "${P[$k]}" ] ; then
 (pidof ROX-Filer || pidof rox) && rox -D "${P[$k]}"
 sleep 0.02
 fuser -m "${P[$k]}"
 sleep 0.02
 MajMin=`mountpoint -d "${P[$k]}"`
 echo "$MajMin"
 LANG=C DEVICE=`ls -l /dev | sed 's| \([[:digit:]]*\),[[:blank:]]*\([[:digit:]]*\) | \1:\2 |g' | grep -m1 -w "$MajMin" | rev | awk '{print $1}' | rev`
 echo "$DEVICE"
 [ "$DEVICE" ] ||
{
    MNTPTS_ALL=`awk '{print $1"+++"$2}' /proc/mounts`
    MNTPTS_ALL=`echo -e "$MNTPTS_ALL"`
    DEVICE=`echo "$MNTPTS_ALL" | grep -m1 -w "${P[$k]}"`
    DEVICE="${DEVICE%%+++*}"
    DEVICE="${DEVICE##*/}"
 }
 DEVNAMEP="$DEVICE"
 MNTPT_M="${P[$k]}"

elif [ -b "${P[$k]}" ] ; then
 MNTPT_D=`echo "$MOUNTEDSB" | grep -m1 -w "^${P[$k]}" | awk '{print $2}'`
 MNTPT_D=`echo -e "$MNTPT_D"`
 (pidof ROX-Filer || pidof rox) && rox -D "$MNTPT_D"
 sleep 0.02
 fuser -m "$MNTPT_D"
 sleep 0.02
 DEVNAMEP="${P[$k]}"
fi
;;
--version)
echo "$0 : Puppy Linux Wrapper bash shell script:"
USE_FULL=YES
;;
--*) #exec umount-FULL ${P[@]} ;;
USE_FULL=YES
;;
esac
done

[ "$USE_FULL" ] && {
umount-FULL ${P[@]}
RETVAL=$?
} || {
busybox umount -dr ${P[@]}
RETVAL=$?
}

[ $RETVAL = 0 ] || exit $RETVAL

  if [ "$MNTPT_M" ] ; then OLDMOUNTPT="$MNTPT_M"
elif [ "$MNTPT_D" ] ; then OLDMOUNTPT="$MNTPT_D"
else
sleep 0.02s
[ -f /proc/mounts ] || { echo "No /proc/mounts ."; exit $RETVAL ; }  ##+++2013-08-10 in case umount -a unmounts /proc
MOUNTEDSA=`tac /proc/mounts`
OLDMOUNT=`echo "$MOUNTEDSB" | grep -v "$MOUNTEDSA"`
OLDMOUNTPT=`echo "$OLDMOUNT" | awk '{print $2}'`
OLDMOUNTPT=`echo -e "$OLDMOUNTPT" | head -n1`
  fi

[ "$MOUNTEDSB" = "$MOUNTEDSA" ] && { echo "NO CHANGES";exit $RETVAL; }
[ "$OLDMOUNTPT" -a -d "$OLDMOUNTPT" -a ! "`ls -A "$OLDMOUNTPT"`" ] && rmdir "$OLDMOUNTPT"

[ "$DISPLAY" ] || { echo "NO DISPLAY";exit $RETVAL; }

. /etc/rc.d/functions4puppy4

[ "$DEVNAMEP" ] || {
DEVNAMEP=`echo "$OLDMOUNT" | awk '{print $1}'`
DEVNAMEP=`echo -e "$DEVNAMEP"`
}

DEVNAME=`echo "$DEVNAMEP" | sed 's%p[0-9]*$%%;s%[0-9]*$%%'`
PROBEDISK2=`probedisk2`
CATEGORY=`echo "$PROBEDISK2" | grep -m1 -w "$DEVNAME" | cut -f2 -d'|'`
DISK_FREE=`df`

echo "${DEVNAMEP##*/}"
echo "$DISK_FREE" | grep -w "^$DEVNAMEP" | grep -E ' /initrd/| /$' &&
{
      icon_mounted_func "${DEVNAMEP##*/}" $CATEGORY; } || {  #see functions4puppy4
      icon_unmounted_func "${DEVNAMEP##*/}" $CATEGORY;
}

exit $RETVAL
