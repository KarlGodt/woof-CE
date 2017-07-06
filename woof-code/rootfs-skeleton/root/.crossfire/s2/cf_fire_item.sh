#!/bin/ash

DEBUG=1
LOGGING=1

TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
LOG_FILE="$TMP_DIR"/cf_inventory.$$

DIRECTION_DEFAULT=east
NUMBER_DEFAULT=10
ITEM_DEFAULT='horn of plenty'
COMMAND=fire
COMMAND_PAUSE=3  # seconds
COMMAND_STOP=fire_stop
FOOD_STAT_MIN=100
FOOD=waybread

_draw(){
	test "$*" || return 3
case $1 in [0-9]|1[0-2])
lCOLOR=$1; shift;;
esac
	test "$*" || return 4
local lCOLOR=${COLOR:-$lCOLOR}
	  lCOLOR=${lCOLOR:-1}

while read -r line
do
	echo draw $lCOLOR "$line"
done <<EoI
`echo "$*"`
EoI
}

# ***
_log(){
# *** echo passed parameters to logfile if LOGGING is set to anything

test "$LOGGING" || return 0
echo "$*" >>"${LOG_FILE:-/tmp/cf_script.log}"
}

# ***
_verbose(){
# ***
test "$VERBOSE" || return 0
echo draw ${COL_VERB:-7} "$*"
sleep 0.1
}

# ***
_debug(){
# *** print passed parameters to window if DEBUG is set to anything

test "$DEBUG" || return 0
echo draw ${COL_DBG:-3} "$*"
sleep 0.1
}

_is(){
	_verbose "$*"
  echo issue "$*"
sleep 0.2
}

# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid $$ $PPID"

_direction_word_to_number(){

case $* in
0|center)    DIRECTION_NUMBER=0;;
1|north)     DIRECTION_NUMBER=1;;
2|northeast) DIRECTION_NUMBER=2;;
3|east)      DIRECTION_NUMBER=3;;
4|southeast) DIRECTION_NUMBER=4;;
5|south)     DIRECTION_NUMBER=5;;
6|southwest) DIRECTION_NUMBER=6;;
7|west)      DIRECTION_NUMBER=7;;
8|northwest) DIRECTION_NUMBER=8;;
*) _error 2 "Invalid direction $*"
esac

}

_assign_long_options(){
test "$*" || return 3

until $# = 0; do
 case $1 in
 *debug) DEBUG=$((DEBUG+1));;
 *help)  _usage;;
 *log*)  LOGGING=$((LOGGING+1));;
 *verb*) VERBOSE=$((VERBOSE+1));;

 *) _draw 3 "Ignoring unrecognized option '$1'";;
#*) _error "Wrong option '$1'";;
 esac
shift
done
}

_assign_short_options(){
test "$*" || return 3

OPTS=`printf '%s' $* | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      d) DEBUG=$((DEBUG+1));;
     #f) FORCE=$((FORCE+1));;
      h) _usage;;
      L) LOGGING=$((LOGGING+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     #*) _error "Wrong option '$oneOP'";;
     esac
   done
}

_parse_parameters(){
_debug "_parse_parameters:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "_parse_parameters:$*"
local c=0

until test $# = 0; do

case $1 in

--)  :;;
--*) _assign_long_options  $1;;
-*)  _assign_short_options $1;;

*)
 c=$((c+1))
 case $c in
 1) NUMBER=`echo $1 | rev`;;    #ITEM=`echo $@ | rev`;;
 2) DIRECTION=`echo $1 | rev`;;
 3) ITEM=`echo $@ | rev`;;      #NUMBER=`echo $1 | rev`;;
 4) :;;
 5) :;;
 6) :;;
 esac
;;
esac

shift
done

_debug "_parse_parameters:ITEM=$ITEM DIR=$DIRECTION NUMBER=$NUMBER"
test "$NUMBER" -a "$DIRECTION" -a "$ITEM" || _error 1 "Missing ITEM -o DIRECTION -o NUMBER"
}

_log(){
test "$LOGGING" || return
echo "$*" >>"$LOG_FILE"
}

_debug(){
test "$DEBUG" || return
echo draw 3 "$*"
sleep 0.5
}

_usage(){
_draw 5 "Script to $COMMAND ITEM DIRECTION NUMBER ."
_draw 5 "Syntax:"
_draw 5 "script $0 <item> <dir> <number>"
_draw 5 "For example: 'script $0 rod of firebolt east 10'"
_draw 5 "will apply rod of firebolt"
_draw 5 "and will issue 10 times the $COMMAND east command."
exit 0
}

_check_have_needed_item_in_inventory(){
_debug "_check_have_needed_item_in_inventory:$*"
TIMEB=`date +%s`

echo request items inv
while :;
do
read -t1 oneITEM
 _log "$oneITEM"
 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 ITEMS="$ITEMS
$oneITEM"
 oldITEM="$oneITEM"
sleep 0.1
done
unset oldITEM oneITEM


TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s"

echo "$ITEMS" | grep -q -i "$ITEM"
}

_check_have_needed_item_applied(){
_debug "_check_have_needed_item_applied:$*"

echo request items actv
while :;
do
read -t1 oneITEM
 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 ITEMSA="$ITEMSA
$oneITEM"
 oldITEM="$oneITEM"
sleep 0.1
done
unset oldITEM oneITEM

echo "$ITEMSA" | grep -q -i "$ITEM"
}

_apply_needed_item(){
 local lITEM={$*:-$ITEM}
test "$lITEM" || return 3

_debug "_apply_needed_item:issue 0 0 apply $lITEM"
                       _is 0 0 apply -u $lITEM
                       _is 0 0 apply -a $lITEM
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"
local REPLY_RANGE oldREPLY_RANGE
#echo watch request range
while :;
do
echo request range
sleep 1
read -t1 REPLY_RANGE
 _log "REPLY_RANGE=$REPLY_RANGE"
 test "`echo "$REPLY_RANGE" | grep -i "$ITEM"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break
 _debug "issue 1 1 rotateshoottype"
    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
#echo unwatch request
}

__watch_food(){

echo request stat hp
read -t1 statHP
 _debug "_watch_food:$statHP"
 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  _debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi

}

_do_emergency_recall(){
_debug "issue 1 1 apply -u rod of word of recall"
  echo "issue 1 1 apply -a rod of word of recall"
  echo "issue 1 1 fire 0"
  echo "issue 1 1 fire_stop"
## apply bed of reality
# sleep 10
# _is 1 1 apply
exit 5
}

_watch_food(){

echo request stat hp
read -t1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD
 _debug "_watch_food:FOOD=$FOOD HP=$HP"
 if test "$FOOD" -lt $FOOD_STAT_MIN; then
  _debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
 if test $HP -lt $((HP_MAX/10)); then
  _do_emergency_recall
 fi


}

_do_loop(){
NUMBER=$1
_debug "_do_loop:$*:NUMBER=$NUMBER"
for one in `seq 1 1 $NUMBER`
do

 TIMEB=`date +%s`

#issue <repeat> <must_send> <command> - send
# <command> to server on behalf of client.
# <repeat> is the number of times to execute command
# <must_send> tells whether or not the command must sent at all cost (1 or 0).
# <repeat> and <must_send> are optional parameters.
 _debug "_do_loop:issue 1 1 $COMMAND $DIRECTION_NUMBER"
             _is 1 1 $COMMAND $DIRECTION_NUMBER
             _is 1 1 $COMMAND_STOP
 sleep $COMMAND_PAUSE

 _watch_food

 TRIES_STILL=$((NUMBER-one))
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEB))
 MINUTES=$(( ((TRIES_STILL * $TIME ) / 60 ) ))
 SECONDS=$(( (TRIES_STILL * TIME) - (MINUTES*60) ))
 _draw 4 "Elapsed $TIME s, still '$TRIES_STILL' to go ($MINUTES:$SECONDS minutes) ..."

done
_debug "_do_loop:issue 0 0 $COMMAND_STOP"
            _is 0 0 $COMMAND_STOP
}

_error(){
RV=$1;shift
_draw 3 "$*"
exit $RV
}

_do_program(){
_parse_parameters "$@"
     ITEM=${ITEM:-$ITEM_DEFAULT}
DIRECTION=${DIRECTION:-$DIRECTION_DEFAULT}
   NUMBER=${NUMBER:-$NUMBER_DEFAULT}
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

case $@ in
*help*) _usage;;
'') _draw 3 "Script needs item direction and number of $COMMAND attempts as argument.";;
*) _do_program "$@";;
esac

# *** Here ends program *** #
_draw 2 "$0 is finished."
