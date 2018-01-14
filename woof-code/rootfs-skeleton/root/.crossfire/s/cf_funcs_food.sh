#!/bin/ash

[ "$HAVE_FUNCS_FOOD" ] && return 0

#Food

_check_mana_for_create_food(){
_debug "_check_mana_for_create_food:$*"
local REPLY
_watch
_is 1 0 cast create

while :;
do

read -t ${TMOUT:-1}
  _log "_check_mana_for_create_food:$REPLY"
_msg 7 "_check_mana_for_create_food:$REPLY"
case $REPLY in
*ready*the*spell*create*food*) return 0;;
*create*food*)
MANA_NEEDED=`echo "$REPLY" | awk '{print $NF}'`
_debug "MANA_NEEDED=$MANA_NEEDED"
test "$SP" -ge "$MANA_NEEDED" && return 0 || break 1
;;
'') break 1;;
*) sleep 0.01; continue;;
esac

sleep 0.1
unset REPLY
done

_unwatch
return 1
}

_cast_create_food_and_eat(){
_debug "_cast_create_food_and_eat:$*"

local lEAT_FOOD REPLY1 REPLY2 REPLY3 REPLY4 BUNGLE

test "$EAT_FOOD" && lEAT_FOOD="$EAT_FOOD"
test "$*" && lEAT_FOOD="$@"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
lEAT_FOOD=${lEAT_FOOD:-food}

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

_is 1 1 pickup 0
_empty_message_stream

# TODO: Check MANA
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
_is 1 1 fire center ## TODO: handle bungling the spell

unset BUNGLE
sleep 0.1
read -t $TMOUT BUNGLE
test "`echo "$BUNGLE" | grep -i 'bungle'`" || break
sleep 0.1
done

_is 1 1 fire_stop
_sleep
_empty_message_stream


_is 1 1 apply ## TODO: check if food is there on tile
_empty_message_stream

}

_apply_horn_of_plenty_and_eat(){
_debug "_apply_horn_of_plenty_and_eat:$*"
local REPLY

read -t $TMOUT
_is 1 1 apply -u Horn of Plenty
_is 1 1 apply -a Horn of Plenty
_sleep
unset REPLY
read -t $TMOUT

_is 1 1 fire center ## TODO: handle bungling
_is 1 1 fire_stop
_sleep
unset REPLY
read -t $TMOUT

_is 1 1 apply ## TODO: check if food is there on tile
unset REPLY
read -t $TMOUT
}


_eat_food(){
_debug "_eat_food:$*"
local REPLY

test "$*" && EAT_FOOD="$@"
EAT_FOOD=${EAT_FOOD:-waybread}

#_check_food_inventory ## Todo: check if food is in INV

read -t $TMOUT
_is 1 1 apply $EAT_FOOD
unset REPLY
read -t $TMOUT
}

_check_food_level(){
_debug "_check_food_level:$*"

fcnt=$((fcnt+1))
test "$fcnt" -lt $COUNT_CHECK_FOOD && return 0
fcnt=0

test "$*" && MIN_FOOD_LEVEL="$@"
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-$MIN_FOOD_LEVEL_DEF}
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-200}

local FOOD_LVL=''
local REPLY

read -t $TMOUT  # empty the stream of messages

#_watch $DRAWINFO
_sleep
echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset FOOD_LVL
read -t ${TMOUT:-1} Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
test "$Re" = request || continue

test "$FOOD_LVL" || break
test "${FOOD_LVL//[[:digit:]]/}" && break

_msg 7 HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL #DEBUG

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food
 _cast_create_food_and_eat $EAT_FOOD

 _sleep
 _empty_message_stream
 _sleep
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 #sleep 0.1
 _sleep
 read -t ${TMOUT:-1} Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
 _msg 7 HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL #DEBUG

 #return $?
 break
fi

test "${FOOD_LVL//[[:digit:]]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done

#_unwatch $DRAWINFO
}

#Food

###END###
HAVE_FUNCS_FOOD=1
