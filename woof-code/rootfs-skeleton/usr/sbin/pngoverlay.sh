#!/bin/sh
#Barry Kauler 2011 GPL3 (/usr/share/doc/legal)
# pngoverlay.sh is an alternative to pngoverlay written by vovchik (in BaCon)
#  (vovchik's pngoverlay requires X to be running, which may be a disadvantage)
# Requires netpbm svn rev 1543 or later, with pamcomp -mixtransparency
# Requires three params, 1st and 2nd must exist:
#  bottom-image top-image output-image
# Overlays the two images, with common areas of transparency in output image.

__old_header__(){
trap "exit 1" HUP INT QUIT KILL TERM

OUT=/dev/null;ERR=$OUT
[ "$DEBUG" ] && { OUT=/dev/stdout;ERR=/dev/stderr; }
[ "$DEBUG" = "2" ] && set -x

Version='1.1'

usage(){
USAGE_MSG="
$0 [ PARAMETERS ]

-V|--version : showing version information
-H|--help : show this usage information

*******  *******  *******  *******  *******  *******  *******  *******  *******
$2
"
exit $1
}

[ "`echo "$1" | grep -wE "\-help|\-H"`" ] && usage 0
[ "`echo "$1" | grep -wE "\-version|\-V"`" ] && { echo "$0 -version $Version";exit 0; }
}

  _TITLE_=PNG_Overlay
_COMMENT_="CLI to run pngtopam pamcomp pamrgbatopng"

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST="FILE1.png FILE2.png OUTFILE"
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}

[ ! $3 ] && exit 1
[ ! -e "$1" ] && exit 1
[ ! -e "$2" ] && exit 1
[ "`echo -n "$1" | grep 'png$'`" = "" ] && exit 1
[ "`echo -n "$2" | grep 'png$'`" = "" ] && exit 1

pngtopam -alphapam "${1}" > /tmp/pngoverlay_${$}_1.pam
pngtopam -alphapam "${2}" > /tmp/pngoverlay_${$}_2.pam
#1st image on top, 2nd on bottom, 3rd is output...
pamcomp -mixtransparency /tmp/pngoverlay_${$}_2.pam /tmp/pngoverlay_${$}_1.pam > /tmp/pngoverlay_${$}_out.png 2>$ERR
pamrgbatopng /tmp/pngoverlay_${$}_out.png > "${3}"
rm -f /tmp/pngoverlay_${$}_1.pam
rm -f /tmp/pngoverlay_${$}_2.pam
rm -f /tmp/pngoverlay_${$}_out.pam
