#!/bin/sh
# Barry Kauler 2011 GPL3 (/usr/share/doc/legal)
#pngoverlay.sh is an alternative to pngoverlay written by vovchik (in BaCon)
# (vovchik's pngoverlay requires X to be running, which may be a disadvantage)
#requires netpbm svn rev 1543 or later, with pamcomp -mixtransparency
#requires three params, 1st and 2nd must exist:
# bottom-image top-image output-image
#overlays the two images, with common areas of transparency in output image.

  _TITLE_="pup_pngoverlay.sh.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

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

[ ! $3 ] && exit 1
[ ! -e "$1" ] && exit 1
[ ! -e "$2" ] && exit 1
[ "`echo -n "$1" | grep 'png$'`" = "" ] && exit 1
[ "`echo -n "$2" | grep 'png$'`" = "" ] && exit 1

pngtopam -alphapam "${1}" > /tmp/pngoverlay_${$}_1.pam
pngtopam -alphapam "${2}" > /tmp/pngoverlay_${$}_2.pam
#1st image on top, 2nd on bottom, 3rd is output...
pamcomp -mixtransparency /tmp/pngoverlay_${$}_2.pam /tmp/pngoverlay_${$}_1.pam > /tmp/pngoverlay_${$}_out.png 2> /dev/null
pamrgbatopng /tmp/pngoverlay_${$}_out.png > "${3}"
rm -f /tmp/pngoverlay_${$}_1.pam
rm -f /tmp/pngoverlay_${$}_2.pam
rm -f /tmp/pngoverlay_${$}_out.pam
# Very End of this file 'usr/sbin/pngoverlay.sh' #
###END###
