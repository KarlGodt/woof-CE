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
# tick
# drawinfo 0 You unwear helmet of xray vision *.
# upditem 9 bytes unparsed: 02 05 39 55 b1 00 00 80 00
# upditem 17 bytes unparsed: 86 05 39 56 b9 00 00 80 03 00 00 00 01 00 00 00 01
# item2 53 bytes unparsed: 00 00 00 00 05 39 66 7e .. .. ..
# delinv 0
# comc 60 322500
# map2 25008 21248 255
# face2 21 bytes unparsed: 0b c7 00 8c aa 69 9c 6e 75 67 67 65 .. ..
# updspell 7 bytes unparsed: 02 05 39 56 69 00 16
# updspell 9 bytes unparsed: 06 05 39 56 2b 00 15 00 09
# map2 16625 32064 28690 -2530 -127 16496 4855 7935 -31424 28690 -2530
 #-135 20592 4854 7935 32080 28690 -2274 -127 20592 4854 7935 -31408 28690
 #-2274 -139 24688 4854 7935 31072 28690 -2274 -131 24688 4854 7935 -32416
 #28690 -2274 -123 24688 4854 7935 -31376 28690 -2274 20742 7935 -31360 28690
 #-2530 -123 -28560 4855 7763 4636 21522 7423 -31328 28690 -2530 -163 -20394 0
 #-159 -20394 4831 -123 -20368 4855 7763 544 -123 -16272 4854 7763 543 21517 -27393
 #-31280 28690 -2274 21250 8959 -31264 28690 -2530 21256 20564 2128 -123 -3984 4855
 #7763 3757 21518 -21163 3757 -122 112
# comc 1 377954
#

touch /tmp/cf_watch_monitor_all.txt
mv -f /tmp/cf_watch_monitor_all.txt /tmp/cf_watch_monitor_all.txt.0

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
*" tick "*) :;;
*) echo "REPLY:$REPLY"
   oREPLY="$REPLY";;
esac

sleep 0.01
done >>/tmp/cf_watch_monitor_all.txt

