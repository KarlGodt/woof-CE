#!/bin/ash


source /etc/rc.d/f4puppy5

#_test_fx /etc/acpi/busybox/powerbutton && exec /etc/acpi/busybox/powerbutton
_test_fx /etc/acpi/PWRF/00000080 && exec /etc/acpi/PWRF/00000080

if
test ! -f /sys/power/state
then
ERR_MSG1="No /sys/power/state file"
_err "$ERR_MSG1"
[ "$DISPLAY" ] && {
 xmessage -bg read -fg white -title "Simple ACPI Sleep Script" "$ERR_MSG1"
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
 xmessage -bg read -fg white -title "Simple ACPI Sleep Script" "$ERR_MSG"
 }
 exit 4;;
esac


WHEREIS_ACPITOOL_BIN=`which acpitool`

read RTC0_TIME_BEFORE </sys/class/rtc/rtc0/since_epoch
grep -H '.*' /sys/class/rtc/rtc0/since_epoch #DEBUG

read RTC0_WAKEALARM_TIME </sys/class/rtc/rtc0/wakealarm
grep -H '.*' /sys/class/rtc/rtc0/wakealarm #DEBUG

if
[ "$WHEREIS_ACPITOOL_BIN" ]
then
#"$WHEREIS_ACPITOOL_BIN" -s
##/usr/bin/acpitool: /usr/lib/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by /usr/bin/acpitool)
echo mem >/sys/power/state

else echo mem >/sys/power/state
fi

sleep 6
read RTC0_TIME_AFTER </sys/class/rtc/rtc0/since_epoch
grep -H '.*' /sys/class/rtc/rtc0/since_epoch #DEBUG

if test "$RTC0_WAKEALARM_TIME"; then

 if test "$RTC0_TIME_AFTER" -ge $RTC0_WAKEALARM_TIME; then

  if _test_fx /etc/acpi/wakealarm/wakealarm_cmd; then
        exec /etc/acpi/wakealarm/wakealarm_cmd &
    else echo "/etc/acpi/wakealarm/wakealarm_cmd not -x" #DEBUG
  fi
 else echo "RTC0_WAKEALARM_TIME is in the future" #DEBUG
 fi
else echo "RTC0_WAKEALARM not set" #DEBUG
fi

