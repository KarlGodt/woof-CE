#!/bin/bash

#
#
#

#
#
#

DIRES=`ls -1F |grep '/$'`

for i in $DIRES;do
echo $i
cd ./$i
pwd

if [ -f ./Makefile ];then
make 2>make.errs.log
if [ "$?" = '0' ];then
make install
if [ "$?" = '0' ];then
new2dir f r make install
fi;
fi;
else
echo "
No Makefile created in $i
">>/tmp/batch_conf_inst.missing
fi

[ ! -s ./configure.errs.log ] && rm ./configure.errs.log
[ ! -s ./make.errs.log ] && rm ./make.errs.log
cd ..

sleep 2s
done
