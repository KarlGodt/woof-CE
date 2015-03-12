#!/bin/bash

source /etc/rc.d/f4puppy5

Version='2.0 Macpup_O2-Puppy_Linux_431 KRG'

# REM: --help message
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
# REM: parse options:
case $1 in
-h|-?help|-?usage) usage 0;;
-V|-?version) echo -e "\n$0: Version '$Version'\nTry help for more info\n";exit 0;;
*check*) set -n;shift;;
-F|-?force)
# REM: if force, if start, start anyway -
#      even if another acpid is running...
FORCE=1;
shift;;
esac

# REM: stub for failsafe parameters (not well thought through yet)
case $2 in
[0-9]*) safeBOOT=$2;set -- $1;;
""|*) :;;
esac


echo "$0:$*:$$:`date +%F~%T`:k`uname -r`" ##DEBUG

# REM: Global variables
BUSYBOX=busybox
ACPID_BIN="$BUSYBOX acpid"

# REM: Check if busybox has acpid applet enabled:
BB_ACPID_ENABLED=`"$BUSYBOX" |grep acpid`
if [ ! "$BB_ACPID_ENABLED" ];then
ACPID_BIN=`which acpid`
echo "$BUSYBOX seems not to have the acpid applet enabled."
  if [ "$ACPID_BIN" ];then
  echo "'$ACPID_BIN' Seems to be installed."
  fi
echo "Exiting init script."
exit 0
fi

# REM: Busybox has a few configure options (like pidfile)
[ "$ACPID_BIN" ] && ACPID_OPTS="`$ACPID_BIN --help 2>&1 | grep -v '^[^[:blank:]]'`"

while read -r option rest; do
[ "$option" ] || continue
case $option in
-a) sOPT_a=1;;
-c) sOPT_c=1;;
##
#-e) sOPT_e=1;;
-l) sOPT_l=1;;
-M) sOPT_M=1;;
-p) sOPT_p=1;;
-e) sOPT_e=1;;
esac
done <<EoI
`echo "$ACPID_OPTS"`
EoI

# REM: Busybox acpid option variables (change content if needed)
Action_file=/etc/acpid.conf      # -a
Config_directory=/etc/acpi       # -c
##
## REM: proc event and evdev event option better be last options ..?
#proc_event_file=/proc/acpi/event # -e
#evdev_event_file=                # no option prefix
##
Log_file=/var/log/acpid.log      # -l
Map_file=/etc/acpi.map           # -m
Pid_file=/var/run/acpid.pid      # -p
##
proc_event_file=/proc/acpi/event # -e
evdev_event_file=                # no option prefix
##

# REM: Options sanity checks ...
[ "$sOPT_a" ] || unset Action_file
[ "$sOPT_c" ] || unset Config_directory
##
#[ "$sOPT_e" ] || unset proc_event_file
##
[ "$sOPT_l" ] || unset Log_file
[ "$sOPT_M" ] || unset Map_file
[ "$sOPT_p" ] || unset Pid_file
[ "$sOPT_e" ] || unset proc_event_file

# REM: Permissions and existence checks ...
if test "$Config_directory"; then
_test_dr "$Config_directory" || exit 10
fi

##
#if test "$proc_event_file"; then
#_test_fr "$proc_event_file" || exit 11
#fi

#if test "$evdev_event_file"; then
#_test_fr "$evdev_event_file" || exit 12
#fi

if test "$Log_file"; then
_test_dw "${Log_file%/*}" || exit 13
fi

if test "$Pid_file"; then
_test_dw "${Pid_file%/*}" || exit 14
fi

if test "$Action_file"; then
_test_fr "$Action_file" || exit 15
fi

if test "$Map_file"; then
_test_fr "$Map_file" || exit 16
fi

##
if test "$proc_event_file"; then
_test_fr "$proc_event_file" || exit 11
fi

if test "$evdev_event_file"; then
_test_fr "$evdev_event_file" || exit 12
fi
##

# REM: Busybox acpid has been introduced v1.14,
#      changed code significantally v.1.18 with a CPU consuming bug,
#      if USB devices changed, that was fixed v1.20?? (cannot remember exactly)
BUSYBOX_VERSION=`"$BUSYBOX" | head -n1 | awk '{print $2}'`
echo "$0: BUSYBOX_VERSION='$BUSYBOX_VERSION'"

case $BUSYBOX_VERSION in
v1.[0-9].*|v1.1[0-3].*)   _exit 3 "Applet acpid should not be enabled for '$BUSYBOX_VERSION'; was first introduced with v1.14.";;
#Usage: acpid [-d] [-c CONFDIR] [-l LOGFILE] [-e PROC_EVENT_FILE] [EVDEV_EVENT_FILE]...
v1.14.*|v1.15.*|v1.16.*|v1.17.*)                               ;; #OLD simple code
#Usage: acpid [-d] [-c CONFDIR] [-l LOGFILE] [-a ACTIONFILE] [-M MAPFILE] [-e PROC_EVENT_FILE] [-p PIDFILE]
v1.18.*|v1.19.*)           unset proc_event_file              ;; #NEW -a and -M code, -e option does not work anymore, PROBLEMS with high load
v1.20.*|v1.21.*|v1.22.*)   unset proc_event_file              ;; #NEW -a and -M code, -e option does not work anymore
*) echo "Unhandled busybox version '$BUSYBOX_VERSION'";;
esac

# REM: play around with kill signals - regular acpid init script has this line :
#      start-stop-daemon --stop --signal 1 --exec "$ACPID" if case reload)
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

# REM : usage message 2
usage(){
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

# REM: Sanity checks :
[ "$1" ] || usage 1 "no parameter given"

[ "$ACPID_BIN" ] || usage 1 "acpid binary apparently not installed"


############### MAIN ####################
case $1 in
*start|*Start|*START)
shift

# Note (myself): if ACPID_BIN='busybox acpid' then pidof does not like double quotes and no simple acpid as basename
ALREADY_RUNNING=`pidof $ACPID_BIN |tr ' ' '\n' | grep -vw '1' |tr '\n' ' '| sed 's!^\ *!!;s!\ *$!!'`

if [ ! "$FORCE" ];then
[ "`echo "$ALREADY_RUNNING" |wc -w`" -ge 1 ] && { echo -e "$0:\n\tAnother instance of '$ACPID_BIN' already running with PID '$ALREADY_RUNNING'"; exit 1; }
fi

# REM: evbug.ko kernel deriver is nasty,
#      unload it to be sure eventX char devices are accessible?? for acpid
modprobe -vr evbug
# REM: load evdev.ko and button.ko
modprobe -vb evdev
modprobe -vb button

#[ "$DISPLAY" ] || export DISPLAY=':0' ## done in acpid.conf scripts
                                       ## because in the boot stage no pidof X possible

# REM: if run like ./script.sh start -d, use the additional parameters
if [ "$*" ];then
$ACPID_BIN $@
else  # use parameters managed in the script

[ "$Log_file" ] && { [ -s "$Log_file" ] && _log_rotate "$Log_file"; true; } || { [ -s /var/log/acpid.log ] && _log_rotate /var/log/acpid.log; }

set --
[ "$Config_directory" ] && set - "$@" -c "$Config_directory"
##
#[ "$proc_event_file" ]  && set - "$@" -e "$proc_event_file" ## maybe needs to be last parameter
##
[ "$Log_file" ]         && set - "$@" -l "$Log_file"
[ "$Pid_file" ]         && set - "$@" -p "$Pid_file"
[ "$Action_file" ]      && set - "$@" -a "$Action_file"
[ "$Map_file" ]         && set - "$@" -M "$Map_file"
[ "$proc_event_file" ]  && set - "$@" -e "$proc_event_file"
[ "$evdev_event_file" ] && set - "$@" "$evdev_event_file"

echo "$0: '$@'"  #DEBUG

# REM : Finally start it
$ACPID_BIN "$@"

__old__start__code__(){
## OLD up to v1.17
$ACPID_BIN -c "$Config_directory" \
 -e "$proc_event_file" \
 -l "$Log_file" \
 -p "$Pid_file" \
 -a "$Action_file" \
 -M "$Map_file"
}

fi

sleep 3
# Note (myself): if ACPID_BIN='busybox acpid' then pidof does not like double quotes and no simple acpid as basename
ACPID_PID=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`
if [ "$ACPID_PID" ];then
                        echo "$0: STARTED '$ACPID_BIN' with PID '$ACPID_PID'";STATUS=0
else
#acpid: /dev/input/event0: No such file or directory -> needs evdev driver
echo "$0: FAILED to start '$ACPID_BIN'"
 if test -f "$Log_file"; then
 grep -H '.*' "$Log_file"
 fi
 if test -f /var/log/acpid.log; then
 grep -H '.*' /var/log/acpid.log
 fi
STATUS=1
fi
exit $STATUS
;;
############### START ####################


############### STOP #####################
*stop|*Stop|*STOP)
shift
# Note (myself): if ACPID_BIN='busybox acpid' then pidof does not like double quotes and no simple acpid as basename
ACPID_PID=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`
[ "$ACPID_PID" ] || { echo "$ACPID_BIN not running."; exit 0; }
if [ "$1" ];then
                if [ "$2" ];then
                    kill $1 $2 $ACPID_PID
                else
                SIGNAL="$1"
                [ "`echo $SIGNAL |grep '^\-'`" ] || SIGNAL="-$SIGNAL"
                kill $SIGNAL $ACPID_PID
                fi
else  #use SIGHUP
SIGNAL=1
kill -$SIGNAL $ACPID_PID
sleep 3
# Note (myself): if ACPID_BIN='busybox acpid' then pidof does not like double quotes and no simple acpid as basename
ACPID_PID_2=`pidof ${ACPID_BIN} |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`
[ "$ACPID_PID_2" ] || { echo "$0: STOPPED pid '$ACPID_PID' with signal '$SIGNAL'";

# REM: Show logfile(s) if content
 if test -f "$Log_file"; then
 grep -H '.*' "$Log_file"
 elif test -f /var/log/acpid.log; then
 grep -H ',*' /var/log/acpid.log
 fi
# REM: Remove pidfile
[ -f "$Pid_file" ] && rm -f "$Pid_file"
exit 0; }

__kill_acpid_with_signal2__(){
## (out) use SIGINT
kill -2 $ACPID_PID_2
sleep 3
ACPID_PID_3=`pidof acpid`
[ "$ACPID_PID_3" ] || { echo "$0: STOPPED '$ACPID_PID'; last PID had been '$ACPID_PID_2'";exit 0; }
echo "$0: FAILED to stop PID '$ACPID_PID' for '$ACPID_BIN'"
exit 1
}

# REM: Try all known signals ...
for s in `seq 1 1 64`;do
kill -$s $ACPID_PID_2
sleep 3
# Note (myself): if ACPID_BIN='busybox acpid' then pidof does not like double quotes and no simple acpid as basename
ACPID_PID_3=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^ *!!;s! *$!!'`
[ "$ACPID_PID_3" ] || { echo "$0: STOPPED pid '$ACPID_PID' with signal '$s'";

# REM: Show logfile(s) if content
 if test -f "$Log_file"; then
 grep -H '.*' "$Log_file"
 fi
 if test -f /var/log/acpid.log; then
 grep -H '.*' /var/log/acpid.log
 fi
# REM: Remove pidfile
[ -f "$Pid_file" ] && rm -f "$Pid_file"
exit 0; }
done
# REM: if come here, acpid mus be running still ...
echo "$0: FAILED to stop PID '$ACPID_PID' for '$ACPID_BIN'"
exit 1

fi
;;
*) echo "$0: Supported parameters : start|stop";exit 1;;
esac
