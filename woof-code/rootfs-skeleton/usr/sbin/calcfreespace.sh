#!/bin/sh
#Barry Kauler www.puppylinux.com
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#calc free space in which to create/save files. called by freememapplet (in taskbar).
#v3.95 freememapplet_xlib does not call this, instead /usr/sbin/savepuppyd does.
#v3.95 savepuppyd no longer calls this. calcfreespace.sh no longer used.



#************
#KRG


OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = 2 ] && set -x


Version=1.1-KRG-MacPup_O2

usage(){
MSG="
$0 [ help | version ]
"
echo "$MSG
$2"
exit $1
}
[ "`echo "$1" | grep -Ei "help|\-h"`" ] && usage 0
[ "`echo "$1" | grep -Ei "version|\-V"`" ] && { echo "$0: $Version";exit 0; }


trap "exit" HUP INT QUIT ABRT KILL TERM


#KRG
#************


#variables created at bootup by /initrd/usr/sbin/init...
. /etc/rc.d/PUPSTATE #v2.02
#PDEV1=the partition have booted off, DEV1FS=f.s. of PDEV1,
#PUPSFS=pup_201.sfs versioned name, stored on PDEV1, PUPSAVE=vfat,sda1,/pup_save.3fs

SIZEFREE=0
#PUPMODE=2
#[ -f /etc/rc.d/PUPMODE ] && PUPMODE=`cat /etc/rc.d/PUPMODE`

case $PUPMODE in
 3|7|13) #home partition/file mntd on pup_ro1, tmpfs on pup_rw
  SIZEFREE=`df -k | grep ' /initrd/pup_ro1$' | tr -s ' ' | cut -f 4 -d ' '`
  SIZETMP=`df -k | grep ' /initrd/pup_rw$' | tr -s ' ' | cut -f 4 -d ' '`
  #v2.21 now have true flushing for pet packages at least, so only use free space
  #in the pup_save file (pup_ro1), unless tmpfs gets too low...
  #[ $SIZETMP -lt $SIZEFREE ] && SIZEFREE=$SIZETMP
  [ $SIZETMP -lt 4096 ] && SIZEFREE=$SIZETMP
  ;;
 6|12) #home partition/file mntd on pup_rw (no tmpfs)
  SIZEFREE=`df -k | grep ' /initrd/pup_rw$' | tr -s ' ' | cut -f 4 -d ' '`
  ;;
 *)
  SIZEFREE=`df -k | grep ' /$' | tr -s ' ' | cut -f 4 -d ' '`
  ;;
esac

#exit $SIZEFREE
echo "$SIZEFREE"
###end###
