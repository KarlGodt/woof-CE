#!/bin/bash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script_err.log

export PATH=/bin:/usr/bin

TIMEA=`/bin/date +%s`

#DEBUG=1
#LOGGING=1

TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
LOG_FILE="$TMP_DIR"/cf_inventory.$$.log

DIRECTION_DEFAULT=east
#NUMBER_DEFAULT=10       # unused since possible to loop forever
ITEM_DEFAULT='horn of plenty'
COMMAND=fire
COMMAND_PAUSE_DEFAULT=7  # seconds; horn need 7, rod 2 to recharge
COMMAND_STOP=fire_stop
# player needs to eat sometimes ...
FOOD_STAT_MIN=300
FOOD=waybread
# player could be low on HP ...
ITEM_RECALL='rod of word of recall' #  [wand], staff, scroll, rod of word of recall

DRAW_INFO=drawinfo # drawinfo (older servers) OR drawextinfo (newer servers)

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}


CHECK_DO=1

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

_debug(){
[ "$DEBUG" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_debugx(){
[ "$DEBUGX" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"${LOG_REPLY_FILE:-/tmp/cf_script.log}"
}

_verbose(){
[ "$VERBOSE" ] || return 0
_draw ${COL_VERB:-12} "$*"
}

_is(){
_verbose "$*"
echo issue "$@"
sleep 0.2
}

_watch_scripttell(){

#echo watch $DRAW_INFO

while :; do

echo watch $DRAW_INFO
 while :; do

  sleep 0.1
  unset REPLY
  read -t 1
  _log "_watch_scripttell:$REPLY"
  _debug "$REPLY"

  case $REPLY in *scripttell*)
   _draw 3 "_watch_scripttell:$REPLY"
   case $REPLY in *abort*|*break*|*exit*|*halt*|*kill*|*quit*|*stop*|*term*)
    touch /tmp/cf_script_exit.flag
     break 2;;
   esac
  ;;
  '') c=$((c+1));;
  esac

 #c=$((c+1))
 test "$c" = ${COMMAND_PAUSE:-9} && break
 done

echo unwatch $DRAW_INFO
#sleep $COMMAND_PAUSE
#echo unwatch $DRAW_INFO
_watch_food
c=0

done

echo unwatch $DRAW_INFO
}


# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid $$ $PPID"

_direction_word_to_number(){

case $* in
 0|c|center)    DIRECTION_NUMBER=0;;
 1|n|north)     DIRECTION_NUMBER=1;;
2|ne|northeast) DIRECTION_NUMBER=2;;
 3|e|east)      DIRECTION_NUMBER=3;;
4|se|southeast) DIRECTION_NUMBER=4;;
 5|s|south)     DIRECTION_NUMBER=5;;
6|sw|southwest) DIRECTION_NUMBER=6;;
 7|w|west)      DIRECTION_NUMBER=7;;
8|nw|northwest) DIRECTION_NUMBER=8;;
*) _error 2 "Invalid direction $*"
esac

}

__parse_parameters(){
_debug "_parse_parameters:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "_parse_parameters:$*"
local c=0
until test $# = 0; do
c=$((c+1))
case $c in
1) NUMBER=`echo $1 | rev`;;    #ITEM=`echo $@ | rev`;;
2) DIRECTION=`echo $1 | rev`;;
3) ITEM=`echo $@ | rev`;;      #NUMBER=`echo $1 | rev`;;
4) :;;
5) :;;
6) :;;
esac
shift
sleep 0.1
done
_debug "_parse_parameters:ITEM=$ITEM DIR=$DIRECTION NUMBER=$NUMBER"
test "$NUMBER" -a "$DIRECTION" -a "$ITEM" || _error 1 "Missing ITEM -o DIRECTION -o NUMBER"
}


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


_parse_parameters(){

#DEBUGX=1

until [ $# = 0 ];
do
_debugx "'$1' '$2'"
case $1 in

[0-9]*) #readonly
COMMAND_PAUSE=$1;;

 c|center)      DIR=center;    DIRN=0; readonly DIR DIRN;;
 n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;

--*) case $1 in
      --help)   _usage;;
      --deb*)    DEBUG=$((DEBUG+1));;
      --fast)  SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --log*)  LOGGING=$((LOGGING+1));;
      --number=*) NUMBER=`echo "$1" | cut -f2 -d'='`;;
      --number)   NUMBER="$2"; shift;;
      --slow)  SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --verb*) VERBOSE=$((VERBOSE+1));;
      --nocheck*) unset CHECK_DO;;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`printf '%s' "$1" | sed -r 's/^-*//; s/(.)/\1\n/g'`  # echo "$1" would echo -n if passed ...
    _debugx "OPTS='$OPTS'"
    for oneOP in $OPTS; do
    _debugx "oneOP='$oneOP'"
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      F) SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      L) LOGGING=$((LOGGING+1));;
      n) NUMBER="$2"; _debugx "n:$*";shift;_debugx "n:$*";;
      S) SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      v) VERBOSE=$((VERBOSE+1));;
      X) unset CHECK_DO;;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;


*) ITEM="${ITEM}$1 ";;

esac
sleep 0.1
_debugx "1:$*"
shift
_debugx "2:$*"
done

ITEM=`echo -n $ITEM`
#readonly SPELL
#readonly DIRECTION="$DIR"
DIRECTION="$DIR"

_debug "_parse_parameters:ITEM=$ITEM DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
_debug "NUMBER='$NUMBER'"
test  "$DIRECTION" -a "$ITEM" || _error 1 "Missing ITEM -o DIRECTION"
}


__log(){
test "$LOGGING" || return 0
echo "$*" >>"$LOG_FILE"
}

__debug(){
test "$DEBUG" || return 0
_draw 3 "$*"
sleep 0.5
}

_usage(){
_draw 5 "Script to $COMMAND ITEM DIRECTION <COMMAND_PAUSE> ."
_draw 5 "Syntax:"
_draw 5 "script $0 <item> <dir> <<seconds>>"
_draw 5 "For example: 'script $0 rod of firebolt east 3'"
_draw 5 "will apply rod of firebolt"
_draw 5 "and will issue the $COMMAND east command with pause of 3 sec."
_draw 4 "Run without any parameters will use these defaults:"
_draw 4 "$ITEM_DEFAULT $DIRECTION_DEFAULT $COMMAND_PAUSE_DEFAULT"
_draw 5 "Options:"
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 4 "-n NUMBER to limit to NUMBER times usage of ITEM."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_FILE ."
_draw 5 "-v to say what is being issued to server."
_draw 3 "-X  do not check inventory ( faster, unsafe )"
exit 0
}


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


_check_have_needed_item_in_inventory(){

_debug "_check_have_needed_item_in_inventory:$*"

[ "$CHECK_DO" ] || return 0

local lITEM=${*:-"$ITEM"}
test "$lITEM" || return 3
local oneITEM oldITEM ITEMS TIMEB TIMEE TIME

_draw 6 "Checking if '$lITEM' in inventory..."
_draw 6 "Please wait ...."

TIMEB=`/bin/date +%s`

echo request items inv
while :;
do
unset oneITEM
read -t 1 oneITEM
 _log "_check_have_needed_item_in_inventory:$oneITEM"
 _debug "$oneITEM"

 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break

 ITEMS="$ITEMS
$oneITEM"
 oldITEM="$oneITEM"
sleep 0.1
done

unset oldITEM oneITEM

TIMEE=`/bin/date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Check took elapsed $TIME sec."

echo "$ITEMS" | grep -q -i "$lITEM"
}

_check_have_needed_item_applied(){

_debug "_check_have_needed_item_applied:$*"

local lITEM=${*:-"$ITEM"}
test "$lITEM" || return 3
local oneITEM oldITEM ITEMSA

_draw 6 "Checking if '$lITEM' is already applied .."

echo request items actv
while :;
do
unset oneITEM
read -t 1 oneITEM
 _log "_check_have_needed_item_applied:$oneITEM"
 _debug "$oneITEM"

 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break

 ITEMSA="$ITEMSA
$oneITEM"
 oldITEM="$oneITEM"
sleep 0.1
done

unset oldITEM oneITEM

echo "$ITEMSA" | grep -q -i "$lITEM"
}

_apply_needed_item(){

_debug "_apply_needed_item:$*"

local lITEM=${*:-"$ITEM"}
test "$lITEM" || return 3

_debug "_apply_needed_item:issue 0 0 apply -u $lITEM"
                       _is 0 0 apply -u "$lITEM"
_debug "_apply_needed_item:issue 0 0 apply -a $lITEM"
                       _is 0 0 apply -a "$lITEM"
}

_rotate_range_attack(){

_debug "_rotate_range_attack:$*"

local lITEM=${*:-"$ITEM"}
test "$lITEM" || return 3
local REPLY_RANGE oldREPLY_RANGE

_draw 6 "Rotate shoottype to ready '$lITEM' .."

while :;
do
echo request range
sleep 1
unset REPLY_RANGE
read -t 1 REPLY_RANGE
 _log "_rotate_range_attack:REPLY_RANGE=$REPLY_RANGE"
 _debug "$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$lITEM"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break
 #_debug "issue 1 1 rotateshoottype"
    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done

}


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


__watch_food(){
local statHP

echo request stat hp
read -t 1 statHP
 _debug "_watch_food:$statHP"
 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi

}

_do_emergency_recall(){
#_debug "issue 1 1 apply rod of word of recall"
 _is 1 1 apply -u "$ITEM_RECALL"
 _is 1 1 apply -a "$ITEM_RECALL"
 _is 1 1 fire 0
 _is 1 1 fire_stop
## apply bed of reality
# sleep 10
# echo issue 1 1 apply
exit 5
}

_watch_food(){
local r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_LVL

echo request stat hp
read -t1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_LVL
 _debug "_watch_food:FOOD_LVL='$FOOD_LVL' HP='$HP'"
 if test "$FOOD_LVL" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
 if test "$HP" -lt $((HP_MAX/10)); then
  _do_emergency_recall
 fi

}

_do_loop(){
NUMBER=$1

DEBUG=1

_debug "_do_loop:$*:NUMBER=$NUMBER"

_watch_scripttell &

TIMEB=`/bin/date +%s`

while :;
do

 TIMEC=${TIMEE:-$TIMEB}

#issue <repeat> <must_send> <command> - send
# <command> to server on behalf of client.
# <repeat> is the number of times to execute command
# <must_send> tells whether or not the command must sent at all cost (1 or 0).
# <repeat> and <must_send> are optional parameters.
 #_debug "_do_loop:issue 1 1 $COMMAND $DIRECTION_NUMBER"
             _is 1 1 $COMMAND $DIRECTION_NUMBER
             _is 1 1 $COMMAND_STOP
 sleep $COMMAND_PAUSE
 one=$((one+1))

 #_watch_food

 TRIES_STILL=$((NUMBER-one))
 _debug TRIES_STILL=$TRIES_STILL

 case $TRIES_STILL in -*) TRIES_STILL=$(( TRIES_STILL * -1 ));; esac
 _debug TRIES_STILL=$TRIES_STILL

 TIMEE=`/bin/date +%s`
 TIME=$((TIMEE-TIMEC))
 _debug TIME=$TIME

 TIMEALL=$((TIMEALL+TIME))
 TIMEAVG=$(( TIMEALL / one ))  # average 8 laps * 8 seconds = 64, 7 * 9 = 63 ...
 _debug TIMEAVG=$TIMEAVG

 MINUTES=$(( ((TRIES_STILL * TIMEAVG) / 60 ) ))
 _debug MINUTES=$MINUTES
 SECONDS=$(( (TRIES_STILL * TIMEAVG) - (MINUTES*60) ))
_debug SECONDS=$SECONDS
 case $SECONDS in [0-9]) SECONDS="0$SECONDS";; esac

 _draw 2 "Elapsed $TIME s, still '$TRIES_STILL' to go ($MINUTES:$SECONDS minutes) ..."

 test "$one" = "$NUMBER" && break
 test -e /tmp/cf_script_exit.flag && break
done
#_debug "_do_loop:issue 0 0 $COMMAND_STOP"
            _is 0 0 $COMMAND_STOP
}


# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***


_error(){
RV=$1;shift
_draw 3 "$*"
exit $RV
}

_do_program(){
if test "$*"; then
_parse_parameters "$@"
else
_draw 3 "Using defaults: $ITEM_DEFAULT $DIRECTION_DEFAULT $COMMAND_PAUSE_DEFAULT"
fi
         ITEM=${ITEM:-"$ITEM_DEFAULT"}
    DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}
COMMAND_PAUSE=${COMMAND_PAUSE:-"$COMMAND_PAUSE_DEFAULT"}

#   NUMBER=${NUMBER:-"$NUMBER_DEFAULT"}
#_check_have_needed_item_in_inventory || _error 1 "Item $ITEM not in inventory"
_check_have_needed_item_applied
case $? in
0) :
;;
*) _check_have_needed_item_in_inventory
   case $? in
   0) _apply_needed_item;;
   *) _error 1 "Item '$ITEM' not in inventory";;
   esac
;;
esac
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
_do_loop $NUMBER
}


rm -f /tmp/cf_script_exit.flag
case $* in
*)  _do_program "$@";
esac


# *** Here ends program *** #

rm -f /tmp/cf_script_exit.flag

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

test "$one" && _draw 5 "You fired '$one' time(s)."

_draw 2 "$0 is finished."


# ***
# ***
# *** diff marker 10
