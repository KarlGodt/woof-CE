#!/bin/bash
# wants bash ARGV ARGC
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_umount-simple.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/bin/umount-simple.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || . /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap

}
# End new header
#
# Karl Reimer Godt July 2013

[ "$*" ] || exec busybox umount

_sync
[ -f /proc/mounts ] || exec mount-FULL "$@"

_exit(){
[ "$REMNT_ROT_RW" ] && mount -o remount,ro /dev/root /
[ "$REMNT_TMP_RW" ] && mount -o remount,ro /tmp
case $1 in
[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])
    RV=$1; shift;;
'') RV=0;;
*)  rV=`echo "$@" | awk '{print $NF}'`
    case $rv in [0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])
    RV=$rV;; # could remove the exit number , but why not print it?
    esac
    [ "$RV" ] || RV=0
;;
esac

[ "$*" ] && echo "$@"
exit $RV
}

__make_writable_tmp(){
test -f /proc/mounts || mount -t proc porc /proc
cut -f1-2 -d' ' /proc/mounts | grep $Q ' /tmp$'
if test $? = 0; then # /tmp is mountpoint
mount -o remount,rw /tmp
else
mount -o remount,rw /
fi
echo "$0:$*"
cat /proc/mounts
echo
}

_make_writable_tmp(){
#unset readONLY REMNT_TMP_RW REMNT_ROT_RW
# the second call to _make_writable_tmp would tell rw before was always true
# if unset
test -f /proc/mounts || mount -t proc porc /proc || return 2

mntLINE=`cut -f1-2 -d' ' /proc/mounts | grep ' /tmp$'`
if test "$mntLINE"; then # /tmp is mountpoint
 readONLY=`grep -m1 "^$mntLINE " /proc/mounts | grep -w ro`
 if test "$readONLY"; then
  mount -o remount,rw /tmp && REMNT_TMP_RW=1
 fi
else
 readONLY=`grep -m1 '^/dev/root / ' /proc/mounts | grep -w ro`
 if test "$readONLY"; then
  mount -o remount,rw / && REMNT_ROT_RW=1
 fi
fi
 (
 echo "$0:$*"
 cat /proc/mounts
 echo
 ) >&2
}

_make_writable_tmp #also mounts /proc if needed
MOUNTEDSB=`tac /proc/mounts`

ARGS=`set | grep -E 'ARGV|ARGC'`
ARGSV=`echo "$ARGS" | grep -m1 ARGV | grep -o '(.*)$' | sed 's|^(||;s|)$||' `
ARGSC=`echo "$ARGS" | grep -m1 ARGC |cut -f2 -d'"'`
c=$ARGSC

while read p
do
_debugx $p
p="${p#*=}"
p="${p/#\"/}"
p="${p/%\"/}"
_debugx $p
P[$c]="$p"
(( c-- ))
done<<EOI
$(echo "$ARGSV" | sed 's|" \[|"\n\[|g')
EOI

_debug "${P[@]}"

for k in `seq 1 1 $ARGSC`
do
case "${P[$k]}"
in
/*)
if [ -d "${P[$k]}" ] ; then
 (pidof ROX-Filer || pidof rox) >>$OUT && rox -D "${P[$k]}"
 sleep 0.02
 fuser -m "${P[$k]}"
 sleep 0.02
 MajMin=`mountpoint -d "${P[$k]}"`
 _debugx "$MajMin"
 LANG=C DEVICE=`ls -l /dev | sed 's| \([[:digit:]]*\),[[:blank:]]*\([[:digit:]]*\) | \1:\2 |g' | grep -m1 -w "$MajMin" | rev | awk '{print $1}' | rev`
 _debugx "DEVICE='$DEVICE'"
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
 (pidof ROX-Filer || pidof rox) >>$OUT && rox -D "$MNTPT_D"
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
umount-FULL "${P[@]}"
RETVAL=$?
} || {
busybox umount -dr "${P[@]}"
RETVAL=$?
}

[ "$RETVAL" = 0 ] || _exit $RETVAL

  if [ "$MNTPT_M" ] ; then OLDMOUNTPT="$MNTPT_M"
elif [ "$MNTPT_D" ] ; then OLDMOUNTPT="$MNTPT_D"
else
sleep 0.02s
[ -f /proc/mounts ] || { _exit $RETVAL "No /proc/mounts ."; }  ##+++2013-08-10 in case umount -a unmounts /proc
test -d /tmp        || { _exit $RETVAL "No /tmp"; }
_make_writable_tmp #could have been umount /proc or /tmp ..
#but an underlying /tmp directory may still exist..
MOUNTEDSA=`tac /proc/mounts`
OLDMOUNT=`echo "$MOUNTEDSB" | grep -v "$MOUNTEDSA"`
OLDMOUNTPT=`echo "$OLDMOUNT" | awk '{print $2}'`
OLDMOUNTPT=`echo -e "$OLDMOUNTPT" | head -n1`
  fi

grep $Q -E " ${OLDMOUNTPT} |${OLDMOUNTPT}/" /proc/mounts && _exit $RETVAL # maybe remounted read-only
[ "$MOUNTEDSB" = "$MOUNTEDSA" ] && { _exit $RETVAL "NO CHANGES"; }
[ "$OLDMOUNTPT" -a -d "$OLDMOUNTPT" -a ! "`ls -A "$OLDMOUNTPT"`" ] && rmdir "$OLDMOUNTPT"

[ "$DISPLAY" ] || { _exit $RETVAL "NO DISPLAY"; }

. /etc/rc.d/functions4puppy4

[ "$DEVNAMEP" ] || {
DEVNAMEP=`echo "$OLDMOUNT" | awk '{print $1}'`
DEVNAMEP=`echo -e "$DEVNAMEP"`
}
[ "$DEVNAMEP" ]    || _exit $RETVAL
[ -b "$DEVNAMEP" ] || _exit $RETVAL
DEVNAME=`echo "$DEVNAMEP" | sed 's%p[0-9]*$%%;s%[0-9]*$%%'`
_debugx "DEVNAME='${DEVNAME}'"
[ "$DEVNAME" ]    || _exit $RETVAL
PROBEDISK2=`probedisk2`
CATEGORY=`echo "$PROBEDISK2" | grep -m1 -w "$DEVNAME" | cut -f2 -d'|'`
DISK_FREE=`df`

_debugx "'${DEVNAMEP##*/}' '$CATEGORY'"
echo "$DISK_FREE" | grep -w "^$DEVNAMEP" | grep -E ' /initrd/| /$' &&
{
      icon_mounted_func "${DEVNAMEP##*/}" $CATEGORY; } || {  #see functions4puppy4
      icon_unmounted_func "${DEVNAMEP##*/}" $CATEGORY;
}

_exit $RETVAL
