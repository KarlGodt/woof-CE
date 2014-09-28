#!/bin/sh
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html)
# Used by probepart.
# read device, example '/dev/hda4' from stdin.

  _TITLE_=Ext2orExt3
_VERSION_=1.0omega
_COMMENT_="CLI to return 0 if ext2 or 1 if ext3 file-system."

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST="MYDEVICE"
ADD_PARAMETERS="MYDEVICE : /dev/sdXy"
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}


test "$*" && MYDEVICE="$*"
test "$MYDEVICE" && {
 [ -b "$MYDEVICE" ] || { echo "'$MYDEVICE' not a block device" >&2; exit 9; }
 CHECK_FS=`guess_fstype "$MYDEVICE"`
 case $CHECK_FS in
 ext[2-4]) :;;
 *) echo "'$MYDEVICE' has '$CHECK_FS' file system" >&2; exit 9;;
 esac
 MYSTR="`tune2fs -l $MYDEVICE | grep 'Filesystem features:' | grep 'has_journal'`"
 [ "$MYSTR" = "" ] && { echo 'ext2' >&2; exit 0; } #ext2
 echo 'ext3' >&2; exit 1 #ext3
} || {
read MYDEVICE
[ "$MYDEVICE" = "" ] && exit 9
[ -b "$MYDEVICE" ] || { echo "'$MYDEVICE' not a block device" >&2; exit 9; }
CHECK_FS=`guess_fstype "$MYDEVICE"`
 case $CHECK_FS in
 ext[2-4]) :;;
 *) echo "'$MYDEVICE' has '$CHECK_FS' file system" >&2; exit 9;;
 esac
MYSTR="`tune2fs -l $MYDEVICE | grep 'Filesystem features:' | grep 'has_journal'`"
[ "$MYSTR" = "" ] && { echo 'ext2' >&2; exit 0; } #ext2
echo 'ext3' >&2; exit 1 #ext3
}
# Very End of this file 'usr/sbin/e2ore3.sh' #
###END###
