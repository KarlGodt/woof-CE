#!/bin/ash

exec 2>/tmp/cf_script.err

DRAW_INFO=drawinfo # drawextinfo

MAX_SEARCH=9
MAX_DISARM=9

LOG_REPLY_FILE=/tmp/cf_script.rpl

rm -f "$LOG_REPLY_FILE"

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #

# *** implementing 'help' option *** #
_usage() {

echo draw 5 "Script to lockpick doors."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <direction> [number]"
echo draw 5 "For example: 'script $0 5 west'"
echo draw 5 "will issue 5 times search, disarm and use_skill lockpicking in west."

        exit 0
}

echo draw 3 "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
	   echo draw 3 "Only :digit: numbers as first option allowed."; exit 1; }
	   readonly NUMBER
       #echo draw 2 "NUMBER=$NUMBER"
	   ;;
 n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;
*help)  _usage;;
'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 1
shift
#echo draw "'$#'"

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

# ** cast DEXTERITY ** #

echo issue 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5


_find_traps(){
# ** search or use_skill find traps ** #

local NUM=${NUMBER:-$MAX_SEARCH}

echo draw 6 "find traps '$NUM' times.."


echo watch $DRAW_INFO

local c=0

while :;
do
:

echo issue 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
  case $REPLY in
   *'Unable to find skill '*)   break 2;;
   *'You spot a '*) TRAPS="${TRAPS}
$REPLY"; break;;
#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
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
test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | uniq | wc -l`
TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_find_traps


_disarm_traps(){
# ** disarm use_skill disarm traps ** #

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
:

echo issue 1 1 use_skill "disarm traps"
# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  case $REPLY in
   *'Unable to find skill '*)   break 2;;
#  *'You fail to disarm '*) continue;;
   *'You successfully disarm '*) break;;
#   *'Your '*)       :;;  # Your monster beats monster
#   *'You killed '*) :;;
  '') break;;
  esac
 done

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1
}

_disarm_traps

# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep
