#!/bin/bash

#
#
#

#
#
#/usr/include/avifile-0.7/fourcc.h:4:2: warning: #warning Use #include "avm_fourcc.h" instead

mkdir NOfourcc.d

ME=`ls ./*/make.errs.log`

for i in $ME;do

if [ "`grep 'warning:' $i | grep 'fourcc\.h'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./NOfourcc.d/$BNDN..."

mv "$DIRN" ./NOfourcc.d/"$BNDN"
sleep 5s
fi
done
