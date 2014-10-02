#!/bin/bash

#
#
#

#
#
#

mkdir NOpackage_requirements.d

CE=`ls ./*/configure.errs.log`

for i in $CE;do

if [ "`grep 'error:' $i | grep -i 'Package requirements' | grep -i 'not met:'`" ];then

DIRN=`dirname "$i"`
BNDN=`basename "$DIRN"`
echo "mv ing $DIRN ./NOpackage_requirements.d/$BNDN..."

mv "$DIRN" ./NOpackage_requirements.d/"$BNDN"
sleep 5s
fi
done

