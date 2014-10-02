#!/bin/bash

#
#
#

#
#
#

mkdir NOdatarootdir.d

CE=`ls ./*/configure.errs.log`

for i in $CE;do

if [ "`grep 'error:' $i | grep '\-\-datarootdir'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./NOdatarootdir.d/$BNDN..."

mv "$DIRN" ./NOdatarootdir.d/"$BNDN"
sleep 5s
fi
done



