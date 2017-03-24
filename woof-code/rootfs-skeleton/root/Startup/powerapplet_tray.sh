#!/bin/ash

test -d /proc/acpi/battery || exit 0
PIF=`find /proc/acpi/battery -maxdepth 3 -type f -name "info"`
for i in $PIF ; do
if test -r $i ; then
/root/Startup/RESERVED/powerapplet_tray.comp
exit
fi
done
