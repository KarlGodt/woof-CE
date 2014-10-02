#!/bin/bash

#
#
#

#
#
#error: 'xorg' undeclared (first use in this function)

mkdir UNDxorg.d

CE=`ls ./*/make.errs.log`

for i in $CE;do
echo $i
if [ "`grep 'error:' $i | grep 'xorg' | grep 'undeclared'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./UNDxorg.d/$BNDN..."

mv "$DIRN" ./UNDxorg.d/"$BNDN"
sleep 5s
fi
done





