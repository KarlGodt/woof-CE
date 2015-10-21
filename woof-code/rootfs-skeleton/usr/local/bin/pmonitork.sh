#!/bin/sh
# log a file tail

  _TITLE_="Puppy_pmonitork.sh"
_VERSION_=1.0omega
_COMMENT_="$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="$0"
MY_PID=$$

test -f /etc/rc.d/f4puppy5 && {
 set +e
 . /etc/rc.d/f4puppy5 && {
 set +n
 . /etc/rc.d/f4puppy5; } || echo "WARNING : Could not source /etc/rc.d/f4puyppy5 ."

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

#Xdialog --title "Monitoring tail of $1" --smooth --fixed-font --no-cancel --ok-label "Exit" --tailbox $1 18 95

LINES1=0
LINES2=0
while [ 1 ];do
 LINES2=`wc -l /var/log/messages | tr -s " " | cut -f 2 -d " "`
 if [ $LINES2 -gt $LINES1 ];then
  LINESDIFF=`expr $LINES2 - $LINES1`
  tail -n $LINESDIFF /var/log/messages
  LINES1=$LINES2
 fi
 sleep 1
done
# Very End of this file 'usr/sbin/pmonitork.sh' #
###END###
