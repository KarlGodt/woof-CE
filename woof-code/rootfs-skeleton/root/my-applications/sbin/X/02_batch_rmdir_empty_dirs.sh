#!/bin/bash

#
#
#

#
#
#

DIRES=`ls -1F |grep '\-i686/$'`

for i in $DIRES;do
echo $i

if [ ! "`ls ./$i`" ];then
rmdir ./$i
fi

done

