#!/bin/ash

# 2018-01-10 : Code reorderings,
# recognize :punct: given to parameters as
# <rod of probe> or "staff of darkness"
# speed up the read loop for the inventory
# from sleep 0.1 to sleep 0.01 (now 4 sec inst 29 sec)

export PATH=/bin:/usr/bin

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

# early functions
_draw(){
    case $1 in [0-9]|1[0-2])
    lCOLOUR="$1"; shift;; esac
    local lCOLOUR=${lCOLOUR:-1} #set default
    local lMSG="$@"
    echo draw $lCOLOUR "$lMSG"
}

__draw(){
case $1 in [0-9]|1[0-2])
    lCOLOUR="$1"; shift;; esac
    local lCOLOUR=${lCOLOUR:-1} #set default
dcnt=0
echo "$*" | while read line
do
dcnt=$((dcnt+1))
    echo draw $lCOLOUR "$line"
done
unset dcnt line
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

_say_version(){
_draw 2 "$0 Version:${VERSION:-'1.0'}"
exit 0
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
__debug(){  ##+++2018-01-10
test "$DEBUG" || return 0
dcnt=0
case $1 in -s) shift; local lSLEEP=0.25;; esac
echo "$*" | while read line
do
dcnt=$((dcnt+1))
    echo draw 3 "__DEBUG:$dcnt:$line"
    sleep ${lSLEEP:-0.0001}
done
unset dcnt line
}

_error(){
RV=$1;shift
#_draw 3 "$*"
eMSG=`echo -e "$*"`
__draw 3 "$eMSG"
exit ${RV:-1}
}

#***
_is(){
    _debug "issue $*"
    echo issue "$@"
    sleep 0.2
}

# *** functions list
_direction_word_to_number(){
_debug "_direction_word_to_number:$*"
case $* in
0|center|centre|c) DIRECTION_NUMBER=0;;
1|north|n)      DIRECTION_NUMBER=1;;
2|northeast|ne) DIRECTION_NUMBER=2;;
3|east|e)       DIRECTION_NUMBER=3;;
4|southeast|se) DIRECTION_NUMBER=4;;
5|south|s)      DIRECTION_NUMBER=5;;
6|southwest|sw) DIRECTION_NUMBER=6;;
7|west|w)       DIRECTION_NUMBER=7;;
8|northwest|nw) DIRECTION_NUMBER=8;;
*) _error 2 "Invalid direction '$*'"
esac

}

_parse_parameters(){
_debug "_parse_parameters:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "_parse_parameters:$*"
local c=0
while test $# != 0; do
c=$((c+1))
case $c in
1)    NUMBER=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;; #ITEM=`echo $@ | rev`;;
2) DIRECTION=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
3)      ITEM=`echo $@ | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;; #NUMBER=`echo $1 | rev`;;
4) :;;
5) :;;
6) :;;
esac
shift
done
_debug "_parse_parameters:ITEM=$ITEM DIR=$DIRECTION NUMBER=$NUMBER"
test "$NUMBER" -a "$DIRECTION" -a "$ITEM" || _error 1 "Missing ITEM -o DIRECTION -o NUMBER"
}

_check_have_needed_item_in_inventory(){
_debug "_check_have_needed_item_in_inventory:$*"

local oneITEM oldITEM ITEMS ITEMSA lITEM
lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

TIMEB=`date +%s`

unset oneITEM oldITEM ITEMS ITEMSA
echo request items inv
while :;
do
read -t ${TMOUT:-1} oneITEM
 _log "$oneITEM"
 #test "$oldITEM" = "$oneITEM" && break
 #test "$oneITEM" || break
 case $oneITEM in
 $oldITEM|'') break;;
 *"$lITEM"*) _draw 7 "Got that item $lITEM in inventory.";;
 esac
 ITEMS="${ITEMS}${oneITEM}\n"
#$oneITEM"
 oldITEM="$oneITEM"
sleep 0.01
done
unset oldITEM oneITEM


TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s"

#_debug "lITEM=$lITEM"
#_debug "head:`echo -e "$ITEMS" | head -n1`"
#_debug "tail:`echo -e "$ITEMS" | tail -n2 | head -n1`"
#HAVEIT=`echo "$ITEMS" | grep "$lITEM"`
#_debug "HAVEIT=$HAVEIT"
echo -e "$ITEMS" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
}

_check_have_needed_item_applied(){
_debug "_check_have_needed_item_applied:$*"

local oneITEM oldITEM ITEMS ITEMSA lITEM

lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

unset ITEMSA oneITEM oldITEM
echo request items actv
while :;
do
read -t ${TMOUT:-1} oneITEM
 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 ITEMSA="$ITEMSA
$oneITEM"
 oldITEM="$oneITEM"
sleep 0.01
done
unset oldITEM oneITEM

echo "$ITEMSA" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
}

_apply_needed_item(){
#_debug "_apply_needed_item:issue 0 0 apply $ITEM"
 _is 0 0 apply ${*:-"$ITEM"}
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"

local REPLY_RANGE oldREPLY_RANGE lITEM
lITEM=${*:-"$ITEM"}

while :;
do
echo request range
sleep 1
read -t ${TMOUT:-1} REPLY_RANGE
 _log "REPLY_RANGE=$REPLY_RANGE"
 test "`echo "$REPLY_RANGE" | grep -i "$lITEM"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break
 #_debug "issue 1 1 rotateshoottype"
    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
}

__watch_food(){
_debug "__watch_food:$*"

echo request stat hp
read -t ${TMOUT:-1} statHP
 _debug "__watch_food:$statHP"
 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "__watch_food:FOOD_STAT=$FOOD_STAT"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
}

__do_emergency_recall(){
#_debug "issue 1 1 apply -a rod of word of recall"
  _is 1 1 apply -u "rod of word of recall"
  _is 1 1 apply -a "rod of word of recall"
  _is 1 1 fire 0
  _is 1 1 fire_stop
## apply bed of reality
# sleep 10
# _is 1 1 apply
exit 5
}

# ***
_do_emergency_recall(){
# *** apply rod of word of recall if hit-points are below HP_MAX /10
# *   fire and fire_stop it
# *   alternatively one could apply rod of heal, scroll of restoration
# *   and ommit exit ( comment 'exit 5' line by setting a '#' before it)
# *   - something like that
RETURN_ITEM=${*:-"$RETURN_ITEM"}
if test "$RETURN_ITEM"; then
 case $RETURN_ITEM in
 *rod*|*staff*|*wand*|*horn*)
  _is 1 1 apply -u "$RETURN_ITEM"
  _is 1 1 apply -a "$RETURN_ITEM"
  _is 1 1 fire 0
  ;;
 *scroll*)
  _is 1 1 apply "$RETURN_ITEM"
  ;;
 *) invoke "$RETURN_ITEM";; # assuming spell
 esac
  #_is 1 1 fire 0
fi
  _is 1 1 fire_stop

# apply bed of reality
 sleep 6
_is 1 1 apply

exit 5
}

_watch_food(){
_debug "_watch_food:$*"

echo request stat hp
read -t ${TMOUT:-1} r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD
 _debug "_watch_food:FOOD=$FOOD HP=$HP"
 if test "$FOOD" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
 if test $HP -lt $((HP_MAX/10)); then
  _do_emergency_recall
 else true
 fi
}

# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid $$ $PPID"
# MAIN

_do_loop(){
NUMBER=${1:-1}
_debug "_do_loop:$*:NUMBER=$NUMBER"
for one in `seq 1 1 $NUMBER`
do

 TIMEB=`date +%s`

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

 TRIES_STILL=$((NUMBER-one))
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEB))
 MINUTES=$(( ((TRIES_STILL * $TIME ) / 60 ) ))
 SECONDS=$(( (TRIES_STILL * TIME) - (MINUTES*60) ))
 _draw 4 "Elapsed $TIME s, still '$TRIES_STILL' to go ($MINUTES:$SECONDS minutes) ..."

done
#_debug "_do_loop:issue 0 0 $COMMAND_STOP"
            _is 0 0 $COMMAND_STOP
}

_do_program(){
_parse_parameters "$@"

ITEM=${ITEM:-"$ITEM_DEFAULT"}
DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}
NUMBER=${NUMBER:-"$NUMBER_DEFAULT"}
#_check_have_needed_item_in_inventory || _error 1 "Item $ITEM not in inventory"
_check_have_needed_item_applied
case $? in
0) :;;
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
-h|*help*) _usage;;
'') _draw 3 "Script needs <item> <direction> and <number of $COMMAND attempts> as argument.";;
*) _do_program "$@";;
esac

# *** Here ends program *** #
_draw 2 "$0 is finished."
###END###
