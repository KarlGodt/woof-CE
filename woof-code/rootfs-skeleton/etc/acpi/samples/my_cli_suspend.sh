#!/bin/bash

usage(){
echo "$2
"
echo "
$0

-a /path/to/acpitool binary
-h  shows this usage
-s  shows supported suspend states by kernel for current machine
-S /dev/SWAP swap-partition to use
-v  shows availabe swap partitions
-R  suspend to RAM (default if DISK not possible)
-D  suspend to DISK (default if possible)
-d  lots of debugging output incl. 'set -x'
"
exit $1
}
show_swaps(){
echo "$2
"

echo "
Currently available swap partitions :
$SWAPS

`free`
"
exit $1
}

STATES_ALL=$(</sys/power/state)
S_NR_STATES=`cat /proc/acpi/sleep`
#S0 S1 S3 S4 S5

supported(){
echo "$2
"

echo "
ACPI Advanced Configuration and
Power Interface specification

Theoretical available : '$S_NR_STATES'

S0: OS is runging
S1: sleep suspend to RAM
S2: sleep suspend to RAM
S3: sleep suspend to RAM
S4: hibernate suspend to DISK
S5: halt to standby mode

Currently supported : '$STATES_ALL'
"
exit $1
}

#defaults:
E_STATE=disk;A_STATE=-S

for one_state in $STATES_ALL;do
[ "$one_state" = mem ] && { E_STATE=mem;A_STATE=-s;RAM_POSSIBLE=1; }
[ "$one_state" = disk ] && { E_STATE=disk;A_STATE=-S;DISK_POSSIBLE=1; }
done

while getopts a:hsS:vRDd opt;do
case $opt in
a)ACPITOOL=$OPTARG;;
h)usage 0;;
s)supported 0;;
S)SWAP_TO_USE=$OPTARG;;
v)show_swaps 0;;
R)E_STATE=mem;A_STATE=-s;;
D)E_STATE=disk;A_STATE=-S;;
d)set -x;VEROSE=-v;LONG_VERBOSE=--verbose;X_LONG_VERBOSE=-verbose;;
esac;done

[ ! "$DISK_POSSIBLE" -a "$E_STATE" = disk ] && supported 1 "Sorry no support for suspend to disk by the kernel for this machine"
[ ! "$RAM_POSSIBLE" -a "E_STATE" = mem ] && supported 1 "Sorry no support for suspend to ram by the kernel for this machine"

[ "$ACPITOOL" ] || ACPITOOL=`which acpitool`
[ "$ACPITOOL" ] && { [ -L "$ACPITOOL" ] && ACPITOOL_LINK=`readlink -e "$ACPITOOL"`; [ "$ACPITOOL_LINK" ] && ACPITOOL="$ACPITOOL_LINK"; }
[ "$ACPITOOL" ] && { [ ! -e "$ACPITOOL" ] && usage 1 "'$ACPITOOL' does not exist";[ ! -f "$ACPITOOL" ] && usage 1 "'$ACPITOOL' is not a file";[ ! -x "$ACPITOOL" ] && usage 1 "'$ACPITOOL' not set executable"; }

if [ "$E_STATE" = mem ];then
if [ "$ACPITOOL" ];then
$ACPITOOL $VERBOSE $A_STATE
else
echo "Fasten belts, telling 'mem' to /sys/power/state"
echo "$E_STATE" >/sys/power/state
fi
exit $?
fi

SWAPS_LONG=`fdisk -l |grep -i 'swap'`
SWAPS=`echo "$SWAPS_LONG" |awk '{print $1}'`

MEM_USED=`free |grep -i 'Mem' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $3}'`
SWAP_FREE=`free |grep -i 'Swap' |tr -s ' ' |sed 's/^[[:blank:]]*//' |awk '{print $4}'`

[ "$SWAP_FREE" -ge "$MEM_USED" ] || show_swaps 1 "Cowardly refusing to suspent to RAM due to free swap lesser than used mem"

if [ "$SWAP_TO_USE" ];then

[ "`echo "$SWAPS" |grep -w "$SWAP_TO_USE"`" ] || show_swaps 1 "'$SWAP_TO_USE' seems not to be a regular swap partition"
{ for swap in $SWAPS;do swapoff $swap;sleep 1s;sync;done;swapon $SWAP_TO_USE; }

else
FIRST_SWAP=`echo "$SWAPS" |head -n1`

for swap in $SWAPS;do

SWAP_LABEL_RESUME=`blkid $swap |grep -iE 'Resume|Hiber' |cut -f1 -d':'`
[ "$SWAP_LABEL_RESUME" ] && { FIRST_SWAP=$SWAP_LABEL_RESUME;break; }
#SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
done

SWAPS_TO_TURN_OFF=`echo "$SWAPS" |grep -vw "$FIRST_SWAP"`
echo "Swapping off all unneeded swaps..."
for swap in $SWAPS_TO_TURN_OFF;do swapoff $swap;sleep 1s;sync;done

fi

if [ "$ACPITOOL" ];then
$ACPITOOL $VERBOSE $A_STATE
else
echo "Fasten belts, telling '$E_STATE' to /sys/power/state"
echo "$E_STATE" >/sys/power/state
fi


