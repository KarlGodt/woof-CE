#!/bin/sh
# log a file tail

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
