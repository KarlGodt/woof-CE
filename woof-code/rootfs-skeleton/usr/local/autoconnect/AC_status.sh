#!/bin/sh
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_AC_status.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/usr/local/autoconnect/AC_status.sh"
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

# give feedback about connection quality etc.
INTERFACE=`cat /tmp/AC_IF`
if  ping -c 1 google.com | grep -q "bytes from" ; 
 	then while [ 0 ] ; do 
		 clear
		 NAME=`iwconfig $INTERFACE | grep 'ESSID' | cut -d\" -f2` 
		 	if [ "$NAME" -eq ""]; then #fix for buggy NIC drivers, eg rt73, orinoco ... etc.
		 	exec /tmp/wag-profiles_iwconfig.sh
		 	else
		 	echo "connected to $NAME "
		 	echo "Link Quality: `iwconfig $INTERFACE | grep 'Quality' | cut -d= -f2 | tr -d 'Signal level'`" 
		 	echo "IP: `ifconfig $INTERFACE | grep 'inet addr' | cut -d: -f2 | tr -d Bcast`"
		 	echo "closing this window will disconnect you."
		 	sleep 8
		 	fi
		 done	
 	else 
 	echo
 	echo "---> Not connected ! <---"
 	sleep 5 
 	exit 0 
fi

# Very End of this file 'usr/local/autoconnect/AC_status.sh' #
###END###
