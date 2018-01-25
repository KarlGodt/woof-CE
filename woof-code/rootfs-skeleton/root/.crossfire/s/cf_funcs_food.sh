#!/bin/ash

[ "$HAVE_FUNCS_FOOD" ] && return 0

#Food

_check_mana_for_create_food(){
_debug "_check_mana_for_create_food:$*"

local lSP=${*:-$SP}
test "$lSP" || return 254

local REPLY

# This function forces drawing of
# all spells that start witch 'create'
# to the message panel and the reads the
# drawinfo lines.
# It needs the SP variable set by
# _check_food_level()
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
 test "$lSP" -ge "$MANA_NEEDED" && return 0 || break 1
 ;;
 *'Something blocks your spellcasting.'*) _exit 1;;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit 1;;
 '') break 1;;
 *) :;;
 esac

sleep 0.01
unset REPLY
done

_unwatch
return 1
}

_cast_create_food_and_eat(){
_debug "_cast_create_food_and_eat:$*"

local lEAT_FOOD BUNGLE

lEAT_FOOD="${*:-$EAT_FOOD}"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
lEAT_FOOD=${lEAT_FOOD:-food}

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

#_is 1 1 pickup 0
_set_pickup 0

_unwatch $DRAWINFO
_empty_message_stream
_watch $DRAWINFO

unset HAVE_NOT_SPELL
# TODO: Check MANA
_is 1 1 cast create food $lEAT_FOOD
while :;
 do
 unset REPLY
 read -t $TMOUT
 _log "_cast_create_food_and_eat:$REPLY"
 _msg 7 "$REPLY"
 case $REPLY in
 *Cast*what*spell*) HAVE_NOT_SPELL=1; break 1;; #Cast what spell?  Choose one of:
 *ready*the*spell*)  break 1;;                  #You ready the spell create food
 '')                 break 1;;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit 1;;
 *) :;;
 esac
sleep 0.01
done

test "$HAVE_NOT_SPELL" && return 253

_empty_message_stream

while :;
do
_is 1 1 fire_stop # precaution
sleep 0.1

 while :;
 do
  _check_mana_for_create_food && break
  sleep 10
 done

# _check_mana_for_create_food returns early
_unwatch $DRAWINFO
_empty_message_stream
sleep 0.2

_watch $DRAWINFO
_is 1 1 fire center ## TODO: handle bungling the spell
_is 1 1 fire_stop

 while :; do
  unset BUNGLE
  read -t $TMOUT BUNGLE
  _log "_cast_create_food_and_eat:$BUNGLE"
  _msg 7 "BUNGLE=$BUNGLE"
  case $BUNGLE in
  *bungle*|*fumble*) break 1;;
  '') break 2;;
  *scripttell*break*) break ${REPLY##*?break};;
  *scripttell*exit*)  _exit 1;;
  *) :;;
  esac
 sleep 0.01
 done

sleep 0.2
done

_unwatch $DRAWINFO
_is 1 1 fire_stop
_empty_message_stream
_sleep

_check_if_on_item -l ${lEAT_FOOD:-haggis} && _is 1 1 apply ## TODO: check if food is there on tile
_empty_message_stream
}

_apply_horn_of_plenty_and_eat(){
_debug "_apply_horn_of_plenty_and_eat:$*"

_is 1 1 apply -u Horn of Plenty
_is 1 1 apply -a Horn of Plenty
_sleep

_is 1 1 fire center ## TODO: handle bungling
_is 1 1 fire_stop
_sleep

_check_if_on_item -lt ${FOOD_DEF:-haggis} && _is 1 1 apply
}

_eat_food_from_inventory(){
_debug "_eat_food_from_inventory:$*"

local lEAT_FOOD="${@:-$EAT_FOOD}"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
test "$lEAT_FOOD" || return 254

#_check_food_in_inventory ## Todo: check if food is in INV
_check_have_item_in_inventory $lEAT_FOOD && _is 1 1 apply $lEAT_FOOD
#_is 1 1 apply $lEAT_FOOD
}

_eat_food_from_open_container(){
_debug "_eat_food_from_open_container:$*"

local lEAT_FOOD="${@:-$EAT_FOOD}"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
test "$lEAT_FOOD" || return 254

#_check_food_in_inventory ## Todo: check if food is in INV
#_check_have_item_in_open_container $lEAT_FOOD && _is 1 1 apply -b $lEAT_FOOD
_is 1 1 apply -b $lEAT_FOOD
}

_check_food_level(){
_debug "_check_food_level:$*"

test "$*" && MIN_FOOD_LEVEL="$@"
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-$MIN_FOOD_LEVEL_DEF}
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-300}

local FOOD_LVL=''
local REPLY

_empty_message_stream
_sleep

echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset HP MHP SP MSP GR MGR FOOD_LVL
read -t ${TMOUT:-1} Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
   _log "HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL"
 _msg 7 "HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL" #DEBUG

test "$Re" = request || continue
test "$FOOD_LVL" || break
test "${FOOD_LVL//[[:digit:]]/}" && break

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food_from_inventory
 _cast_create_food_and_eat $EAT_FOOD || _eat_food_from_inventory $EAT_FOOD

 _sleep
 _empty_message_stream
 _sleep
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 _sleep
 read -t ${TMOUT:-1} Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
   _log "HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL"
 _msg 7 "HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL" #DEBUG
 break
fi

test "${FOOD_LVL//[[:digit:]]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done
}

#Food

###END###
HAVE_FUNCS_FOOD=1
