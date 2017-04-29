#!/bin/ash
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html)
#used by probepart.
. /etc/rc.d/f4puppy5
# BATCHMARKER01 - Marker for Line-Position to bulk insert code into.
#read device, example '/dev/hda4' from stdin.

if test "$*"; then
MYDEVICE="$*"
else
read -t 99 MYDEVICE
fi
[ -b "$MYDEVICE" ] || exit 2

MYSTR="`_command tune2fs -l $MYDEVICE | grep 'Filesystem features:' | grep 'has_journal'`"

[ "$MYSTR" ] || exit 0 #ext2
exit 1 #ext3
