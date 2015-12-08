#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5


L1=`for i in *.current; do echo $i; done`
L2=`for i in *.current; do echo $i; done`

L1=`echo "$L1" | tac | sed '1d' | tac`
L2=`echo "$L2" | sed '1d'`

for i in $L1;
do
 for j in $L2;
  do
   diff -up $i $j >>/tmp/$i.diff;
   echo >>/tmp/$i.diff;
  done;
done
