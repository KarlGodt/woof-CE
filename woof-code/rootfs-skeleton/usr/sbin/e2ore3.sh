#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_e2ore3.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/sbin/e2ore3.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in 1; do shift; done; }

_trap

}
# End new header
#
#Lesser GPL licence v2 (http://www.fsf.org/licensing/licenses/lgpl.html)
# Used by probepart.
# Read device, example '/dev/hda4' from stdin.

test "$*" && {
    :
} || {
read MYDEVICE
[ "$MYDEVICE" = "" ] && exit
MYSTR="`tune2fs -l $MYDEVICE | grep 'Filesystem features:' | grep 'has_journal'`"

[ "$MYSTR" = "" ] && exit 0 #ext2
exit 1 #ext3
}
