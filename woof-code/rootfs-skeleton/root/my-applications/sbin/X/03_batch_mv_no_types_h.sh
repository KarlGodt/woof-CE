#!/bin/bash

#
#
#

#
#
#/usr/include/sys/_types.h:39: error: conflicting types for '__blksize_t'

mkdir NOtypes_h.d

ME=`ls ./*/make.errs.log`

for i in $ME;do

if [ "`grep 'error:' $i | grep 'types\.h'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./NOtypes_h.d/$BNDN..."

mv "$DIRN" ./NOtypes_h.d/"$BNDN"
sleep 5s
fi
done


