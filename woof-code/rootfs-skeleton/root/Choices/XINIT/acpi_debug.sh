#!/bin/bash
echo "$0: `pwd`"
f=/root/Startup/ACPI_DEBUG.txt

echo "`date`" > $f
if [ -f /proc/acpi/debug_layer ] ; then
echo /proc/acpi/debug_layer >> $f
cat /proc/acpi/debug_layer >> $f
fi
if [ -f /sys/module/acpi/parameters/debug_layer ] ; then
echo /sys/module/acpi/parameters/debug_layer >> $f
cat /sys/module/acpi/parameters/debug_layer >> $f
fi
if [ -f /proc/acpi/debug_level ] ; then
echo /proc/acpi/debug_level >> $f
cat /proc/acpi/debug_level >> $f
fi
if [ -f /sys/module/acpi/parameters/debug_level ] ; then
echo /sys/module/acpi/parameters/debug_level >> $f
cat /sys/module/acpi/parameters/debug_level >> $f
fi
sleep 2s

if [ -f /sys/module/acpi/parameters/debug_level ] ; then
echo 0xFFFFFFFF > /sys/module/acpi/parameters/debug_level
fi
if [ -f /sys/module/acpi/parameters/debug_layer ] ; then
echo 0xFFFFFFFF > /sys/module/acpi/parameters/debug_layer
fi
sleep 2s

if [ -f /proc/acpi/debug_layer ] ; then
					echo >> $f
cat /proc/acpi/debug_layer >> $f
fi
if [ -f /sys/module/acpi/parameters/debug_layer ] ; then
									echo >> $f
cat /sys/module/acpi/parameters/debug_layer >> $f
fi
if [ -f /proc/acpi/debug_level ] ; then
					echo >> $f
cat /proc/acpi/debug_level >> $f
fi
if [ -f /sys/module/acpi/parameters/debug_level ] ; then
									echo >> $f
cat /sys/module/acpi/parameters/debug_level >> $f
fi

