#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

#DEBUG=1
#LOGGING=1

TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
LOG_FILE="$TMP_DIR"/cf_inventory.$$

DIRECTION_DEFAULT=east
NUMBER_DEFAULT=10
ITEM_DEFAULT='horn of plenty'
COMMAND=fire
COMMAND_PAUSE=7  # seconds
COMMAND_STOP=fire_stop
FOOD_STAT_MIN=300
FOOD=waybread

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
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

_parse_parameters(){

until [ $# = 0 ];
do
case $1 in

[0-9]*) readonly COMMAND_PAUSE=$1;;

 c|center)      DIR=center;    DIRN=0; readonly DIR DIRN;;
 n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)    DEBUG=$((DEBUG+1));;
      --fast)  SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --log*)  LOGGING=$((LOGGING+1));;
      --slow)  SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --verb*) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`echo "$PARAM_1" | sed -r 's/^-*//; s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      F) SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      L) LOGGING=$((LOGGING+1));;
      S) SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;


*) SPELL="${SPELL}$1 ";;

esac
sleep 0.1
shift
done

SPELL=`echo -n $SPELL`
readonly SPELL
readonly DIRECTION="$DIR"

_debug "_parse_parameters:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
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
_draw 5 "Script to $COMMAND ITEM DIRECTION NUMBER ."
_draw 5 "Syntax:"
_draw 5 "script $0 <item> <dir> <number>"
_draw 5 "For example: 'script $0 rod of firebolt east 10'"
_draw 5 "will apply rod of firebolt"
_draw 5 "and will issue 10 times the $COMMAND east command."
_draw 4 "Run without any parameters will use these defaults:"
_draw 4 "$ITEM_DEFAULT $DIRECTION_DEFAULT $NUMBER_DEFAULT"
_draw 5 "Options:"
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_FILE ."
_draw 5 "-v to say what is being issued to server."
exit 0
}

_check_have_needed_item_in_inventory(){
_debug "_check_have_needed_item_in_inventory:$*"
local oneITEM oldITEM ITEMS TIMEB TIMEE TIME

_draw 6 "Checking if in inventory..."

TIMEB=`date +%s`
#echo watch request
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
#echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Check took elapsed $TIME s"

echo "$ITEMS" | grep -q -i "$ITEM"
}

_check_have_needed_item_applied(){
_debug "_check_have_needed_item_applied:$*"
local oneITEM oldITEM ITEMSA

_draw 6 "Checking if '$ITEM' is already applied .."
#echo watch request
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
#echo unwatch request

echo "$ITEMSA" | grep -q -i "$ITEM"
}

_apply_needed_item(){
#_debug "_apply_needed_item:issue 0 0 apply $ITEM"
                       _is 0 0 apply $ITEM
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"
local REPLY_RANGE oldREPLY_RANGE

_draw 6 "Rotate shoottype to ready '$ITEM' .."
#echo watch request range
while :;
do
echo request range
sleep 1
unset REPLY_RANGE
read -t 1 REPLY_RANGE
 _log "_rotate_range_attack:REPLY_RANGE=$REPLY_RANGE"
 _debug "$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$ITEM"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break
 #_debug "issue 1 1 rotateshoottype"
    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
#echo unwatch request
}

__watch_food(){
local statHP
#echo watch request
echo request stat hp
read -t1 statHP
 _debug "_watch_food:$statHP"
 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
#echo unwatch request
}

_do_emergency_recall(){
#_debug "issue 1 1 apply rod of word of recall"
 _is 1 1 apply rod of word of recall
 _is 1 1 fire 0
 _is 1 1 fire_stop
## apply bed of reality
# sleep 10
# echo issue 1 1 apply
exit 5
}

_watch_food(){
local r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_LVL
#echo watch request
echo request stat hp
read -t1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_LVL
 _debug "_watch_food:FOOD_LVL=$FOOD_LVL HP=$HP"
 if test "$FOOD_LVL" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
 if test "$HP" -lt $((HP_MAX/10)); then
  _do_emergency_recall
 fi

#echo unwatch request
}

_do_loop(){
NUMBER=$1
_debug "_do_loop:$*:NUMBER=$NUMBER"

TIMEB=`date +%s`
#for one in `seq 1 1 $NUMBER`
while :;
do

 TIMEC=${TIMEE:-`date +%s`}

#issue <repeat> <must_send> <command> - send
# <command> to server on behalf of client.
# <repeat> is the number of times to execute command
# <must_send> tells whether or not the command must sent at all cost (1 or 0).
# <repeat> and <must_send> are optional parameters.
 #_debug "_do_loop:issue 1 1 $COMMAND $DIRECTION_NUMBER"
             _is 1 1 $COMMAND $DIRECTION_NUMBER
             _is 1 1 $COMMAND_STOP
 sleep $COMMAND_PAUSE

 _watch_food

 one=$((one+1))

 TRIES_STILL=$((NUMBER-one))
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEC))
 MINUTES=$(( ((TRIES_STILL * TIME ) / 60 ) ))
 SECONDS=$(( (TRIES_STILL * TIME) - (MINUTES*60) ))
 _draw 4 "Elapsed $TIME s, still '$TRIES_STILL' to go ($MINUTES:$SECONDS minutes) ..."


done
#_debug "_do_loop:issue 0 0 $COMMAND_STOP"
            _is 0 0 $COMMAND_STOP
}

_error(){
RV=$1;shift
_draw 3 "$*"
exit $RV
}

_do_program(){
if test "$*"; then
_parse_parameters "$@"
fi
     ITEM=${ITEM:-"$ITEM_DEFAULT"}
DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}
   NUMBER=${NUMBER:-"$NUMBER_DEFAULT"}
#_check_have_needed_item_in_inventory || _error 1 "Item $ITEM not in inventory"
_check_have_needed_item_applied
case $? in
0) :
;;
*) _check_have_needed_item_in_inventory
   case $? in
   0) _apply_needed_item;;
   *) _error 1 "Item $ITEM not in inventory";;
   esac
;;
esac
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
_do_loop $NUMBER
}

until test $# = 0; do
case $1 in
-h|*help*) _usage;;
#-d|*debug)     DEBUG=$((DEBUG+1));;
#-F|*fast)   SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
#-L|*logging) LOGGING=$((LOGGING+1));;
#-S|*slow)   SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
#-v|*verbose) VERBOSE=$((VERBOSE+1));;
'') _draw 3 "Script needs <item> <direction> and <number of $COMMAND attempts> as argument.";;
*) _do_program "$@"; break;;
esac
shift
sleep 0.1
done

# *** Here ends program *** #
_draw 2 "$0 is finished."
