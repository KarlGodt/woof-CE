#!/bin/ash

DEBUG=1
LOGGING=1

TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
LOG_FILE="$TMP_DIR"/cf_inventory.$$

ITEM_NEEDED='horn of plenty'
COMMAND=fire
DIRECTION=0   #1=north, 8=northwest
COMMAND_STOP=fire_stop
FOOD_STAT_MIN=495 #100
FOOD=haggis #waybread

# *** Here begins program *** #
echo draw 2 "$0 is started with pid $$ $PPID"

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
echo draw 5 "Script to $COMMAND $ITEM_NEEDED ."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <number>"
echo draw 5 "For example: 'script $0 50'"
echo draw 5 "will apply $ITEM_NEEDED"
echo draw 5 "and will issue 50 times the $COMMAND command."
exit 0
}

_check_have_needed_item_in_inventory(){
_debug "_check_have_needed_item_in_inventory:$*"
TIMEB=`date +%s`
echo watch request
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
echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo draw 4 "Elapsed $TIME s"

echo "$ITEMS" | grep -q -i "$ITEM_NEEDED"
}

_check_have_needed_item_applied(){
_debug "_check_have_needed_item_applied:$*"
echo watch request
echo request items actv
while :;
do
read -t1 oneITEM
 _log "$oneITEM"
 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 ITEMSA="$ITEMSA
$oneITEM"
 oldITEM="$oneITEM"
sleep 0.1
done
unset oldITEM oneITEM
echo unwatch request
echo "$ITEMSA" | grep -q -i "$ITEM_NEEDED"
}

_apply_needed_item(){
_debug "_apply_needed_item:issue 0 0 apply $ITEM_NEEDED"
                       echo issue 0 0 apply $ITEM_NEEDED
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"
local REPLY_RANGE oldREPLY_RANGE
echo watch request range
while :;
do
_debug "_rotate_range_attack:request range"
echo request range
sleep 1
read -t1 REPLY_RANGE
 _log "REPLY_RANGE=$REPLY_RANGE"
 test "`echo "$REPLY_RANGE" | grep -i "$ITEM_NEEDED"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break
 _debug "issue 1 1 rotateshoottype"
    echo issue 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
echo unwatch request
}

_watch_food(){
echo watch request
echo request stat hp
read -t1 statHP
 _debug "_watch_food:$statHP"
 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  _debug "issue 0 0 apply $FOOD"
     echo issue 0 0 apply $FOOD
   sleep 1
 fi
echo unwatch request
}

_do_loop(){
NUMBER=$1
_debug "_do_loop:$*:NUMBER=$NUMBER"
for one in `seq 1 1 $NUMBER`
do

 TIMEB=`date +%s`

 _debug "_do_loop:issue 0 0 $COMMAND $DIRECTION"
              echo issue 0 0 $COMMAND $DIRECTION
       sleep 6

 _watch_food

 TRIES_STILL=$((NUMBER-one))
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEB))
 echo draw 4 "Elapsed $TIME s, still '$TRIES_STILL' to go..."

done
_debug "_do_loop:issue 0 0 $COMMAND_STOP"
echo issue 0 0 $COMMAND_STOP
}

_error(){
RV=$1;shift
echo draw 3 "$*"
exit $RV
}

_do_program(){
#_check_have_needed_item_in_inventory || _error 1 "Item $ITEM_NEEDED not in inventory"
_check_have_needed_item_applied
case $? in
0) :
;;
*) _check_have_needed_item_in_inventory
   case $? in
   0) _apply_needed_item;;
   *) _error 1 "Item $ITEM_NEEDED not in inventory";;
   esac
;;
esac
sleep 1
_rotate_range_attack
sleep 1
_do_loop $1
}

case $1 in
*help) _usage;;
[0-9]*) _do_program $1;;
*) echo draw 3 "Script needs number of $COMMAND attempts as argument.";;
esac

# *** Here ends program *** #
echo draw 2 "$0 is finished."
