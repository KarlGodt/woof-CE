#!/bin/sh
# log a file tail


  _TITLE_=Puppy_Monitor_Xerrs
_VERSION_=1.0omega
_COMMENT_="CLI to display /tmp/xerrs.log"

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in `seq 1 1 $DO_SHIFT`; do shift; done; }

_trap
}


#Xdialog --title "Monitoring tail of $1" --smooth --fixed-font --no-cancel --ok-label "Exit" --tailbox $1 18 95

LINES1=0
LINES2=0
while [ 1 ];do
 LINES2=`wc -l /tmp/xerrs.log | tr -s " " | cut -f 2 -d " "`
 if [ $LINES2 -gt $LINES1 ];then
  LINESDIFF=`expr $LINES2 - $LINES1`
  tail -n $LINESDIFF /tmp/xerrs.log
  LINES1=$LINES2
 fi
 sleep 1
done
# Very End of this file 'usr/sbin/pmonitorx.sh' #
###END###
