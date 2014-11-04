#!/bin/ash


source /etc/rc.d/f4puppy5

#_test_fx /etc/acpi/busybox/powerbutton && exec /etc/acpi/busybox/powerbutton

if
test ! -f /sys/power/state
then
ERR_MSG1="No /sys/power/state file"
_err "$ERR_MSG1"
[ "$DISPLAY" ] && {
 xmessage -bg read -fg white -title "Simple Sleep Script" "$ERR_MSG1"
 }
exit 3
fi

read ACPI_POWER_STATES </sys/power/state

case "$ACPI_POWER_STATES" in
mem|"mem "*|*" mem "*) :;;
*) ERR_MSG2=" No mem possible in /sys/power/state file :
'$ACPI_POWER_STATES'"
_err "$ERR_MSG2"
[ "$DISPLAY" ] && {
 xmessage -bg read -fg white -title "Simple Sleep Script" "$ERR_MSG"
 }
 exit 4;;
esac

#read RTC0_WAKE_ALARM_TIME_PRE </sys/class/rtc/rtc0/wakealarm

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

read RTC0_WAKE_ALARM_TIME_PRE </sys/class/rtc/rtc0/wakealarm

WHEREIS_ACPITOOL_BIN=`which acpitool`

if
[ "$WHEREIS_ACPITOOL_BIN" ]
then
"$WHEREIS_ACPITOOL_BIN" -s || {
##/usr/bin/acpitool: /usr/lib/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by /usr/bin/acpitool)
echo mem >/sys/power/state; }

else echo mem >/sys/power/state
fi


read CURRENT_SINCE_EPOCH_POST </sys/class/rtc/rtc0/since_epoch

if test "$RTC0_WAKE_ALARM_TIME_PRE"; then

 if test "$((RTC0_WAKE_ALARM_TIME_PRE))" -ge "$((CURRENT_SINCE_EPOCH_POST-60))"
 then
  if test "$((RTC0_WAKE_ALARM_TIME_PRE))" -le $((CURRENT_SINCE_EPOCH_POST))
   then
    if test -x /etc/acpi/wakealarm/wakealarm.sh ; then
          exec /etc/acpi/wakealarm/wakealarm.sh &
    fi
  fi
 fi

fi
