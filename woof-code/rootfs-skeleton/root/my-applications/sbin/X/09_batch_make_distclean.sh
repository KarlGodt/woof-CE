#!/bin/bash

#
#
#

#
#
#

DIRES=`ls -1F |grep '/$' |grep -v '\-i686'`

for i in $DIRES;do
echo $i
cd ./$i
pwd

if [ -f ./Makefile ];then
make clean
make distclean
fi

cd ..

done
