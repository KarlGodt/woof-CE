#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_mailto.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/sbin/mailto.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap

}
# End new header
#

exec sylpheed --compose "$@"
