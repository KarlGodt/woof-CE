#!/bin/sh
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html)
#used by probepart.
#read device, example '/dev/hda4' from stdin.

  _TITLE_=
_COMMENT_=""

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && {
 set +e
 source /etc/rc.d/f4puppy5 && {
 set +n
 source /etc/rc.d/f4puppy5; } || echo "WARNING : Could not source /etc/rc.d/f4puyppy5 ."

ADD_PARAMETER_LIST=
ADD_PARAMETERS=
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
for i in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
} || echo "Warning : No /etc/rc.d/f4puppy5 installed."

read MYDEVICE
[ "$MYDEVICE" = "" ] && exit
MYSTR="`tune2fs -l $MYDEVICE | grep 'Filesystem features:' | grep 'has_journal'`"

[ "$MYSTR" = "" ] && exit 0 #ext2
exit 1 #ext3
