#!/bin/bash

#
#
#

#
#
#

ME=`ls -1 ./*/make.errs.log`
exec 1>/tmp/make-errs.logs 2>&1
for i in $ME;do
echo $i
cat $i
echo '***'
grep -m1 -i 'ERROR' $i
echo '***'
echo
done
geany -i /tmp/make-errs.logs
