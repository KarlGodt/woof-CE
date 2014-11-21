#!/bin/ash

# REM: Could as well run /etc/acpi/busybox/powerbutton...
#_test_fx /etc/acpi/busybox/powerbutton && exec /etc/acpi/busybox/powerbutton


# REM: f4puppy5 conains various functions needed
source /etc/rc.d/f4puppy5


# REM: Global variables
TITLE=`gettext 'Simple Sleep Script`

# REM: Use acpitool if avalable,
#      but check if it works

## acpitool -s; echo $?
## Function Do_Suspend : could not open file : /proc/acpi/sleep.
## You must have write access to /proc/acpi/sleep to suspend your computer.
## 0
## acpitool; echo $?
##  Battery status : <not available>
##  AC adapter     : <info not available or off-line>
##  Thermal info   : <not available>
## 0

# REM: kernel can be compiled with no proc-fs support
test -e /proc/acpi/sleep && {
WHEREIS_ACPITOOL_BIN=`which acpitool`
}


# REM: Sanity check if /sys/power/state exist
if
test ! -f /sys/power/state
then
ERR_MSG1=`gettext "No /sys/power/state file"`
_err "$ERR_MSG1"
[ "$DISPLAY" ] && {
 xmessage -bg read -fg white -title "$TITLE" "$ERR_MSG1"
 }
exit 3
fi


# REM: Sanity check if S3 'mem' is possible in /sys/power/state
read ACPI_POWER_STATES </sys/power/state

case "$ACPI_POWER_STATES" in
mem|"mem "*|*" mem "*) :;;
*) ERR_MSG2=`gettext " No mem possible in /sys/power/state file :
'$ACPI_POWER_STATES'"`

_err "$ERR_MSG2"

[ "$DISPLAY" ] && {
 xmessage -bg read -fg white -title "$TITLE" "$ERR_MSG"
 }
 exit 4;;
esac


# REM: Handle /sys/class/rtc/rtc0/wakealarm entry
#      must do further down...
#read RTC0_WAKE_ALARM_TIME_PRE </sys/class/rtc/rtc0/wakealarm


# REM: Check if wakealarm.sh is installed
#      And if so, ask to run it
test -x /etc/acpi/wakealarm.sh && {

test -f /proc/driver/rtc && \
PROC_RTC=`cat /proc/driver/rtc`

SET_WAKEALARM_MSG=`gettext "Do you want to
set the rtc driver wakealarm ?

It is currently set to

$PROC_RTC
"`

xmessage   \
-bg yellow \
-fg black  \
-buttons "No:201,Yes:200" \
-title "$TITLE" \
"$SET_WAKEALARM_MSG"
case $? in
200)
/etc/acpi/wakealarm.sh
;;esac

}

# REM: Now handle /sys/class/rtc/rtc0/wakealarm
read RTC0_WAKE_ALARM_TIME_PRE </sys/class/rtc/rtc0/wakealarm


# REM: Now issue sleep...
if
[ "$WHEREIS_ACPITOOL_BIN" ]
then

"$WHEREIS_ACPITOOL_BIN" -s || {
# REM: acpitool dependencies might be broken ..
## /usr/bin/acpitool: /usr/lib/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by /usr/bin/acpitool)
#      so fallback ...
echo mem >/sys/power/state; }

else echo mem >/sys/power/state
fi


# REM: After wakeup, read /sys/class/rtc/rtc0/since_epoch
read CURRENT_SINCE_EPOCH_POST </sys/class/rtc/rtc0/since_epoch


# REM: Now compare  /sys/class/rtc/rtc0/wakealarm
#       and current /sys/class/rtc/rtc0/since_epoch
#      The code now uses a time window of one minute ahead
if test "$RTC0_WAKE_ALARM_TIME_PRE";
then
  # REM: RTC0_WAKE_ALARM_TIME_PRE has value
 if test "$((RTC0_WAKE_ALARM_TIME_PRE))" -ge "$((CURRENT_SINCE_EPOCH_POST-60))"
 then
  # REM: RTC0_WAKE_ALARM_TIME_PRE greater than CURRENT_SINCE_EPOCH_POST minus 1 minute
  #      in the future yet
  if test "$((RTC0_WAKE_ALARM_TIME_PRE))" -le $((CURRENT_SINCE_EPOCH_POST))
   then
    # REM: RTC0_WAKE_ALARM_TIME_PRE lesser than CURRENT_SINCE_EPOCH_POST
    #       in the past which should be true since wakeup from S3
    #       usually takes 4-9 seconds for me
    if test -x /etc/acpi/wakealarm/wakealarm_cmd;
    then
          # REM: Run /etc/acpi/wakealarm/wakealarm_cmd
          exec /etc/acpi/wakealarm/wakealarm_cmd &
    fi
  fi
 fi

fi
