#!/bin/ash

[ "$HAVE_FUNCS_FIGHT" ] && return 0

_kill_monster_move(){
_debug "_kill_monster_move:$*"
_log   "_kill_monster_move:$*"

local lATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

# TODO:
#*'You withhold your attack'*)  _set_next_direction; break 1;;
#*'You avoid attacking '*)      _set_next_direction; break 1;;

for i in `seq 1 1 ${lATTACKS:-1}`; do
_is 1 1 $DIRECTION
done
_empty_message_stream
}

_kill_monster_fire(){
_debug "_kill_monster_fire:$*"
_log   "_kill_monster_fire:$*"

local lATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

# TODO:
#*'You withhold your attack'*)  _set_next_direction; break 1;;
#*'You avoid attacking '*)      _set_next_direction; break 1;;

for i in `seq 1 1 ${lATTACKS:-1}`; do
_is 1 1 fire $DIRN
_is 1 1 fire_stop
done
_empty_message_stream
}


_brace(){
_debug "_brace:$*"
_log   "_brace:$*"

_watch $DRAWINFO
while :
do
_is 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log "_brace:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 2;;
 *'Not braced.'*)     break 1;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch $DRAWINFO
_empty_message_stream
}

_unbrace(){
_debug "_unbrace:$*"
_log   "_unbrace:$*"

_watch $DRAWINFO
while :
do
_is 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log "_unbrace:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 1;;
 *'Not braced.'*)     break 2;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch $DRAWINFO
_empty_message_stream
}

_melee_around(){
_debug "_melee_around:$*"
_log   "_melee_around:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction $DIRECTION_OPT || _set_next_direction

_kill_monster_fire $ATTACKS_SPOT

case $NUMBER in $one) break;; esac
#case $MELEE_ATTEMPTS in $MELEE_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp
_check_hp_and_return_home $HP
_check_skill_available "$SKILL_MELEE" || return 1
fi

_say_script_time

done
}


_karate_around(){
_debug "_karate_around:$*"
_log   "_karate_around:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction $DIRECTION_OPT || _set_next_direction

_kill_monster_fire $ATTACKS_SPOT

case $NUMBER in $one) break;; esac
#case $KARATE_ATTEMPTS in $KARATE_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp
_check_hp_and_return_home $HP
_check_skill_available "karate" || return 1
fi

_say_script_time

done
}

_claw_around(){
_debug "_claw_around:$*"
_log   "_claw_around:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction $DIRECTION_OPT || _set_next_direction

_kill_monster_fire $ATTACKS_SPOT

case $NUMBER in $one) break;; esac
#case $CLAW_ATTEMPTS in $CLAW_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp
_check_hp_and_return_home $HP
_check_skill_available "clawing" || return 1
fi

_say_script_time

done
}

_flame_touch_around(){
_debug "_flame_touch_around:$*"
_log   "_flame_touch_around:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction $DIRECTION_OPT || _set_next_direction

_kill_monster_fire $ATTACKS_SPOT

case $NUMBER in $one) break;; esac
#case $FLAME_TOUCH_ATTEMPTS in $FLAME_TOUCH_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp
_check_hp_and_return_home $HP
_check_skill_available "flame touch" || return 1
fi

_say_script_time

done
}

_punch_around(){
_debug "_punch_around:$*"
_log   "_punch_around:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction $DIRECTION_OPT || _set_next_direction

_kill_monster_fire $ATTACKS_SPOT

case $NUMBER in $one) break;; esac
#case $PUNCH_ATTEMPTS in $PUNCH_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp
_check_hp_and_return_home $HP
_check_skill_available "punching" || return 1
fi

_say_script_time

done
}


###END###
HAVE_FUNCS_FIGHT=1
