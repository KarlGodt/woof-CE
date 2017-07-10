#!/bin/sh


echo watch stats

while :;
do

unset REPLY
sleep 0.1
read -t 1

# _log
# _debug

#echo draw 7 "$REPLY"
#echo "$REPLY" >>/tmp/cf_watch_stats_all_reply.txt

case $REPLY in
'') :

;;

*)  :
echo draw 7 "$REPLY"
echo "$REPLY" >>/tmp/cf_watch_stats_all_reply.txt


;;
esac


done
