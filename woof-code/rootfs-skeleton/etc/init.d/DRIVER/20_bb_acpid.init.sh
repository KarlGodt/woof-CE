#!/bin/bash
# Karl Reimer Godt in June 2012
# usual Puppy license
Version='1.1 Puppy_Linux_Racy_5.3 KRG'
Version='2.1 Puppy_Linux_Racy_5.3 KRG'

source /etc/rc.d/f4puppy5

_usage(){
MSG="
$0 [start|stop]
Starts busybox acpid daemon at boot and
shuts it down at reboot or poweroff event.
"
if [ "$2" ];then
MSG="$MSG

$2
"
fi
echo "$MSG"
[ "$DISPLAY" ] && xmessage -bg blue3 "$MSG"
exit $1
}

 ACPID_BIN=`which acpid`
 [ "$ACPID_BIN" ] || _usage 1 "No (executable) acpid binary installed?"
 [ "`readlink "$ACPID_BIN" | grep -i 'busybox'`" ] || _usage 1 "$0: Laucher for busybox acpid applet."

_wrong_place_(){
 DEBUG=1
 _debug "$*"
 while getopts a:C:e:l:M:p oneO; do
 case $oneO in
 a) test "$OPTARG" && HAVE_ACTION_FILE;;
 C) test "$OPTARG" && HAVE_CONFIG_DIR;;
 e) test "$OPTARG" && HAVE_EVENT_FILE;;
 l) test "$OPTARG" && HAVE_LOG_FILE;;
 M) test "$OPTARG" && HAVE_MAP_FILE;;
 p) test "$OPTARG" && HAVE_PID_FILE;;
 esac
 done
 unset oneO
 _debug "$*"
}

 Config_directory=/etc/acpi       # -c

 #1.19.4 does not work wit -e /proc/acpi/event
 proc_event_file=/proc/acpi/event # -e

 Log_file=/var/log/acpid.log      # -l  #1.18.3 does not create it, or if exist, does not update mod,acc,ch-times

 #acpid: invalid option -- 'p'
 #BusyBox v1.19.3 (2011-11-09 07:34:50 WST)
 #BusyBox v1.18.3 (2011-05-01 19:45:13 CEST) oK, also creates pid file with correct content
 Pid_file=/var/run/acpid.pid      # -p
 Action_file=/etc/acpid.conf      # -a
 Map_file=/etc/acpi.map           # -M

_use_input_event(){

 PWRB_INPUT=`sed -n '/N:.*Power Button.*/,/^$/p' /proc/bus/input/devices | \
 sed 's/^$/__NEMWLINE__/' | tr '\n' ' ' \
 | sed 's/__NEMWLINE__/\n/g' | grep -o 'Sysfs.*input[0-9]'`

#PWRB_INPUT=`echo "$PWRB_INPUT" | tac`

DEBUG=1
_debug "$PWRB_INPUT"

 if [ "$PWRB_INPUT" ]; then
  for oneI in $PWRB_INPUT
   do
    _debugx "$oneI"
    ev_dev=${oneI##*input}
    if test -e "/dev/input/event$ev_dev"; then
    proc_event_file="/dev/input/event$ev_dev"
    Log_file=/var/log/acpid-event$ev_dev.log
    Pid_file=/var/run/acpid-event$ev_dev.pid
    #break #if break, use the first one, no break the last one
    fi
   done
 fi

 INFO=1
}
#_use_input_event

 _info "Using event file '$proc_event_file'"
 _info "Using log   file '$Log_file'"
 _info "Using pid   file '$Pid_file'"


_get_acpid_process_ids(){

DEBUG=1
DEBUGX=1

  acpidPS=`ps | grep 'acpid' | grep -v 'grep'`
_debug "$acpidPS" >&2

  if test "$Config_directory"; then
   acpidPS=`echo "$acpidPS" | grep -Fw "$Config_directory"`
   _debugx "$acpidPS" >&2
  fi


  if test "$proc_event_file"; then
   acpidPS=`echo "$acpidPS" | grep -Fw "$proc_event_file"`
   _debugx "$acpidPS" >&2
  fi


  if test "$Action_file"; then
   acpidPS=`echo "$acpidPS" | grep -Fw "$Action_file"`
   _debugx "$acpidPS" >&2
  fi


  if test "$Map_file"; then
   acpidPS=`echo "$acpidPS" | grep -Fw "$Map_file"`
   _debugx "$acpidPS" >&2
  fi


  if test "$Log_file"; then
   acpidPS=`echo "$acpidPS" | grep -Fw "$Log_file"`
   _debugx "$acpidPS" >&2
  fi


  if test "$Pid_file"; then
   acpidPS=`echo "$acpidPS" | grep -Fw "$Pid_file"`
   _debugx "$acpidPS" >&2
  fi

_debug "$acpidPS" >&2
echo "$acpidPS"
}

 case $1 in
 *help) _usage 0;;
 *version) echo -e "$0: Version '$Version'\nTry help for more info.\n";exit 0;;

 *start)
 shift
 #if pidof acpid ;then
 if ps | grep -w "$Config_directory" | grep -w "$Log_file" | grep -w "$Action_file" | grep $Q -w "$Map_file";then
  echo "acpid Already running."
 else
  export DISPLAY=':0'

 if test -s "$Log_file"; then
 _log_rotate "$Log_file"
 fi

# with
# \  # -e "$proc_event_file" \
# :
#12130     1 12130 ?        12:42:55       59:10 S   0  0.0   acpid -c /etc/acpi -l /var/log/acpid.log -a /etc/acpid.conf -M /etc/acpi.map  # -e /proc/acpi/event

# \  # -e "$proc_event_file"
#27803     1 27803 ?        13:47:36       00:15 S   1  0.0   acpid -c /etc/acpi -l /var/log/acpid.log -a /etc/acpid.conf -M /etc/acpi.map  # -e /proc/acpi/event

##  -e "$proc_event_file"    \
#30061     1 30061 ?        13:49:27       00:05 S   1  0.0   acpid -c /etc/acpi -l /var/log/acpid.log -a /etc/acpid.conf -M /etc/acpi.map
#31610 27224 31610 pts/6    13:50:43       00:13 S   1  0.0               /bin/bash /etc/init.d/DRIVER/bb_acpid.init start -d
#31616 31610 31616 pts/6    13:50:43       00:13 S   1  0.0                 acpid -d -c /etc/acpi -l /var/log/acpid.log -a /etc/acpid.conf -M /etc/acpi.map

##  -e "$proc_event_file"
# 1709 27224  1709 pts/6    13:52:51       00:08 S   1  0.0               /bin/bash /etc/init.d/DRIVER/bb_acpid.init start -d
# 1715  1709  1715 pts/6    13:52:51       00:08 S   1  0.0                 acpid -d -c /etc/acpi -l /var/log/acpid.log -a /etc/acpid.conf -M /etc/acpi.map

__old_start__(){
 echo "
acpid -c $Config_directory
      -l $Log_file
      -a $Action_file
      -M $Map_file
      -e $proc_event_file

  $*
"

 acpid \
      -c "$Config_directory" \
      -l "$Log_file"        \
      -a "$Action_file"     \
      -M "$Map_file"        \
      -e "$proc_event_file" \
 \
 $*

# \ #  -e "$proc_event_file" \
# 7204 27224  7204 pts/6    13:57:22       00:21 S   1  0.0               /bin/bash /etc/init.d/DRIVER/bb_acpid.init start -d
# 7210  7204  7210 pts/6    13:57:22       00:21 S   1  0.0                 acpid -c /etc/acpi -l /var/log/acpid.log -a /etc/acpid.conf -M /etc/acpi.map  # -e /proc/acpi/event -d

# \ #  -e "$proc_event_file"
##  -e "$proc_event_file" \
##  -e "$proc_event_file"
#/etc/init.d/DRIVER/bb_acpid.init: line 76: -d: command not found

}

 DEBUG=1
 _debug "$*"
 while getopts a:c:e:l:M:p oneO; do
 case $oneO in
 a) test "$OPTARG" && HAVE_ACTION_FILE=1;Action_file="$OPTARG";;
 c) test "$OPTARG" && HAVE_CONFIG_DIR=1;Config_directory="$OPTARG";;
 e) test "$OPTARG" && HAVE_EVENT_FILE=1;proc_event_file="$OPTARG";;
 l) test "$OPTARG" && HAVE_LOG_FILE=1;Log_file="$OPTARG";;
 M) test "$OPTARG" && HAVE_MAP_FILE=1;Map_file="$OPTARG";;
 p) test "$OPTARG" && HAVE_PID_FILE=1;Pid_file="$OPTARG";;
 esac
 done
 unset oneO
 _debug "$*"

[ "$HAVE_ACTION_FILE" ] || ACPID_OPTS="$ACPID_OPTS -a $Action_file"
[ "$HAVE_CONFIG_DIR" ]  || ACPID_OPTS="$ACPID_OPTS -c $Config_directory"
[ "$HAVE_EVENT_FILE" ]  || ACPID_OPTS="$ACPID_OPTS -e $proc_event_file"
[ "$HAVE_LOG_FILE" ]    || ACPID_OPTS="$ACPID_OPTS -l $Log_file"
[ "$HAVE_MAP_FILE" ]    || ACPID_OPTS="$ACPID_OPTS -M $Map_file"
[ "$HAVE_PID_FILE" ]    || ACPID_OPTS="$ACPID_OPTS -p $Pid_file"

_info "Starting acpid $ACPID_OPTS $*"
acpid $ACPID_OPTS $*

 sleep 2
 echo -n "Started acpid:"
 #pidof acpid || echo "FAILED."
 ps | grep -w "$Config_directory" | grep -w "$Log_file" | grep -w "$Action_file" | grep -w "$Map_file" || echo "FAILED."

 test -s "$Log_file" && cat "$Log_file"

 fi
 ;;

 *stop)

__old_stop__(){
  #if pidof acpid;then
  if ps | grep -w "$Config_directory" | grep -w "$Log_file" | grep -w "$Action_file" | grep $Q -w "$Map_file"; then
  procPID=`ps | grep -w "$Config_directory" | grep -w "$Log_file" \
  | grep -w "$Action_file" | grep -w "$Map_file" | awk '{print $1}'`
  for aP_ in $procPID; do
  #for n in {1..4};do
  for n in `seq 1 1 4`; do
  #kill -$n `pidof acpid`
   kill -$n $aP_
  sleep 1
  #pidof acpid || break
   /bin/ps -p $aP_ --no-headers >>$OUT || break
  done
  done
  fi
}

procPID=`_get_acpid_process_ids | awk '{print $1}'`
if [ "$procPID" ]; then

   for aP_ in $procPID; do
  for n in `seq 1 1 4`; do
   kill -$n $aP_
  sleep 1
   /bin/ps -p $aP_ --no-headers >>$OUT || break
  done
   done

    if [ -f "$Pid_file" ];then
    #pid_file_pid=$(cat "$Pid_file")
    read pid_file_pid <"$Pid_file"
    [ "$pid_file_pid" ] || pid_file_pid=999999999999999 #fake, hopefully never used :oops:
    #if ps | grep -w "$pid_file_pid" | grep -v grep >>$OUT;then
    if ps | awk "{if (\\$1 == $pid_file_pid) print}" >>$OUT; then
     for n in `seq 1 1 4`; do
     #for n in {1..4};do
       kill -$n $pid_file_pid  #MARKER
       sleep 1
       #pidof acpid || break
       ps | awk "{if (\$1 == $pid_file_pid) print}" || break
      done
    fi
    fi
   #if pidof acpid;then
   if ps | grep -w "$Config_directory" | grep -w "$Log_file" | grep -w "$Action_file" | grep $Q -w "$Map_file"; then
    echo "FAILED to stop acpid."
   else
    echo "acpid stopped."
   fi
 else
 echo "acpid not running."
 fi
 rm -f "$Pid_file"
 ;;
 "") _usage 1 "Need Parameter.";;
 *) _usage 1 "Unknown Parameter '$1' .";;
 esac
