#!/bin/bash
echo "$0: `pwd`"
Logf=/root/Startup/ACPI_DEBUG.txt

# create logfile with current acpi settings :
echo "`date`" > "$Logf"

# debug_layer in /proc
if [ -f /proc/acpi/debug_layer ] ; then
echo /proc/acpi/debug_layer >> "$Logf"
cat /proc/acpi/debug_layer >> "$Logf"
fi
# debug_layer in /sys
if [ -f /sys/module/acpi/parameters/debug_layer ] ; then
echo /sys/module/acpi/parameters/debug_layer >> "$Logf"
cat /sys/module/acpi/parameters/debug_layer >> "$Logf"
fi
# debug_level in /proc
if [ -f /proc/acpi/debug_level ] ; then
echo /proc/acpi/debug_level >> "$Logf"
cat /proc/acpi/debug_level >> "$Logf"
fi
 # debug_level in /sys
if [ -f /sys/module/acpi/parameters/debug_level ] ; then
echo /sys/module/acpi/parameters/debug_level >> "$Logf"
cat /sys/module/acpi/parameters/debug_level >> "$Logf"
fi
# end create logfile

sleep 2s

# change  debug_level and  debug_layer settings :
if [ -f /sys/module/acpi/parameters/debug_level ] ; then
#  all:FFFFFFFF
echo 0xFFFFFFFF > /sys/module/acpi/parameters/debug_level
fi
if [ -f /sys/module/acpi/parameters/debug_layer ] ; then
#  all:FFFFFFFF
echo 0xFFFFFFFF > /sys/module/acpi/parameters/debug_layer
fi
sleep 2s

# put new values into LogFile :
if [ -f /proc/acpi/debug_layer ] ; then
                      echo >> "$Logf"
cat /proc/acpi/debug_layer >> "$Logf"
fi
if [ -f /sys/module/acpi/parameters/debug_layer ] ; then
                                       echo >> "$Logf"
cat /sys/module/acpi/parameters/debug_layer >> "$Logf"
fi
if [ -f /proc/acpi/debug_level ] ; then
                      echo >> "$Logf"
cat /proc/acpi/debug_level >> "$Logf"
fi
if [ -f /sys/module/acpi/parameters/debug_level ] ; then
                                       echo >> "$Logf"
cat /sys/module/acpi/parameters/debug_level >> "$Logf"
fi

cat >>"$Logf" <<EoI

debug_layer (component)
-----------------------

You can set the debug_layer mask at boot-time using the acpi.debug_layer
command line argument, and you can change it after boot by writing values
to /sys/module/acpi/parameters/debug_layer.

The possible components are defined in include/acpi/acoutput.h and
include/acpi/acpi_drivers.h.  Reading /sys/module/acpi/parameters/debug_layer
shows the supported mask values, currently these:

    ACPI_UTILITIES                  0x00000001
    ACPI_HARDWARE                   0x00000002
    ACPI_EVENTS                     0x00000004
    ACPI_TABLES                     0x00000008
    ACPI_NAMESPACE                  0x00000010
    ACPI_PARSER                     0x00000020
    ACPI_DISPATCHER                 0x00000040
    ACPI_EXECUTER                   0x00000080
    ACPI_RESOURCES                  0x00000100
    ACPI_CA_DEBUGGER                0x00000200
    ACPI_OS_SERVICES                0x00000400
    ACPI_CA_DISASSEMBLER            0x00000800
    ACPI_COMPILER                   0x00001000
    ACPI_TOOLS                      0x00002000
    ACPI_BUS_COMPONENT              0x00010000
    ACPI_AC_COMPONENT               0x00020000
    ACPI_BATTERY_COMPONENT          0x00040000
    ACPI_BUTTON_COMPONENT           0x00080000
    ACPI_SBS_COMPONENT              0x00100000
    ACPI_FAN_COMPONENT              0x00200000
    ACPI_PCI_COMPONENT              0x00400000
    ACPI_POWER_COMPONENT            0x00800000
    ACPI_CONTAINER_COMPONENT        0x01000000
    ACPI_SYSTEM_COMPONENT           0x02000000
    ACPI_THERMAL_COMPONENT          0x04000000
    ACPI_MEMORY_DEVICE_COMPONENT    0x08000000
    ACPI_VIDEO_COMPONENT            0x10000000
    ACPI_PROCESSOR_COMPONENT        0x20000000

EoI

cat >>"$Logf" <<EoI

debug_level
-----------

You can set the debug_level mask at boot-time using the acpi.debug_level
command line argument, and you can change it after boot by writing values
to /sys/module/acpi/parameters/debug_level.

The possible levels are defined in include/acpi/acoutput.h.  Reading
/sys/module/acpi/parameters/debug_level shows the supported mask values,
currently these:

    ACPI_LV_INIT                    0x00000001
    ACPI_LV_DEBUG_OBJECT            0x00000002
    ACPI_LV_INFO                    0x00000004
    ACPI_LV_INIT_NAMES              0x00000020
    ACPI_LV_PARSE                   0x00000040
    ACPI_LV_LOAD                    0x00000080
    ACPI_LV_DISPATCH                0x00000100
    ACPI_LV_EXEC                    0x00000200
    ACPI_LV_NAMES                   0x00000400
    ACPI_LV_OPREGION                0x00000800
    ACPI_LV_BFIELD                  0x00001000
    ACPI_LV_TABLES                  0x00002000
    ACPI_LV_VALUES                  0x00004000
    ACPI_LV_OBJECTS                 0x00008000
    ACPI_LV_RESOURCES               0x00010000
    ACPI_LV_USER_REQUESTS           0x00020000
    ACPI_LV_PACKAGE                 0x00040000
    ACPI_LV_ALLOCATIONS             0x00100000
    ACPI_LV_FUNCTIONS               0x00200000
    ACPI_LV_OPTIMIZATIONS           0x00400000
    ACPI_LV_MUTEX                   0x01000000
    ACPI_LV_THREADS                 0x02000000
    ACPI_LV_IO                      0x04000000
    ACPI_LV_INTERRUPTS              0x08000000
    ACPI_LV_AML_DISASSEMBLE         0x10000000
    ACPI_LV_VERBOSE_INFO            0x20000000
    ACPI_LV_FULL_TABLES             0x40000000
    ACPI_LV_EVENTS                  0x80000000

EoI

cat >>"$Logf" <<EoI

FILE:linux/Documentation/acpi/debug.txt

Compile-time configuration
--------------------------

ACPI debug output is globally enabled by CONFIG_ACPI_DEBUG.  If this config
option is turned off, the debug messages are not even built into the
kernel.

Boot- and run-time configuration
--------------------------------

When CONFIG_ACPI_DEBUG=y, you can select the component and level of messages
you're interested in.  At boot-time, use the acpi.debug_layer and
acpi.debug_level kernel command line options.  After boot, you can use the
debug_layer and debug_level files in /sys/module/acpi/parameters/ to control
the debug messages.

EoI
