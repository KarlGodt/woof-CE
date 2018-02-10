#!/bin/ash

[ "$HAVE_FUNCS_ORATORY" ] && return 0

_sing_and_orate_around(){
_debug "_sing_and_orate_around:$*"

while :;
do

#_sleep
one=$((one+1))

[ "$DIRECTION_OPT" ] || _set_next_direction

_calm_down_monster_ready_skill
case $? in
 0) _orate_to_monster_ready_skill
  case $? in
  0) :;;
  *) _kill_monster;;
  esac
 ;;
 *) :;;
esac

_draw 2 "You calmed ${CALMS:-0} and convinced ${FOLLOWS:-0} monsters."

case $NUMBER in $one) break;; esac
case $ORATORY_ATTEMPTS in $ORATORY_ATTEMPTS_DONE) break;; esac
case $SINGING_ATTEMPTS in $SINGING_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp_and_return_home $HP
fi

_say_script_time
#_sleep
#_set_next_direction

done
}

_calm_down_monster_ready_skill(){
_debug "_calm_down_monster_ready_skill:$*"

# Return Possibilities :
# 0 : success calming down, go on with orate
# 1 : no success calming down
#     -> kill the monster and try next in DIRN
#     -> turn to next monster
# 3 : Monster does not respond
#     -> try again
#     -> it is already calmed, go on with orate
#     -> kill monster and try next in DIRN
#     -> turn to next monster

local lRV=

_watch $DRAWINFO
 while :;
 do

  _is 1 1 fire_stop
  _is 1 1 ready_skill singing
  _empty_message_stream

  _is 1 1 fire $DIRN
  _is 1 1 fire_stop
  SINGING_ATTEMPTS_DONE=$((SINGING_ATTEMPTS_DONE+1))

  while :; do unset REPLY
  read -t $TMOUT
  _log "_calm_down_monster_ready_skill:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  # EMPTY response by !FLAG_MONSTER
  # FLAG_NO_STEAL, FLAG_SPLITTING, FLAG_HITBACK,
  # FLAG_UNDEAD, FLAG_UNAGGRESSIVE, FLAG_FRIENDLY
  '') break 2;; #!=PLAYER
  *'You sing'*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  *) :;;
  esac

  sleep 0.01
  done

  while :; do unset REPLY
  read -t $TMOUT
  _log "_calm_down_monster_ready_skill:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  '') lRV=0; break 2;;
  *'You calm down the '*) CALMS=$((CALMS+1)); lRV=0;;
  *"Too bad the "*"isn't listening!"*) _kill_monster; break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  *) :;;
  esac

  sleep 0.01
  done

 sleep 0.1
 done

_unwatch $DRAWINFO
_draw 5 "With ${SINGING_ATTEMPTS_DONE:-0} singings you calmed down ${CALMS:-0} monsters."
#_sleep
_debug 3 "lRV=$lRV"
return ${lRV:-1}
}

_orate_to_monster_ready_skill(){
_debug "_orate_to_monster_ready_skill:$*"

local lRV=

 while :;
 do

  _watch $DRAWINFO
  _is 1 1 fire_stop
  _is 1 1 ready_skill oratory
  _empty_message_stream   # todo : check if skill available

  _is 1 1 fire $DIRN
  _is 1 1 fire_stop
  ORATORY_ATTEMPTS_DONE=$((ORATORY_ATTEMPTS_DONE+1))

  while :; do unset REPLY
  read -t $TMOUT
  _log "_orate_to_monster_ready_skill:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  #PLAYER, more, head, msg
  '') lRV=0; break 2;; # monster does not respond at all, try next
  *'There is nothing to orate to.'*) lRV=0; break 2;; # next monster #!tmp
  *'You orate to the '*) break 1;; #tmp
  *scripttell*break*)    break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  *) :;;
  esac

  sleep 0.01
  done

  while :; do unset REPLY
  read -t $TMOUT
  _log "_orate_to_monster_ready_skill:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  #!FLAG_UNAGGRESSIVE && !FLAG_FRIENDLY
  *'Too bad '*) _draw 3 "Catched Too bad oratory"; break 2;; # try again singing the kobold isn't listening!
  #FLAG_FRIENDLY && PETMOVE && get_owner(tmp)==pl
  *'Your follower loves '*)          lRV=0; break 2;; # next creature or exit
  #FLAG_FRIENDLY && PETMOVE && (skill->level > tmp->level)
  *"You convince the "*" to follow you instead!"*)   FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  *'You convince the '*' to become your follower.'*) FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  #/* Charm failed. Creature may be angry now */ skill < random_roll
  *"Your speech angers the "*) _draw 3 "Catched Anger oratory";   break 2;;
  #/* can't steal from other player */, /* Charm failed. Creature may not be angry now */
  '') break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  *) :;;
  esac

  sleep 0.01
  done

 sleep 0.1
 done

_unwatch $DRAWINFO
_draw 5 "With ${ORATORY_ATTEMPTS_DONE:-0} oratings you conceived ${FOLLOWS:-0} followers."
#_sleep
_debug 3 "lRV=$lRV"
return ${lRV:-1}
}


###END###
HAVE_FUNCS_ORATORY=1
