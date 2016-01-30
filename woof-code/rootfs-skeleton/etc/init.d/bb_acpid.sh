#!/bin/bash


Version='1.0.1 Macpup_O2-Puppy_Linux_431 KRG'


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
-h|*help|*usage) usage 0;;
-V|*version) echo -e "\n$0: Version '$Version'\nTry help for more info\n";exit 0;;
*check*) set -n;shift;;
-F|*force) FORCE=1;shift;;
esac


case $2 in
[0-9]*) safeBOOT=$2;set -- $1;;
""|*) :;;
esac

echo "$0:$@:$$:`date +%F\"~\"%T`:k`uname -r`"  ##DEBUG


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

_show_example_acpi_configuration(){

cat >&1 <<EoI

#
# Power management and ACPI options
#
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_VERBOSE is not set
CONFIG_CAN_PM_TRACE=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_SLEEP=y
CONFIG_SUSPEND=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATION_NVS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION="/dev/sda5"
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=2001
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_DEBUG_FUNC_TRACE is not set
CONFIG_ACPI_PCI_SLOT=m
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=m
CONFIG_ACPI_SBS=m
CONFIG_X86_APM_BOOT=y
CONFIG_APM=m
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
CONFIG_APM_DO_ENABLE=y
CONFIG_APM_CPU_IDLE=y
CONFIG_APM_DISPLAY_BLANK=y
CONFIG_APM_ALLOW_INTS=y

EoI

}

Config_directory=/etc/acpi               # -c
 proc_event_file=/proc/acpi/event        # -e
        Log_file=/var/log/acpid-proc_acpi_event.log      # -l
        Pid_file=/var/run/acpid-proc_acpi_event.pid      # -p
     Action_file=/etc/acpid-proc_acpi_event.conf         # -a
        Map_file=/etc/acpi-proc_acpi_event.map           # -m

# REM: Options sanity checks:
[ "$Map_file" -a -f "$Map_file" ] || unset Map_file
[ "$Action_file" -a -f "$Action_file" ] || unset Action_file
[ "$Config_directory" -a -d "$Config_directory" ] || unset Config_directory
[ "$proc_event_file" -a -f "$proc_event_file" ]   || unset proc_event_file
[ "$Log_file" -a -d "${Log_file%/*}" ] || unset Log_file
[ "$Pid_file" -a -d "${Pid_file%/*}" ] || unset Pid_file



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

[ "$1" ] || usage 1 "no parameter given"

[ "$ACPID_BIN" ] || usage 1 "acpid binary apparently not installed"


############### MAIN ####################
case $1 in
*start|*Start|*START)
shift


ALREADY_RUNNING=`pidof $ACPID_BIN |tr ' ' '\n' | grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`


if [ ! "$FORCE" ];then
[ "`echo "$ALREADY_RUNNING" |wc -w`" -ge 1 ] && { echo "Another instance of '$ACPID_BIN' already running with PID '$ALREADY_RUNNING'"; exit 1; }
fi


[ "$DISPLAY" ] || export DISPLAY=':0'

[ "$proc_event_file" ]  && set - -e "$proc_event_file" $*
[ "$Config_directory" ] && set - -c "$Config_directory" $*
[ "$Log_file" ]         && set - -l "$Log_file" $*
[ "$Pid_file" ]         && set - -p "$Pid_file" $*
[ "$Action_file" ]      && set - -a "$Action_file" $*
[ "$Map_file" ]         && set - -M "$Map_file" $*


if [ "$*" ];then
$ACPID_BIN $@

else :  ## DO NOTHING (for now)
__static__(){
$ACPID_BIN -c $Config_directory \
 -e $proc_event_file \
 -l $Log_file \
 -p $Pid_file \
 -a $Action_file \
 -M $Map_file
}

fi

sleep 3


ACPID_PID=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`


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
*stop|*Stop|*STOP)
shift


ACPID_PID=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`


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


ACPID_PID_2=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`


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
ACPID_PID_3=`pidof $ACPID_BIN |tr ' ' '\n' |grep -vw '1' |tr '\n' ' ' | sed 's!^\ *!!;s!\ *$!!'`
[ "$ACPID_PID_3" ] || { echo "$0: STOPPED pid '$ACPID_PID' with signal '$s'";exit 0; }
done

echo "$0: FAILED to stop PID '$ACPID_PID' for '$ACPID_BIN'"
exit 1

fi
;;
*) echo "$0: Supported parameters : start|stop";exit 1;;
esac

