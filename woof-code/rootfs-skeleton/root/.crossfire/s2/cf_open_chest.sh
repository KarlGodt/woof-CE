#!/bin/ash

exec 2>/tmp/cf_script.err

#DEBUG=1   # unset to disable, set to anything to enable
#LOGGING=1 # unset to disable, set to anything to enable

DRAW_INFO=drawinfo # drawextinfo

MAX_SEARCH=9
MAX_DISARM=9

DIRB=west # need to leave pile of chests to be able to apply
case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

# beeping
BEEP_DO=1
BEEP_LENGTH=500
BEEP_FREQ=700

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}

# colours
COL_BLACK=0
COL_WHITE=1
COL_NAVY=2
COL_RED=3
COL_ORANGE=4
COL_BLUE=5
COL_DORANGE=6
COL_GREEN=7
COL_LGREEN=8
COL_GRAY=9
COL_BROWN=10
COL_GOLD=11
COL_TAN=12

_draw(){
test "$*" || return
local COLOUR=${1:-0}
shift
while read -r line
do
test "$line" || continue
echo draw $COLOUR "$line"
sleep 0.1
done <<EoI
`echo "$@"`
EoI
}

_verbose(){
[ "$VERBOSE" ] || return 0
_draw ${COL_VERB:-12} "$*"
}

_debug(){
[ "$DEBUG" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOG_REPLY_FILE"
}

_is(){
_verbose "$*"
echo issue "$*"
sleep 0.2
}

# *** Here begins program *** #
_draw 2 "$0 is started.."


# *** Check for parameters *** #


# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to open chests."
_draw 5 "Syntax:"
_draw 5 "script $0 [number]"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times search, disarm, apply and get."
_draw 4 "Options:"
_draw 5 "-d set debug"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 5 "-v set verbosity"

        exit 0
}


until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
	   _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
	   readonly NUMBER
           _debug "NUMBER=$NUMBER"
	   ;;
*help|*usage)  _usage;;

--*) case $PARAM_1 in
     *debug) DEBUG=$((DEBUG+1));;
     *help)  _usage;;
     *logging) LOGGING=$((LOGGING+1));;
     *verbose) VERBOSE=$((VERBOSE+1));;
     *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
;;

-*) OPTS=`printf '%s' $PARAM_1 | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      d) DEBUG=$((DEBUG+1));;
      h) _usage;;
      L) LOGGING=$((LOGGING+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
   done
;;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

sleep 1
shift
done

# TODO : check if available space to walk in DIRB

# ** set pickup  0 and drop chests


_is 0 0 pickup 0
sleep 1

_is 0 0 drop chest
sleep 1

_is 1 1 $DIRB
sleep 1

_is 1 1 $DIRF
sleep 1

# TODO : check if on chest


_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_draw 5 "casting dexterity.."


_is 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5

_is 1 1 fire center   # better 0, 1 (north) ..clockwise.. 8 (northwest)
sleep 0.5

_is 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_cast_dexterity:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX;;
 *'This ground is unholy!'*)                     unset CAST_REST;;
 *'You grow no more agile.'*)                    unset CAST_DEX;;
 *'You lack the skill '*)                        unset CAST_DEX;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX;;
 *'That spell path is denied to you.'*)          unset CAST_DEX;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 '') break;;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}
CAST_DEX=_cast_dexterity
$CAST_DEX

_disarm_traps(){
# ** disarm use_skill disarm traps ** #
[ "$SKILL_DISARM" = no ] && return 1

_draw 6 "disarming trap ..."

local c=0 CNT=0

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
  _log "_disarm_traps:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*)  SKILL_DISARM=no; break 2;;
#  *'You fail to disarm '*) continue;;

   *'You successfully disarm '*)
      break ;;

   *'In fact, you set it off!'*)
      break ;;
   *'You detonate '*|*'You are pricked '*|*'You are stabbed '*|*'You set off '*|*"RUN!  The timer's ticking!"*|*'You feel depleted of psychic energy!'*)
      break ;;
   *'A portal opens up, and screaming hordes pour'*)
      break;; # better exit with beep

  '')
      break 2;;
  esac
 done

sleep 1

done

sleep 1
}

_find_traps(){
# ** search or use_skill find traps ** #
[ "$SKILL_FIND" = no ] && return 1

local NUM=${1:-$MAX_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

local c=0

while :;
do

_is 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
 _log "_find_traps:$REPLY"
 _debug "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Unable to find skill '*) SKILL_FIND=no;  break 2;;

#   *'You spot a '*) TRAPS="${TRAPS}
#$REPLY"; break;;
    *'You spot a '*) _debug "Found Trap";
    _disarm_traps;
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

_find_traps $NUMBER


__disarm_traps(){
# ** disarm use_skill disarm traps ** #

local NUM CNT
unset NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$
_debug NUM=$NUM
NUM=${NUM:-$MAX_DISARM}
_debug NUM=$NUM

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
#You detonate

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
   _log "__disarm_traps:$REPLY"
   _debug "REPLY='$REPLY'"
  _debug NUM=$NUM
  case $REPLY in
   *'Unable to find skill '*)   break 2;;
#  *'You fail to disarm '*) continue;;

   *'You successfully disarm '*)
      NUM=$((NUM-1));
      test "$NUM" -gt 0 || break 2;
      break;;

   *'In fact, you set it off!'*)
      NUM=$((NUM-1));
      test "$NUM" -gt 0 || break 2;
      break ;;
   *'You detonate '*|*'You are pricked '*|*'You are stabbed '*|*'You set off '*|*"RUN!  The timer's ticking!"*|*'You feel depleted of psychic energy!'*)
      NUM=$((NUM-1));
      test "$NUM" -gt 0 || break 2;
      break;;
   *'A portal opens up, and screaming hordes pour'*)
      NUM=$((NUM-1));
      test "$NUM" -gt 0 || break 2;
      break;; # better exit with beep

  '') CNT=$((CNT+1)); break;;
  esac
 done

_debug NUM=$NUM
test "$CNT" -gt 9 && break
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}


# ** open chest, apply, get ** #

_draw 6 "apply and get .."

c=0
NUM=$NUMBER

while :;
do

# TODO : food level, hit points


_is 1 1 apply  # handle trap release, being killed
sleep 1


_is 1 1 get all

sleep 1

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO


_is 0 0 drop chest # Nothing to drop.

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "drop chest:$REPLY"
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


# *** Here ends program *** #
_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

_draw 2 "$0 is finished."
_beep
