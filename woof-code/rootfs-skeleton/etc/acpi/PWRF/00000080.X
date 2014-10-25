#!/bin/ash

. /etc/rc.d/f4puppy5

aplay /usr/share/audio/2barks.au

Version='1.0 Macpup_O2-Puppy_Linux_431 KRG'

usage(){
MSG="
$0

OPTIONS:
[help|version]
[checkcode|debug|verbose]
[hiber|sleep|resume=/dev/SWAP|/dev/SWAP]

Available Modes :
$KERN_VER
$AVAIL_MODES
"
echo "$MSG"
[ "$DISPLAY" ] && xmessage -bg white4 "$MSG"
exit $1
}

__available_modes__(){
pidof sync >>$OUT || sync

KERN_VER=`uname -r`
#AVAIL_MODES=$(</sys/power/state)
read AVAIL_MODES </sys/power/state
BUTTONS="Let me outa here:200"
for m in $AVAIL_MODES;do
case $m in
standby)
BUTTONS="Powerdown to Standby:201,${BUTTONS}"
;;
mem)
BUTTONS="REST in RAM:203,${BUTTONS}"
;;
disk)
BUTTONS="Hiber on DISK:204,${BUTTONS}"
;;
esac;done
}

out=/dev/null;err=$out
HIBER=1;MODE=DISK;mode=disk
for param in $@;do
case $1 in

*version) echo -e "\n$0: Version '$Version'\nTry help for more info\n";exit 0;;
*help) usage 0;;

*checkcode|*codecheck)   set -n; shift;;
*debug)                  set -x; shift;;
*verbose) VERBOSE=1;VERB=-v;L_VERB=--verbose;A_VERB=-verbose;out=/dev/stdout;err=/dev/stderr;shift;;

*hiber) HIBER=1;MODE=DISK;mode=disk; shift;;
*sleep) SLEEP=1;MODE=RAM;mode=mem;   shift;;
resume=/dev/*) SWAP_TO_USE=${1#*=};  shift;;
/dev/*) SWAP_TO_USE=$1;              shift;;

*) :;;

esac;done

echo "$0"

pidof sync >>$OUT || sync

KERN_VER=`uname -r`
#AVAIL_MODES=$(</sys/power/state)
read AVAIL_MODES </sys/power/state
BUTTONS="Let me outa here:200"
for m in $AVAIL_MODES;do
case $m in
standby)
BUTTONS="Powerdown to Standby:201,${BUTTONS}"
;;
mem)
BUTTONS="REST in RAM:203,${BUTTONS}"
;;
disk)
BUTTONS="Hiber on DISK:204,${BUTTONS}"
;;
esac;done

#[ "$DISPLAY" ] || export DISPLAY=':0'
#if [ "$DISPLAY" ];then
if pidof X; then

# get tty of X and change there ...  2014-10-25
__bin_ps__(){
ttyALL=`ps -A -o pid,ppid,tty,args | awk '{if (match($3, "tty[0-9]?")) print}'`
  _debugx "ttyALL='$ttyALL'"
  ttyX=`echo "$ttyALL" | awk '{if ($4 == "X" && $5 == ":0") print $3}' | head -n1`
  _info "X server found running on '$ttyX'"
  #sanity checks ..
  test -c /dev/"$ttyX" && {
   _debug "OK, /dev/'$ttyX' is a chaacter special device"
   nrVT=${ttyX##*[[:alpha:][:punct:]_]}
   case $nrVT in
    [1-9]|[1-9][0-9]) chvt $nrVT
                      RV=$?;
    [ $RV = 0 ] && { _debug "OK, switched to tty${nrVT}"; } || { _err "chvt '$nrVT' returned with '$RV' exitcode"; }
    ;;
    *) _err "'$nrVT' not in range of 1-9 | 10-99";;
   esac
   true
  } || { _warn "dev/'$ttyX' not a character special file .. WHAT ??"; }
}

# busybox ps
ttyALL=`busybox ps -A -o pid,ppid,tty,args | awk '{if (match($3, "4,[0-9]?")) print}'`
  _debugx "ttyALL='$ttyALL'"
  ttyX_=`echo "$ttyALL" | awk '{if ($4 == "X" && $5 == ":0") print $3}' | head -n1`
  ttyX=`stat -c %t','%T' '%n /dev/tty* | grep -w "^$ttyX_" | awk '{print $2}'`
  _info "X server found running on '$ttyX'"
  #sanity checks ..
  test -c "$ttyX" && {
   _debug "OK, '$ttyX' is a character special device"
   nrVT=${ttyX##*[[:alpha:][:punct:]_]}
   case $nrVT in
    [1-9]|[1-9][0-9]) chvt $nrVT
                      RV=$?; sleep 1;
    [ $RV = 0 ] && { _debug "OK, switched to tty${nrVT}"; } || { _err "chvt '$nrVT' returned with '$RV' exitcode"; }
    ;;
    *) _err "'$nrVT' not in range of 1-9 | 10-99";;
   esac
   true
  } || { _warn "dev/'$ttyX' not a character special file .. WHAT ??"; }
#...2014-10-25

    [ "$DISPLAY" ] || export DISPLAY=':0'
    #xmessage -buttons "Hiber on DISK:204,Rest in RAM:203,Let me outa here:200" "
    xmessage -timeout 30 -buttons "$BUTTONS" -title "`pwd`/$0" "
acpid daemon triggered '$0' :
Kernel : $KERN_VER
available modes: $AVAIL_MODES
Power Button Pressed ?

Note: Timesout in 30 seconds with wmpoweroff.
"
    ANSWER=$?  ##+++2012-06-01 added menu
    #exit
    case $ANSWER in
    205) HIBER='';SLEEP='';MODE=STANDBY;mode=standby;descr='Power Management SOFT OFF "S5"' ;;
    204) HIBER=1; SLEEP='';MODE=DISK;mode=disk;descr='Power Management Hibernate aka Suspend to Swap Partition "S4"';;
    203) SLEEP=1; HIBER='';MODE=RAM;mode=mem;descr='Power Management Sleep aka Light Sleep in RAM "S1-3 (BIOS Setting)"';;
    200) exit 0;;
    "")  exit 0;;
    *)   wmpoweroff;; #exit 0;;
    esac

else #X not running, read console

__old_fallback__(){
chvt 12
sleep 1
echo "Security stub for frozen systems to poweroff cleanly." >/dev/tty12
sleep 3s

#echo "Timesout in 30 seconds to run poweroff." >/dev/tty12
#exec 1>>/dev/tty12 2>&1
#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " </dev/console >/dev/console NO_KEY
#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " </dev/tty12 >/dev/tty12 NO_KEY
#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " </dev/vcs12 >/dev/vcs12 NO_KEY
#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " </dev/vcsa12 >/dev/vcsa12 NO_KEY

#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " NO_KEY >/dev/console </dev/console
#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " NO_KEY </dev/console >/dev/console

#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " </dev/console NO_KEY >/dev/console
#read -t 30 -p "Ready to poweroff. Press n-key to cancel system poweroff: " >/dev/console NO_KEY </dev/console

case $NO_KEY in
N|n) exit;;
*) exec poweroff;exit;;
esac
}

lastTTY=`_last_logged_in_on_tty | awk '{print $3}'`
lTTYnr=${lastTTY##*[[:alpha:][:punct:]_]}
chvt $lTTYnr
sleep 1
echo -e "\nPowerbutton pressed:\n" >/dev/${lastTTY##*/}

cat >>/dev/${lastTTY##*/} <<EoI
acpid daemon triggered '$0' :
Kernel : $KERN_VER
available modes: $AVAIL_MODES
Power Button Pressed ?

Note: Timesout in 30 seconds with /sbin/poweroff .
EoI

cat >>/dev/${lastTTY##*/} <<EoI
$BUTTONS
EoI

while [ selecting ]
do
echo -n "Enter your ACPI MODE choice :" >>/dev/${lastTTY##*/}
read -t 30 SELECT
RV=$?
echo "SELECT='$SELECT'" >>/dev/${lastTTY##*/}
if [ ! "$SELECT" ]; then
     case $RV in
        0) echo "Timed out..." >>/dev/${lastTTY##*/} ; break;; #exec /sbin/poweroff force;;
        *) echo "Try again"    >>/dev/${lastTTY##*/} ; continue;;
     esac
else
 case $SELECT in
    205) HIBER='';SLEEP='';MODE=STANDBY;mode=standby;descr='Power Management SOFT OFF "S5"' ; break;;
    204) HIBER=1; SLEEP='';MODE=DISK;mode=disk;descr='Power Management Hibernate aka Suspend to Swap Partition "S4"'; break;;
    203) SLEEP=1; HIBER='';MODE=RAM;mode=mem;descr='Power Management Sleep aka Light Sleep in RAM "S1-3 (BIOS Setting)"'; break;;
    201) echo "try again ..." >>/dev/${lastTTY##*/} ; continue;;
    200) exit 0;;
    "")  exit 0;;
    *)   :;;  #/sbin/poweroff;; ##exit 0;;
 esac

fi
done

exit

fi #pidof X


[ "$DISPLAY" ] && xmessage -bg blue -fg yellow "Power button pressed ..
Preparing to suspend to $MODE .." &

aplay /usr/share/audio/2barks.au

[ "`pidof pppd`" ] && { echo "Shutting down pppd" ;kill -2 `pidof pppd`;sleep 1; }


MNTDPARTS=`tac /proc/mounts`
readonly MNTDPARTS
##REMARK1 : fuser -c /dev/sda4 would return ntfs-3g PID but -c [||-m] /mnt/sda4 not  ##+++2011-10-27

echo -e "\e[1;35m""Unmounting stray filesystems:""\e[0;39m"

STRAYPARTL=`echo "$MNTDPARTS" |grep -vE ' /dev | /dev/shm | /dev/pts | devpts | /proc | /sys | proc | sysfs | *tmpfs  | *ramfs | rootfs |/dev/root | usbfs | unionfs | /initrd| on / '`

#STRAYPARTL=`echo $STRAYPARTL |rev |sed 's# )#\n)#g'|rev`
readonly STRAYPARTL

STRAYPARTMP=`echo "$STRAYPARTL" | cut -f 2 -d " "` ### |sed 's# type.*##' | tr ' ' '·'`

pidof sync || sync

for ONESTRAY in $STRAYPARTMP  ##in MountPoints
do
 [ "$ONESTRAY" ] || continue
 #Prepare the vars :
 ONESTRAY="${ONESTRAY//·/ }"
 ONESTRAY=${ONESTRAY//\"/}

 echo -e "\e[1;31mUnmounting '$ONESTRAY'...\e[0;39m"

 #ONESTRAYP=`busybox mount | grep -w "$ONESTRAY" | cut -f 1 -d ' '`

 #fuser:
 #fuser -v -k -c -m $ONESTRAYP ##Device  ##Error both mount and mountpoint dont work

 #fuser -v -k -m  "$ONESTRAY"  ##+++2011-10-27

 pidof sync || sync

 #ntfs or not:
 if [ "`busybox mount | grep "$ONESTRAY" | grep -E 'fuse|ntfs'`" != "" ] ; then
 #fusermount version: 2.7.0 [options] mountpoint
 noROX=1 fusermount -u "$ONESTRAY" ##unmounts MountPoint
 else
 noROX=1 /bin/umount -r "$ONESTRAY"  ##unmounts MountPoint
 echo -e "\e[1;31m'$?'\e[0;39m"
 sleep 1
 fi
done

pidof sync || sync

if [ "$HIBER" ];then

show_swaps(){
echo "$2
"

echo "
Currently available swap partitions :
$SWAPS

`free`
"
[ "$DISPLAY" ] && xmessage -bg red -fg white "Aborted hibernation shutdown
due for more RAM to send to SWAP than SWAP available" &
aplay /usr/share/audio/2barks.au
exit $1
}

#prepare vars:
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

SWAPS_ON=`cat /proc/swaps |sed '1d'`

#MEM_USED=`free |grep -i 'Mem' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $3}'`
MEM_USED=`free | awk '/Mem:/ {print $3}'`
#SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`
SWAP_FREE=`free | awk '/Swap:/ {print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to DISK due to free swap lesser than used mem"


#
if [ "$SWAP_TO_USE" ];then

[ "`echo "$SWAPS_LONG" |grep "^$SWAP_TO_USE"`" ] || show_swaps 1 "'$SWAP_TO_USE' seems not to be a regular swap partition"
#[ "`echo "$SWAPS" |grep -w "$SWAP_TO_USE"`" ] || show_swaps 1 "'$SWAP_TO_USE' seems not to be a regular swap partition"
{ for swap in $SWAPS_ON;do swapoff $swap;sleep 1s;pidof sync || sync;done;swapon $SWAP_TO_USE; }
FIRST_SWAP=$SWAP_TO_USE

else

FIRST_SWAP=`echo "$SWAPS" |head -n1`

for swap in $SWAPS;do

SWAP_LABEL_RESUME=`blkid $swap |grep -iE 'Resume|Hiber' |cut -f1 -d':'`
[ "$SWAP_LABEL_RESUME" ] && { FIRST_SWAP=$SWAP_LABEL_RESUME;break; }

done

SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
echo "Swapping off all unneeded swaps..."
for swap in $SWAPS_TO_TURN_OFF;do swapoff $swap;sleep 1s;pidof sync || sync;done

fi #swap_to_use

SWAP_FREE=`free |grep -i 'Swap' |awk '{print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to RAM due to free swap lesser than used mem"

echo 'disk' >/sys/power/state 2>/tmp/acpi.err
[ $? -ne 0 ] && xmessage -bg red -file /tmp/acpi.err

sleep 30s
echo "$0: HELLO AGAIN '$USER'"
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

SWAPS_TO_TURN_ON=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
for swap in $SWAPS_TO_TURN_ON;do swapon $swap;sleep 1s;done

free

[ "$DISPLAY" ] && xmessage -bg green -fg white "HELLO AGAIN !
And WELCOME BACK '$USER'
on '$HOSTNAME' '$MACHTYPE'" &
aplay /usr/share/audio/2barks.au

else #hiber
  if [ "$SLEEP" ];then
echo 'mem' >/sys/power/state 2>/tmp/acpi.err
[ $? -ne 0 ] && xmessage -bg red -file /tmp/acpi.err || {
  aplay /usr/share/audio/2barks.au
  oldIFS="$IFS"
  IFS=$'\n'
  for oneLINE in $STRAYPARTL
  do
   _device_=${oneLINE%% *}
   _mntpnt_=`echo "$oneLINE" | awk '{print $2}'`
   _mntpnt_=`echo -e "$_mntpnt_"`
   _fstype_=`echo "$oneLINE" | awk '{print $3}'`
   _mntops_=`echo "$oneLINE" | awk '{print $4}'`
   test "$_device_" -a "$_mntpnt_" -a "$_fstype_" -a "$_mntops_" || continue
   grep -w "$_fstype_" /proc/filesystems | grep $Q '^nodev' && noROX=1
   if grep $Q -w "$_mntpnt_" /proc/mounts; then
    noROX=$noROX /bin/mount -t $_fstype_ -o remount,$_mntops_ "$_device_" "$_mntpnt_"
   else
    noROX=$noROX /bin/mount -t $_fstype_ -o $_mntops_ "$_device_" "$_mntpnt_"
   fi
   sleep 0.2
   unset noROX
  done
  IFS="$oldIFS"
   }
  fi
fi

exit 0

