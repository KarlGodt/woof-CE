#!/bin/sh
# log a file tail

  _TITLE_=pup_monitor_kernel.sh
_COMMENT_="Cli to show kernel messages in the console"

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5

#Xdialog --title "Monitoring tail of $1" --smooth --fixed-font --no-cancel --ok-label "Exit" --tailbox $1 18 95
test "$*" && {
    :
} || {
LINES1=0
LINES2=0
while [ 1 ];do
 LINES2=`wc -l /var/log/messages | awk '{print $1}'`
 if [ $LINES2 -gt $LINES1 ];then
  LINESDIFF=`expr $LINES2 - $LINES1`
  tail -n $LINESDIFF /var/log/messages
  LINES1=$LINES2
 fi
 sleep 1
done
}
