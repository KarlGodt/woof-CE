#!/bin/bash

#
#
#

#
#
#


mkdir COMPILED.D

DIRES=`ls -1F |grep '\-i686/$'`

for i in $DIRES;do
echo $i

if [ ! "`ls ./$i`" ];then
rmdir ./$i
fi

done


DIRES=`ls -1F |grep '\-i686/$'`

for i in $DIRES;do
echo $i

mv ./$i ./COMPILED.D/

done




