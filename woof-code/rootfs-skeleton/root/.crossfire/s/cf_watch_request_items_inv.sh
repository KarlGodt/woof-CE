#!/bin/bash

export PATH=/bin:/usr/bin

#echo "`env`" >>/tmp/cf_script.env

#exec 2>>/tmp/cf_script.err

#exec 0>>/tmp/cf_script.stdin

#ls /proc/$$/fd >> /tmp/cf_script.err
#ls /proc/self/fd >> /tmp/cf_script.err
#file  /proc/$$/fd/* >> /tmp/cf_script.err
#file  /proc/self/fd/* >> /tmp/cf_script.err

#read INVENTORY </proc/self/fd/0

#echo monitor

# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 5 " with '$*' parameter."

MAPPOS='';
echo request map pos
while test "$MAPPOS" = ""; do
read MAPPOS || break
test "$MAPPOS" = "scripttell break" && break
test "$MAPPOS" = "scripttell exit" && exit 1
sleep 0.1s
done
echo "$MAPPOS" >>/tmp/cf_script.mappos


UNDER_ME='';
echo request items on
#while test "$UNDER_ME" = ""; do
while [ 1 ]; do
read UNDER_ME || break
sleep 0.1s
echo "$UNDER_ME" >>/tmp/cf_script.mappos
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done

#func(){
rm -f /tmp/cf_script.inv || exit 1
INVTRY='';
#echo watch request items inv
echo request items inv
while [ 1 ]; do
INVTRY=""
read INVTRY || break
echo "$INVTRY" >>/tmp/cf_script.inv
#echo draw 3 "$INVTRY"
test "$INVTRY" = "" && break
test "$INVTRY" = "request items inv end" && break
test "$INVTRY" = "scripttell break" && break
test "$INVTRY" = "scripttell exit" && exit 1
sleep 0.1s
done
#}

# for one in ???
