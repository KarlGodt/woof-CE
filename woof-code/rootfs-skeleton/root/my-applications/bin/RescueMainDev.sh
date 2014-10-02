#!/bin/sh
#
#
#
#
procPartitions=`cat /proc/partitions | sed 's/^[[:blank:]]*//g' | grep '^[0-9]'`
echo "$procPartitions" | while read maj min siz dev ; do
echo "maj=$maj min=$min siz=$siz dev=$dev"
[ -z "$dev" ] && continue
rm /dev/$dev
mknod /dev/$dev b $maj $min ; done
