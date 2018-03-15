#!/bin/ash


. /etc/rc.d/f4puppy5

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
'$ACPI_POWER_STATES'

Make sure that ACPI state S3 RAM sleep is enabled in the BIOS
and that the kernel is configured to support it.
Look for CONFIG_SUSPEND=y in /etc/modules/DOTconfig*"
_err "$ERR_MSG2"
[ "$DISPLAY" ] && {
 xmessage -bg read -fg white -title "Simple Sleep Script" "$ERR_MSG"
 }
 exit 4;;
esac


WHEREIS_ACPITOOL_BIN=`which acpitool`

if
[ "$WHEREIS_ACPITOOL_BIN" ]
then "$WHEREIS_ACPITOOL_BIN" -s

else echo mem >/sys/power/state
fi

