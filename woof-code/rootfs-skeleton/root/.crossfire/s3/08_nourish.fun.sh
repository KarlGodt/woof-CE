#!/bin/ash


#Food

_check_mana_for_create_food(){  # called from _cast_create_food_and_eat()

local REPLY=''

_watch
_is 1 0 cast create # check if create food is in spell inventory

while :;
do

read -t $TMOUT
_log "_check_mana_for_create_food:$REPLY"
_debug "$REPLY"

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
unset REPLY
done

_unwatch
return 1
}

_cast_create_food_and_eat(){  # called by _check_food_level()
# problem with nested loops and _watch / _unwatch

local lEAT_FOOD REPLY1 REPLY2 REPLY3 REPLY4 BUNGLE

test "$EAT_FOOD" && lEAT_FOOD="$EAT_FOOD"
test "$*" && lEAT_FOOD="$@"
lEAT_FOOD=${lEAT_FOOD:-$FOOD_DEF}
lEAT_FOOD=${lEAT_FOOD:-food}

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

_is 1 1 pickup 0
_empty_message_stream

#_watch
# TODO : Check MANA
_is 1 1 cast create food $lEAT_FOOD
_empty_message_stream

_is 1 1 fire_stop
#sleep 0.1

while :;
do
#_is 1 1 fire_stop
#sleep 0.1

 while :;
 do  # needs _watch / _unwatch
 _check_mana_for_create_food && break || { sleep 10; continue; }
 done

#_unwatch
_watch
sleep 0.1
_is 1 1 fire 0    ## Todo handle bungling the spell AND low mana

unset BUNGLE
sleep 0.1
read -t $TMOUT BUNGLE
_log "$BUNGLE"
_debug "$BUNGLE"

test "`echo "$BUNGLE" | grep -E -i 'bungle|fumble|not enough'`" || break
_is 1 1 fire_stop
sleep 10
done

_is 1 1 fire_stop
_unwatch
sleep 1
_empty_message_stream


_is 1 1 apply ## Todo check if food is there on tile
_empty_message_stream

#+++2017-03-20 pickup any leftovers
#_is 1 1 get  ## gets 1 of topmost item
_is 0 1 take $lEAT_FOOD
#_is 0 1 get all
#_is 0 1 get
#_is 99 1 get  ## TODO: would get cauldron if only one $lEAT_FOOD

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water
_empty_message_stream

#_unwatch
}

_apply_horn_of_plenty_and_eat(){
local REPLY BUNGLE

_watch
read -t $TMOUT
unset REPLY
_is 1 1 apply -a Horn of Plenty
#+++2017-03-20 handle failure applying
while :;
do
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"
case $REPLY in
*apply*) break;;
*) _exit 1;;
esac
unset REPLY
sleep 1
done

_unwatch
sleep 1
unset REPLY
_watch
read -t $TMOUT

#+++2017-03-20 check if available
# check if topmost item has changed afterwards

while :; #+++2017-03-20 handle bungle AND time to charge
do
_is 1 1 fire 0 ## Todo handle bungling AND time to charge

unset BUNGLE
sleep 0.1
read -t $TMOUT BUNGLE
_log "$BUNGLE"
_debug "$BUNGLE"
test "`echo "$BUNGLE" | grep -E -i 'bungle|fumble|needs more time to charge'`" || break
sleep 0.1
unset BUNGLE
sleep 1
done

_is 1 1 fire_stop
sleep 1
unset REPLY
read -t $TMOUT

#+++2017-03-20 check if available
# check if topmost item has changed afterwards

# check known food items
echo request items on

while :;
do
unset REPLY
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"
case $REPLY in
*cursed*|*poisoned*) _exit 1;;
*apple*|*food*|*haggis*|*waybread*) :;;
*) _exit 1;;
esac
break

done

_is 1 1 apply ## Todo check if food is there on tile AND if not poisoned/cursed
unset REPLY
read -t $TMOUT

#+++2017-03-20 pickup any leftovers
#_is 1 1 get  ##gets 1 of topmost item
#_is 0 1 take
#_is 0 1 get all
#_is 0 1 get
#_is 99 1 get

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water
#_empty_message_stream
_unwatch
}


_eat_food(){

local REPLY=

test "$*" && EAT_FOOD="$@"
EAT_FOOD=${EAT_FOOD:-waybread}

#_check_food_inventory ## Todo: check if food is in INV

_watch
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"
_is 1 1 apply $EAT_FOOD

unset REPLY
_unwatch
read -t $TMOUT

}

_check_food_level(){

fc=$((fc+1))
test "$fc" -lt $COUNT_CHECK_FOOD && return
fc=0

test "$*" && MIN_FOOD_LEVEL="$@"
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-$MIN_FOOD_LEVEL_DEF}
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-200}

local FOOD_LVL=''
local REPLY oF
#local Re  Stat  Hp  HP  MHP  SP  MSP  GR  MGR
 local Re  Stat  Hp      MHP      MSP  GR  MGR  # HP and SP global: cf_prayXtimes.sh, _check_mana_for_create_food()
 local Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2

read -t $TMOUT  # empty the stream of messages

_watch
sleep 1
echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset FOOD_LVL
read -t $TMOUT Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
test "$Re" = request || continue

test "$FOOD_LVL" || break
#test "${FOOD_LVL//[[:digit:]]/}" && break
test "${FOOD_LVL//[0-9]/}" && break

_debug HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL #DEBUG

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food
 _cast_create_food_and_eat $EAT_FOOD

 sleep 1
 _empty_message_stream
 sleep 1
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 #sleep 0.1
 sleep 1
 read -t $TMOUT Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
 _debug HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL #DEBUG

 #return $?
 break
fi

#test "${FOOD_LVL//[[:digit:]]/}" || break
test "${FOOD_LVL//[0-9]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done

_unwatch
}

#Food

_watch_food(){  # cast by _do_loop if _conter_for_checks returns 0
                # cast by _regenerate_spell_points and breaks it if returns 0
# *** controlling function : Probably not needed for high-level characters with
# *   high armour class , resistances and high sustainance level
# *   Sends stat hp request
# *   Applies foood if neccessary
# *   Does switch to _do_emergency_recall if necessary
# *   Does switch to _watch_wizard_spellpoints
# *   TODO : implement a counter to call it every Yth time, not every time

local r s h HP HP_MAX FOOD_STAT

echo request stat hp
read -t 1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_STAT

 _debug "_watch_food:FOOD_STAT=$FOOD_STAT HP=$HP SP=$SP"

 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
     _is 0 0 apply $FOOD
   sleep 1
 fi

 if test $HP -lt $((HP_MAX/5)); then  #
  _do_emergency_recall
 fi

 if test "$PRAY_DO"; then
  _watch_cleric_gracepoints
 else
  _watch_wizard_spellpoints
 fi

return $?
}
