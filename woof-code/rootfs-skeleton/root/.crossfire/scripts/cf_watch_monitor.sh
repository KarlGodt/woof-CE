#!/bin/ash

# PARAMETERS:
# stats
#      food #
#     flags #
#     skill # # # #
#       exp #
#        wc #
#       dam #
#   weap_sp #
#   unknown # # bytes left
#     grace #
#        hp #
#        sp #   ( mana )
#     maxhp #
#   resists # #
# str dex int wis pow cha #
#        ac #
#     speed #
#weight_lim #

#without parameters:
#
#
#
#
#

touch /tmp/cf_watch_monitor.txt
mv -f /tmp/cf_watch_monitor.txt /tmp/cf_watch_monitor.txt.0

if test "$*"; then
echo watch "$@"
else
echo watch #monitor issue
#echo monitor
fi

cnt0=1
while [ 1 ]; do
read -t 1 REPLY
case $REPLY in '')
  case $oREPLY in EMPTY) :;;
    *)
    echo "empty reply:$REPLY"
    oREPLY=EMPTY
   ;;
   esac;;
*) echo "REPLY:$REPLY"
   oREPLY="$REPLY";;
esac

sleep 0.1
done >>/tmp/cf_watch_monitor.txt

