#!/bin/sh
# /etc/acpi/powerbtn.sh

/bin/logger -t "acpid:$0" -p 1 "Started"

/bin/logger -t "acpid:$0" -p 1 " "
/bin/logger -t "acpid:$0" -p 1 "`env`"
/bin/logger -t "acpid:$0" -p 1 " "

/bin/logger -t "acpid:$0" -p 1 "DISPLAY='$DISPLAY'"
/bin/logger -t "acpid:$0" -p 1 "pidof X = '`pidof X`'"
pidof X && export DISPLAY=':0'
/bin/logger -t "acpid:$0" -p 1 "DISPLAY='$DISPLAY'"

[ "$DISPLAY" ] && xmessage -bg blue -fg yellow "Power button pressed ..
Preparing to suspend to resume partition .." &
aplay /usr/share/audio/2barks.au

[ "`pidof pppd`" ] && { echo "Shutting down pppd" ;kill -1 `pidof pppd`;sleep 1; }
#[ "`pidof X`" ] && { echo "Shutting down X" ;kill -9 `pidoff X`;sleep 1; }

MNTDPARTS="`mount`"
#echo
##REMARK1 : fuser -c /dev/sda4 would return ntfs-3g PID but -c [||-m] /mnt/sda4 not  ##+++2011_10_27
echo -e "\e[1;35m""Unmounting stray filesystems:""\e[0;39m"
#echo "$MNTDPARTS"
STRAYPARTL="`echo "$MNTDPARTS" |grep -v -E "/dev/pts|/proc|/sys|tmpfs|rootfs|/dev/root|usbfs|unionfs|/initrd| on / "`"
#echo "$STRAYPARTL"
STRAYPARTL=`echo $STRAYPARTL |rev |sed 's# )#\n)#g'|rev`
echo "STRAYPARTL='$STRAYPARTL'"
sleep 5s
STRAYPARTMP="`echo "$STRAYPARTL" | cut -f 3- -d " " |sed 's# type.*##' | tr ' ' '·' | tr "\n" " "`"  ##2011_10_27 BUG though inside doublequotes , $STRAYPARTL needs doubblequotes
echo "STRAYPARTMP='$STRAYPARTMP'"  ##2011_10_27 BUG echo"$STRAYPARTMP"
for ONESTRAY in $STRAYPARTMP  ##in MountPoints
do
 ONESTRAY="${ONESTRAY//·/ }"
 echo "$ONESTRAY"
 #done
 echo -e "\e[1;31mUnmounting STRAY '$ONESTRAY'...\e[0;39m"
 ONESTRAYP=`busybox mount | grep -w "$ONESTRAY" | cut -f 1 -d ' '`
 #fuser -v -k -c -m $ONESTRAYP ##Device  ##Error both mount and mountpoint dont work
 fuser -v -k -m  "$ONESTRAY"  ##+++2011_10_27
 #killzombies #v3.99
 sync
 if [ "`busybox mount | grep "$ONESTRAY" | grep -E 'fuse|ntfs'`" != "" ] ; then
 #fusermount version: 2.7.0 [options] mountpoint
 fusermount -u "$ONESTRAY" ##unmounts MountPoint
 else
 umount -r "$ONESTRAY"  ##unmounts MountPoint
 echo -e "\e[1;31m'$?'\e[0;39m"
 sleep 2s
 fi
done
#swapoff -a #works only if swaps are in mtab or ftab
#v2.13 menno suggests this improvement...
#STRAYPARTD="`cat /proc/swaps | grep "/dev/" | cut -f 1 -d " " | tr "\n" " "`"
#for ONESTRAY in $STRAYPARTD
#do
# echo "Swapoff $ONESTRAY"
# swapoff $ONESTRAY
#done
#sync
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
SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

MEM_USED=`free |grep -i 'Mem' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $3}'`
SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to DISK due to free swap lesser than used mem"

if [ "$SWAP_TO_USE" ];then

[ "`echo "$SWAPS" |grep -w "$SWAP_TO_USE"`" ] || show_swaps 1 "'$SWAP_TO_USE' seems not to be a regular swap partition"
{ for swap in $SWAPS;do swapoff $swap;sleep 1s;sync;done;swapon $SWAP_TO_USE; }

else
FIRST_SWAP=`echo "$SWAPS" |head -n1`

for swap in $SWAPS;do

SWAP_LABEL_RESUME=`blkid $swap |grep -iE 'Resume|Hiber' |cut -f1 -d':'`
[ "$SWAP_LABEL_RESUME" ] && { FIRST_SWAP=$SWAP_LABEL_RESUME;break; }
#SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
done

SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
echo "Swapping off all unneeded swaps..."
for swap in $SWAPS_TO_TURN_OFF;do swapoff $swap;sleep 1s;sync;done

fi

SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to RAM due to free swap lesser than used mem"

echo 'disk' >/sys/power/state

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

/bin/logger -t "acpid:$0" -p 1 "Ended"
