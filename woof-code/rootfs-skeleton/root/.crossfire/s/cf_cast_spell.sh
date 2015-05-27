#!/bin/ash

DEBUG=1
LOGGING=1

TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
LOG_FILE="$TMP_DIR"/cf_spells.$$

DIRECTION_DEFAULT=east
NUMBER_DEFAULT=10
SPELL_DEFAULT='create food waybread'
COMMAND=fire
COMMAND_PAUSE=4  # seconds
COMMAND_STOP=fire_stop
FOOD_STAT_MIN=100
FOOD=waybread

# *** Here begins program *** #
echo draw 2 "$0 started <$*> with pid $$ $PPID"

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

_parse_parameters(){
_debug "_parse_parameters:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "_parse_parameters:$*"
local c=0
while test $# != 0; do
c=$((c+1))
case $c in
1) NUMBER=`echo $1 | rev`;;    #SPELL=`echo $@ | rev`;;
2) DIRECTION=`echo $1 | rev`;;
3) SPELL=`echo $@ | rev`;;      #NUMBER=`echo $1 | rev`;;
4) :;;
5) :;;
6) :;;
esac
shift
done
_debug "_parse_parameters:SPELL=$SPELL DIR=$DIRECTION NUMBER=$NUMBER"
test "$NUMBER" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o NUMBER"
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
echo draw 5 "Script to $COMMAND SPELL DIRECTION NUMBER ."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <spell> <dir> <number>"
echo draw 5 "For example: 'script $0 firebolt east 10'"
echo draw 5 "will issue cast firebolt"
echo draw 5 "and will issue 10 times the $COMMAND east command."
exit 0
}

_check_have_needed_spell_in_inventory(){
_debug "_check_have_needed_spell_in_inventory:$*"
TIMEB=`date +%s`
echo watch request
echo request spells
while :;
do
read -t1 oneSPELL
 _log "$oneSPELL"
 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break
 SPELLS="$SPELLS
$oneSPELL"
 oldSPELL="$oneSPELL"
sleep 0.1
done
unset oldSPELL oneSPELL
echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo draw 4 "Elapsed $TIME s"
SPELL_LINE=`echo "$PELLS" | grep -i "$PELL"`

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$SPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i "$SPELL"
}

_check_have_needed_spell_applied(){
_debug "_check_have_needed_spell_applied:$*"
echo watch request
echo request spells
while :;
do
read -t1 oneSPELL
_log "$oneSPELL"
 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break
 SPELLSA="$SPELLSA
$oneSPELL"
 oldSPELL="$oneSPELL"
sleep 0.1
done
unset oldSPELL oneSPELL
echo unwatch request
echo "$SPELLSA" | grep -q -i "$SPELL"
}

_apply_needed_spell(){
_debug "_apply_needed_spell:issue 1 1 cast $SPELL"
                        echo issue 1 1 cast $SPELL
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"
local REPLY_RANGE oldREPLY_RANGE
echo watch request range
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
    echo issue 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
echo unwatch request
}

__watch_food(){
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

_do_emergency_recall(){
_debug "issue 1 1 apply rod of word of recall"
  echo "issue 1 1 apply rod of word of recall"
  echo "issue 1 1 fire 0"
  echo "issue 1 1 fire_stop"
## apply bed of reality
# sleep 10
# echo issue 1 1 apply
exit 5
}

_watch_food(){
echo watch request
echo request stat hp
read -t1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_STAT
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT HP=$HP SP=$SP"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  _debug "issue 0 0 apply $FOOD"
     echo issue 0 0 apply $FOOD
   sleep 1
 fi
 if test $HP -lt $((HP_MAX/10)); then
  _do_emergency_recall
 fi
 if [ "$SP" -le 0 ]; then
   return 6
 elif [ "$SP" -lt $SP_NEEDED ]; then
   return 6
 elif [ "$SP" -th $SP_MAX ]; then
   return 4
 elif [ "$SP" -eq $SP_MAX ]; then
   return 0
 fi

echo unwatch request
test "$SP" = $SP_MAX || return 3
}

_regenerate_spell_points(){

while :;
do
sleep 20s
_watch_food && break
_debug "Still regenerating to $SP_MAX ($SP) spellpoints .."
done

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
            echo issue 1 1 $COMMAND $DIRECTION_NUMBER
            echo issue 1 1 $COMMAND_STOP
 sleep $COMMAND_PAUSE

 _watch_food
 case $? in 6)
  _regenerate_spell_points
 esac

 TRIES_STILL=$((NUMBER-one))
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEB))
 MINUTES=$(( ((TRIES_STILL * $TIME ) / 60 ) ))
 SECONDS=$(( (TRIES_STILL * TIME) - (MINUTES*60) ))
 echo draw 4 "Elapsed $TIME s, still '$TRIES_STILL' to go ($MINUTES:$SECONDS minutes) ..."

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
_parse_parameters "$@"
test "$SPELL"     || SPELL="$SPELL_DEFAULT"
test "DIRECTION" || DIRECTION="$DIRECTION_DEFAULT"
test "$NUMBER"   || NUMBER="$NUMBER_DEFAULT"
#_check_have_needed_spell_in_inventory || _error 1 "SPELL $SPELL not in inventory"
#_check_have_needed_spell_applied
#case $? in
#0) :
#;;
#*) _check_have_needed_spell_in_inventory
#   case $? in
#   0) _apply_needed_spell;;
#   *) _error 1 "SPELL $SPELL not in inventory";;
#   esac
#;;
#esac
_check_have_needed_spell_in_inventory && _apply_needed_spell || _error 1 "Spell is not in inventory"
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
_do_loop $NUMBER
}

case $@ in
*help*) _usage;;
'') echo draw 3 "Script needs SPELL direction and number of $COMMAND attempts as argument.";;
*) _do_program "$@";;
esac

# *** Here ends program *** #
echo draw 2 "$0 is finished."
