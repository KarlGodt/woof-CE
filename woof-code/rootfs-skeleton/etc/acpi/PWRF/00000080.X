#!/bin/ash

#==================
#
# ACPI managing script
# Has dialog (xmessage) to select between
# detected ACPI Power Management (PM) states
# supported by the current running kernel
# The linux kernel has various ACPI configuration
# options and Puppy Linux default kernels mostly
# came with just S3 RAM sleep enabled.
#
#==================

# REM: f4puppy5 short for functions4puppy5
. /etc/rc.d/f4puppy5

# REM: make some noise to inform that things are going on..
aplay /usr/share/audio/2barks.au

# REM: Version and usage section...
Version='1.0 Macpup_O2-Puppy_Linux_431 KRG'
Version='1.1 Macpup_O2-Puppy_Linux_431 KRG' ## wakealarm_cmd handling stub added
                                            ## lots of comments/remarks added
                                            ## added poweroff menu entry
                                            ## xmessage layout fixes
                                            ## ACPI_S4_RESUME_PARTITION variable instead of SWAP_TO_USE
Version='1.2 Macpup_O2-Puppy_Linux_431 KRG' ## Building site /sys/power/resume handling

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
[ "$DISPLAY" ] && xmessage -bg white4 -title "00000080.X" "$MSG"
exit $1
}


# REM: option paramete arguments processing...
out=/dev/null;err=$out
HIBER=1;MODE=DISK;mode=disk
for param in $@;do
case $1 in

-?version|-V) echo -e "\n$0: Version '$Version'\nTry help for more info\n";exit 0;;
-?help|-?usage|-h) usage 0;;

-?checkcode|-?codecheck)   set -n; shift;;
-?debug)                  set -x; shift;;
-?verbose|-v) VERBOSE=1;VERB=-v;L_VERB=--verbose;A_VERB=-verbose;out=/dev/stdout;err=/dev/stderr;shift;;

-?hiber) HIBER=1;MODE=DISK;mode=disk; shift;;
-?sleep) SLEEP=1;MODE=RAM;mode=mem;   shift;;
-?resume=/dev/*) ACPI_S4_RESUME_PARTITION=${1#*=};  shift;;
/dev/*)          ACPI_S4_RESUME_PARTITION=$1;       shift;;

*) :;;

esac;done

# REM: UTS_RELEASE actually ... VERSION in Makefile is first number,
#      `make kernelversion' prints VERSION.PATCHLEVEL.SUBLEVEL.EXTRALEVEL
KERN_VER=`uname -r`
echo "$0:$*:$$:`date +%F~%T`:$KERN_VER"  ##DEBUG

# prevent multiple sync running ...
pidof sync >>$OUT || sync

# REM: create menu ...
#AVAIL_MODES=$(</sys/power/state)  ##bash syntax
read AVAIL_MODES </sys/power/state #ash and bash
BUTTONS="Power Off:205,Let me outa here:200"
for m in $AVAIL_MODES;do
case $m in
standby)
BUTTONS="Running Standby:201,${BUTTONS}"
;;
mem)
BUTTONS="REST in RAM:203,${BUTTONS}"
;;
disk)
BUTTONS="Hiber on DISK:204,${BUTTONS}"
;;
esac;done

# REM: use pidof X in case we have currently switched to console;
#      DISPLAY would not work there .
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
   _debug "OK, /dev/'$ttyX' is a character special device"
   nrVT=${ttyX##*[[:alpha:][:punct:]_]}
   case $nrVT in
    [1-9]|[1-9][0-9]) chvt $nrVT
                      RV=$?;
    [ $RV = 0 ] && { _debug "OK, switched to tty${nrVT}"; } || { _err "chvt '$nrVT' returned with '$RV' exitcode"; }
    ;;
    *) _err "'$nrVT' not in range of 1-9 | 10-99";;
   esac
   true
  } || { _warn "/dev/'$ttyX' not a character special file .. WHAT ??"; }
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
  } || { _warn "'$ttyX' not a character special file .. WHAT ??"; }
#...2014-10-25

    [ "$DISPLAY" ] || export DISPLAY=':0'
    #xmessage -buttons "Hiber on DISK:204,Rest in RAM:203,Let me outa here:200" "
    xmessage -timeout 30 -buttons "$BUTTONS" -title "`pwd`/$0" "
    acpid daemon triggered '$0'      :
    Kernel : $KERN_VER
    ACPI Support:
                Available modes: $AVAIL_MODES
Power Button Pressed ?

                        Note: Timesout in 30 seconds with wmpoweroff.
"
    ANSWER=$?  ##+++2012-06-01 added menu
    #exit
    case $ANSWER in
    201) HIBER='';SLEEP='';MODE=STANDBY;mode=standby;
    descr='Power Management Light Sleep Standby "S1"'

    ;;
    203) HIBER='';SLEEP=1; MODE=RAM;mode=mem;
    descr='Power Management Sleep aka Low Power Sleep in RAM "S1-3 (BIOS Setting)"'

    ;;
    204) HIBER=1; SLEEP='';MODE=DISK;mode=disk;
    descr='Power Management Hibernate aka Suspend to Swap Partition "S4"'

    ;;
    205) HIBER='';SLEEP='';MODE=SOFT_OFF;mode=softoff;
    descr='Power Management normal poweroff (the power cable stays attached)'
    exec wmpoweroff
    ;; #exit 0;;
    200) echo "OK, getting out now.. Bye Bye!";exit 0
    ;;
    "")  echo "BUG? No ANSWER ..?";exit 0
    ;;
    *) exec wmpoweroff;; #exit 0;;
    esac

else #X not running, read console

# REM: need to change tty to catch input or do you have a better idea ..?
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
    201) HIBER='';SLEEP='';MODE=STANDBY;mode=standby; descr='Power Management Light Sleep Standby "S1"' ;                             break;;
    203) HIBER='';SLEEP=1; MODE=RAM;mode=mem;         descr='Power Management Sleep aka Low Power Sleep in RAM "S1-3 (BIOS Setting)"'; break;;
    204) HIBER=1; SLEEP='';MODE=DISK;mode=disk;       descr='Power Management Hibernate aka Suspend to Swap Partition "S4"';          break;;
    205) HIBER='';SLEEP='';MODE=SOFT_OFF;mode=softoff;descr='Power Management Normal Poweroff (the power cable stays attached)';     break;;
    206) echo "try again ..." >>/dev/${lastTTY##*/} ; continue;;
    200) echo "OK, will leave now.. Bye Bye!";exit 0;;
    "")  echo "BUG? Got no SELECT ..?";exit 0;;
    *)   :;;  #/sbin/poweroff;; ##exit 0;;
 esac

fi
done

exit #TESTING

fi #pidof X
# REM: So now have ANSWER or SELECT

# REM: message and some noise ..
[ "$DISPLAY" ] && xmessage -bg blue -fg yellow -timeout 9 -title "00000080.X" "Power button pressed ..
Preparing to suspend to $MODE .." &

aplay /usr/share/audio/2barks.au

# REM: shutdown pppd internet connection ..?
[ "`pidof pppd`" ] && { echo "Shutting down pppd" ;kill -2 `pidof pppd`;sleep 1; }

# REM: unmount almost everything unmountable...
_unmount_all(){

# REM: unmount last mounts first ...
MNTDPARTS=`tac /proc/mounts`
readonly MNTDPARTS
##REMARK1 : fuser -c /dev/sda4 would return ntfs-3g PID but -c [||-m] /mnt/sda4 not  ##+++2011-10-27

echo -e "\e[1;35m""Unmounting stray filesystems:""\e[0;39m"
# REM: filter out rootfs, pseudo-file-systems and frugal layer mounts ...
STRAYPARTL=`echo "$MNTDPARTS" |grep -vE ' /dev | /dev/shm | /dev/pts | devpts | /proc | /sys | proc | sysfs | *tmpfs  | *ramfs | rootfs |/dev/root | usbfs | unionfs | /initrd| on / '`

readonly STRAYPARTL

STRAYPARTMP=`echo "$STRAYPARTL" | cut -f 2 -d " "` ### |sed 's# type.*##' | tr ' ' '·'`

pidof sync || sync

for oneSTRAY in $STRAYPARTMP  ##in MountPoints
do
 [ "$oneSTRAY" ] || continue

__old__space__care__code__(){
 #Prepare the vars :
 oneSTRAY="${oneSTRAY//·/ }"
 oneSTRAY=${oneSTRAY//\"/}
}
 # REM: use echo -e to handle \0octal entries
 oneSTRAY=`echo -e "$oneSTRAY"`

 echo -e "\e[1;31mUnmounting '$oneSTRAY'...\e[0;39m"

 pidof sync >>$OUT || sync

 #ntfs or not:
 if [ "`busybox mount | grep "$oneSTRAY" | grep -E 'fuse|ntfs'`" != "" ] ; then
 #fusermount version: 2.7.0 [options] mountpoint
 noROX=1 fusermount -u "$oneSTRAY"   ##unmounts MountPoint
 else
 noROX=1 /bin/umount $VERB -r "$oneSTRAY"  ##unmounts MountPoint
 echo -e "\e[1;31m'$?'\e[0;39m"
 #sleep 1
 fi
 sleep 1
done
}
_unmount_all

pidof sync >>$OUT || sync

#### S4/204
if [ "$HIBER" ];then

# REM: Error message macro:
show_swaps(){
echo "$2
"

echo "
Currently available swap partitions :
$SWAPS

`free`
"
[ "$DISPLAY" ] && xmessage -bg red -fg white -title "00000080.X" "Aborted hibernation shutdown
due for more RAM to send to SWAP than SWAP available" &
aplay /usr/share/audio/2barks.au
exit $1
}

#prepare vars:
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

SWAPS_ON=`cat /proc/swaps |sed '1d' | grep -v 'deleted'`

# REM: /sys/power/image_size has default 500MB in bytes
#      gzip compression is 2-4 times of source
#      500 MB * 2.5 would make 1,250 MB RAM content a 500MB resume image
#      I assume 1:1 and compare free Mem and Swap lines...
#MEM_USED=`free |grep -i 'Mem' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $3}'`
MEM_USED=`free | awk '/Mem:/ {print $3}'`
#SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`
SWAP_FREE=`free | awk '/Swap:/ {print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to DISK due to free swap lesser than used mem"



# Sanity checks..
# REM: /sys/power/resume may be already set
# or set by CONFIG_PM_STD_PARTITION in kernel .config
read RESUME_MAJ_MIN </sys/power/resume

 if test "$RESUME_MAJ_MIN"; then

  # need to transform digits to hex .. DAMN ...
  RESUME_MAJ=${RESUME_MAJ_MIN%:*}
  RESUME_MIN=${RESUME_MAJ_MIN#*:}

  RESUME_MAJh=`printf %x $RESUME_MAJ`
  RESUME_MINh=`printf %x $RESUME_MIN`
# get the /dev/<resume partition>
 RESUME_DEVICE=`stat -c %t":"%T" "%n /dev/* | grep -m1 "^${RESUME_MAJh}:${RESUME_MINh}" | awk '{print $2}'`
# Sanity checks...
  [ -b "$RESUME_DEVICE" ] || unset RESUME_DEVICE RESUME_MAJ_MIN RESUME_MAJ RESUME_MIN
  guess_fstype "$RESUME_DEVICE" | grep $Q -i swap || unset RESUME_DEVICE RESUME_MAJ_MIN RESUME_MAJ RESUME_MIN
 [ "$RESUME_DEVICE" ] || { _warn "RESUME_DEVICE='$RESUME_DEVICE' had to be unset"; echo "" >/sys/power/resume; }
 fi

# ACPI_S4_RESUME_PARTITION : parameter option to this script
# or environment variable (still todo..)
 if test "$ACPI_S4_RESUME_PARTITION"; then
  [ -b "$ACPI_S4_RESUME_PARTITION" ] || unset ACPI_S4_RESUME_PARTITION
  guess_fstype "$ACPI_S4_RESUME_PARTITION" | grep $Q -i swap || unset ACPI_S4_RESUME_PARTITION
  [ "$ACPI_S4_RESUME_PARTITION" ] || _warn "ACPI_S4_RESUME_PARTITION='$ACPI_S4_RESUME_PARTITION' had to be unset"
 fi

 if [ "$ACPI_S4_RESUME_PARTITION" ];then

  # REM: handle /sys/power/resume entry...
  if [ "$RESUME_DEVICE" ]; then
      ACPI_S4_RESUME_PARTITION_MAJh=`stat -c %t $ACPI_S4_RESUME_PARTITION`
      ACPI_S4_RESUME_PARTITION_MINh=`stat -c %T $ACPI_S4_RESUME_PARTITION`
   if
   [ "$ACPI_S4_RESUME_PARTITION_MAJh" = "$RESUME_MAJh" ] && \
   [ "$ACPI_S4_RESUME_PARTITION_MINh" = "$RESUME_MINh" ]
   then
   _info "OK, ACPI_S4_RESUME_PARTITION should be identical with RESUME_DEVICE"
   else
   _warn "ACPI_S4_RESUME_PARTITION seems not to be identical with RESUME_DEVICE, using ACPI_S4_RESUME_PARTITION for /sys/power/resume"
   ACPI_S4_RESUME_PARTITION_MAJ=`printf %d 0x$ACPI_S4_RESUME_PARTITION_MAJh`
   ACPI_S4_RESUME_PARTITION_MIN=`printf %d 0x$ACPI_S4_RESUME_PARTITION_MINh`
   echo "${ACPI_S4_RESUME_PARTITION_MAJ}:${ACPI_S4_RESUME_PARTITION_MIN}" >/sys/power/resume
   [ $? = 0 ] || _exit 98 "#%^&!!@#!"  ##TODO
   fi
  fi

 [ "`echo "$SWAPS_LONG" |grep "^$ACPI_S4_RESUME_PARTITION"`" ] || show_swaps 1 "'$ACPI_S4_RESUME_PARTITION' seems not to be a regular swap partition"
#[ "`echo "$SWAPS" |grep -w "$ACPI_S4_RESUME_PARTITION"`" ] || show_swaps 1 "'$ACPI_S4_RESUME_PARTITION' seems not to be a regular swap partition"
 { for swap in $SWAPS_ON;do swapoff $swap;sleep 1s;pidof sync || sync;done;
   swapon $ACPI_S4_RESUME_PARTITION;
   [ $? = 0 ] || _exit 99 "#%^&!!@#!"; }  ##TODO
   FIRST_SWAP=$ACPI_S4_RESUME_PARTITION

 else # no ACPI_S4_RESUME_PARTITION...

 FIRST_SWAP=`echo "$SWAPS" |head -n1`

# REM: test if we have a swap partition labeled partly hiber or resume and use this ...
 for swap in $SWAPS;do
 SWAP_LABEL_RESUME=`blkid $swap |grep -iE 'Resume|Hiber' |cut -f1 -d':'`
 [ "$SWAP_LABEL_RESUME" ] && { FIRST_SWAP=$SWAP_LABEL_RESUME;break; }
 done

# turn off swaps
 SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
 echo "Swapping off all unneeded swaps..."
 for swap in $SWAPS_TO_TURN_OFF;do swapoff $swap;sleep 1s;pidof sync || sync;done

 fi #ACPI_S4_RESUME_PARTITION

SWAP_FREE=`free |grep -i 'Swap' |awk '{print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to RAM due to free swap lesser than used mem"

echo 'disk' >/sys/power/state 2>>/tmp/acpi.err
[ $? -ne 0 ] && xmessage -bg red -title "00000080.X" -file /tmp/acpi.err  ##DEBUG

sleep 3s
echo "$0: HELLO AGAIN '$USER'"  ##DEBUG
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

SWAPS_TO_TURN_ON=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
for swap in $SWAPS_TO_TURN_ON;do swapon $swap;sleep 1s;done

free ##DEBUG

# REM: welcome back message ...
[ "$DISPLAY" ] && xmessage -bg green -fg white -title "00000080.X" "HELLO AGAIN !
And WELCOME BACK '$USER'
on '$HOSTNAME' '$MACHTYPE'" &
aplay /usr/share/audio/2barks.au
### End HIBERNATION CODE ###


else # !hiber
  #     S3/203
  if [ "$SLEEP" ];then
echo 'mem' >/sys/power/state 2>>/tmp/acpi.err
# either debug or when back bark
[ $? -ne 0 ] && xmessage -bg red -title "00000080.X" -file /tmp/acpi.err || {
  aplay /usr/share/audio/2barks.au

  # REM: some cooling 5 seconds here...
  sleep 5
  # REM : restore mounts again
  #       use \n as IFS to care for special chars like space in path/to/mountpoint
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

    # noROX env variable for mount.sh
   grep -w "$_fstype_" /proc/filesystems | grep $Q '^nodev' && noROX=1

   # Remount it if still in proc/mounts ( umount -r option )
   if grep $Q -w "$_mntpnt_" /proc/mounts; then
    noROX=$noROX /bin/mount $VERB -t $_fstype_ -o remount,$_mntops_ "$_device_" "$_mntpnt_"
   else
   # mount it again
    noROX=$noROX /bin/mount $VERB -t $_fstype_ -o $_mntops_ "$_device_" "$_mntpnt_"
   fi

   sleep 0.2
   unset noROX
  done
  IFS="$oldIFS"

   }

 # REM: S1
 elif [ "$MODE" = "STANDBY" ]; then

  sleep 2
  echo standby >/sys/power/state
  sleep 2

 # REM: S5
 elif [ "$MODE" = "SOFT_OFF" ]; then

  sleep 2
  exec wmpoweroff

 # Dont know what this is, k3.9.9 has this ..?
 elif [ "$MODE" = "FREEZE" ]; then

  sleep 2
  echo freeze >/sys/power/state
  sleep2

  fi

fi


echo "$0:$*:$$:`date +%F~%T`:$KERN_VER"  ##DEBUG

###END###
# REM: /etc/acpi/wakealarm/wakealarm_cmd : run script when waked up
#      by RTC driver setting in /sys/class/rtc/*/*
if test -x /etc/acpi/wakealarm/wakealarm_cmd; then
 exec /etc/acpi/wakealarm/wakealarm_cmd &
fi
exit 0
###END###
