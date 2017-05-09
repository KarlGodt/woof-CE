#!/bin/ash

_find_traps_bulk_search(){
# ** search to find traps ** #

[ "$SKILL_FIND" = no ] && return 1

local NUM=${NUMBER:-$MAX_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

while :;
do

unset TRAPS

_is 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
 _log "_find_traps_bulk_search:$REPLY"
 _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) SKILL_FIND=no; break 2;;

*'You spot a '*) TRAPS="${TRAPS}
$REPLY"
    ;;

#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
    *'You search the area.'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1

TRAPS=`echo "$TRAPS" | sed '/^$/d'`

if test "$DEBUG"; then
_draw 5 "TRAPS='$TRAPS'"
fi

 test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`
TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_find_traps_bulk_use_skill(){
# ** use_skill find traps to find traps ** #

[ "$SKILL_FIND" = no ] && return 1

local NUM=${NUMBER:-$MAX_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

while :;
do

unset TRAPS

_is 1 1 use_skill find traps

 while :; do read -t 1
 _log "_find_traps_bulk_use_skill:$REPLY"
 _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) SKILL_FIND=no; break 2;;

*'You spot a '*) TRAPS="${TRAPS}
$REPLY"
    ;;

#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
    *'You search the area.'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1

TRAPS=`echo "$TRAPS" | sed '/^$/d'`

if test "$DEBUG"; then
_draw 5 "TRAPS='$TRAPS'"
fi

 test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`

TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_find_traps_bulk_ready_skill(){
# ** ready_skill find traps to find traps ** #

[ "$SKILL_FIND" = no ] && return 1

local NUM=${NUMBER:-$MAX_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_is 1 1 ready_skill "find traps"

while :;
do

unset TRAPS

 _is 1 1 fire ${DIRN:-0}
 _is 1 1 fire_stop

 while :; do read -t 1
 _log "_find_traps_bulk_ready_skill:$REPLY"
 _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) SKILL_FIND=no; break 2;;

*'You spot a '*) TRAPS="${TRAPS}
$REPLY"
    ;;
#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
    *'You search the area.'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1

TRAPS=`echo "$TRAPS" | sed '/^$/d'`

if test "$DEBUG"; then
_draw 5 "TRAPS='$TRAPS'"
fi

 test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`
TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}


_find_traps_single(){
# ** search to find traps ** #
[ "$SKILL_FIND" = no ] && return 1

local NUM=${1:-$MAX_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

while :;
do

_is 1 1 search

 while :; do read -t 1
 _log "_find_traps_single:$REPLY"
 _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) return 112;;
                #SKILL_FIND=no;  break 2;;

    *'You spot a '*) _debug "Found Trap";
    _disarm_traps_single;
    case $? in 112) return 112;; esac
    break;;

   *'You search the area.'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}

_disarm_traps_bulk_use_skill(){
# ** disarm using use_skill disarm traps ** #

[ "$SKILL_DISARM" = no ] && return 1

local NUM CNT
unset NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$MAX_DISARM}

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

CNT=0

while :;
do

_is 1 1 use_skill "disarm traps"
# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
   _log "_disarm_traps_bulk_use_skill:$REPLY"
   _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) SKILL_DISARM=no; break 2;;
#  *'You fail to disarm '*) continue;;
   *'You successfully disarm '*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break;;
   *'In fact, you set it off!'*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break ;;

# src/lib/archetypes
#   *'You detonate '**)
#    NUM=$((NUM-1)); test "$NUM" -gt 0 || break 2;
#    break;;
#  *'RUN!  The timer's ticking!'*)
#  *'You feel depleted of psychic energy!'*)
#  *'You set off '*)


#   *'Your '*)       :;;  # Your monster beats monster
#   *'You killed '*) :;;

  '') CNT=$((CNT+1)); break;;
  esac
 done


test "$CNT" -gt 9 && break
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}

_disarm_traps_bulk_ready_skill(){
# ** disarm using ready_skill disarm traps ** #

[ "$SKILL_DISARM" = no ] && return 1

local NUM CNT
unset NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$MAX_DISARM}

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0


_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_is 1 1 ready_skill "disarm traps"

CNT=0

while :;
do

_is 1 1 fire ${DIRN:-0}
_is 1 1 fire_stop

# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
   _log "_disarm_traps_bulk_ready_skill:$REPLY"
   _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) SKILL_DISARM=no; break 2;;
#  *'You fail to disarm '*) continue;;
   *'You successfully disarm '*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break;;
   *'In fact, you set it off!'*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break ;;

# src/lib/archetypes
#   *'You detonate '**)
#    NUM=$((NUM-1)); test "$NUM" -gt 0 || break 2;
#    break;;
#  *'RUN!  The timer's ticking!'*)
#  *'You feel depleted of psychic energy!'*)
#  *'You set off '*)


#   *'Your '*)       :;;  # Your monster beats monster
#   *'You killed '*) :;;

  '') CNT=$((CNT+1)); break;;
  esac
 done


test "$CNT" -gt 9 && break
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}

_disarm_traps_single(){
# ** disarm by use_skill disarm traps ** #
[ "$SKILL_DISARM" = no ] && return 1

_draw 6 "disarming trap ..."


while :;
do

_is 1 1 use_skill "disarm traps"
# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!
#You detonate

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_disarm_traps_single:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*)  return 112;;
                #SKILL_DISARM=no; break 2;;

   *'You fail to disarm '*)
      break;;  # break 1 tries again to disarm
   *'You successfully disarm '*)
      break ;; # break 1 disarms further if more traps already spotted

   *'In fact, you set it off!'*)
      break ;;

   *'You are pricked '*|*'You are stabbed '*|*'You set off '*)
      break ;; # poisoned / diseased needle, spikes, blades
   *'You feel depleted of psychic energy!'*)
      break ;; # ^harmless^

   #You detonate a Rune of Mass Confusion!
   *'of Mass Confusion!'*|*'of Paralysis'*) # these multiplify
      if [ "$FORCE" ]; then
      break  # at low level better exit with beep
      else return 112
      fi;;

   *'You detonate '*|*"RUN!  The timer's ticking!"*)
      if [ "$FORCE" ]; then
      break  # at low level better exit with beep
      else return 112
      fi;;
   *'A portal opens up, and screaming hordes pour'*)
      if [ "$FORCE" ]; then
      break # always better to exit with beep
      else return 112
      fi;;
  '')
      break 2;;
  esac
 done

sleep 1

done

sleep 1
}


_lockpick_door_use_skill(){
# ** open door with use_skill lockpicking ** #

[ "$SKILL_LOCKPICK" = no ] && return 1

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

c=0; cc=0
NUM=$NUMBER

while :;
do

_is 1 1 use_skill lockpicking

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_lockpick_door_use_skill:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*) SKILL_LOCKPICK=no; break 2;;
  *"You can't pick that lock!"*) break 2;;  # special key
  *'The door has no lock!'*)   break 2;;
  *'There is no lock there.'*) break 2;;
  *' no door'*)                break 2;;
  *'You unlock'*)              break 2;;
  *'You pick the lock.'*)      break 2;;
  *'Your '*)       :;;  # Your monster beats monster
  *'You killed '*) :;;
  *'You find '*)   :;;
  *'You pickup '*) :;;
  *' tasted '*)    :;;  # food tasted good
  *) break;;
  esac
 done

if test "$FOREVER"; then
 cc=$((cc+1))
 test "$cc" = $INF_THRESH && {
  if test "$TOGGLE" = $INF_TOGGLE; then
   $CAST_REST
       TOGGLE=0;
  else TOGGLE=$((TOGGLE+1));
  fi
 }
  $CAST_DEX
  $CAST_PROBE
  _draw 3 "Infinite loop. Use 'scriptkill $0' to abort."; cc=0;

elif test "$NUMBER"; then
NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
c=$((c+1)); test "$c" -lt $MAX_LOCKPICK || break;
fi

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_lockpick_door_ready_skill(){
# ** open door with ready_skill lockpicking ** #

[ "$SKILL_LOCKPICK" = no ] && return 1

local REPLY=

#while :; do unset REPLY
#read -t 1;
#_log "_lockpick_door:pre:$REPLY"
#_debug "$REPLY"
#case $REPLY in '') break;; esac
#sleep 0.1
#done

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

c=0; cc=0
NUM=$NUMBER

_is 1 1 ready_skill lockpicking

#You search the area.
#You stop using the talisman of sorcery *.
#You ready lockpicks of quality *.
#You can now use the skill: lockpicking.
#You feel more agile.
#You stop using the lockpicks of quality *.
#You feel clumsy!
#Readied skill: lockpicking.

while :; do unset REPLY
read -t 1;
_log "_lockpick_door_ready_skill:pre:$REPLY"
_debug "$REPLY"
case $REPLY in '') break;; esac
sleep 0.1
done

while :;
do

 _is 1 1 fire ${DIRN:-0}
 _is 1 1 fire_stop

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_lockpick_door_ready_skill:main:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*) SKILL_LOCKPICK=no; break 2;;
  *"You can't pick that lock!"*) break 2;;  # special key
  *'The door has no lock!'*)   break 2;;
  *'There is no lock there.'*) break 2;;
  *' no door'*)                break 2;;
  *'You unlock'*)              break 2;;
  *'You pick the lock.'*)      break 2;;
  *'Your '*)       :;;  # Your monster beats monster
  *'You killed '*) :;;
  *'You find '*)   :;;
  *'You pickup '*) :;;
  *' tasted '*)    :;;  # food tasted good
  *) break;;
  esac
 done

if test "$FOREVER"; then
 cc=$((cc+1))
 test "$cc" = $INF_THRESH && {
  if test "$TOGGLE" = $INF_TOGGLE; then
   $CAST_REST
       TOGGLE=0;
  else TOGGLE=$((TOGGLE+1));
  fi
 }
  $CAST_DEX
  $CAST_PROBE
  _draw 3 "Infinite loop. Use 'scriptkill $0' to abort."; cc=0;

elif test "$NUMBER"; then
NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
c=$((c+1)); test "$c" -lt $MAX_LOCKPICK || break;
fi

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_open_chest(){
# ** open chest by apply, get all, drop ** #

_draw 6 "apply and get .."


while :;
do

# TODO : food level, hit points


_is 1 1 apply  # handle trap release, being killed
sleep 1


_is 0 0 get all
sleep 1

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO


_is 0 0 drop chest # Nothing to drop.

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_open_chest:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Nothing to drop.'*) break 2;;
   *'Your '*)        :;;  # Your monster beats monster
   *'You killed '*)  :;;
   *'You find '*)    :;;
   *'You pick up '*) :;;
   *' tasted '*)     :;;  # food tasted good
  *) break;;
  esac
 done


_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
sleep 1


_is 1 1 $DIRB
sleep 1

_is 1 1 $DIRF
sleep 1

done
}
