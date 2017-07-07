#!/bin/ash

exec 2>/tmp/cf_script.err

TIMEA=`date +%s`

DRAW_INFO=drawinfo # drawextinfo

DEF_SEARCH=9
DEF_DISARM=9
DEF_LOCKPICK=9

# FOREVER mode
INF_THRESH=30 # threshold to cast dexterity and probe
INF_TOGGLE=4  # threshold to cast restoration (INF_THRESH * INF_TOGGLE)

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

COL_VERB=$COL_TAN
COL_DBG=$COL_GOLD

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

# *** implementing 'help' option *** #
_usage() {

_draw 2 "Script to lockpick doors."
_draw 4 "Syntax:"
_draw 7 "script $0 <direction> <<number>>"
_draw 8 "For example: 'script $0 5 west'"
_draw 5 "will issue 5 times search, disarm and use_skill lockpicking in west."
_draw 4 "Options:"
_draw 5 "-d set debug"
_draw 5 "-D dump defaults"
_draw 4 "-I lockpick forever"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 5 "-v set verbosity"

        exit 0
}

_dump(){

ENV_ALL=`set`

for var in  DRAW_INFO \
 DEF_SEARCH DEF_DISARM DEF_LOCKPICK \
 INF_THRESH INF_TOGGLE \
 LOG_REPLY_FILE \
 TEST_VARIABLE

do

unset MAYBE
MAYBE=`echo "$ENV_ALL" | grep "^${var}=" | tail -n 1 | cut -f 2- -d '='`
MAYBE=${MAYBE:-'(unset)'}
_draw 7 "$var=$MAYBE"

done

exit 0
}

_word_to_number(){

case ${1:-PARAM_1} in

one)            PARAM_1=1;;
two)            PARAM_1=2;;
three)          PARAM_1=3;;
four)           PARAM_1=4;;
five)           PARAM_1=5;;
six)            PARAM_1=6;;
seven)          PARAM_1=7;;
eight)          PARAM_1=8;;
nine)           PARAM_1=9;;
ten)            PARAM_1=10;;
eleven)         PARAM_1=11;;
twelve)         PARAM_1=12;;
thirteen)       PARAM_1=13;;
fourteen)       PARAM_1=14;;
fifteen)        PARAM_1=15;;
sixteen)        PARAM_1=16;;
seventeen)      PARAM_1=17;;
eighteen)       PARAM_1=18;;
nineteen)       PARAM_1=19;;
twenty)         PARAM_1=20;;

esac

}

_number_to_direction(){

case $1 in
[0-8]) DIRN=$1;;
*)    return 1;;
esac

case $1 in

0) DIR=center;;
1) DIR=north;;
2) DIR=northeast;;
3) DIR=east;;
4) DIR=southeast;;
5) DIR=south;;
6) DIR=southwest;;
7) DIR=west;;
8) DIR=northwest;;
*) return 1;;

esac

readonly DIR DIRN;
return $?
}


# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #

_debug "'$#' Parameters: '$*'"

# REM: Parameter Ordering:
#      1) <search/attempts to lockpick> <direction>
#      2) <direction> <search/attempts to lockpick>
#  Since there are usually several doors on one dungeon
#   it is easier to re-run this script with prevkey
#   and change the last parameter.
#   Therefore if there are several numbers as parameters given,
#   assume the last number parameter is direction of door,
#   not attempts to search/lockpick .

# If there is only one parameter and it is a number
# assume it means direction,
# because the direction is mandatory
# since a default as 'center' will never work

if test $# = 1; then

PARAM_1="$1"
_word_to_number "$PARAM_1"

case $PARAM_1 in [0-8])
 _number_to_direction "$PARAM_1"
 shift;;
esac
fi

until test $# = 0;
do

PARAM_1="$1"
_debug "PARAM_1=$PARAM_1 #=$#"
sleep 0.1
shift

case $PARAM_1 in
[0-9]*)

# REM: Parameter Ordering:
#      1) <search/attempts to lockpick> <direction>
#      2) <direction> <search/attempts to lockpick>
#  Since there are usually several doors on one dungeon
#   it is easier to re-run this script with prevkey
#   and change the last parameter.
#   Therefore if there are several numbers as parameters given,
#   assume the last number parameter is direction of door,
#   not attempts to search/lockpick .

__direction_first__(){
if test "$DIR"; then

        NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
           _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
        #   readonly NUMBER
       _debug 2 "NUMBER=$NUMBER"
else
  # Check if more numbers to come and if so,
  # assume direction
  unset p
  for p in "$@"; do
   case $p in [0-9]*)
    _number_to_direction $PARAM_1;;
   esac
  done
fi
}

if test "$NUMBER"; then
       _number_to_direction $PARAM_1;
else
       NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
           _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
        #   readonly NUMBER
       _debug 2 "NUMBER=$NUMBER"
fi

;;

 1|n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
2|ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 3|e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
4|se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 5|s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
6|sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 7|w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
8|nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;

-h|*help|*usage)  _usage;;
-D|*dump)          _dump;;

-d|*debug)      DEBUG=$((DEBUG+1));;
-I|*infinite) FOREVER=$((FOREVER+1));;
-L|*log*)     LOGGING=$((LOGGING+1));;
-v|*verbose)  VERBOSE=$((VERBOSE+1));;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

done

_debug "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'"

# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 _draw 3 "Need direction as parameter."
 exit 1
fi

_find_traps(){
# ** search or use_skill find traps ** #

local NUM=${NUMBER:-$DEF_SEARCH}
NUM=${NUM:-1}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO


while :;
do

TRAPS=0

_verbose "search '$NUM' ..."
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
 _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Unable to find skill '*)   break 2;;

   *'You spot a '*) TRAPS=$((TRAPS+1));;

#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
    *'You search the area'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

test "$TRAPS" && TRAPS_BACKUP="$TRAPS"

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1

test ! "$TRAPS" && test "$TRAPS_BACKUP" && TRAPS="$TRAPS_BACKUP"
#TRAPS=`echo "$TRAPS" | sed '/^$/d'`

if test "$DEBUG"; then
_draw 5 "TRAPS='$TRAPS'"
fi

#test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`
TRAPS_NUM=${TRAPS:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_disarm_traps(){
# ** disarm use_skill disarm traps ** #

local NUM CNT
unset NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$DEF_DISARM}

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

CNT=0

while :;
do

_verbose "$NUM:$CNT:use_skill disarm traps"
_is 1 1 use_skill "disarm traps"
# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
   _log "_disarm_traps:$REPLY"
   _debug $COL_GREEN "REPLY='$REPLY'"

  case $REPLY in

   *'Unable to find skill '*)   break 2;;

#  *'You fail to disarm '*) continue;;
   *'You successfully disarm '*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break;;

   *'In fact, you set it off!'*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break ;;

   #You detonate a Rune of Mass Confusion!
   *of*Confusion*|*'of Paralysis'*) # these multiplify
    break;;

   #You detonate a Rune of Fireball!
   *of*Fireball*|*of*Burning*Hands*|*of*Dragon*Breath*|*Firebreath*)
    break;;
   #You set off a fireball!
   *of*fireball*)  ## rune_fireball.arc
    break;;

   *of*Ball*Lightning*) ## rune_blightning.arc
    break;;

   #You detonate a Rune of Large Icestorm!
   #You detonate a Rune of Icestorm
   *of*Icestorm*)
    break;;

   *"RUN!  The timer's ticking!"*)
    break;;

   *'A portal opens up, and screaming hordes pour'*)
    break;;

   *'transfers power to you'*|*'You feel powerful'*)  ## rune_transfer.arc, rune_sp_restore.arc
    break;;

# src/lib/archetypes
#   *'You detonate '*)

  '') CNT=$((CNT+1)); break;;
  *) _debug "_disarm_traps:Ignoring REPLY";;
  esac
 done

test "$CNT" -gt 9 && break
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}

# TODO : find out if turn possible without casting/firing in DIRN

_turn_dir_ready_skill(){

local lSKILL=${1:-'find traps'}
local lDIRN=${2:-$DIRN}

_is 1 1 ready_skill $lSKILL

_is 1 1 fire $lDIRN

_is 1 1 fire_stop

}

__read_and_handle_door_msgs(){
 local REPLY
 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "lockpicking:$REPLY"
  _debug $COL_GREEN "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*)     break 2;;

  *'You can no longer use the skill:'*) :;;  # lockpicking.
  *'You stop using'*) :;;      # You stop using the talisman of sorcery *.
  *'You ready lockpicks'*) :;; # You ready lockpicks of quality *.
  *'You can now use the skill: lockpicking'*) :;;
  *'You stop using the lockpicks'*) :;;
  *'Readied skill: lockpicking'*)   :;;
  *'You feel'* )      :;; # You feel more agile. You feel clumsy!

  *'The door has no lock'*)      break 2;;
  *'There is no lock there'*)    break 2;;
  *"You can't pick that lock"*)  break 2;;  # special key
  *' no door'*)                  break 2;;
  *'You unlock'*)                break 2;;
  *'You pick the lock'*)         break 2;;

  *'You search'*)   :;;

  *'Your '*)        :;;  # Your monster beats monster
  *' your '*)       :;;
  *'You killed '*)  :;;
  *'You find '*)    :;;
  *'You pick up '*) :;;
  *' tasted '*)     :;;  # food tasted good

  *) break;;
  esac
 done
}

_read_and_handle_door_msgs(){
 local REPLY
 local RV=0

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "lockpicking:$REPLY"
  _debug $COL_GREEN "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*)   RV=2; break;;

  *'You can no longer use the skill:'*) :;;  # lockpicking.
  *'You stop using'*) :;;      # You stop using the talisman of sorcery *.
  *'You ready lockpicks'*) :;; # You ready lockpicks of quality *.
  *'You can now use the skill: lockpicking'*) :;;
  *'You stop using the lockpicks'*) :;;
  *'Readied skill: lockpicking'*)   :;;
  *'You feel'* )      :;; # You feel more agile. You feel clumsy!

  *'The door has no lock'*)      RV=2; break;;
  *'There is no lock there'*)    RV=2; break;;
  *"You can't pick that lock"*)  RV=2; break;;  # special key
  *' no door'*)                  RV=2; break;;
  *'You unlock'*)                RV=2; break;;
  *'You pick the lock'*)         RV=2; break;;

  *'You search'*)   :;;

  *'Your '*)        :;;  # Your monster beats monster
  *' your '*)       :;;
  *'You killed '*)  :;;
  *'You find '*)    :;;
  *'You pick up '*) :;;
  *' tasted '*)     :;;  # food tasted good

  *) break;;
  esac
 done

return ${RV:-1}
}


_lockpick_door(){
# ** open door with use_skill lockpicking ** #

_draw 6 "Lockpicking door ..."

local c=0 cc=0
local NUM=$NUMBER

CNT=1
TIMEB=`/bin/date +%s`

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_turn_dir_ready_skill "lockpicking" $DIRN
_read_and_handle_door_msgs || return 0

while :;
do

CNT=$((CNT+1))

_verbose "$NUM:$c:$cc:use_skill lockpicking"
_is 1 1 use_skill lockpicking
_read_and_handle_door_msgs || break

c=$((c+1)); cc=$((cc+1))
if test "$FOREVER"; then
 test "$cc" = $INF_THRESH && {
  cc=0
  if test "$TOGGLE" = $INF_TOGGLE; then
   #$CAST_REST
       TOGGLE=0;
  else TOGGLE=$((TOGGLE+1));
  fi
  #$CAST_DEX
  #$CAST_PROBE
  _draw 3 "Infinite loop. Use 'scriptkill $0' to abort.";
 }

elif test "$NUMBER"; then
NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
test "$c" -lt $DEF_LOCKPICK || break;
fi

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_find_traps
_disarm_traps && _lockpick_door


# *** Here ends program *** #

TIMEE=`/bin/date +%s`

if test "$TIMEB"; then
TIME_L=$((TIMEE-TIMEB))
TIME_LM=$((TIME_L/60))
TIME_LS=$(( TIME_L - (TIME_LM*60) ))
case $TIME_LS in [0-9]) TIME_LS="0$TIME_LS";; esac
_draw 7 "Loop   took $TIME_LM:$TIME_LS minutes"
fi

TIME_S=$((TIMEE-TIMEA))
TIME_SM=$((TIME_S/60))
TIME_SS=$(( TIME_S - (TIME_SM*60) ))
case $TIME_SS in [0-9]) TIME_SS="0$TIME_SS";; esac
_draw 7 "Script took $TIME_SM:$TIME_SS minutes"

_draw 6 "For '$CNT' attempts to lockpick."

_draw 2 "$0 is finished."
beep -f 700 -l 1000
