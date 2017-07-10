#!/bin/sh


echo watch

while :;
do

unset REPLY
sleep 0.1
read -t 1

# _log
# _debug

echo draw 7 "$REPLY"
echo "$REPLY" >>/tmp/cf_watch_all_reply.txt

case $REPLY in
'') :

;;

*)  :

;;
esac


done
