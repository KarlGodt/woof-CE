#!/bin/ash




DRAW_INFO=drawinfo

echo watch $DRAW_INFO

echo issue 0 0 apply

while :
do
unset REPLY
sleep 0.1
read -t 1
 echo draw 8 "REPLY='$REPLY'"
 [ "$*" ] && { echo "$REPLY" | grep -q -iE "$*" && echo draw 3 "$REPLY"; }

case $REPLY in '') break;; esac
done

echo unwatch $DRAW_INFO
