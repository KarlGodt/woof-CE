#!/bin/ash
# *** script to cast wizard spell - does not handle praying spells regeneration (yet)
# *   written May 2015 by Karl Reimer Godt
# * Uses busybox almquist shell as interpreter - should work with bash
# * busybox ash can be configured with options - and some internal functions
# * may not be implemented by the distribution
# * Use 'scrits' to check if it is still running
# * This script loops forever,
# * use 'scriptkill' to terminate it -
# * otherwise should be terminated when the computer shuts down,
# * but your character may die of starvation if FOOD runs out
# * Purpose : Place the character in a chamber with generators and
# * where the character cannot be killed by monsters.
# * Then fire a spell in the desired direction all the time until termination.
# * Syntax : script_name <spell name <option>> <direction to cast to> <pause between firings>
# * spell name option is space delimited
# * direction to cast to are center, north, northeast, east, southeast, south, southwest, west, northwest
# * direction to cast to is a whole word without delimter
# * pause between firing is used to pause between firings
# * pause between firing is an integer value; 1,2,3,4,5 are usable for me,
# * larger pause values make monsters regenerating too much, smaller may not generate enough monsters to be effective ( cone spells )
# * - Remember : Dependent on the complexity of the code the pausing sleep value given can increase by one to three seconds currently.
# * CAUTION : Does not handle "You bungle the spell" events (yet) - so make sure no two-handed weapon applied
# * Also high armour class and armour resistances may be of some use
# * While the script is running, the character can level up, while you are multi-tasking or taking a shower :)

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

# *** Variables : Most are set or unset ( set meaning have content ( even " " ) , unset no content
# *** common editable variables
VERBOSE=1  # be a bit talkactive
DEBUG=1    # print gained values
LOGGING=1  # print to a file - especially large requests like inv
PROBE=1    # apply rod of probe in firing direction after firing
STATS=1    # check hp, sp and food level
CHECK_COUNT=10 #only run every yth time a check for food and probe

# *** common variables
readonly TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
readonly LOG_FILE="$TMP_DIR"/cf_spells.$$

# *** uncommon editable variables *** #
readonly DIRECTION_DEFAULT=east
readonly NUMBER_DEFAULT=10
readonly SPELL_DEFAULT='create food waybread'
readonly COMMAND=fire
readonly COMMAND_PAUSE_DEFAULT=4  # seconds
readonly COMMAND_STOP=fire_stop
readonly FOOD_STAT_MIN=100
readonly FOOD=waybread

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid $$ $PPID"

# *** functions list

# ***
_direction_word_to_number(){
# *** converts direction-word to global program-understandable number
# * Syntax : _direction_word_to_number WORD
# * return : not used
# * generates : DIRECTION_NUMBER

case $* in
 0|c|center)    readonly DIRECTION_NUMBER=0;;
 1|n|north)     readonly DIRECTION_NUMBER=1;;
2|ne|northeast) readonly DIRECTION_NUMBER=2;;
 3|e|east)      readonly DIRECTION_NUMBER=3;;
4|se|southeast) readonly DIRECTION_NUMBER=4;;
 5|s|south)     readonly DIRECTION_NUMBER=5;;
6|sw|southwest) readonly DIRECTION_NUMBER=6;;
 7|w|west)      readonly DIRECTION_NUMBER=7;;
8|nw|northwest) readonly DIRECTION_NUMBER=8;;
*) _error 2 "Invalid direction $*"
esac

}

# ***
_parse_parameters(){
# *** parameters to script: "spell name" "directiontocastto" "pausing_between_casts"
# *   We do a ^normal^ logic :
# *   Since the spell could contain endless words ie: "summon pet monster water elemental"
# *   it needs to use 'rev' to revert the positional parameter line
# *   and re-set to parameter line using 'set'
# *   and then 'rev' each parameter again
# *   TODO : add more parameters

_debug "_parse_parameters:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "_parse_parameters:$*"
local c=0

until test $# = 0; do
c=$((c+1))
case $c in
1) readonly COMMAND_PAUSE=`echo $1 | rev`;;
2) readonly DIRECTION=`echo $1 | rev`;;
3) readonly SPELL=`echo $@ | rev`;;
4) :;;
5) :;;
6) :;;
esac
shift
done

_debug "_parse_parameters:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
}

# ***
__log(){
# *** echo passed parameters to logfile if LOGGING is set to anything
test "$LOGGING" || return
echo "$*" >>"$LOG_FILE"
}

# ***
__verbose(){
# ***
test "$VERBOSE" || return
_draw 7 "$*"
sleep 0.5
}

# ***
__debug(){
# *** print passed parameters to window if DEBUG is set to anything

test "$DEBUG" || return
_draw 3 "$*"
sleep 0.5
}

# ***
_usage(){
# *** print usage message to client window and exit

_draw 5 "Script to $COMMAND SPELL DIRECTION COMMAND_PAUSE ."
_draw 5 "Syntax:"
_draw 5 "script $0 <spell> <dir> <pause>"
_draw 5 "For example: 'script $0 firebolt east 10'"
_draw 5 "will issue cast firebolt"
_draw 5 "and will issue the $COMMAND east command with a pause of 10 seconds in between."
_draw 3 "WARNING:"
_draw 4 "Loops forever - use scriptkill command to terminate :P ."
exit 0
}

# ***
_check_have_needed_spell_in_inventory(){
# *** check if spell is applyable - takes some time ( 16 seconds )

_debug "_check_have_needed_spell_in_inventory:$*"
local oneSPELL oldSPELL SPELLS r s ATTYPE LVL SP_NEEDED rest

TIMEB=`date +%s`
#echo watch request
echo request spells
while :;
do
read -t 1 oneSPELL
 _log "$oneSPELL"
 _debug "$oneSPELL"

 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break

 SPELLS="$SPELLS
$oneSPELL"
 oldSPELL="$oneSPELL"
sleep 0.1
done

unset oldSPELL oneSPELL
#echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s"

#SPELL_LINE=`echo "$SPELLS" | grep -i "$SPELL"`

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$SPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i "$SPELL"
}

# *** unused - leftover from cf_fire_item.sh
_check_have_needed_spell_applied(){
# ***
_debug "_check_have_needed_spell_applied:$*"

local oneSPELL oldSPELL SPELLSA

#echo watch request
echo request spells
while :;
do
read -t 1 oneSPELL
_log "$oneSPELL"
_debug "$oneSPELL"

 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break

 SPELLSA="$SPELLSA
$oneSPELL"
 oldSPELL="$oneSPELL"
sleep 0.1
done

unset oldSPELL oneSPELL
#echo unwatch request

echo "$SPELLSA" | grep -q -i "$SPELL"
}

# ***
_probe_enemy(){
# ***
_debug "_probe_enemy:$*"
if test ! "$HAVE_APPLIED_PROBE"; then
#_debug "issue 1 1 apply rod of probe"
   _is 1 1 apply rod of probe
   # TODO: read drawinfo if successfull ..
fi
_is 1 1 fire $DIRECTION_NUMBER
_is 1 1 fire_stop
HAVE_APPLIED_PROBE=1
}

# ***
_apply_needed_spell(){
# *** apply the spell that was given as parameter
# *   does not cast - actual casting is done by 'fire'
#_debug "_apply_needed_spell:issue 1 1 cast $SPELL"
                        _is 1 1 cast $SPELL
}

# *** unused
__watch_food(){
# *** watch food and spellpoint level
# *   apply FOOD if under threshold FOOD_STAT_MIN

#echo watch request
echo request stat hp
read -t 1 statHP
 _debug "__watch_food:$statHP"
   _log "__watch_food:$statHP"

 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "__watch_food:FOOD_STAT=$FOOD_STAT"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi
#echo unwatch request
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"

local REPLY_RANGE oldREPLY_RANGE

#echo watch request range
while :;
do
_debug "_rotate_range_attack:request range"
echo request range
sleep 1
read -t 1 REPLY_RANGE
 _log "REPLY_RANGE=$REPLY_RANGE"
 _debug "$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$PELL"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break
 #_debug "issue 1 1 rotateshoottype"
    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
#echo unwatch request
}

# ***
_do_emergency_recall(){
# *** apply rod of word of recall if hit-points are below HP_MAX /10
# *   fire and fire_stop it
# *   alternatively one could apply rod of heal, scroll of restoration
# *   and ommit exit ( comment 'exit 5' line by setting a '#' before it)
# *   - something like that
#_debug "issue 1 1 apply rod of word of recall"
  _is 1 1 apply "rod of word of recall"
  _is 1 1 fire 0
  _is 1 1 fire_stop
## apply bed of reality
# sleep 10
# echo issue 1 1 apply
exit 5
}

# *** stub to switch wizard-cleric spells in future
_watch_wizard_spellpoints(){
# ***

_debug "_watch_wizard_spellpoints:$*:SP=$SP SP_MAX=$SP_MAX"

if [ "$SP" -le 0 ]; then
   return 6
 elif [ "$SP" -lt $SP_NEEDED ]; then
   return 6
 elif [ "$SP" -lt $SP_MAX ]; then
   return 4
 elif [ "$SP" -eq $SP_MAX ]; then
   return 0
 fi

test "$SP" -ge $((SP_MAX/2)) || return 3
}

# *** stub to switch wizard-cleric spells in future
_watch_cleric_gracepoints(){
# ***

_debug "_watch_cleric_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"

if [ "$GR" -le 0 ]; then
   return 6
 elif [ "$GR" -lt $GR_NEEDED ]; then
   return 6
 elif [ "$GR" -th $GR_MAX ]; then
   return 4
 elif [ "$GR" -eq $GR_MAX ]; then
   return 0
 fi

test "$GR" -ge $((GR_MAX/2)) || return 3

}

# *** stub to issue use_skill praying
_pray_up_gracepoints(){
# ***

_debug "_pray_up_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"
PRAYS=$((GR_MAX-GR))
local c=0
while :;
do
c=$((c+1))
#_debug "issue 1 1 use_skill praying"
   _is 1 1 use_skill praying
sleep 1
test $c = $PRAYS && break
done

}


# ***
_watch_food(){
# *** controlling function : Probably not needed for high-level characters with
# *   high armour class , resistances and high sustainance level
# *   Sends stat hp request
# *   Applies foood if neccessary
# *   Does switch to _do_emergency_recall if necessary
# *   Does switch to _watch_wizard_spellpoints
# *   TODO : implement a counter to call it every Yth time, not every time

#echo watch request

echo request stat hp
read -t1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_STAT
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT HP=$HP SP=$SP"
 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
  #_debug "issue 0 0 apply $FOOD"
     _is 0 0 apply $FOOD
   sleep 1
 fi

#echo unwatch request

 if test $HP -lt $((HP_MAX/10)); then
  _do_emergency_recall
 fi

 ## Now done in _watch_wizard_spellpoints()
 #if [ "$SP" -le 0 ]; then
 #  return 6
 #elif [ "$SP" -lt $SP_NEEDED ]; then
 #  return 6
 #elif [ "$SP" -lt $SP_MAX ]; then
 #  return 4
 #elif [ "$SP" -eq $SP_MAX ]; then
 #  return 0
 #fi
#echo unwatch request
 #test "$SP" = $SP_MAX || return 3
 #test "$SP" -ge $((SP_MAX/2)) || return 3

_watch_wizard_spellpoints
return $?
}

# ***
_regenerate_spell_points(){
# ***

_draw 4 "Regenerating spell points.."
while :;
do

sleep 20s
_watch_food && break
_verbose "Still regenerating to spellpoints $SP -> $((SP_MAX/2)) .."
done

}

# *** both STATS and PROBE
_counter_for_checks(){
# ***
_debug "_counter_for_checks:$*:$PROBE:$STATS:$check_c"

check_c=$((check_c + 1))

if test "$PROBE" -a "$STATS"; then
test $check_c -eq $(( (CHECK_COUNT*2) - 1)) || { test $check_c -eq $((CHECK_COUNT*2)) && unset check_c; }
elif test "$PROBE" -o "$STATS"; then
test $check_c -eq $CHECK_COUNT && unset check_c
else false
fi

#_debug "_counter_for_checks:$*:$PROBE:$STATS:$check_c"
#test $check_c -eq $CHECK_COUNT && unset check_c
}

# *** STATS
__counter_for_checks(){
# ***
#test "$check_c" -eq $CHECK_COUNT && unset check_c
check_c=$((check_c+1))
test $check_c -eq $CHECK_COUNT && unset check_c
}

# *** PROBE
__counter_for_checks2(){
# ***
#test "$check_c2" -eq $CHECK_COUNT && unset check_c
check_c2=$((check_c2+1))
test $check_c2 -eq $CHECK_COUNT && unset check_c2
}


# ***
_do_loop(){
# ***

TIMES=`date +%s`

while :;
do

 #TIMEB=`date +%s`
 TIMEB=${TIMEE:-$TIMES}

# user could change range attack while pausing ...
 _apply_needed_spell

# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters._apply_needed_spell
 #_debug "_do_loop:issue 1 1 $COMMAND $DIRECTION_NUMBER"
               _is 1 1 $COMMAND $DIRECTION_NUMBER
               _is 1 1 $COMMAND_STOP
 sleep $COMMAND_PAUSE

 if test "$STATS"; then
 if _counter_for_checks; then
 _watch_food
 case $? in 6)
  _regenerate_spell_points
 esac
 fi
 fi

 test "$PROBE" && { _counter_for_checks && { _probe_enemy; sleep 1.5; }; }

 TRIES_STILL=$((NUMBER-one))
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEB))
 TIMET=$((TIMEE-TIMES))
 TIMET=$(( (TIMET/60) +1))


 count=$((count+1))
 _draw 4 "Elapsed $TIME s, now being the $count lap ($TIMET m total time) ..."

done
#_debug "_do_loop:issue 0 0 $COMMAND_STOP"
            _is 0 0 $COMMAND_STOP
}

# ***
_error(){
# ***

RV=$1;shift
_draw 3 "$*"
exit $RV
}

# *** main *** #
_do_program(){
# ***

_parse_parameters "$@"
SPELL=${SPELL:-"$SPELL_DEFAULT"}
DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}
COMMAND_PAUSE=${COMMAND_PAUSE:-"$COMMAND_PAUSE_DEFAULT"}

_check_have_needed_spell_in_inventory && { _apply_needed_spell || _error 1 "Could not apply spell."; } || _error 1 "Spell is not in inventory"
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
_do_loop $COMMAND_PAUSE
}

# ***

until test $# = 0; do
case $1 in
-h|*help*) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
'') _draw 3 "Script needs <spell> <direction> and <number of $COMMAND pausing> as argument.";;
*) _do_program "$@"; break;;
esac
shift
sleep 0.1
done

# *** Here ends program *** #
_draw 2 "$0 is finished."
