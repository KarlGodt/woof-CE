#!/bin/sh
#Barry Kauler www.puppylinux.com
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html).
#calc free space in which to create/save files. called by freememapplet (in taskbar).
#v3.95 freememapplet_xlib does not call this, instead /usr/sbin/savepuppyd does.
#v3.95 savepuppyd no longer calls this. calcfreespace.sh no longer used.

_TITLE_=calcfreespace
_VERSION_=1.0omega
_COMMENT_="CLI to output free space in save-file (KiB)."

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
 set +e
 source /etc/rc.d/f4puppy5 && {
 set +n
 source /etc/rc.d/f4puppy5; } || echo "WARNING : Could not source /etc/rc.d/f4puyppy5 ."

ADD_PARAMETER_LIST=
ADD_PARAMETERS=
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
for i in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
} || echo "Warning : No /etc/rc.d/f4puppy5 installed."

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
# Very End of this file 'usr/sbin/calcfreespace.sh' #
###END###
