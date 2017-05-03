#!/bin/ash


mv -f /tmp/cf_watch_monitor.txt /tmp/cf_watch_monitor.txt.0

echo watch #monitor issue
#echo monitor

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_watch_monitor.txt
sleep 0.1
done

