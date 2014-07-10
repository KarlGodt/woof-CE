#!/bin/bash


Version='1.0 Macpup_O2-Puppy_Linux_431 KRG'
usage(){
MSG="
$0 [start|stop] [help|version]

Launches busybox acpid daemon.

Init script to be launched by
/etc/rc.d/rc.services with 'start' parameter
and stopped by
rc.shutdown with 'stop' parameter
"
echo "$MSG"
[ "$DISPLAY" ] && xmessage -bg white4 "$MSG"
exit $1
}

case $1 in
-h|-help|--help|help) usage 0;;
-V|--version|-version|version) echo -e "\n$0: Version '$Version'\nTry help for more info\n";exit 0;;
checkcode|codecheck) set -n;shift;;
-F|force) FORCE=1;shift;;
esac

case $2 in
[0-9]*) safeBOOT=$2;set -- $1;;
""|*) :;;
esac
echo "'$@'"

ACPID_BIN='busybox acpid'
BB_ACPID_ENABLED=`busybox |grep acpid`
if [ ! "$BB_ACPID_ENABLED" ];then
ACPID_BIN=`which acpid`
echo "Busybox seems not to have the acpid applet enabled."
  if [ "$ACPID_BIN" ];then
  echo "'$ACPID_BIN' Seems to be installed."
  fi
echo "Exiting init script."
exit 0
fi

modprobe -vb evdev

[ "$ACPID_BIN" ] && ACPID_OPTS="`$ACPID_BIN --help 2>&1`"

Config_directory=/etc/acpi       # -c
proc_event_file=/proc/acpi/event # -e
Log_file=/var/log/acpid.log      # -l
Pid_file=/var/run/acpid.pid      # -p
Action_file=/etc/acpid.conf      # -a
Map_file=/etc/acpi.map           # -m

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


############### MAIN ####################
case $1 in
start|Start|START|-start|--start)
shift
ALREADY_RUNNING=`pidof $ACPID_BIN |tr ' ' '\n' | grep -vw '1' |tr '\n' ' '`

if [ ! "$FORCE" ];then
[ "`echo "$ALREADY_RUNNING" |wc -w`" -ge 1 ] && { echo "Another instance of '$ACPID_BIN' already running with PID '$ALREADY_RUNNING'"; exit 1; }
fi
#[ "$DISPLAY" ] || export DISPLAY=':0'
if [ "$@" ];then
$ACPID_BIN $@
else
$ACPID_BIN -c $Config_directory \
 -e $proc_event_file \
 -l $Log_file \
 -p $Pid_file \
 -a $Action_file \
 -M $Map_file

fi

sleep 3
ACPID_PID=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' '`
if [ "$ACPID_PID" ];then
                        echo "$0: STARTED '$ACPID_BIN' with PID '$ACPID_PID'";STATUS=0
else
#acpid: /dev/input/event0: No such file or directory -> needs evdev driver
echo "$0: FAILED to start '$ACPID_BIN'";STATUS=1
fi
exit $STATUS
;;
############### START ####################


############### STOP #####################
stop|Stop|STOP|-stop|--stop)
shift
ACPID_PID=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' '`
[ "$ACPID_PID" ] || exit 0
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
ACPID_PID_2=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' '`
[ "$ACPID_PID_2" ] || { echo "$0: STOPPED pid '$ACPID_PID'";exit 0; }
#kill -2 $ACPID_PID_2
#sleep 3
#ACPID_PID_3=`pidof acpid`
#[ "$ACPID_PID_3" ] || { echo "$0: STOPPED '$ACPID_PID'; last PID had been '$ACPID_PID_2'";exit 0; }
#echo "$0: FAILED to stop PID '$ACPID_PID' for '$ACPID_BIN'"
#exit 1

for s in `seq 1 1 64`;do
kill -$s $ACPID_PID_2
sleep 3
ACPID_PID_3=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' '`
[ "$ACPID_PID_3" ] || { echo "$0: STOPPED pid '$ACPID_PID' with signal '$c'";exit 0; }
done
echo "$0: FAILED to stop PID '$ACPID_PID' for '$ACPID_BIN'"
exit 1

fi
;;
*) echo "S0: Supported parameters : start|stop";exit 1;;
esac

