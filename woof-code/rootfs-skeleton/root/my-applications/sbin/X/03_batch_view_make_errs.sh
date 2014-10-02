#!/bin/bash

#
#
#

#
#
#

ME=`ls -1 ./*/make.errs.log`

for i in $ME;do
echo $i
cat $i
echo '***'
grep -m1 -i 'ERROR' $i
echo '***'
echo
done

