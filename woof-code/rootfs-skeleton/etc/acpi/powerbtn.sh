#!/bin/sh
# /etc/acpi/powerbtn.sh


[ "$DISPLAY" ] && xmessage -bg blue -fg yellow -timeout 19 -title "powerbtn.sh" "Power button pressed ..
Preparing to suspend to resume partition .." &
aplay /usr/share/audio/2barks.au

[ "`pidof pppd`" ] && { echo "Shutting down pppd" ;kill -1 `pidoff pppd`;sleep 1; }
#[ "`pidof X`" ] && { echo "Shutting down X" ;kill -9 `pidoff X`;sleep 1; }

MNTDPARTS="`mount`"
#echo
##REMARK1 : fuser -c /dev/sda4 would return ntfs-3g PID but -c [||-m] /mnt/sda4 not  ##+++2011_10_27
echo -e "\e[1;35m""Unmounting stray filesystems:""\e[0;39m"
#echo "$MNTDPARTS"
STRAYPARTL="`echo "$MNTDPARTS" |grep -v -E "/dev/pts|/proc|/sys|tmpfs|rootfs|/dev/root|usbfs|unionfs|/initrd| on / "`"
#echo "$STRAYPARTL"
STRAYPART_L=`echo $STRAYPARTL |rev |sed 's# )#\n)#g'|rev`
echo "STRAYPART_L='$STRAYPART_L'"
sleep 5s
STRAYPART_MP="`echo "$STRAYPART_L" | cut -f 3- -d " " |sed 's# type .*##' | tr ' ' '·'`"  ##2011_10_27 BUG though inside doublequotes , $STRAYPARTL needs doubblequotes
echo "STRAYPART_MP='$STRAYPART_MP'"  ##2011_10_27 BUG echo"$STRAYPARTMP"
for ONESTRAY in $STRAYPART_MP  ##in MountPoints
do
 ONESTRAY="${ONESTRAY//·/ }"
 echo "$ONESTRAY"
 #done
 echo -e "\e[1;31mUnmounting STRAY '$ONESTRAY'...\e[0;39m"
 ONESTRAY_P=`busybox mount | grep -w "$ONESTRAY" | cut -f 1 -d ' '`
 #fuser -v -k -c -m $ONESTRAY_P ##Device  ##Error both device and mountpoint dont work
 fuser -v -k -m  "$ONESTRAY"  ##+++2011_10_27
 #killzombies #v3.99
 pidof sync || sync
 if [ "`busybox mount | grep "$ONESTRAY" | grep -E 'fuse|ntfs'`" != "" ] ; then
 #fusermount version: 2.7.0 [options] mountpoint
 fusermount -u "$ONESTRAY" ##unmounts MountPoint
 else
 umount -r "$ONESTRAY"  ##unmounts MountPoint
 echo -e "\e[1;31m'$?'\e[0;39m"
 sleep 2s
 fi
done

__swapoff_code_from_rc_shutdwon__(){
swapoff -a #works only if swaps are in mtab or ftab
#v2.13 menno suggests this improvement...
STRAYPARTD="`cat /proc/swaps | grep "/dev/" | cut -f 1 -d " " | tr "\n" " "`"
for ONESTRAY in $STRAYPARTD
do
 echo "Swapoff $ONESTRAY"
 swapoff $ONESTRAY
done
sync
}

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


grep disk /sys/power/state || {

    [ "$DISPLAY" ] && xmessage -bg red -timeout 19 -title "ERROR" "No suspend to swap on disk configured
    for kernel
                `uname -r`
"

echo "ERROR: No suspend to swap on disk configured
       for kernel
                `uname -r`
"

    exit 4
}

# find swap partitions...
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`
# has all swap enough space to put ram into it...
# kernel documentation says default is 500 megabytes
# and it is compressed
# ratio for gzip is 2-4 times smaller than source in average
# so 500*2.5 is 1250 MB RAM..
# I assume uncompressed 1:1 to be sure and decompression takes time also
# and delays boot...
# Further hiberanation size can be adjusted in /sys/power/image_size..
# TODO: put this code below or above swapon SWAP_TO_USE or FIRST_SWAP ...
MEM_USED=`free |grep -i 'Mem' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $3}'`
SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to DISK due to free swap lesser than used mem"

# SWAP_TO_USE: environment variable for now..
if [ "$SWAP_TO_USE" ];then

echo "Have SWAP_TO_USE='$SWAP_TO_USE'"

# Sanity check...
[ "`echo "$SWAPS" |grep -w "$SWAP_TO_USE"`" ] || show_swaps 1 "'$SWAP_TO_USE' seems not to be a regular swap partition"

# swapoff everything
{ for swap in $SWAPS;do echo "'$swap'";
  grep $Q -w "^$swap" /proc/swaps   || continue;
  swapoff $swap;sleep 1s;pidof sync || sync;done;
# swapon  SWAP_TO_USE
  swapon $SWAP_TO_USE; }

# set FIRST_SWAP variable - it is used at wakeup ..
FIRST_SWAP="$SWAP_TO_USE"


# no SWAP_TO_USE variable set
else

# find out the swap device with highest priority
 FIRST_SWAP=`echo "$SWAPS" |head -n1`
 echo "FIRST_SWAP='$FIRST_SWAP'"

# or if some swap partition is labeled Resume|Hiber
  for swap in $SWAPS;do
   SWAP_LABEL_RESUME=`blkid $swap |grep -iE 'Resume|Hiber' |cut -f1 -d':'`
   [ "$SWAP_LABEL_RESUME" ] && { FIRST_SWAP=$SWAP_LABEL_RESUME;break; }
   #SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
  done

# turn off swap devices ...
 SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
 echo "Swapping off all unneeded swaps..."
  for swap in $SWAPS_TO_TURN_OFF;do echo "'$swap'";
   grep $Q -w "^$swap" /proc/swaps   || continue;
   swapoff $swap;sleep 1s;pidof sync || sync;done

fi

# Sanity checks...
SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`
[ "$SWAP_FREE" ] ||  show_swaps 1 "No free swap .."
[ "${SWAP_FREE//[[:digit:]]/}" ] && show_swaps 1 "Garbage output for SWAP_FREE '$SWAP_FREE'"

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to DISK due to free swap lesser than used mem"

# last chance to abort...
[ "$DISPLAY" ] && {

    xmessage -bg red -timeout 19 -buttons "Yes:200,No:199" -title "SURE" "Are You Sure ?"
   test $? = 200 -o $? = 0 || exit 0
}

# REM: /sys/power/resume may have content...
read defaultRESUME </sys/power/resume
case $defaultRESUME in
"") :;;
*)

   d_majDEC=${defaultRESUME%:*}
   d_minDEC=${defaultRESUME#*:}

   d_majHEX=`printf %x $majDEC`
   d_minHEX=`printf %x $minDEC`

  availableSWAP=`grep '^/dev/' /proc/swaps | grep -vi 'deleted' | head -n1 | awk '{print $1}'`

  a_majHEX=`stat -c %t $availableSWAP`
  a_minHEX=`stat -c %T $availableSWAP`

  if test $d_majHEX = $a_majHEX -a $d_minHEX = $a_minHEX; then
  :
  else

   a_majDEC=`printf %d 0x$a_majHEX`
   a_minDEC=`printf %d 0x$a_minHEX`

   # echo the available swap major:minor in decimal
   # to /sys/power/resume
   echo $a_majDEC:$a_minDEC >/sys/power/resume
   test $? = 0 || {

echo d_majDEC=$d_majDEC d_minDEC=$d_minDEC d_majHEX=$d_majHEX d_minHEX=$d_minHEX
echo a_majDEC=$a_majDEC a_minDEC=$a_minDEC a_majHEX=$a_majHEX a_minHEX=$a_minHEX

       exit 99; }

  fi

;;
esac

# now inform the kernel that we want to suspend to disk ...
echo 'disk' >/sys/power/state

# code below now runs further when the kernel is booted next time
# with the right resume= parameter
# either
# resume=/dev/<device> ie /dev/sda2 ,
# or PARTUUID=<UUID> , or <MAJOR>:<MINOR> in decimal , or <HEX>

# let the dust setle a little ..
sleep 3s

# debug or welcome message to state that this script is still running ...
echo "$0: HELLO AGAIN '$USER'"

# swapon again all swapoff 'ed swaps ...
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

SWAPS_TO_TURN_ON=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
for swap in $SWAPS_TO_TURN_ON;do swapon $swap;sleep 1s;done

# debug ..
free

# now real welcome message ..
[ "$DISPLAY" ] && xmessage -bg green -fg white -title "Wakeup" "HELLO AGAIN !
And WELCOME BACK '$USER'
on '$HOSTNAME' '$MACHTYPE'" &
aplay /usr/share/audio/2barks.au

### END ###
[ $STATUS ] || STATUS=0
exit $STATUS
### END ###
