#!/bin/sh
# log a file tail

  _TITLE_=pup_monitor_xerrs.sh
_COMMENT_="Cli to show /tmp/xerrs.log in console"

MY_SELF="$0"

test -f /etc/rc.d/f4puppy5 && . /etc/rc.d/f4puppy5

[ "$*" ] || set - /tmp/xerrs.log
[ -f "$*" -a -r "$*" ] || _exit 4 "'$*' either does not exist, is not a file andor not readable"

_xdialog_tailbox(){
# REM: Xdialog tailbox
Xdialog --title "Monitoring tail of $@" --smooth --fixed-font --no-cancel --ok-label "Exit" --tailbox "$@" 18 95
}

_console_tail_log(){
LINES1=0
LINES2=0
while [ 1 ];do
 LINES2=`wc -l "$@" | awk '{print $1}'`
 if [ $LINES2 -gt $LINES1 ];then
  LINESDIFF=`expr $LINES2 - $LINES1`
  tail -n $LINESDIFF "$@"
  LINES1=$LINES2
 fi
 sleep 1
done
}

[ "$DISPLAY" ] && { _xdialog_tailbox; true; } || _console_tail_log

