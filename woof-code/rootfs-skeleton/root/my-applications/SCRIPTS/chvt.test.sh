#!/bin/sh

currentTTY=`tty | grep -o -e '[0-9]*$'`
echo currentTTY=$currentTTY
sleep 6s
deallocvt 12
sleep 2s
chvt 12
sleep 2s
xorgwizard
sleep 2s
chvt $currentTTY
deallocvt 12
#openvt -c 12 -s xorgwizard #&
#sleep 3s
#chvt 12
#while [ "`ps -C xorgwizard`" ] ; do
#sleep 3s
#if [ ! "`ps -C xorgwizard`" ] ; then
# chvt $currentTTY
# break
#fi
#done
exit
