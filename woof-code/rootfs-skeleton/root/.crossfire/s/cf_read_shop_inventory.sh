#!/bin/ash

# *** diff marker 1
# ***
# ***

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO


# *** Here begins program *** #
echo draw 2 "$0 is started.."

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


# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700


# ***
# ***
# *** diff marker 2
