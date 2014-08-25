#!/bin/bash

DIRS='/bin /sbin /usr/bin /usr/sbin /usr/local/bin /etc/rc.d /etc/init.d /usr/local/petget'

rm -f bkscripts.lst
for dir in $DIRS;do
[ -d $dir ] || continue
grep -I -m1 -iE 'Barry |Kauler |BK|B\.K\.' $dir/* | grep '#' >> bkscripts.lst
done

geany bkscripts.lst

