#!/bin/bash -i

###
#
#
###


shopt execfail

echo 'PROGRAM to test the exec command'
sleep 2s

PARAM="$1"
[ -z "$PARAM" ] && PARAM=1
echo 0
case $PARAM in
1)
echo 10
exec xorgwizard
reVal=$?
echo reVal="$reVal" >> /tmp/exectest.sh
echo 19
;;
2)
echo 20
exec video-wizard
reval2=$?
echo reVal2="$reVal2" >> /tmp/exectest.sh
echo 29
;;
*)
echo 30
exec xserverwizard
reval3=$?
echo 38
echo reVal3="$reVal3" >> /tmp/exectest.sh
echo 39
;;
esac
echo 40
exec jwmconfig
echo  50

sleep 1m

echo finishing script

