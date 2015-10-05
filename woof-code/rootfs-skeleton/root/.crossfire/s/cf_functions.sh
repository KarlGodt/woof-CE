#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5


_set_global_variables(){
TMOUT=1    # read -t timeout

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

# Log file path in /tmp
#MY_SELF=`realpath "$0"` ## needs to be in main script
#MY_BASE=${MY_SELF##*/}  ## needs to be in main scrip
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err
}

_is(){
    echo issue "$@"
    sleep 0.2
}

_draw(){
    local COLOUR="$1"
    test "$COLOUR" || COLOUR=1 #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_debug(){
test "$DEBUG" || return 0
    echo draw 3 "$@"
}

_log(){
   test "$LOGGING"
}

# *** EXIT FUNCTIONS *** #
_exit(){
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep ${SLEEP}s
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawinfo
beep -l 1000 -f 700
exit $1
}

_emergency_exit(){
_is 1 1 apply rod of word of recall
_is 1 1 fire center
echo draw 3 "Emergency Exit $0 !"
echo unwatch drawinfo
_is 1 1 fire_stop
beep -l 1000 -f 700
exit $1
}

_exit_no_space(){
echo draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
echo draw 3 "Remove that Item and try again."
echo draw 3 "If this is a Wall, try another place."
beep -l 1000 -f 700
exit $1
}

# *** Check if standing on a cauldron *** #
_check_if_on_cauldron(){
echo drawinfo 5 "Checking if on a cauldron..."

UNDER_ME='';
UNDER_ME_LIST='';
echo request items on
#echo watch request

while :; do
#unset UNDER_ME
read -t $TMOUT UNDER_ME
echo "$UNDER_ME" >>"$ON_LOG"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
beep -l 1000 -f 700
exit 1
}

#echo unwatch request
echo drawinfo 7 "OK."
}

_check_for_space(){
# *** Check for 4 empty space to DIRB ***#

local REPLY_MAP OLD_REPLY

echo drawinfo 5 "Checking for space to move..."

echo request map pos

echo watch request

while :; do
read -t $TMOUT REPLY_MAP
echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

echo unwatch request


PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 4`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
esac

echo request map $R_X $R_Y

echo watch request

while :; do
read -t $TMOUT REPLY
echo "request map '$R_X' '$R_Y':$REPLY" >>"$REPLY_LOG"

test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`
echo "IS_WALL=$IS_WALL" >>"$REPLY_LOG"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch request

done

else

echo drawinfo 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

echo drawinfo 3 "Could not get X and Y position of player."
exit 1

fi

echo drawinfo 7 "OK."
}

 _prepare_rod_of_recall(){
# *** Readying rod of word of recall - just in case *** #

local RECALL OLD_REPLY REPLY

echo drawinfo 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

echo watch request

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "request items actv:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , _emergency_exit applies again
_is 1 1 apply rod of word of recall
fi

echo unwatch request

echo drawinfo 6 "Done."

}

_get_player_speed(){
echo drawinfo 5 "Processing Player's speed..."

local ANSWER OLD_ANSWER PL_SPEED
ANSWER=
OLD_ANSWER=

echo request stat cmbt

echo watch request

while :; do
read -t $TMOUT ANSWER
echo "request stat cmbt:$ANSWER" >>"$REQUEST_LOG"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

echo unwatch request

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED="0.${PL_SPEED:0:2}"

echo drawinfo 7 "Player speed is '$PL_SPEED'"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!^0*!!;s!\.!!g'`
echo drawinfo 7 "Player speed is '$PL_SPEED'"

  if test "$PL_SPEED" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$PL_SPEED" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$PL_SPEED" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$PL_SPEED" -gt 35; then
SLEEP=1; DELAY_DRAWINFO=2; TMOUT=2
elif test "$PL_SPEED" -gt 25; then
SlEEP=2; DELAY_DRAWINFO=4; TMOUT=2
elif test "$PL_SPEED" -gt 15; then
SLEEP=3; DELAY_DRAWINFO=6; TMOUT=2
elif test "$PL_SPEED" -gt 10; then
SLEEP=4; DELAY_DRAWINFO=8; TMOUT=2
elif test "$PL_SPEED" -ge 0;  then
SLEEP=5; DELAY_DRAWINFO=10; TMOUT=2
fi

echo drawinfo 6 "Done."
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

local REPLY OLD_REPLY REPLY_ALL

[ "$SLEEP" ] || SLEEP=3           # setting defaults
[ "$DELAY_DRAWINFO" ] || DELAY_DRAWINFO=6

_is 0 1 pickup 0  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s


echo drawinfo 5 "Checking for empty cauldron..."

_is 1 1 apply
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo watch drawinfo

_is 1 1 get

#echo watch drawinfo

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "get:$REPLY" >>"$REPLY_LOG"
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo drawinfo 3 "Cauldron NOT empty !!"
echo drawinfo 3 "Please empty the cauldron and try again."
_exit 1
}

echo unwatch drawinfo

echo drawinfo 7 "OK ! Cauldron IS empty."
}

#** the messages in the msgpane may pollute **#
#** need to catch msg to discard them into an unused variable **#
_empty_message_stream(){
local REPLY
while :;
do
read -t 1 REPLY
test "$REPLY" || break
[ "$DEBUG" ] && echo draw 3 "_empty_message_stream:$REPLY"
unset REPLY
sleep 0.1
done
}

#** we may get attacked and die **#
_check_hp_and_return_home(){

local REPLY

test "$1" && local currHP=$1
test "$2" && local currHPMin=$2

test "$currHP"     || local currHP=$HP
test "$HP_MIN_DEF" && local currHPMin=$HP_MIN_DEF
test "$currHPMin"  || local currHPMin=$((MHP/10))

[ "$DEBUG" ] && echo draw 3 currHP=$currHP currHPMin=$currHPMin
if test "$currHP" -le $currHPMin; then

_empty_message_stream
_is 1 1 apply -a rod of word of recall
_empty_message_stream

_is 1 1 fire center ## Todo check if already applied and in inventory
_is 1 1 fire_stop
_empty_message_stream

echo unwatch drawinfo
exit
fi

unset HP
}

#Food

_check_mana_for_create_food(){

local REPLY
_is 1 0 cast create

while :;
do
unset REPLY
read -t 1 REPLY
[ "$DEBUG" ] && echo draw 3 "_check_mana_for_create_food:$REPLY"
case $REPLY in
*ready*the*spell*create*food*) return 0;;
*create*food*)
MANA_NEEDED=`echo "$REPLY" | awk '{print $NF}'`
test "$SP" -ge "$MANA_NEEDED" && return 0
;;
'') break;;
*) sleep 0.1; continue;;
esac

sleep 0.1
done

return 1
}

_cast_create_food_and_eat(){

local lEAT_FOOD REPLY1 REPLY2 REPLY3 REPLY4 BUNGLE

test "$*" && lEAT_FOOD="$@"
test "$EAT_FOOD" || lEAT_FOOD=$FOOD_DEF
test "$EAT_FOOD" || lEAT_FOOD=food

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

_is 1 1 pickup 0
_empty_message_stream

# TODO : Check MANA
_is 1 1 cast create food $lEAT_FOOD
_empty_message_stream

while :;
do
_is 1 1 fire_stop
sleep 0.1

while :;
do
_check_mana_for_create_food && break || { sleep 10; continue; }
done

sleep 0.1
_is 1 1 fire center ## Todo handle bungling the spell

unset BUNGLE
sleep 0.1
read -t 1 BUNGLE
test "`echo "$BUNGLE" | grep -i 'bungle'`" || break
sleep 0.1
done

_is 1 1 fire_stop
sleep 1
_empty_message_stream


_is 1 1 apply ## Todo check if food is there on tile
_empty_message_stream

}

_apply_horn_of_plenty_and_eat(){
local REPLY

read -t 1 REPLY
_is 1 1 apply -a Horn of Plenty
sleep 1
unset REPLY
read -t 1 REPLY

_is 1 1 fire center ## Todo handle bungling
_is 1 1 fire_stop
sleep 1
unset REPLY
read -t 1 REPLY

_is 1 1 apply ## Todo check if food is there on tile
unset REPLY
read -t 1 REPLY
}


_eat_food(){

local REPLY

test "$*" && EAT_FOOD="$@"
test "$EAT_FOOD" || EAT_FOOD=waybread

#_check_food_inventory ## Todo: check if food is in INV

read -t 1 REPLY
_is 1 1 apply $EAT_FOOD
unset REPLY
read -t 1 REPLY
}

_check_food_level(){

#c=$((c+1))
#test $C -lt $PAUSE_CHECK_FOOD && return
#c=0

test "$*" && MIN_FOOD_LEVEL="$@"
test "$MIN_FOOD_LEVEL" || MIN_FOOD_LEVEL=200

local FOOD_LVL=''
local REPLY

read -t 1 REPLY # empty the stream of messages

echo watch drawinfo
sleep 1
echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset FOOD_LVL
read -t1 Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
test "$Re" = request || continue

test "$FOOD_LVL" || break
test "${FOOD_LVL//[[:digit:]]/}" && break

[ "$DEBUG" ] && echo draw 3 HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL #DEBUG

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food
 _cast_create_food_and_eat $EAT_FOOD

 sleep 1
 _empty_message_stream
 sleep 1
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 #sleep 0.1
 sleep 1
 read -t1 Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
 [ "$DEBUG" ] && echo draw 3 HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL #DEBUG

 #return $?
 break
fi

test "${FOOD_LVL//[[:digit:]]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done

echo unwatch drawinfo
}



#Food
