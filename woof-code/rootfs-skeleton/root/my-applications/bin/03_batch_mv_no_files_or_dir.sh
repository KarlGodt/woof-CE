#!/bin/bash

#
#
#

#
#
# error: xf86Xxorg/input.h: No such file or directory

mkdir NOfiles.d

ME=`ls ./*/make.errs.log`

for i in $ME;do

if [ "`grep 'error:' $i | grep -i 'No such file or directory'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./NOfiles.d/$BNDN..."

mv "$DIRN" ./NOfiles.d/"$BNDN"
sleep 5s
fi
done

