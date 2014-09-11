#!/bin/sh
# log a file tail

  _TITLE_=pup_monitor_xerrs.sh
_COMMENT_="Cli to show /tmp/xerrs.log in console"

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5

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
