#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_run-ac.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/autoconnect/run-ac.sh"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
[ "$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

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
cd /usr/local/autoconnect
#run standalone is supported.
rxvt -bg blue -geometry 50X8 -e ./autoconnect.sh scan_open_networks=yes ##use this argument to autoconnect to open networks also 
INTERFACE=`cat /tmp/AC_IF`
rxvt -bg green -geometry 43X5 -e ./AC_status.sh 
ifconfig $INTERFACE down



# Very End of this file 'usr/local/autoconnect/run-ac.sh' #
###END###
