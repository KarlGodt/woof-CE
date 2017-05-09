#!/bin/ash

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

DRAW_INFO=drawinfo # drawextinfo

DEBUG=1   # unset to disable, set to anything to enable
LOGGING=1 # unset to disable, set to anything to enable

MAX_SEARCH=9
MAX_DISARM=9

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

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #

# *** implementing 'help' option *** #
_usage() {

echo draw 5 "Script to lockpick doors."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <direction> <<number>>"
echo draw 5 "For example: 'script $0 5 west'"
echo draw 5 "will issue 5 times search, disarm and use_skill lockpicking in west."

        exit 0
}

_debug 3 "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
           echo draw 3 "Only :digit: numbers as optional option allowed."; exit 1; }
           readonly NUMBER
       _debug 2 "NUMBER=$NUMBER"
           ;;
 n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;
-h|*help|*usage)  _usage;;
'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 0.1
shift
_debug "'$#'"

done

#readonly NUMBER DIR
echo draw 3 "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'"


# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 echo draw 3 "Need direction as parameter."
 exit 1
fi

_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

echo watch $DRAW_INFO

echo issue 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
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




_find_traps(){
# ** search or use_skill find traps ** #

local NUM=${NUMBER:-$MAX_SEARCH}

echo draw 6 "find traps '$NUM' times.."


echo watch $DRAW_INFO

local c=0

while :;
do

unset TRAPS

echo issue 1 1 search
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


#test "$NUMBER" && { NUM=$((NUM-1)); test "$NUM" -le 0 && break; } || { c=$((c+1)); test "$c" = $MAX_SEARCH && break; }
NUM=$((NUM-1)); test "$NUM" -gt 0 || break;


sleep 1

done

echo unwatch $DRAW_INFO

sleep 1

TRAPS=`echo "$TRAPS" | sed '/^$/d'`
#TRAPS=`echo "$TRAPS" | uniq`
#TRAPS_NUM=`echo -n "$TRAPS" | wc -l`

if test "$DEBUG"; then
#echo draw 5 "TRAPS='$TRAPS'"
#echo draw 6 "`echo "$TRAPS" | uniq`"
_draw 5 "TRAPS='$TRAPS'"
#_draw 6 "`echo "$TRAPS" | uniq`"
fi

#test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | uniq | wc -l`
 test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`

TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_find_traps


_disarm_traps(){
# ** disarm use_skill disarm traps ** #

sleep 1

local NUM c

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$MAX_DISARM}

echo draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0


echo watch $DRAW_INFO

c=0

while :;
do

echo issue 1 1 use_skill "disarm traps"
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
echo draw 2 "$0 is finished."
beep -f 700 -l 1000
