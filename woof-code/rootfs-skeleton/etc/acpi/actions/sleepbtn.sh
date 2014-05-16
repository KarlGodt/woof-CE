#!/bin/sh
# /etc/acpi/actions/sleepbtn.sh

/bin/logger -t "acpid:$0" -p 1 "Started"

[ "`pidof pppd`" ] && { echo "Shutting down pppd" ;kill -1 `pidoff pppd`;sleep 1; }

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

echo 'mem' >/sys/power/state

sleep 30s
echo "$0: HELLO AGAIN '$USER'"

free

/bin/logger -t "acpid:$0" -p 1 "Ended"
