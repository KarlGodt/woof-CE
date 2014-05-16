#! /bin/sh

/bin/logger -t "acpid:$0" -p 1 "Started"

original_code(){
test -f /usr/sbin/laptop_mode || exit 0

# lid button pressed/released event handler

/usr/sbin/laptop_mode auto force
}

[ "`pidof pppd`" ] && { echo "Shutting down pppd" ;kill -1 `pidoff pppd`;sleep 1; }

MNTDPARTS=`tac /proc/mounts | cut -f 2 -d ' '` # | sed 's/$/\$/'`
#echo
##REMARK1 : fuser -c /dev/sda4 would return ntfs-3g PID but -c [||-m] /mnt/sda4 not  ##+++2011_10_27
echo -e "\e[1;35m""Unmounting stray filesystems:""\e[0;39m"
#echo "$MNTDPARTS"
MNTDPARTS=`echo "$MNTDPARTS" | grep -vwE '/$|/dev$|/sys$|/proc$'`
for ONESTRAY in $MNTDPARTS  ##in MountPoints
do

 #fuser -v -k -m  "$ONESTRAY"  ##+++2011_10_27

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


echo 'mem' >/sys/power/state

sleep 3s
mountpoint /dev/pts || { mkdir -p /dev/pts; mount -t devpts none /dev/pts; }
echo "$0: HELLO AGAIN '$USER'"

free

/bin/logger -t "acpid:$0" -p 1 "Ended"
