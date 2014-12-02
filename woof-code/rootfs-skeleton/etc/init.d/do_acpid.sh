#!/bin/bash

ACPID_BIN=`which acpid`
[ "$ACPID_BIN" ] || ACPID_BIN='busybox acpid'
[ "$ACPID_BIN" ] && ACPID_OPTS="`$ACPID_BIN --help 2>&1`"


SUP_KILL_SIGS=`trap -l |sed 's|$| END|'`

#echo "$SUP_KILL_SIGS
#"

#SUP_KILL_SIGS=`echo $SUP_KILL_SIGS |sed 's|\([0-9]*)\)|\n\1|g'`
SUP_KILL_SIGS=`echo " "$SUP_KILL_SIGS" " |rev|sed 's|\()[0-9]*\)|\n\1|g'`
#echo "$SUP_KILL_SIGS
#"
#SUP_KILL_SIGS=`echo $SUP_KILL_SIGS |sed 's|DNE|\n|g'|rev`
#SUP_KILL_SIGS=`echo $SUP_KILL_SIGS |sed 's|END|\n|g'`
SUP_KILL_SIGS=`echo $SUP_KILL_SIGS" " |sed 's|DNE|\n|g'|rev|tr -s ' '`
#echo "$SUP_KILL_SIGS
#"

usage (){
echo "$2
"
echo "
$0 [start [acpid_options]| stop [kill_options]]

Supported acpid options:
$ACPID_OPTS

#
Supported kill signals:
`echo \"$SUP_KILL_SIGS\" |tr -d '\t'|sed 's|SIG||g;s|\([0-9][0-9])\)| \1|g;s|) |=|g' |tr -s ' '|sed 's|\(=[[:alnum:]]\{2\} \)|\1\t|g;s|\(=[[:alnum:]]\{3\} \)|\1\t|g;s|\(=[[:alnum:]]\{4\} \)|\1\t|g;s|\([ \t""][0-9]=[[:alnum:]]\{5\} \)|\1\t|g'| tr ' ' '\t'`

#
"
        exit $1
}

###
#`echo \"$SUP_KILL_SIGS\" |tr -d '\t'|sed 's|SIG||g;s|\([0-9][0-9])\)| \1|g;s|) |=|g' |tr -s ' '|sed 's|\(=[[:alnum:]]\{2\} \)|\1\t|g;s|\(=[[:alnum:]]\{3\} \)|\1\t|g;s|\(=[[:alnum:]]\{4\} \)|\1\t|g;s|\( [0-9]=[[:alnum:]]\{5\} \)|\1\t|g'| tr -s ' ' |tr ' ' '\t'`
###

#`echo \"$SUP_KILL_SIGS\" |tr -d '\t'|sed 's|SIG||g;s|\([0-9][0-9])\)| \1|g;s|) |=|g' |tr -s ' '|sed 's|\(=[[:alnum:]]\{3\} \)|\1\t|g;s|\(=[[:alnum:]]\{4\} \)|\1\t|g;s|\(=[[:alnum:]]\{5\} \)|\1\t|g'| tr -s ' ' |tr ' ' '\t'`

#`trap -l |tr -d '\t'|sed 's|SIG||g;s|\([0-9][0-9])\)| \1|g;s|) |=|g' |tr ' ' '\t'`

#`trap -l | sed 's|SIG||g;s|\([[^[\^ ][0-9]]][0-9])\)|\t\1|g;s|\(.\{3\}\t\)|\1 \t|g'`
#`trap -l | sed 's|SIG||g;s|\([^[[\^ ][0-9]]][0-9])\)|\t\1|g;s|\(.\{3\}\t\)|\1 \t|g'`
#`trap -l | sed 's|SIG||g;s|\([^[\^ ][0-9]][0-9])\)|\t\1|g;s|\(.\{3\}\t\)|\1 \t|g'`
#`trap -l | sed 's|SIG||g;s|\([[^\^ ][^0-9]][0-9])\)|\t\1|g;s|\(.\{3\}\t\)|\1 \t|g'`
#`trap -l | sed 's|SIG||g;s|\([^\^ ][^[0-9]][0-9])\)|\t\1|g;s|\(.\{3\}\t\)|\1 \t|g'`
#`trap -l | sed 's|SIG||g;s|\([^\^ ][^[0-9][0-9])\)|\t\1|g;s|\(.\{3\}\t\)|\1 \t|g'`

[ "$1" ] || usage 1 "no parameter given"

[ "$ACPID_BIN" ] || usage 1 "acpid binary apparently not installed"
[ "$ACPID_OPTS" ] || usage 1 "even busybox acpid seems not to work "

case $1 in
*start|*Start|*START)
shift

test -d /dev/input || mkdir -p /dev/input
test -c /dev/input/event0 || {
rm -rf /dev/input/event0
test -c /dev/event0 && {
cp -a /dev/event0 /dev/input/
} || {
mknod /dev/input/event0 c 13 64
}
}

test -c /dev/input/event0 || { echo "Failed to create /dev/input/event0"; exit 3; }

ALREADY_RUNNING=`pidof ${ACPID_BIN##*/} |sed 's| 1$||;s| 1 | |'`
[ "$ALREADY_RUNNING" = 1 ] && ALREADY_RUNNING=''
[ "`echo "$ALREADY_RUNNING" |wc -w`" -ge 1 ] && { echo "Another instance of '$ACPID_BIN' already running with PID '$ALREADY_RUNNING'"; exit 1; }
case "$@" in
'') [ -e /proc/acpi/event ] && {
$ACPID_BIN -e /proc/acpi/event
} || {
$ACPID_BIN
} ;;
*) $ACPID_BIN $@;;
esac
sleep 3
ACPID_PID=`pidof ${ACPID_BIN##*/} |sed 's| 1$||;s| 1 | |'`
[ "$ACPID_PID" = 1 ] && ACPID_PID=''
if [ "$ACPID_PID" ];then
                                                echo "$0: STARTED '$ACPID_BIN' with PID '$ACPID_PID'";STATUS=0
else
echo "$0: FAILED to start '$ACPID_BIN'";STATUS=1
test -f /var/log/acpid.log && cat /var/log/acpid.log
fi
exit $STATUS
;;

*stop|*Stop|*STOP)
shift
[ "$ACPID_BIN" = "busybox acpid" ] && { echo "Cowardly refusing to kill busybox (init) .Exit .";exit 2; }
ps |grep 'busybox acpid' |grep -v 'grep' && { echo "Cowardly refusing to kill busybox (init) .Exit .";exit 2; }

ACPID_PID=`pidof ${ACPID_BIN##*/} |sed 's| 1$||;s| 1 | |'`
[ "$ACPID_PID" = 1 ] && ACPID_PID=''
[ "$ACPID_PID" ] || { echo "acpid not running.";exit 0; }
if [ "$1" ];then
                                if [ "$2" ];then
                                        kill $1 $2 $ACPID_PID
                                else
                                SIGNAL="$1"
                                [ "`echo $SIGNAL |grep '^\-'`" ] || SIGNAL="-$SIGNAL"
                                kill $SIGNAL $ACPID_PID
                                fi
else
kill -1 $ACPID_PID
sleep 3
ACPID_PID_2=`pidof ${ACPID_BIN##*/} |sed 's| 1$||;s| 1 | |'`
[ "$ACPID_PID_2" ] || { echo "$0: STOPPED '$ACPID_PID'";exit 0; }
kill -2 $ACPID_PID_2
sleep 3
ACPID_PID_3=`pidof ${ACPID_BIN##*/} |sed 's| 1$||;s| 1 | |'`
[ "$ACPID_PID_3" ] || { echo "$0: STOPPED '$ACPID_PID'; last PID had been '$ACPID_PID_2'";exit 0; }
echo "$0: FAILED to stop PID '$ACPID_PID' for '$ACPID_BIN'"
exit 1
fi
;;
esac
