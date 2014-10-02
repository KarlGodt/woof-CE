#!/bin/bash

#
#
#

#
#
#/usr/include/dev.ffmpeg.backup/amd/amd.h:197: error: expected specifier-qualifier-list before 'device_t'

mkdir NObsd.d

ME=`ls ./*/make.errs.log`

for i in $ME;do

if [ "`grep 'error:' $i | grep '/dev\.ffmpeg\.backup/'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./NObsd.d/$BNDN..."

mv "$DIRN" ./NObsd.d/"$BNDN"
sleep 5s
fi
done
