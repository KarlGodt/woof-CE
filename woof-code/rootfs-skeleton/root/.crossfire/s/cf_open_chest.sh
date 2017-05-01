#!/bin/ash

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

exec 2>/tmp/cf_script.err

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


# *** Here begins program *** #
echo draw 2 "$0 is started.."


# *** Check for parameters *** #


# *** implementing 'help' option *** #
_usage() {

echo draw 5 "Script to open chests."
echo draw 5 "Syntax:"
echo draw 5 "script $0 [number]"
echo draw 5 "For example: 'script $0 5'"
echo draw 5 "will issue 5 times search, disarm, apply and get."

        exit 0
}

# *** testing parameters for validity *** #
#PARAM_1test="${PARAM_1//[[:digit:]]/}"
#test "$PARAM_1test" && {
#echo draw 3 "Only :digit: numbers as first option allowed."
#        exit 1 #exit if other input than letters
#        }

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
	   echo draw 3 "Only :digit: numbers as first option allowed."; exit 1; }
	   readonly NUMBER
       #echo draw 2 "NUMBER=$NUMBER"
	   ;;
*help)  _usage;;
'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

sleep 1
shift
done


# ** set pickup  0 and drop chests

echo issue 0 0 pickup 0
sleep 1
echo issue 0 0 drop chest
sleep 1
echo issue 1 1 $DIRB
sleep 1
echo issue 1 1 $DIRF
sleep 1

# TODO : check if on chest


# ** cast DEXTERITY ** #

echo draw 5 "casting dexterity.."

echo issue 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire center   # better 0, 1 (north) ..clockwise.. 8 (northwest)
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5


_find_traps(){
# ** search or use_skill find traps ** #

local TRAPS=''

local NUM=${NUMBER:-$MAX_SEARCH}

echo draw 6 "find traps '$NUM' times.."


echo watch $DRAW_INFO

while :;
do

echo issue 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!
unset TRAPS

 while :; do read -t 1
  case $REPLY in
   *'Unable to find skill '*)   break 2;;
   *'You spot a '*) TRAPS="${TRAPS}
$REPLY";;
#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done


NUM=$((NUM-1)); test "$NUM" -gt 0 || break;

sleep 1

done


echo unwatch $DRAW_INFO

sleep 1

TRAPS=`echo "$TRAPS" | sed '/^$/d'`
#TRAPS=`echo "$TRAPS" | uniq`
#TRAPS_NUM=`echo -n "$TRAPS" | wc -l` # at one trap, it would be 0 using echo -n
test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`
TRAPS_NUM=${TRAPS_NUM:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_find_traps


_disarm_traps(){
# ** disarm use_skill disarm traps ** #

local NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$MAX_DISARM}

echo draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0


echo watch $DRAW_INFO

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
  case $REPLY in
   *'Unable to find skill '*)   break 2;;
#  *'You fail to disarm '*) continue;;

   *'You successfully disarm '*) NUM=$((NUM-1)); break;;
   *'you set it off'*)   :;;
   *'You set off '*)     NUM=$((NUM-1)); break;;
   *'You detonate '*)    NUM=$((NUM-1)); break;;
   *'You are stabbed '*) NUM=$((NUM-1)); break;;
   *'You are pricked '*) NUM=$((NUM-1)); break;;

#   *'Your '*)       :;;  # Your monster beats monster
#   *'You killed '*) :;;
  '') break;;
  esac
 done

test "$NUM" -gt 0 || break;

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1
}

_disarm_traps

# ** open chest apply and get ** #

echo draw 6 "apply and get .."

c=0
NUM=$NUMBER

while :;
do

# TODO : food level, hit points

echo issue 1 1 apply  # handle trap release, being killed
sleep 1

echo issue 1 1 get all

sleep 1
echo watch $DRAW_INFO

echo issue 0 0 drop chest # Nothing to drop.

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  echo "$REPLY" >>"$LOG_REPLY_FILE"
  case $REPLY in
   *'Nothing to drop.'*) break 2;;
   *'Your '*)       :;;  # Your monster beats monster
   *'You killed '*) :;;
   *'You find '*trap*)   :;;
   *'You find '*Rune*)   :;;
   *'You find '*needle*) :;;
   *'You find '*Spikes*) :;;
   *'you set it off'*)   :;;
   *'You set off '*)     :;;
   # traps that multiply
   *'You detonate '*Paralysis*)      break 2;;
   *'You detonate '*Mass*Confusion*) break 2;;
   # traps that are too dangerous to continue
   *'You detonate '*Summon*)         break 2;;
   *'You detonate '*Ball*Lightning*) break 2;;

   *'You detonate '*)    :;;
   *'You are stabbed '*) :;;
   *'You are pricked '*) :;;
   *'You find '*)   :;;
   *'You pickup '*) :;;
   *' tasted '*)    :;;  # food tasted good
  *) break;;
  esac
 done

echo unwatch $DRAW_INFO
sleep 1

echo issue 1 1 $DIRB
sleep 1
echo issue 1 1 $DIRF
sleep 1

done


# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep
