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
Version='1.3 Macpup_O2-Puppy_Linux_431 KRG' ## Complete rework of S4 hibernation code
                                            ## Hibernation code now with GUI to select resume swap partition
                                            ##  if more than one swap partition detected
                                            ##   !! NOTE : New S4 hibernation code not tested yet !!
                                            ## Small xmessage GUI usability improvements
                                            ##  ( -default , -timeout and mouse wakeup hint )
                                            ## Disabled fusermount umount part
Version='1.4 Macpup_O2-Puppy_Linux_431 KRG' ## S1 handling
                                            ## restore mounts for all modes
                                            ## Typo su(s)pend

usage(){
MSG="
$0

OPTIONS:
[help|version]
[checkcode|debug|verbose]
[hiber|sleep|resume=/dev/SWAP|/dev/SWAP]

Available Modes :
$KERN_REL
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
#===================================================================================================================================


# REM: UTS_RELEASE actually ... VERSION in Makefile is first number,
#      `make kernelversion' prints VERSION.PATCHLEVEL.SUBLEVEL.EXTRALEVEL
KERN_REL=`uname -r`
echo "$0:$*:$$:`date +%F~%T`:$KERN_REL"  ##DEBUG

# prevent multiple sync running ...
pidof sync >>$OUT || sync

# REM: create menu ...
#AVAIL_MODES=$(</sys/power/state)  ##bash syntax
read AVAIL_MODES </sys/power/state #ash and bash
# REM: Default buttons:
BUTTONS="Power Off:205,Let me outa here:200"

for m in $AVAIL_MODES;do
case $m in
standby)
# REM: k2.6.31 did not wake up until now from S1
 #_kernel_version
 case "$KERN_REL" in
 2.6.31.*) :;;
 *)
BUTTONS="Runng Standby S1:201,${BUTTONS}"
 ;;
 esac
;;
mem)
BUTTONS="Rest  in  RAM S3:203,${BUTTONS}"
;;
disk)
BUTTONS="Hiber on DISK S4:204,${BUTTONS}"
;;
esac;done
#===================================================================================================================================

#===================================================================================================================================

# REM : Now a bunch of hibernation functions :
#
#

_swapon_all_swap_partitions(){
local dev rest

oldIFS=$"$IFS"
IFS=':'

blkid | grep -i ' TYPE="swap"' |
while read dev rest; do
         [ "$dev" ]           || continue
  grep -w "^$dev" /proc/swaps && continue
      swapon $dev; sleep 0.5; done

IFS=$"$oldIFS"

}

_swapon_all_swap_partitions_array(){
local i dev

[ "$c" ] || return 0

for i in `seq 0 1 $c`
do
dev=`eval echo \\$swapd$i`
[ "$dev" ] || continue
grep -w "^$dev" /proc/swaps && continue
swapon $dev
sleep 0.5
done
}

_unknown_error(){

UNKNOWN_ERR_MSG="Sorry!
an unknown error occured.

Will have to exit.

"
[ "$*" ] && UNKNOWN_ERR_MSG="$UNKNOWN_ERR_MSG

Additional hints:
$*
"

Xdialog -infobox "$UNKNOWN_ERR_MSG" 0x0 9999

_swapon_all_swap_partitions
exit 9
}

_error_no_swap(){

NO_SWAP_MSG="Darn!
Could not find any swap partitions.

To setup a swap partition:
 Use Gparted in the System Menu
   and format a free partition with
   swap filesystem .
  Maybe it needs resizing and extended
   partition setup too beforehand .
   Swap is said should be 2 times installed RAM,
   but the kernel default resume image size is 500 MB
 (currently set to ${curRESUME_IMG_SIZE_MB} MB in /sys/power/image_size)

Note: This script assumes size of the resume swap partition
      as minimum = Ram size because it does not trust in compression.
Further Note : This script does not support swap-files yet
               ( patches welcome ) .
"

Xdialog -infobox "$NO_SWAP_MSG" 0x0 9999

_swapon_all_swap_partitions
exit 4
}

_error_no_suitable_swap(){

NO_SUIT_SWAP_MSG="Ouch!

Swap partitons are there, but they are not
usable because of too small size.

Aborting ...
"

Xdialog -infobox "$NO_SUIT_SWAP_MSG" 0x0 9999

_swapon_all_swap_partitions
exit 5
}

_grab_resume_from_menu_lst(){

[ "$BOOTLOADER_FILE" ] || BOOTLOADER_FILE=/boot/grub/menu.lst

if [ -f "$BOOTLOADER_FILE" ]; then

BOOTLOADER_RESUME=`grep -o 'resume=[^[:blank:]]*' "$BOOTLOADER_FILE" | tail -n1 | cut -f 2- -d'='`

fi

}

_say_mem_used(){
memK_USED=`free -k | awk '{ if (match($1, "Mem")) print $3}'`
echo "$memK_USED"
}

_get_curr_default_resume(){
IFS=":" read def_res_MAJd def_res_MINd </sys/power/resume
def_res_MAJh=`printf %x $def_res_MAJd`
def_res_MINh=`printf %x $def_res_MINd`

echo def_res_MAJd=$def_res_MAJd def_res_MAJh=$def_res_MAJh
echo def_res_MINd=$def_res_MINd def_res_MINh=$def_res_MINh

DEFAULT_RESUME=`stat -c %t":"%T":"%n /dev/* | grep -m1 "^${def_res_MAJh}:${def_res_MINh}" | awk -F':' '{print $3}'`

}

_get_curr_res_img_size(){

read currentRESUME_IMG_SIZE_B </sys/power/image_size
echo currentRESUME_IMG_SIZE_B=$currentRESUME_IMG_SIZE_B

if [ ! "$currentRESUME_IMG_SIZE_B" ]; then
currentRESUME_IMG_SIZE_K=`_say_mem_used`
else
currentRESUME_IMG_SIZE_K=$((currentRESUME_IMG_SIZE_B/1024))
fi

[ "$currentRESUME_IMG_SIZE_K" ] || currentRESUME_IMG_SIZE_K=$((500*1024))

echo currentRESUME_IMG_SIZE_K=$currentRESUME_IMG_SIZE_K

}

_swap_array_ash(){

local d t sk uk p i

_swapon_all_swap_partitions
_get_curr_res_img_size
_grab_resume_from_menu_lst

    c=-1
while read d t sk uk p; do
echo $d $sk $p;
case "$d" in
/dev/*) :;;
*) continue;;
esac
[ "$sk" -gt "$currentRESUME_IMG_SIZE_K" ] || continue
[ "$t" = "partition" ] || continue
c=$((c+1))
echo $d $sk $p;
eval swapd$c=$d;eval swapsk$c=$sk; eval swapp$c=$p;
#c=$((c+1));
done</proc/swaps

echo c=$c

#eval echo $swapd0
#eval echo \$swapd0
#eval echo \\$swapd0

if [ "$c" = '-1' ]; then
_error_no_suitable_swap
fi

for i in `seq 0 1 $c`; do
eval echo \$swapd$i \$swapsk$i \$swapp$i
[ "`eval echo \\$swapd$i`" ] || break; done

}


create_on_off_help_list(){

unset ONOFFHELP_LIST

# REM: _swap_array_ash is a function
#      that creates device[0] size[0] and so forth variables...
_swap_array_ash

ONOFF=off
i=0

while [ A ];
do
[ "`eval echo \\$swapd$i`" ] || break

# REM: Set "on" if available ..
[ "`eval echo \\$swapd$i`" = "$BOOTLOADER_RESUME" ] && ONOFF=on

_single_newline(){ # does not work for now
ONOFFHELP_LIST="$ONOFFHELP_LIST
`eval echo \\$swapd$i` `eval echo \\$swapsk$i` $ONOFF \"{priority `eval echo \\$swapp$i`}\" \\ "
}
#_single_newline  # does not work for now

_single_line(){ # does not work for now
ONOFFHELP_LIST="${ONOFFHELP_LIST} `eval echo \\$swapd$i` `eval echo \\$swapsk$i` $ONOFF {priority `eval echo \\$swapp$i`}"
}
#_single_line  # does not work for now

# REM: works for Xdialog if IFS=$'\n' set before Xdialog
_multi_line(){
ONOFFHELP_LIST="$ONOFFHELP_LIST
`eval echo \\$swapd$i`
`eval echo \\$swapsk$i`
$ONOFF
{priority `eval echo \\$swapp$i`}
"
}
_multi_line


[ "`eval echo \\$swapd$i`" ] || break;
i=$((i+1))
ONOFF=off
done

:

echo "$ONOFFHELP_LIST"
echo
echo $ONOFFHELP_LIST
}


_xd_choose_swap(){

create_on_off_help_list

[ "$ONOFFHELP_LIST" ] || _error_no_suitable_swap

if [ "$c" = 0 ] ; then
ACPI_S4_RESUME_PARTITION=`eval echo \\$swapd0`
else

SELECT_RESUME_TEXT="Select from the determined
suitable swap partitions below the one
to put the resume image onto :
"

if [ "$BOOTLOADER_RESUME" ] ; then
SELECT_RESUME_TEXT="$SELECT_RESUME_TEXT
Note:
$BOOTLOADER_RESUME has been found a resume= parameter
in $BOOTLOADER_FILE configuration file
"
fi

_get_curr_default_resume
if [ "$DEFAULT_RESUME" ]; then
SELECT_RESUME_TEXT="$SELECT_RESUME_TEXT
Note2:
$DEFAULT_RESUME has been found in /sys/power/resume
as current default resume partition
"
fi

oldIFS=$"$IFS"
IFS=$'\n'
Xdialog \
-title "Resume Partition" \
-stdout \
-item-help \
-radiolist \
 "$SELECT_RESUME_TEXT" \
 0x0 \
 5 $ONOFFHELP_LIST >/tmp/swap_selection
[ "$?" = 0 ] || { _swapon_all_swap_partitions; exit 6; }

read ACPI_S4_RESUME_PARTITION </tmp/swap_selection
echo ACPI_S4_RESUME_PARTITION=$ACPI_S4_RESUME_PARTITION
[ "$ACPI_S4_RESUME_PARTITION" ] || _unknown_error "ACPI_S4_RESUME_PARTITION='$ACPI_S4_RESUME_PARTITION'"
[ "$DEBUG" ] || rm -f /tmp/swap_selection
fi

}



_swapoff_all_swap_partitions(){
    local i dev
for i in `seq $c -1 0`;
do
dev=`eval echo \\$swapd$i`
[ "$dev" ] || continue
grep -w "^$dev" /proc/swaps || continue
swapoff $dev
sleep 0.2
done
}

_verify_resume_partition(){
# ACPI_S4_RESUME_PARTITION : parameter option to this script
# or environment variable (still todo..)
[ "$ACPI_S4_RESUME_PARTITION" ] || return 6

 if test "$ACPI_S4_RESUME_PARTITION"; then
  [ -b "$ACPI_S4_RESUME_PARTITION" ] || {
      _warn "$ACPI_S4_RESUME_PARTITION not a block special device";
      unset ACPI_S4_RESUME_PARTITION; }
 fi

 if test "$ACPI_S4_RESUME_PARTITION"; then
   #guess_fstype "$ACPI_S4_RESUME_PARTITION" | grep $Q -i swap || unset ACPI_S4_RESUME_PARTITION
   blkid $ACPI_S4_RESUME_PARTITION | grep $Q -i ' TYPE="swap"' || {
   _warn "ACPI_S4_RESUME_PARTITION='$ACPI_S4_RESUME_PARTITION' had to be unset"
   unset ACPI_S4_RESUME_PARTITION; }
 else
  return 5
 fi

[ "$ACPI_S4_RESUME_PARTITION" ] && return 0
return 4
}

_swapon_resume_partition(){
test "$ACPI_S4_RESUME_PARTITION" || return 4

ACPI_S4_RESUME_PARTITION_MAJh=`stat -c %t $ACPI_S4_RESUME_PARTITION`
ACPI_S4_RESUME_PARTITION_MINh=`stat -c %T $ACPI_S4_RESUME_PARTITION`

_hex_into_sys_power_resume(){
# REM: does not like MAJ:MIN in hex ...
echo ACPI_S4_RESUME_PARTITION_MAJh=$ACPI_S4_RESUME_PARTITION_MAJh ACPI_S4_RESUME_PARTITION_MINh=$ACPI_S4_RESUME_PARTITION_MINh
echo "0x${ACPI_S4_RESUME_PARTITION_MAJh}:0x${ACPI_S4_RESUME_PARTITION_MINh}"
echo "0x${ACPI_S4_RESUME_PARTITION_MAJh}:0x${ACPI_S4_RESUME_PARTITION_MINh}" >/sys/power/resume
}

ACPI_S4_RESUME_PARTITION_MAJd=`printf %d 0x$ACPI_S4_RESUME_PARTITION_MAJh`
ACPI_S4_RESUME_PARTITION_MINd=`printf %d 0x$ACPI_S4_RESUME_PARTITION_MINh`
echo ACPI_S4_RESUME_PARTITION_MAJd=$ACPI_S4_RESUME_PARTITION_MAJd ACPI_S4_RESUME_PARTITION_MINd=$ACPI_S4_RESUME_PARTITION_MINd
echo "${ACPI_S4_RESUME_PARTITION_MAJd}:${ACPI_S4_RESUME_PARTITION_MINd}"
# REM: does not accept empty entry to reset beforehand
#echo "" >/sys/power/resume
echo "${ACPI_S4_RESUME_PARTITION_MAJd}:${ACPI_S4_RESUME_PARTITION_MINd}" >/sys/power/resume

sleep 1
swapon $ACPI_S4_RESUME_PARTITION
return $?
}


_final_acknowledgement(){

_swapoff_all_swap_partitions

_swapon_resume_partition || _unknown_error "Could not swapon $ACPI_S4_RESUME_PARTITION"

ACK_MSG="So..
everything is prepared
for suspending to disk ...

Click Aye button to hibernate now,
or Bye button to return into session..
"

Xdialog -cancel-label "Bye" -ok-label "Aye" -yesno "$ACK_MSG" 0x0
[ "$?" = 0 ] || { _swapon_all_swap_partitions; exit 11; }

# REM: better be done in main
#echo disk >/sys/power/state
}


_main_resume_partition(){

# REM: _xd_choose_swap calls a bunch of functions:
#
_xd_choose_swap

# REM: non-zero ??
[ "$?" = 0 ] || _unknown_error "_main:_xd_choose_swap returned non-zero"

# REM: _final_acknowledgement calls
#      _swapoff_all_swap_partitions, _swapon_resume_partition
#      _swapon_all_swap_partitions if canceled
#      and echo's disk >/sys/power/state
_final_acknowledgement

# REM: Big moment
echo disk >/sys/power/state
# REM:
_swapon_all_swap_partitions
}


#===================================================================================================================================

#===================================================================================================================================
# REM: use pidof X in case we have currently switched to console;
#      DISPLAY would not work there .
#if [ "$DISPLAY" ];then
if pidof X; then
 #=============================================================================================================================

  # get tty of X and change there ...  2014-10-25

  # REM: regular ps outputs 'human readable' tty
  #      busybox ps tells major and minor of tty

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
    Kernel : $KERN_REL
    ACPI Support:
                Available modes: $AVAIL_MODES
Power Button Pressed ?

                        Note: Timesout in 30 seconds with wmpoweroff.
"
    ANSWER=$?  ##+++2012-06-01 added menu
    #exit  ##TEST
    case $ANSWER in
    201) HIBER='';SLEEP='';MODE=STANDBY;mode=standby;
    descr='Power Management Light Sleep Standby "S1"'

    ;;
    203) HIBER='';SLEEP=1; MODE=RAM;mode=mem;
    descr='Power Management Sleep aka Low Power Sleep in RAM "S1-3 (BIOS Setting)"'

    ;;
    204) HIBER=1; SLEEP='';MODE=DISK;mode=disk;
    descr='Power Management Hibernate aka Suspend to Swap Partition "S4"'

    # REM: If ACPI_S4_RESUME_PARTITION env var or parameter to this script,
    #       attempt to check if valid swap partition ...
    #      _verify_resume_partition unsets ACPI_S4_RESUME_PARTITION if invalid
    [ "$ACPI_S4_RESUME_PARTITION" ] && _verify_resume_partition

    # REM: if _verify_resume_partition does not unset ACPI_S4_RESUME_PARTITION
    if [ "$ACPI_S4_RESUME_PARTITION" ]; then
      # _final_acknowledgement needs this:
      _swap_array_ash

    # REM: else run choice GUI _xd_choose_swap
    else

      _xd_choose_swap
      # REM: non-zero ??
      [ "$?" = 0 ] || _unknown_error "_main:_xd_choose_swap returned non-zero"
    fi

     # REM: _final_acknowledgement calls
     #       _swapoff_all_swap_partitions,
     #      then _swapon_resume_partition
     #       which also sets /sys/power/resume entry,
     #      and then presents GUI to go on or leave :
     _final_acknowledgement

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
 #=====================================================

else #X not running, read console

 # REM: need to change tty to catch input or do you have a better idea ..?
  lastTTY=`_last_logged_in_on_tty | awk '{print $3}'`
  lTTYnr=${lastTTY##*[[:alpha:][:punct:]_]}
  chvt $lTTYnr
  sleep 1
  echo -e "\nPowerbutton pressed:\n" >/dev/${lastTTY##*/}

cat >>/dev/${lastTTY##*/} <<EoI
acpid daemon triggered '$0' :
Kernel : $KERN_REL
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
#===================================================================================================================================
# REM: So now have ANSWER or SELECT and MODE

#===================================================================================================================================
# REM: message and some noise ..
if [ "$MODE" != "SOFT_OFF" ]; then
xmPREPARE_TMOUT=30
[ "$DISPLAY" ] && xmessage -bg blue -fg yellow -timeout $xmPREPARE_TMOUT -title "00000080.X" -nearmouse -default "okay" "Power button pressed ..
Preparing system to suspend to $MODE .

Will unmount everything mounted
with read-only fallback .

Should mount everything again with
pre-mount options when awaking ... (hopefully)

Note : If you have an USB mouse attached,
       you should turn it off before suspend happens,
       not afterwards . Moving the mouse a tiny bit may
       not wake up the system, but the USB hub and light up
       any LEDs connected to it ...

Note : Timesout in $xmPREPARE_TMOUT ...
       ( else press Enter )
" & xPID=$!
fi
aplay /usr/share/audio/2barks.au
#===================================================================================================================================


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

# REM: !MUST! use mountpoint
#      in case device is mounted another time
#      by mount -o bind || mount --bind
for oneSTRAY in $STRAYPARTMP  ##in MountPoints
do
 [ "$oneSTRAY" ] || continue
 unset yPID  #yaf PID

__old__space__care__code__(){
 #Prepare the vars :
 oneSTRAY="${oneSTRAY//·/ }"
 oneSTRAY=${oneSTRAY//\"/}
}
 # REM: use echo -e to handle \0octal entries
 #      !MUST! be done after test if ntfs or not
 #      because otherwise mountpoint entry from /proc/mounts
 #
 #oneSTRAY=`echo -e "$oneSTRAY"`

 # say what is going on ...
 # REM: better after test for fuse | ntfs and translating \0octals ...
 #echo -e "\e[1;31mUnmounting '$oneSTRAY'...\e[0;39m"

 pidof sync >>$OUT || sync

 # REM: fusermount disabled, because if it calls umount -i
 #      it would probably not be able to transform -z into -l
 #      and -o ro into -O ro -- busybox umount does not understand
 #                              -o or -O anyways ....
 __use_fusermount__(){
 # ntfs or not:
 # REM: lame grep attempt
 #if [ "`busybox mount | grep "$oneSTRAY" | grep -E 'fuse|ntfs'`" != "" ] ; then

 #awk "{if (\$2 == \"$oneSTRAY\" && ( match(\$3, \".*fuse.*\") || match(\$3, \".*ntfs.*\") )) print}" /proc/mounts ## DEBUG
 if [ "`awk "{if (\\$2 == \\"$oneSTRAY\\" && ( match(\\$3, \\".*fuse.*\\") || match(\\$3, \\".*ntfs.*\\") )) print}" /proc/mounts`" ]; then

 # REM: now translate \0octals ...
 oneSTRAY=`echo -e "$oneSTRAY"`

 echo -e "\e[1;31mfusermount unmounting '$oneSTRAY'...\e[0;39m"
 [ "$DISPLAY" ] && yaf-splash -bg purple -text "Unmounting '$oneSTRAY'..." & yPID=$!

 # REM: fusermount version: 2.7.0 [options] mountpoint
 # REM: ignoreROX env var for mount.sh, mainly for nodev file-systems...
 ignoreROX=1 fusermount -u "$oneSTRAY"   ##unmounts MountPoint

 else

 # REM: now translate \0octals ...
 oneSTRAY=`echo -e "$oneSTRAY"`

 echo -e "\e[1;31mUnmounting '$oneSTRAY'...\e[0;39m"
 [ "$DISPLAY" ] && yaf-splash -bg purple -text "Unmounting '$oneSTRAY'..." & yPID=$!

 ignoreROX=1 /bin/umount $VERB -r "$oneSTRAY"  ##unmounts MountPoint
 echo -e "\e[1;31m'$?'\e[0;39m"
 #sleep 1
 fi

 sleep 1
 [ "$yPID" -a "`ls -d /proc/$yPID`" ] && kill $yPID
 }  ###__use_fusermount__(){

  # REM: now translate \0octals ...
 oneSTRAY=`echo -e "$oneSTRAY"`

 echo -e "\e[1;31mUnmounting '$oneSTRAY'...\e[0;39m"
 [ "$DISPLAY" ] && yaf-splash -bg purple -text "Unmounting '$oneSTRAY'..." & yPID=$!

 ignoreROX=1 /bin/umount $VERB -r "$oneSTRAY"  ##unmounts MountPoint
 echo -e "\e[1;31m'$?'\e[0;39m"

 sleep 1
 [ "$yPID" -a "`ls -d /proc/$yPID`" ] && kill $yPID

done
}
_unmount_all

pidof sync >>$OUT || sync
#===================================================================================================================================

#exit ##TEST

#===================================================================================================================================
#### S4/204
if [ "$HIBER" ];then

__old_resume_partition_code__(){
# REM: Now comes a bunch of sanity checks ...

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

__determine_swaps_using_fdisk__(){
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`
}

SWAPS=`_find_swap_devices`

SWAPS_ON=`grep -v 'deleted' /proc/swaps |sed '1d'`

# REM: /sys/power/image_size has default 500MB in bytes
#      gzip compression is 2-4 times of source
#      500 MB * 2.5 would make 1,250 MB RAM content a 500MB resume image
#      I assume 1:1 and compare free Mem and Swap lines...
#MEM_USED=`free |grep -i 'Mem' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $3}'`
MEM_USED=`free | awk '/Mem:/ {print $3}'`
#SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`
SWAP_FREE=`free | awk '/Swap:/ {print $4}'`
# REM: NOTE: This now is complete swap space of all current used swaps
# TODO: Need to calculate the swap space of the used swap partition further down ...
#       And filter out available swaps with too little space (<500MB or <RAM)
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
# get the /dev/<resume partition> (CONFIG_PM_STD_PARTITION in kernel .config)
 RESUME_DEVICE=`stat -c %t":"%T" "%n /dev/* | grep -m1 "^${RESUME_MAJh}:${RESUME_MINh}" | awk '{print $2}'`
# Sanity checks...
  [ -b "$RESUME_DEVICE" ] || unset RESUME_DEVICE RESUME_MAJ_MIN RESUME_MAJ RESUME_MIN
  guess_fstype "$RESUME_DEVICE" | grep $Q -i swap || unset RESUME_DEVICE RESUME_MAJ_MIN RESUME_MAJ RESUME_MIN
 [ "$RESUME_DEVICE" ] || { _warn "RESUME_DEVICE='$RESUME_DEVICE' had to be unset"; echo "" >/sys/power/resume; }
 fi

_verify_resume_partition(){
# ACPI_S4_RESUME_PARTITION : parameter option to this script
# or environment variable (still todo..)
 if test "$ACPI_S4_RESUME_PARTITION"; then
  [ -b "$ACPI_S4_RESUME_PARTITION" ] || unset ACPI_S4_RESUME_PARTITION
  guess_fstype "$ACPI_S4_RESUME_PARTITION" | grep $Q -i swap || unset ACPI_S4_RESUME_PARTITION
  [ "$ACPI_S4_RESUME_PARTITION" ] || _warn "ACPI_S4_RESUME_PARTITION='$ACPI_S4_RESUME_PARTITION' had to be unset"
 fi
}
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

 [ "`echo "$SWAPS" |grep "^$ACPI_S4_RESUME_PARTITION"`" ] || show_swaps 1 "'$ACPI_S4_RESUME_PARTITION' seems not to be a regular swap partition"
#[ "`echo "$SWAPS" |grep -w "$ACPI_S4_RESUME_PARTITION"`" ] || show_swaps 1 "'$ACPI_S4_RESUME_PARTITION' seems not to be a regular swap partition"
 { for swap in $SWAPS_ON;do swapoff $swap;sleep 1s;pidof sync || sync;done;
   swapon $ACPI_S4_RESUME_PARTITION;
   [ $? = 0 ] || _exit 99 "#%^&!!@#!"; }  ##TODO
   FIRST_SWAP=$ACPI_S4_RESUME_PARTITION

 else # no ACPI_S4_RESUME_PARTITION...

 FIRST_SWAP=`echo "$SWAPS" |head -n1`

# REM: test if there is a swap partition labeled partly 'hiber' or 'resume' use this ...
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
} ###__old_resume_partition_code__(){ #END


#_final_acknowledgement
#kill $xPID

_pidof_pid $xPID && wait $xPID
sleep 1

echo 'disk' >/sys/power/state 2>>/tmp/acpi.err
[ $? -ne 0 ] && xmessage -bg red -title "00000080.X" -file /tmp/acpi.err  ##DEBUG

sleep 3s
echo "$0: HELLO AGAIN '$USER'"  ##DEBUG

__determine_swaps_using_fdisk_after__(){
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`
}

SWAPS=`_find_swap_devices`

SWAPS_TO_TURN_ON=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
for swap in $SWAPS_TO_TURN_ON;do
grep $Q -w "^$swap" /proc/swaps && continue
swapon $swap;sleep 1s;done

free ##DEBUG

# REM: now at the very end of script
__welcome_back_message__(){
# REM: welcome back message ...
[ "$DISPLAY" ] && xmessage -bg green -fg white -title "00000080.X" "HELLO AGAIN !
And WELCOME BACK '$USER'
on '$HOSTNAME' '$MACHTYPE'" &
aplay /usr/share/audio/2barks.au
}
### End HIBERNATION CODE ###
#===================================================================================================================================

#===================================================================================================================================
else # !hiber
  #     S3/203
  if [ "$SLEEP" ];then
  #kill $xPID
  wait $xPID
  sleep 1
echo 'mem' >/sys/power/state 2>>/tmp/acpi.err
# if fails, debug
[ $? -ne 0 ] && xmessage -bg red -title "00000080.X" -file /tmp/acpi.err || {
  #aplay /usr/share/audio/2barks.au

  :

__restore_mounts__(){
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

    # ignoreROX env variable for mount.sh
   grep -w "$_fstype_" /proc/filesystems | grep $Q '^nodev' && ignoreROX=1

   # Remount it if still in proc/mounts ( umount -r option )
   if grep $Q -w "$_mntpnt_" /proc/mounts; then
    ignoreROX=$ignoreROX /bin/mount $VERB -t $_fstype_ -o remount,$_mntops_ "$_device_" "$_mntpnt_"
   else
   # mount it again
    ignoreROX=$ignoreROX /bin/mount $VERB -t $_fstype_ -o $_mntops_ "$_device_" "$_mntpnt_"
   fi

   sleep 0.2
   unset ignoreROX
  done
  IFS="$oldIFS"

   }

  :

 }
#===================================================================================================================================

#===================================================================================================================================
 # REM: S1
 elif [ "$MODE" = "STANDBY" ]; then

  #kill $xPID
  wait $xPID
  sleep 2
  echo standby >/sys/power/state
  sleep 2

 # REM: S5
 elif [ "$MODE" = "SOFT_OFF" ]; then

  kill $xPID
  sleep 2
  exec wmpoweroff

 # Don't know what this is, k3.9.9 has this ..?
 elif [ "$MODE" = "FREEZE" ]; then

  #kill $xPID
  wait $xPID
  sleep 2
  echo freeze >/sys/power/state
  sleep2

  fi
#===================================================================================================================================

fi


echo "$0:$*:$$:`date +%F~%T`:$KERN_REL"  ##DEBUG
aplay /usr/share/audio/2barks.au
BACK_MSG=`gettext "WELCOME BACK, $USER !"`
xmessage -timeout "$xmPREPARE_TMOUT" -default "okay" -nearmouse -bg seagreen -fg yellow "$BACK_MSG" & xPID=$!

_restore_mounts(){
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

    # ignoreROX env variable for mount.sh
   grep -w "$_fstype_" /proc/filesystems | grep $Q '^nodev' && ignoreROX=1

   # Remount it if still in proc/mounts ( umount -r option )
   if grep $Q -w "$_mntpnt_" /proc/mounts; then
    ignoreROX=$ignoreROX /bin/mount $VERB -t $_fstype_ -o remount,$_mntops_ "$_device_" "$_mntpnt_"
   else
   # mount it again
    ignoreROX=$ignoreROX /bin/mount $VERB -t $_fstype_ -o $_mntops_ "$_device_" "$_mntpnt_"
   fi

   sleep 0.2
   unset ignoreROX
  done
  IFS="$oldIFS"

   }
_restore_mounts

#_pidof_pid $xPID && wait $xPID


### END ###
# REM: /etc/acpi/wakealarm/wakealarm_cmd : run script when waked up
#      by RTC driver setting in /sys/class/rtc/*/*
#      ** TODO **
if test -x /etc/acpi/wakealarm/wakealarm_cmd; then
 exec /etc/acpi/wakealarm/wakealarm_cmd &
fi

_pidof_pid $xPID && wait $xPID

# REM: Newline for the acpid.log
#      to have a delimiter for next invocation
echo "$BACK_MSG
"

exit 0
### END ###
