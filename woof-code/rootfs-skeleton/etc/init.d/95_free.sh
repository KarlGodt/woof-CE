#!/bin/ash

. /etc/rc.d/f4puppy5
. /etc/rc.d/PUPSTATE
. /etc/eventmanager.cfg

case $1 in
start)



ME_PROGRAM=`realpath "$0"`  ##+-2013-08-10 should be readlink -e but busybox readlink treats -f as -e option
ME_PID=$$
ME_OTHER_PIDS=`pidof -o $$ -o %PPID ${ME_PROGRAM##*/}`

[ "$POLL_INTERVALL" ] || POLL_INTERVALL=2 #seconds

test "$KERNVER" || KERNVER=`uname -r`
[ "$ZDRV" ]     || ZDRV='';
[ "$ZDRVINIT" ] || ZDRVINIT='no' #these usually set in PUPSTATE

SIZE_MODS_M=0
if [ "$ZDRVINIT" = "yes" ];then
 #all mods were in initrd at bootup, then moved to main f.s.
 SIZE_MODS_M=`du -m -s /lib/modules | cut -f 1`
fi
RETVALm=1
PREVSIZETMPM=0
PREVSIZEFREEM=0

#note that init script in initrd takes care of restoring modules if enough space.
_delete_drivers() { #called from _free() and _free_flash(). delete modules to create more free space.
 #passed param: /pup_rw=delete tmpfs top layer only.
 DEL_LAYER=$1
 #find out what modules are loaded, keep those...
 for oneKEEP_MOD in `lsmod | cut -f 1 -d ' ' | grep -v 'Module'`
 do
  oneKEEP_SPEC=`modinfo -F filename ${oneKEEP_MOD}`
  oneKEEP_PATH-${oneKEEP_SPEC%/*}
  test -d /tmp${oneKEEP_PATH} || mkdir $VERB -p /tmp${oneKEEP_PATH}
  cp $VERB -af ${oneKEEP_SPEC} /tmp${oneKEEP_PATH}/
 done
 if [ "$DEL_LAYER" ];then
  rm $VERB -rf ${DEL_LAYER}/lib/modules
 else
  if [ $PUPMODE -eq 3 -o $PUPMODE -eq 7 -o $PUPMODE -eq 13 ];then
   rm $VERB -rf ${SAVE_LAYER}/lib/modules
  fi
  rm $VERB -rf /lib/modules
 fi
 cp $VERB -af /tmp/lib/modules /lib/modules
 depmod -a
}

_free_initrd() { #UniPup, runs entirely in initramfs.
 SIZEFREEK=`free | grep '^Total:' | tr -s ' ' | cut -f 4 -d ' '`
 test "$SIZEFREEK" || {
    SIZEFREEM_=`free -m |  awk '{ if (match($1, "Mem.*")) || (match($1, "Swap.*")) print $4}'`
   for m_ in $SIZEFREEM_; do SIZEFREEM=$((SIZEFREEM+m_)); done
 }
 test "$SIZEFREEM" || {
    test "$SIZEFREEK" || {
        SIZEFREEK_=`free |  awk '{ if (match($1, "Mem.*")) || (match($1, "Swap.*")) print $4}'`
         for k_ in $SIZEFREEK_; do SIZEFREEK=$((SIZEFREEK+m_)); done
    }
      test "$SIZEFREEK" &&  SIZEFREEM=$((SIZEFREEK / 1024))
 }

 [ -s /tmp/pup_event_sizefreem ] && read PREVSIZEFREEM </tmp/pup_event_sizefreem
 [ "$PREVSIZEFREEM" = "$SIZEFREEM" ] && return
 #save to a file, freememapplet can read this...
 echo "$SIZEFREEM" > /tmp/pup_event_sizefreem
}

_free() { #called every 4 seconds.
 case $PUPMODE in
  6|12)
   SIZEFREEM=`/bin/df -m | grep -m1 ' /initrd/pup_rw$' | tr -s ' ' | cut -f 4 -d ' '`
  ;;
  *)
   SIZEFREEM=`/bin/df -m | grep -m1 ' /$' | tr -s ' ' | cut -f 4 -d ' '`
  ;;
 esac
 WARNMSG=""
 PREVSIZEFREEM=0
 [ -s /tmp/pup_event_sizefreem ] && read PREVSIZEFREEM </tmp/pup_event_sizefreem
 [ "$PREVSIZEFREEM" -eq $SIZEFREEM ] && return
 if [ "$SIZEFREEM" -lt 10 ];then
  if [ -d /initrd/pup_rw/lib/modules/all-firmware -a "$ZDRVINIT" = "yes" ];then
   _delete_drivers /initrd/pup_rw #save layer is at top, delete mods.
  else
   WARNMSG="WARNING: Personal storage getting full, strongly recommend you resize it or delete files!"
  fi
 fi
 VIRTUALFREEM=$SIZEFREEM
 if [ "$ZDRVINIT" = "yes" ];then #full set of modules present, moved from initrd.
  if [ -d /initrd/pup_rw/lib/modules/all-firmware ];then #have not yet deleted modules.
   #calc the "virtual" free space (would have if modules not there...)
   VIRTUALFREEM=$((SIZEFREEM + SIZE_MODS_M))
   VIRTUALFREEM=$((VIRTUALFREEM - 1)) #allow for some mods will not be deleted.
  fi
 fi
 #save to a file, freememapplet can read this...
 echo "$VIRTUALFREEM" > /tmp/pup_event_sizefreem
 [ "$PUPMODE" -eq 5 -o "$PUPMODE" -eq 2 ] && return 0 #5=first boot, no msgs at top of screen.
 if [ "$WARNMSG" ];then
  killall yaf-splash
  yaf-splash -margin 2 -bg red -bw 0 -placement top -font "9x15B" -outline 0 -text "$WARNMSG" &
 _savepuppy
 fi
}

_savepuppy(){

case $PUPMODE in 13)
     MESSAGE_SAVE=`gettext "Saving RAM to 'pup_save' file..."`;;
3|7) MESSAGE_SAVE=`gettext "Saving RAM to 'home' partition.."`;;
esac
BG=orange

if test "$WARNMSG"; then
MESSAGE_SAVE="$WARNMSG
$MESSAGE_SAVE"
BG=red
fi

yaf-splash -font "8x16" -outline 0 -margin 4 -bg $BG -placement top -text "$MESSAGE_SAVE" & YAFPID=$!

  pidof sync >>$OUT || sync
  nice -n 19 /usr/sbin/snapmergepuppy
  /bin/ps -p $YAFPID >$OUT && kill $YAFPID
WARNMSG=""
}

_free_flash(){ #PUPMODE 3,7,13. called every 3 seconds.
 WARNMSG=""
 SIZEFREEM=`/bin/df -m | grep ' /initrd/pup_ro1$' | tr -s ' ' | cut -f 4 -d ' '`
  SIZETMPM=`/bin/df -m | grep ' /initrd/pup_rw$'  | tr -s ' ' | cut -f 4 -d ' '`
 [ -s /tmp/pup_event_sizefreem ] && read PREVSIZEFREEM </tmp/pup_event_sizefreem
 [ -s /tmp/pup_event_sizetmpm ]  && read PREVSIZETMPM  </tmp/pup_event_sizetmpm
 [ $PREVSIZEFREEM -eq $SIZEFREEM -a $PREVSIZETMPM -eq $SIZETMPM ] && return
 if [ $SIZEFREEM -lt 10 ];then
  if [ -d /initrd/pup_ro1/lib/modules/all-firmware -a "$ZDRVINIT" = "yes" ];then
   _delete_drivers /initrd/pup_ro1 #delete modules in save layer only.
  else
   WARNMSG_SAVE=`gettext "WARNING: Personal storage file getting full, strongly recommend you resize it or delete files!"`
  fi
 fi
 if [ "$SIZETMPM" -lt 5 ];then
  if [ -d /initrd/pup_rw/lib/modules/all-firmware -a "$ZDRVINIT" = "yes" ];then
   _delete_drivers /initrd/pup_rw #delete modules in top tmpfs layer only.
  else
   WARNMSG_TMP=`gettext "WARNING: RAM working space only ${SIZETMPM}MB, recommend a reboot which will flush the RAM"`
  fi
 fi
 WARNMSG="$WARNMSG_SAVE
$WARNMSG_TMP
"
 VIRTUALFREEM=$SIZEFREEM
 if [ "$ZDRVINIT" = "yes" ];then #full set of modules present at bootup.
  if [ -d /initrd/pup_ro1/lib/modules/all-firmware ];then #have not yet deleted modules.
   #calc the "virtual" free space (would have if modules not there...)
   VIRTUALFREEM=$((SIZEFREEM + SIZE_MODS_M))
   VIRTUALFREEM=$((VIRTUALFREEM - 1)) #allow for some mods will not be deleted.
  fi
 fi
 echo "$SIZETMPM" > /tmp/pup_event_sizetmpm
 #save to a file, freememapplet can read this...
 echo "$VIRTUALFREEM" > /tmp/pup_event_sizefreem
 if [ "$WARNMSG" ];then
  #killall yaf-splash
  #yaf-splash -margin 2 -bg red -bw 0 -placement top -font "9x15B" -outline 0 -text "$WARNMSG" &
  _savepuppy
 fi
}

_do_ramsaveinterval(){
while :; do
 SAVECNT=$((SAVECNT + 60))
 if [ "$SAVECNT" -ge "$RAMSAVEINTERVAL" ];then
  _savepuppy
  SAVECNT=0
 fi
sleep 60
done
}


case $PUPMODE in
3|7|13)
   FREE_FUNCTION='_free_flash'
   _debug "RAMSAVEINTERVAL='$RAMSAVEINTERVAL'"
   [ "$RAMSAVEINTERVAL" -gt 0 ] && _do_ramsaveinterval &
 ;;
16|24|17|25) #unipup.
   FREE_FUNCTION='_free_initrd'  ;;
  *)
   FREE_FUNCTION='_free'  ;;
esac

 trap "echo 'Got signal  2'; exit"  2
#trap "echo 'Got signal  9'; exit"  9
 trap "echo 'Got signal 15'; exit" 15

while :;
do

sleep $POLL_INTERVALL

$FREE_FUNCTION

done
;;

stop)
kill -15 `pidof -o $$ -o %PPID ${0##*/}`
;;

status)
echo -n "Status of: "
echo -n "$0:$*:$$:$PPID: "
sleep $POLL_INTERVALL
#echo -ne `pidof -o $$ -o %PPID ${0##*/} && { echo "Running.\n"; } || { echo "Not running.\n"; }` >&2
RUNNING_PID=`pidof -o $$ -o %PPID ${0##*/}`
#if test "$RUNNING_PID"; then echo "$RUNNING_PID Running.";true
#else echo "Not running.";false
#fi
case $RUNNING_PID in '') echo "Not running.";false;;
*) echo "$RUNNING_PID Running."; true;;
esac
RV=$?

;;
esac
exit $RV
