#!/bin/ash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

#DEBUG=1   # unset to disable, set to anything to enable
#LOGGING=1 # unset to disable, set to anything to enable

DEF_SEARCH=9
DEF_DISARM=9

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

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
COLOUR=${1:-0}
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

_draw 5 "Script to disarm traps."
_draw 2 "Syntax:"
#_draw 7 "script $0 <direction> <<number>>"
#_draw 5 "For example: 'script $0 5 west'"
#_draw 5 "will issue 5 times search, disarm and use_skill lockpicking in west."
_draw 7 "script $0 <<number>>"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times search and disarm."
_draw 2 "Options:"
_draw 4 "-I search infinite for traps until first spot"
_draw 5 "-d set debug"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 5 "-v set verbosity"
        exit 0
}

_debug 3 "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
           _draw 3 "Only :digit: numbers as optional option allowed."; exit 1; }
           readonly NUMBER
       _debug 2 "NUMBER=$NUMBER"
           ;;
# n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
#ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
# e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
#se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
# s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
#sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
# w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
#nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;

-h|*help|*usage)  _usage;;
-d|*debug)      DEBUG=$((DEBUG+1));;
-L|*log*)     LOGGING=$((LOGGING+1));;
-v|*verb*)    VERBOSE=$((VERBOSE+1));;
-I|*infinite) FOREVER=$((FOREVER+1));;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 0.1
shift
_debug "'$#'"

done

#readonly NUMBER DIR
_debug "NUMBER='$NUMBER'" # DIR='$DIR' DIRN='$DIRN'"


# TODO: check for near doors and direct to them

#if test "$DIR"; then
# :
#else
# _draw 3 "Need direction as parameter."
# exit 1
#fi


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

echo watch $DRAW_INFO

_is 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5
_is 1 1 fire ${DIRN:-0}
sleep 0.5
_is 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_cast_dexterity:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'" #debug

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX CAST_PROBE;;
 *'This ground is unholy!'*)                     unset CAST_REST;;
 *'You grow no more agile.'*)                    unset CAST_DEX;;
 *'You lack the skill '*)                        unset CAST_DEX;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX;;
 *'That spell path is denied to you.'*)          unset CAST_DEX;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

#You grow no more agile.

echo unwatch $DRAW_INFO

}
CAST_REST=_cast_restoration
CAST_PROBE=_cast_probe
CAST_DEX=_cast_dexterity
$CAST_DEX
#_cast_dexterity


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


_find_traps(){
# ** search or use_skill find traps ** #

# This creates the TRAPS variable, which is a list.
# The server has several loops to find traps on all
# direct reachable tiles around the player.
# Each search attempt could possibly find on 9 tiles
# traps and even several of them on each tile.
# It is not necessary, to direct the search
# onto one tile.
# Same is for disarming these traps.

if test "$FOREVER"; then
local NUM=FOREVER
else
local NUM=${NUMBER:-$DEF_SEARCH}
fi

SEARCH_CNT=0

_draw 6 "find traps '$NUM' times.."


echo watch $DRAW_INFO

local c=0

while :;
do

unset TRAPS

_is 1 1 search
SEARCH_CNT=$((SEARCH_CNT+1))

#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
  _log "search:$REPLY"
  _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Unable to find skill '*)   break 2;;

#   *'You spot a '*) TRAPS="${TRAPS}
#$REPLY"; break;;
   *'You spot a '*) TRAPS="${TRAPS}
$REPLY";
#break;;
    ;;

#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
    *'You search the area.'*) :;;
  '') break;;
  esac

  sleep 0.1
  unset REPLY
 done

test "$TRAPS" && TRAPS_BACKUP="$TRAPS"

if test "$FOREVER"; then
 if test "$TRAPS_BACKUP"; then
 ##test "$NUMBER" && { NUM=$((NUM-1)); test "$NUM" -le 0 && break; } || { c=$((c+1)); test "$c" = $DEF_SEARCH && break; }
 #NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
 break
 else :
 fi
else
 NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
fi

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1

test ! "$TRAPS" && test "$TRAPS_BACKUP" && TRAPS="$TRAPS_BACKUP"
TRAPS=`echo "$TRAPS" | sed '/^$/d'`
#TRAPS=`echo "$TRAPS" | uniq`
#TRAPS_NUM=`echo -n "$TRAPS" | wc -l`

if test "$DEBUG"; then
#_draw 5 "TRAPS='$TRAPS'"
#_draw 6 "`echo "$TRAPS" | uniq`"
_draw 5 "TRAPS='$TRAPS'"
#_draw 6 "`echo "$TRAPS" | uniq`"
fi

#test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | uniq | wc -l`
 test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`

TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_find_traps

# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


_disarm_traps(){
# ** disarm use_skill disarm traps ** #
# REM: For now, it ignores handling of triggered traps.
# Usuallay, there is only one trap each tile or object,
# but at few occasions, there are more than one in a chest or door.
# Especially Confusion and Paralyses traps could be handled,
# since they tend to multiplify and disturbing the correct
# commit of commands or reading of DRAW_INFO .
# NOTE: cf_open_chest.sh handles it atm.

sleep 1

local NUM c

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$DEF_DISARM}

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0

TIMEB=`/bin/date +%s`

echo watch $DRAW_INFO

c=0

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
   _log "disarm traps:$REPLY"
   _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Unable to find skill '*)   break 2;;
#  *'You fail to disarm '*) continue;;
   *'In fact, you set it off!'*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 || break 2;
    break ;;
   *'You successfully disarm '*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 || break 2;
    break;;
#   *'Your '*)       :;;  # Your monster beats monster
#   *'You killed '*) :;;
  '') break;;
  esac
 done

#NUM=$((NUM-1)); test "$NUM" -gt 0 || break;

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1
}

_disarm_traps

# *** Here ends program *** #
_count_time(){

test "$*" || return 3

TIMEE=`/bin/date +%s` || return 4

TIMEX=$((TIMEE - $*)) || return 5
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

_count_time $TIMEB && _draw 7 "Looped for $TIMEM:$TIMES minutes"
_count_time $TIMEA && _draw 7 "Script ran $TIMEM:$TIMES minutes"

if test "$FOREVER"; then
test "${SEARCH_CNT:-0}" -gt 0 && _draw 5 "You searched $SEARCH_CNT times for traps"
fi

_draw 2 "$0 is finished."
beep -f 700 -l 1000


# ***
# ***
# *** diff marker 8
