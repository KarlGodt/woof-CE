#!/bin/ash

export PATH=/bin:/usr/bin

# *** Color numbers found in common/shared/newclient.h : *** #
#define NDI_BLACK       0
#define NDI_WHITE       1
#define NDI_NAVY        2
#define NDI_RED         3
#define NDI_ORANGE      4
#define NDI_BLUE        5       /**< Actually, it is Dodger Blue */
#define NDI_DK_ORANGE   6       /**< DarkOrange2 */
#define NDI_GREEN       7       /**< SeaGreen */
#define NDI_LT_GREEN    8       /**< DarkSeaGreen, which is actually paler
#                                 *   than seagreen - also background color. */
#define NDI_GREY        9
#define NDI_BROWN       10      /**< Sienna. */
#define NDI_GOLD        11
#define NDI_TAN         12      /**< Khaki. */
#define NDI_MAX_COLOR   12      /**< Last value in. */
#
#define NDI_COLOR_MASK  0xff    /**< Gives lots of room for expansion - we are
#                                 *   using an int anyways, so we have the
#                                 *   space to still do all the flags.
#                                 */
#define NDI_UNIQUE      0x100   /**< Print immediately, don't buffer. */
#define NDI_ALL         0x200   /**< Inform all players of this message. */
#define NDI_ALL_DMS     0x400   /**< Inform all logged in DMs. Used in case of
#                                 *   errors. Overrides NDI_ALL. */


# Global variables
PAUSE_CHECK_FOOD=10 # number between praying attemts to check foodlevel.
                    #  1 would mean check every pray, which is too much
EAT_FOOD=waybread   # set to desired food to eat ie food, mushroom, booze, .. etc.
FOOD_DEF=$EAT_FOOD     # default
MIN_FOOD_LEVEL_DEF=200 # default minimum. 200 starts to beep. waybread has foodvalue of 500 .
                       # 999 is max foodlevel

HP_MIN_DEF=20          # minimum HP to return home. Lowlevel charakters probably need this set.

DEBUG=1; #set to ANYTHING ie "1" to enable, empty to disable


# *** Here begins program *** #
echo draw 2 "$0 has started.."
echo draw 2 "PARAM:$* PID:$$ PPID :$PPID"

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to pray given number times."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <number>"
echo draw 5 "For example: 'script $0 50'"
echo draw 5 "will issue 50 times the use_skill praying command."

        exit 0
        }

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

} || {
echo draw 3 "Script needs number of praying attempts as argument."
        exit 1
}

test "$1" || {
echo draw 3 "Need <number> ie: script $0 50 ."
        exit 1
}

test -f "${MY_SELF%/*}"/cf_functions.sh && . "${MY_SELF%/*}"/cf_functions.sh

echo request stat cmbt
#read REQ_CMBT
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n", cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read Req Stat Cmbt WC AC DAM SPEED W_SPEED
[ "$DEBUG" ] && echo draw 7 "wc=$WC:ac=$AC:dam=$DAM:speed=$SPEED:weaponspeed=$W_SPEED"
case $SPEED in
1[0-9][0-9][0-9][0-9]) USLEEP=1500000;;
2[0-9][0-9][0-9][0-9]) USLEEP=1400000;;
3[0-9][0-9][0-9][0-9]) USLEEP=1300000;;
4[0-9][0-9][0-9][0-9]) USLEEP=1200000;;
5[0-9][0-9][0-9][0-9]) USLEEP=1100000;;
6[0-9][0-9][0-9][0-9]) USLEEP=1000000;;
7[0-9][0-9][0-9][0-9]) USLEEP=900000;;
8[0-9][0-9][0-9][0-9]) USLEEP=800000;;
9[0-9][0-9][0-9][0-9]) USLEEP=700000;;
*) USLEEP=600000;;
esac
[ "$DEBUG" ] && echo draw 10 "USLEEP=$USLEEP:SPEED=$SPEED"

USLEEP=$(( USLEEP- ((SPEED/10000)*1000) ))
[ "$DEBUG" ] && echo draw 7 "Sleeping $USLEEP usleep micro-seconds between praying"

#** the messages in the msgpane may pollute **#
#** need to catch msg to discard them into an unused variable **#
__empty_message_stream(){
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
__check_hp_and_return_home(){

local REPLY

test "$1" && local currHP=$1
test "$2" && local currHPMin=$2

test "$currHP"     || local currHP=$HP
test "$HP_MIN_DEF" && local currHPMin=$HP_MIN_DEF
test "$currHPMin"  || local currHPMin=$((MHP/10))

[ "$DEBUG" ] && echo draw 3 currHP=$currHP currHPMin=$currHPMin
if test "$currHP" -le $currHPMin; then

_empty_message_stream
echo issue 1 1 apply -a rod of word of recall
_empty_message_stream

echo issue 1 1 fire center ## Todo check if already applied and in inventory
echo issue 1 1 fire_stop
_empty_message_stream

echo unwatch drawinfo
exit
fi

unset HP
}

#Food

__check_mana_for_create_food(){

local REPLY
echo issue 1 0 cast create

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

__cast_create_food_and_eat(){

local lEAT_FOOD REPLY1 REPLY2 REPLY3 REPLY4 BUNGLE

test "$*" && lEAT_FOOD="$@"
test "$EAT_FOOD" || lEAT_FOOD=$FOOD_DEF
test "$EAT_FOOD" || lEAT_FOOD=food

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

echo issue 1 1 pickup 0
_empty_message_stream

# TODO : Check MANA
echo issue 1 1 cast create food $lEAT_FOOD
_empty_message_stream

while :;
do
echo issue 1 1 fire_stop
sleep 0.1

while :;
do
_check_mana_for_create_food && break || { sleep 10; continue; }
done

sleep 0.1
echo issue 1 1 fire center ## Todo handle bungling the spell

unset BUNGLE
sleep 0.1
read -t 1 BUNGLE
test "`echo "$BUNGLE" | grep -i 'bungle'`" || break
sleep 0.1
done

echo issue 1 1 fire_stop
sleep 1
_empty_message_stream


echo issue 1 1 apply ## Todo check if food is there on tile
_empty_message_stream

}

__apply_horn_of_plenty_and_eat(){
local REPLY

read -t 1 REPLY
echo issue 1 1 apply -a Horn of Plenty
sleep 1
unset REPLY
read -t 1 REPLY

echo issue 1 1 fire center ## Todo handle bungling
echo issue 1 1 fire_stop
sleep 1
unset REPLY
read -t 1 REPLY

echo issue 1 1 apply ## Todo check if food is there on tile
unset REPLY
read -t 1 REPLY
}


__eat_food(){

local REPLY

test "$*" && EAT_FOOD="$@"
test "$EAT_FOOD" || EAT_FOOD=waybread

#_check_food_inventory ## Todo: check if food is in INV

read -t 1 REPLY
echo issue 1 1 apply $EAT_FOOD
unset REPLY
read -t 1 REPLY
}

__check_food_level(){

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

# *** Actual script to pray multiple times *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

c=0
for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 use_skill praying"
#sleep 1s
usleep $USLEEP

c=$((c+1))
test $c -ge $PAUSE_CHECK_FOOD && {
c=0
_check_food_level
#_check_hp_and_return_home $HP $HP_MIN_DEF
_check_hp_and_return_home $HP
unset Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
unset Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2
echo draw 5 "$((NUMBER-one)) prayings left"
}

done

# *** Here ends program *** #
echo draw 2 "$0 is finished."
