#!/bin/bash
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

# 2018-01-10 : Code reorderings,
# recognize :punct: given to parameters as
# <create food> or "holy word"
# speed up the read loop for the inventory
# from sleep 0.1 to sleep 0.01 (now 4 sec inst 29 sec)
# TODO : request spells only sends 'request spells end'
#  but no other lines to the script in the client v1.60.0,
#  v1.70.0 works.
#  This seems related switching the character without
#  closing and restarting the client.

VERSION=0.0 # initial versions
VERSION=1.0 # usung readonly variables
VERSION=1.1 # added -o parameter option to spells
VERSION=2.0 # recognize more options
# switch cleric/wizzard spells by SPELL_KIND
VERSION=3.0 # use external function files
VERSION=3.1 # smaller code overhauling
VERSION=4.0 # renamed own functions to *_stdalone
# to distinguish from functions from sourced files

export PATH=/bin:/usr/bin

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables $*

test -f "${MY_SELF%/*}"/cf_funcs_common.sh && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables $*

test -f "${MY_SELF%/*}"/cf_funcs_food.sh   && . "${MY_SELF%/*}"/cf_funcs_food.sh

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf  && . "${MY_SELF%/*}"/"${MY_BASE}".conf


# *** Variables : Most are set or unset ( set meaning have content ( even " " ) , unset no content
# *** common editable variables
VERBOSE=1  # be a bit talkactive
DEBUG=1     # print gained values
LOGGING=1  # print to a file - especially large requests like inv
PROBE=1    # apply rod of probe in firing direction after firing
STATS=1    # check hp, sp and food level
CHECK_COUNT=10 #only run every yth time a check for food and probe
SPELL_KIND=wizzard # wizzard or cleric

# *** common variables
readonly TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
readonly LOG_FILE="$TMP_DIR"/cf_spells.$$

# *** uncommon editable variables
readonly DIRECTION_DEFAULT=east
readonly NUMBER_DEFAULT=10
readonly SPELL_DEFAULT='create food waybread'
readonly COMMAND=fire
readonly COMMAND_PAUSE_DEFAULT=4  # seconds
readonly COMMAND_STOP=fire_stop
readonly FOOD_STAT_MIN=400
readonly FOOD=waybread # TODO: Check if FOOD is in inventory
RETURN_ITEM='rod of word of recall'
 PROBE_ITEM='rod of probe'


# early functions
_draw_stdalone(){
    case $1 in [0-9]|1[0-2])
    lCOLOUR="$1"; shift;; esac
    local lCOLOUR=${lCOLOUR:-1} #set default
    local lMSG="$@"
    echo draw $lCOLOUR "$lMSG"
}

__draw_stdalone(){
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

# ***
_usage_stdalone(){
# *** print usage message to client window and exit
_draw 5 "$MY_BASE"
_draw 5 "Script to $COMMAND SPELL DIRECTION COMMAND_PAUSE ."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 2 "Syntax:"
_draw 2 "script $0 <spell> <<-o spell option>> <dir> <pause> <<options>>"
_draw 5 "For example: 'script $0 firebolt east 4'"
_draw 5 "will issue cast firebolt"
_draw 5 "and will issue the $COMMAND east command with a pause of 4 seconds in between."
_draw 2 "Other examples:"
_draw 5 "script $0 create food -o waybread south 9"
_draw 3 "WARNING:"
_draw 4 "Loops forever - use scriptkill command to terminate :P ."
exit 0
}

_say_version_stdalone(){
_draw 2 "$0 Version:${VERSION:-'1.0'}"
exit 0
}

# ***
_error_stdalone(){  # _error 1 "Some error occured"
# ***

RV=$1;shift
eMSG=`echo -e "$*"`
__draw 3 "$eMSG"
exit ${RV:-1}
}

# ***
_log_stdalone(){
# *** echo passed parameters to logfile if LOGGING is set to anything

test "$LOGGING" || return 0
echo "$*" >>"$LOG_FILE"
}

# ***
_verbose_stdalone(){
# ***
test "$VERBOSE" || return 0
case $1 in -s) shift; sleep 0.5;; esac
echo draw 7 "$*"
}

# ***
_debug_stdalone(){
# *** print passed parameters to window if DEBUG is set to anything

test "$DEBUG" || return 0
case $1 in -s) shift; sleep 0.5;; esac
echo draw 3 "$*"
}

__debug_stdalone(){  ##+++2018-01-10
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

_empty_message_stream_stdalone(){
local lREPLY
while :;
do
read -t ${TMOUT:-1} lREPLY
_log "_empty_message_stream:$lREPLY"
case "$lREPLY" in '') break;;
*scripttell*break*)     break ${lREPLY##*?break};;
*scripttell*exit*)      _exit_stdalone 1 $lREPLY;;
*'YOU HAVE DIED.'*) _just_exit_stdalone;;
esac
_debug "_empty_message_stream:$lREPLY"
unset lREPLY
 sleep 0.01
done
}

# *** functions list

#***
_is_stdalone(){
# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.

    _debug "issue $*"
    echo issue "$@"
    sleep 0.2
}

# ***
_direction_word_to_number_stdalone(){
# *** converts direction-word to global program-understandable number
# * Syntax : _direction_word_to_number WORD
# * return : not used
# * generates : DIRECTION_NUMBER
_debug "_direction_word_to_number_stdalone:$*"

case $* in
0|center|centre|c) readonly DIRECTION_NUMBER=0;;
1|north|n)      readonly DIRECTION_NUMBER=1;;
2|northeast|ne) readonly DIRECTION_NUMBER=2;;
3|east|e)       readonly DIRECTION_NUMBER=3;;
4|southeast|se) readonly DIRECTION_NUMBER=4;;
5|south|s)      readonly DIRECTION_NUMBER=5;;
6|southwest|sw) readonly DIRECTION_NUMBER=6;;
7|west|w)       readonly DIRECTION_NUMBER=7;;
8|northwest|nw) readonly DIRECTION_NUMBER=8;;
*) _exit 2 "Invalid direction '$*'";;
esac
}

# ***
____parse_parameters_stdalone(){
# *** parameters to script: "spell name" "directiontocastto" "pausing_between_casts"
# *   We do a ^normal^ logic :
# *   Since the spell could contain endless words ie: "summon pet monster water elemental"
# *   it needs to use 'rev' to revert the positional parameter line
# *   and re-set to parameter line using 'set'
# *   and then 'rev' each parameter again
# *   TODO : add more parameters

_debug "____parse_parameters_stdalone:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "____parse_parameters_stdalone:$*"
local c=0
while test $# != 0; do
c=$((c+1))
case $c in
1) COMMAND_PAUSE=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
2)     DIRECTION=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
3)         SPELL=`echo $@ | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
4) :;;
5) :;;
6) :;;
esac
shift
done

_debug "____parse_parameters_stdalone:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _exit 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
}

___parse_parameters_stdalone(){
# *** parameters to script: "spell name" "directiontocastto" "pausing_between_casts"
# *   We do a ^normal^ logic :
# *   Since the spell could contain endless words ie: "summon pet monster water elemental"
# *   it needs to use 'rev' to revert the positional parameter line
# *   and re-set to parameter line using 'set'
# *   and then 'rev' each parameter again
# *   TODO : add more parameters

_debug "___parse_parameters_stdalone:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "___parse_parameters_stdalone:$*"
local c=0
while test $# != 0; do
c=$((c+1))
case $c in
1) COMMAND_PAUSE=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
2)     DIRECTION=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
3)         SPELL=`echo $@ | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`
    SPELL_OPTION=${SPELL##* -o}
    SPELL_OPTION=`echo $SPELL_OPTION`
    SPELL=${SPELL% -o*}
    SPELL=`echo $SPELL`
    ;;
4) :;;
5) :;;
6) :;;
esac
shift
done

_debug "___parse_parameters_stdalone:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _exit 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
test "${COMMAND_PAUSE//[0-9.,]/}" && _exit 1 "COMMAND_PAUSE not an integer or float"
}


# ***
__parse_parameters_stdalone(){
# *** parameters to script: "spell name" "directiontocastto" "pausing_between_casts"
# *   We do a ^normal^ logic :
# *   Since the spell could contain endless words ie: "summon pet monster water elemental"
# *   it needs to use 'rev' to revert the positional parameter line
# *   and re-set to parameter line using 'set'
# *   and then 'rev' each parameter again
# *   TODO : add more parameters

_debug "__parse_parameters_stdalone:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "__parse_parameters_stdalone:$*"

local c=0
while test $# != 0; do
_debug "\$1=$1"
case $1 in
*--) case $1 in
     pleh--)    _usage_stdalone 0;;
     noisrev--) _say_version 0;;
     esobrev--) VERBOSE=$((VERBOSE+1));;
     gubed--)     DEBUG=$((DEBUG+1));;
     *) _draw 4 "Unrecognized long option '`echo $1 | rev`' .";;
     esac
     shift
     continue
     ;;
*-) case $1 in
    h-) _usage_stdalone 0;;
    V-) _say_version 0;;
    v-) VERBOSE=$((VERBOSE+1));;
    d-)   DEBUG=$((DEBUG+1));;
    *) _draw 4 "Unrecognized short option '`echo $1 | rev`' .";;
    esac
    shift
    continue
    ;;
esac

c=$((c+1))
case $c in
1) COMMAND_PAUSE=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
2)     DIRECTION=`echo $1 | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`;;
3)         SPELL=`echo $@ | sed 'sV^[[:punct:]]VV;sV[[:punct:]]$VV' | rev`

    SPELL_OPTION=${SPELL##* -o}
    _debug "SPELL_OPTION=$SPELL_OPTION"
    SPELL_OPTION=${SPELL_OPTION% -*}  # trailing parameters
    _debug "SPELL_OPTION=$SPELL_OPTION"
    SPELL_OPTION=`echo $SPELL_OPTION`
    _debug "SPELL_OPTION=$SPELL_OPTION"

    MORE_OPTION1="${SPELL_OPTION##*-}-"
    _debug "MORE_OPTION1=$MORE_OPTION1"
    test "$MORE_OPTION1" = "${SPELL_OPTION}-" && unset MORE_OPTION1
    _debug "MORE_OPTION1=$MORE_OPTION1"

    SPELL=${SPELL% -o*}
    _debug "SPELL=$SPELL"
    MORE_OPTION2="${SPELL##*-}-"
    _debug "MORE_OPTION2=$MORE_OPTION2"
    test "$MORE_OPTION2" = "${SPELL}-" && unset MORE_OPTION2
    _debug "MORE_OPTION2=$MORE_OPTION2"

    SPELL=${SPELL% -*}  # trailing parameters
    _debug "SPELL=$SPELL"
    SPELL=`echo $SPELL`
    _debug "SPELL=$SPELL"

    break 1
    ;;
4) :;;
5) :;;
6) :;;
esac
sleep 0.1
shift
done

set -- $MORE_OPTION1 $MORE_OPTION2
_debug "\$*=$*"

while [ "$1" ]
do
_debug "\$1=$1"
case $1 in
--*) :;;
-*)  :;;
esac
sleep 0.1
shift
done

_debug "__parse_parameters_stdalone:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _exit 1 "Missing SPELL or DIRECTION or COMMAND_PAUSE"
test "${COMMAND_PAUSE//[0-9.,]/}" && _exit 1 "COMMAND_PAUSE not an integer or float"
}

_parse_parameters_stdalone(){
#____parse_parameters_stdalone "$@"
# ___parse_parameters_stdalone "$@"
   __parse_parameters_stdalone "$@"
}

# ***
_check_have_needed_spell_in_inventory_stdalone(){
# *** check if spell is applyable - takes some time ( 16 seconds )
_debug "_check_have_needed_spell_in_inventory_stdalone:$*"

TIMEB=`date +%s`

_empty_message_stream
echo request spells
while :;
do
read -t ${TMOUT:-1} oneSPELL
   _log "_check_have_needed_spell_in_inventory_stdalone:$oneSPELL"
 _debug "$oneSPELL"

 case $oneSPELL in $oldSPELL|'') break 1;; esac

 SPELLS="$SPELLS
$oneSPELL"
 oldSPELL="$oneSPELL"

 sleep 0.01
done
unset oldSPELL oneSPELL

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_debug "_check_have_needed_spell_in_inventory_stdalone:Elapsed $TIME s"

# client v.1.60.0 seems not to send spells data
# if character changed without restarting the client ...
case $SPELLS in '') _exit 1 "Did not receive any data for request spells.\nTry restarting the client.";; esac

SPELLS=`echo "$SPELLS" | sed 'sV^$VV'`
__debug "$SPELLS"

test "`echo "$SPELLS" | grep -v 'request spells end'`" || {
    _exit 1 "Did not receive any spells for request spells.\nTry restarting the client."
}

SPELL_LINE=`echo "$SPELLS" | grep -i "$SPELL"`
_debug "SPELL_LINE=$SPELL_LINE"

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$SPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i " ${SPELL}$"
}

# ***
_check_have_needed_spell_in_inventory_debug_stdalone(){
# *** check if spell is applyable - takes some time ( 16 seconds )
_debug "_check_have_needed_spell_in_inventory_debug_stdalone:$*"

TIMEB=`date +%s`

local cnt=0
while :
do
cnt=$((cnt+1))

_empty_message_stream
echo request spells
while :;
do
read -t ${TMOUT:-1} oneSPELL
   _log    "_check_have_needed_spell_in_inventory_debug_stdalone:$cnt:$oneSPELL"
 _debug -s "$cnt:$oneSPELL"

 #test "$oldSPELL" = "$oneSPELL" && break
 #test "$oneSPELL" || break
 case $oneSPELL in $oldSPELL|'') break 1;; esac

 SPELLS="$SPELLS
$oneSPELL"
 oldSPELL="$oneSPELL"

 sleep 0.01
done

unset oldSPELL oneSPELL
#echo unwatch

SPELLS=`echo "$SPELLS" | sed 'sV^$VV'`
__debug "$cnt:$SPELLS"

test "`echo "$SPELLS" | grep -v 'request spells end'`" && break 1
test "$cnt" -ge 9 && break 1

 sleep 0.1
done

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s"

# client v.1.60.0 seems not to send spells data
# if character changed or applied savebed without restarting the client ...
case $SPELLS in '') _exit 1 "Did not receive any data for request spells.\nTry restarting the client.";; esac

SPELLS=`echo "$SPELLS" | sed 'sV^$VV'`
__debug "$SPELLS"

test "`echo "$SPELLS" | grep -v 'request spells end'`" || {
    _exit 1 "Did not receive any spells for request spells.\nTry restarting the client."
}

SPELL_LINE=`echo "$SPELLS" | grep -i "$SPELL"`
_debug "SPELL_LINE=$SPELL_LINE"

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$SPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory_debug_stdalone:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i " ${SPELL}$"
}

# *** unused - leftover from cf_fire_item.sh
_check_have_needed_spell_applied_stdalone(){
# ***
_debug "_check_have_needed_spell_applied_stdalone:$*"

_empty_message_stream
echo request spells
while :;
do
read -t ${TMOUT:-1} oneSPELL
_log "_check_have_needed_spell_applied_stdalone:$oneSPELL"
 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break

 SPELLSA="$SPELLSA
$oneSPELL"
 oldSPELL="$oneSPELL"

sleep 0.01
done
unset oldSPELL oneSPELL

echo "$SPELLSA" | grep -q -i " ${SPELL}$"
}

# ***
_probe_enemy_stdalone(){
# ***
_debug "_probe_enemy_stdalone:$*"

local lPROBE_ITEM=${*:-"$PROBE_ITEM"}
test "$lPROBE_ITEM" || return 0

case $lPROBE_ITEM in
*rod*|*staff*|*wand*|*horn*)
   _is 1 1 apply -u $lPROBE_ITEM
   _is 1 1 apply -a $lPROBE_ITEM
   _is 1 1 fire $DIRECTION_NUMBER
;;
*scroll*)
   _is 1 1 apply $lPROBE_ITEM
;;
*) _is 1 1 invoke $lPROBE_ITEM # assuming spell
;;
esac

_is 1 1 fire_stop
}

# ***
_set_spell_stdalone(){
# *** apply the spell that was given as parameter
# *   does not cast - actual casting is done by 'fire'
 _is 1 1 cast ${1:-"$SPELL"} ${2:-$SPELL_OPTION}
# TODO: Something blocks your spellcasting.
}

# *** unused
__watch_food_stdalone(){
# *** watch food and spellpoint level
# *   apply FOOD if under threshold FOOD_STAT_MIN
_debug "__watch_food_stdalone:$*"

_empty_message_stream
echo request stat hp
read -t ${TMOUT:-1} statHP
 _debug "_watch_food:$statHP"
 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "_watch_food:FOOD_STAT=$FOOD_STAT"

 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
   _is 0 0 apply $FOOD
   sleep 1
 else true
 fi
}

_rotate_range_attack_stdalone(){
_debug "_rotate_range_attack_stdalone:$*"
local REPLY_RANGE oldREPLY_RANGE

_empty_message_stream
while :;
do
_debug "_rotate_range_attack_stdalone:request range"
echo request range
sleep 1
read -t ${TMOUT:-1} REPLY_RANGE
 _log "_rotate_range_attack_stdalone:REPLY_RANGE=$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$SPELL"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break

 _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
}

# ***
_do_emergency_recall_stdalone(){
# *** apply rod of word of recall if hit-points are below HP_MAX /10
# *   fire and fire_stop it
# *   alternatively one could apply rod of heal, scroll of restoration
# *   and ommit exit ( comment 'exit 5' line by setting a '#' before it)
# *   - something like that
_debug "_do_emergency_recall_stdalone:$*"

lRETURN_ITEM=${*:-"$RETURN_ITEM"}
if test "$lRETURN_ITEM"; then
 case $lRETURN_ITEM in
 *rod*|*staff*|*wand*|*horn*)
  _is 1 1 apply -u "$lRETURN_ITEM"
  _is 1 1 apply -a "$lRETURN_ITEM"
  _is 1 1 fire 0
  ;;
 *scroll*)
  _is 1 1 apply "$lRETURN_ITEM"
  ;;
 *) invoke "$lRETURN_ITEM";; # assuming spell
 esac
fi
  _is 1 1 fire_stop

# apply bed of reality
 sleep 6
_is 1 1 apply

exit 5
}

# *** stub to switch wizard-cleric spells in future
_watch_wizard_spellpoints_stdalone(){
# ***
_debug "_watch_wizard_spellpoints_stdalone:$*:SP=$SP SP_MAX=$SP_MAX"

if [ "$SP" -le 0 ]; then
   return 6
 elif [ "$SP" -lt $SP_NEEDED ]; then
   return 6
 elif [ "$SP" -lt $SP_MAX ]; then
   return 4
 elif [ "$SP" -ge $SP_MAX ]; then
   return 0
 fi

test "$SP" -ge $((SP_MAX/2)) || return 3
}

# *** stub to switch wizard-cleric spells in future
_watch_cleric_gracepoints_stdalone(){
# ***

_debug "_watch_cleric_gracepoints_stdalone:$*:GR=$GR GR_MAX=$GR_MAX"

if [ "$GR" -le 0 ]; then
   return 6
 elif [ "$GR" -lt $GR_NEEDED ]; then
   return 6
 elif [ "$GR" -lt $GR_MAX ]; then
   return 4
 elif [ "$GR" -ge $GR_MAX ]; then
   return 0
 fi

test "$GR" -ge $((GR_MAX/2)) || return 3

}

# *** stub to issue use_skill praying
_pray_up_gracepoints_stdalone(){
# ***

_debug "_pray_up_gracepoints_stdalone:$*:GR=$GR GR_MAX=$GR_MAX"
PRAYS=$((GR_MAX-GR))
local c=0
while :;
do
c=$((c+1))
 _is 1 1 use_skill praying
sleep 1
test $c = $PRAYS && break
done
}

_get_inventory_list_stdalone(){
# * Valid requests:
#         *
#         *   player       Return the player's tag and title
#         *   range        Return the type and name of the currently selected range attack
#         *   stat <type>  Return the specified stats
#         *   stat stats   Return Str,Con,Dex,Int,Wis,Pow,Cha
#         *   stat cmbt    Return wc,ac,dam,speed,weapon_sp
#         *   stat hp      Return hp,maxhp,sp,maxsp,grace,maxgrace,food
#         *   stat xp      Return level,xp,skill-1 level,skill-1 xp,...
#         *   stat resists Return resistances
#         *   stat paths   Return spell paths: attuned, repelled, denied.
#         *   weight       Return maxweight, weight
#         *   flags        Return flags (fire, run)
#         *   items inv    Return a list of items in the inventory, one per line
#         *   items actv   Return a list of inventory items that are active, one per line
#         *   items on     Return a list of items under the player, one per line
#         *   items cont   Return a list of items in the open container, one per line
#         *   map pos      Return the players x,y within the current map
#         *   map near     Return the 3x3 grid of the map centered on the player
#         *   map all      Return all the known map information
#         *   map <x> <y>  Return the information about square x,y in the current map
#         *   skills       Return a list of all skill names, one per line (see also stat xp)
#         *   spells       Return a list of known spells, one per line

local lTOPMOST='' lREQUEST=''

while [ "$1" ]
do
case $1 in
-t) lTOPMOST=1;;
-S) lREQUEST=skills;;
-s) lREQUEST=spells;;
-a) lREQUEST="items actv";;
-c) lREQUEST="items cont";;
-i) lREQUEST="items inv";;
-o) lREQUEST="items on";;
-*) :;;
*) break;;
esac

shift
sleep 0.1
done

test "$lREQUEST" || return 253

#[ "$INV_LIST" ] && return 0

local rcnt=0
unset INV_LIST

_empty_message_stream
echo request $lREQUEST
while :
do
 rcnt=$((rcnt+1))
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_get_inventory_list_stdalone:$rcnt:$REPLY"

 INV_LIST="$INV_LIST
$REPLY"

 case $REPLY in
 #*request*items*inv*$lITEM)    lRV=0; break 1;;
 #*request*items*inv*${lITEM}s) lRV=0; break 1;;
 ''|*request*end)    break 1;;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac

test "$TOPMOST" && break 1
sleep 0.01
done

_empty_message_stream

INV_LIST=`echo "$INV_LIST" | sed 'sV^$VV'`
}

_check_if_item_available_stdalone(){ # pos where item
_debug "_check_if_item_available_stdalone:$*"

local lTOPMOST='' lREQUEST=''
while [ "$1" ]
do
case $1 in
-t) lTOPMOST=1;;
-S) lREQUEST=-S;;
-s) lREQUEST=-s;;
-a) lREQUEST=-a;;
-c) lREQUEST=-c;;
-i) lREQUEST=-i;;
-o) lREQUEST=-o;;
-*) :;;
*) break 1;;
esac
shift
sleep 0.1
done

local lITEM="$*"

_debug "lTOPMOST=$lTOPMOST"
_debug "lREQUEST=$lREQUEST"
_debug "lITEM=$lITEM"

#[ "$INV_LIST" ] || _get_inventory_list $lTOPMOST $lREQUEST
_get_inventory_list $lTOPMOST $lREQUEST

if test "$lTOPMOST"; then
 echo "$INV_LIST" | head -n1 | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
else
 echo "$INV_LIST"            | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
fi
}

_check_if_item_in_inventory_stdalone(){
_debug "_check_if_item_in_inventory_stdalone:$*"
local lITEM="$*"
test "$lITEM" || return 254
local lRV=1

_empty_message_stream
echo request items inv
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_item_in_inventory_stdalone:$REPLY"
 case $REPLY in
 *request*items*inv*$lITEM)     lRV=0; break 1;;
 *request*items*inv*${lITEM}s)  lRV=0; break 1;;
 *request*items*inv*${lITEM}es) lRV=0; break 1;; # tomato tomatoes
 ''|*request*items*inv*end)   break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac
sleep 0.01
done

_empty_message_stream
return ${lRV:-1}
}

_check_if_item_in_open_container_stdalone(){
_debug "_check_if_item_open_container_stdalone:$*"
local lITEM="$*"
test "$lITEM" || return 254
local lRV=1

_empty_message_stream
echo request items cont
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_item_in_open_container_stdalone:$REPLY"
 case $REPLY in
 *request*items*cont*$lITEM)     lRV=0; break 1;;
 *request*items*cont*${lITEM}s)  lRV=0; break 1;;
 *request*items*cont*${lITEM}es) lRV=0; break 1;; # tomato tomatoes
 ''|*request*items*cont*end)   break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac
sleep 0.01
done

_empty_message_stream
return ${lRV:-1}
}

_check_if_food_in_inventory_stdalone(){
_debug "_check_if_food_in_inventory_stdalone:$*"
local lRV=1

_empty_message_stream
echo request items inv
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_food_in_inventory_stdalone:$REPLY"
 case $REPLY in
 *request*items*inv*$FOOD)     lRV=0; break 1;;
 *request*items*inv*${FOOD}s)  lRV=0; break 1;;
 *request*items*inv*${FOOD}es) lRV=0; break 1;;  # tomato tomatoes
 ''|*request*items*inv*end)   break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac
sleep 0.01
done

_empty_message_stream
return ${lRV:-1}
}

_check_if_food_on_floor_simple_stdalone(){
_debug "_check_if_food_on_floor_simple_stdalone:$*"
local lRV=1

_empty_message_stream
echo request items on
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_food_on_floor_simple_stdalone:$REPLY"
 case $REPLY in
 *request*items*on*$FOOD)     lRV=0; break 1;;
 *request*items*on*${FOOD}s)  lRV=0; break 1;;
 *request*items*on*${FOOD}es) lRV=0; break 1;;  # tomato tomatoes
 ''|*request*items*on*end)   break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac
sleep 0.01
done

_empty_message_stream
return ${lRV:-1}
}

_check_if_item_on_floor_stdalone(){
_debug "_check_if_item_on_floor_stdalone:$*"
local lITEM="$*"
test "$lITEM" || return 254
local lRV=1 ITEMS_ON=''

_empty_message_stream
echo request items on
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_item_on_floor_stdalone:$REPLY"
 _debug "$REPLY"

 ITEMS_ON="$ITEMS_ON
$REPLY"

 case $REPLY in
 *request*items*on*$lITEM)     lRV=0; break 1;;
 *request*items*on*${lITEM}s)  lRV=0; break 1;;
 *request*items*on*${lITEM}es) lRV=0; break 1;; # tomato tomatoes
 ''|*request*items*on*end)   break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac

 sleep 0.01
done
_empty_message_stream

ITEMS_ON=`echo "$ITEMS_ON" | sed 'sV^$VV'`

echo "$ITEMS_ON" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
}

_check_if_item_on_floor_topmost_stdalone(){
_debug "_check_if_item_on_floor_topmost_stdalone:$*"
local lITEM="$*"
test "$lITEM" || return 254
local lRV=1 ITEMS_ON=''

_empty_message_stream
echo request items on
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_item_on_floor_topmost_stdalone:$REPLY"
 _debug "$REPLY"

 ITEMS_ON="$ITEMS_ON
$REPLY"

 case $REPLY in
 *request*items*on*$lITEM)     lRV=0; break 1;;
 *request*items*on*${lITEM}s)  lRV=0; break 1;;
 *request*items*on*${lITEM}es) lRV=0; break 1;; # tomato tomatoes
 ''|*request*items*on*end)   break ${REPLY##*?break};;
 *scripttell*break*)   break 1;;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac

 sleep 0.01
done
_empty_message_stream

ITEMS_ON=`echo "$ITEMS_ON" | sed 'sV^$VV'`

echo "$ITEMS_ON" | head -n1 | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
}

_check_if_food_on_floor_stdalone(){
_debug "_check_if_food_on_floor_stdalone:$*"
local lRV=1 ITEMS_ON=''

_empty_message_stream
echo request items on
while :
do
 unset REPLY
 read -t ${TMOUT:-1}
 _log "_check_if_food_on_floor_stdalone:$REPLY"

 ITEMS_ON="$ITEMS_ON
$REPLY"

 case $REPLY in
 *request*items*on*$FOOD)     lRV=0; break 1;;
 *request*items*on*${FOOD}s)  lRV=0; break 1;;
 *request*items*on*${FOOD}es) lRV=0; break 1;; # tomato tomatoes
 ''|*request*items*on*end)   break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac

# ITEMS_ON="$ITEMS_ON
#$REPLY"

sleep 0.01
done
_empty_message_stream

ITEMS_ON=`echo "$ITEMS_ON" | sed 'sV^$VV'`

if test "`echo "$ITEMS_ON" | head -n1 | grep -E " $FOOD| ${FOOD}s| ${FOOD}es"`"; then
 :
else
 _is 0 0 get $FOOD
 lRV=1
fi

return ${lRV:-1}
}

_check_if_food_available_stdalone(){
# Here it could switch from FOOD
# on floor tile to FOOD in inventory
_check_if_food_on_floor     && return 4
#_check_if_item_on_floor_topmost $FOOD && return 4
#_check_if_item_on_floor         $FOOD && _is 0 0 get $FOOD
_check_if_food_in_inventory && return 5
#_check_if_item_in_inventory     $FOOD && return 5
return 0
}

__check_if_item_available_stdalone(){
_debug "__check_if_item_available_stdalone:$*"

local lITEM="$*"
test "$lITEM" || return 254

_check_if_item_on_floor_topmost  $lITEM && return 4
_check_if_item_on_floor          $lITEM && _is 0 0 get $lITEM
_check_if_item_in_inventory      $lITEM && return 5
_check_if_item_in_open_container $lITEM && return 6
return 0
}

_do_eat_simple_stdalone(){
     _is 0 0 apply $FOOD
}

_do_eat_stdalone(){
    _debug "_do_eat:$*"
     #_check_if_food_available
     __check_if_item_available $FOOD
     case $? in
     4) _is 0 0 apply;;          # topmost on floor
     5) _is 0 0 apply $FOOD;;    # in inventory
     6) _is 0 0 apply -b $FOOD;; # in open container
     0) _do_emergency_recall;;
    #*) _draw 4 "Unhandled return value from __check_if_food_available";;
     *) _draw 4 "Unhandled return value from __check_if_item_available";;
     esac
}

__do_eat_stdalone(){
    _debug "__do_eat_stdalone:$*"

       if _check_if_item_available -t -o $FOOD; then _is 0 0 apply
     elif _check_if_item_available    -o $FOOD; then _is 0 0 get $FOOD; _is 0 0 apply $FOOD
     else false
       fi
     case $? in 0) _draw 8 "OK, should have eaten $FOOD.";;
     *)
      if _check_if_item_available   -i $FOOD; then _is 0 0 apply $FOOD
      elif _check_if_item_available -c $FOOD; then _is 0 0 apply -b $FOOD
      else _do_emergency_recall
      fi;;
     esac
     #unset INV_LIST
}

# ***
_watch_food_stdalone(){
# *** controlling function : Probably not needed for high-level characters with
# *   high armour class , resistances and high sustainance level
# *   Sends stat hp request
# *   Applies foood if neccessary
# *   Does switch to _do_emergency_recall if necessary
# *   Does switch to _watch_wizard_spellpoints
# *   TODO : implement a counter to call it every Yth time, not every time
_debug "_watch_food_stdalone:$*"

echo request stat hp
read -t ${TMOUT:-1} r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_STAT
 _debug "_watch_food_stdalone:FOOD_STAT=$FOOD_STAT HP=$HP SP=$SP"

 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then

   #_do_eat_simple
   #_do_eat
   __do_eat

   sleep 1
 fi

 #test "$HP" -lt $((HP_MAX/10)) && _do_emergency_recall
 #test "$HP" -gt $((HP_MAX/10)) || _do_emergency_recall
 if test "$HP" -lt $((HP_MAX/10)); then
  _do_emergency_recall
 fi

 if test "$SPELL_KIND" = cleric; then
      _watch_cleric_gracepoints;
 else _watch_wizard_spellpoints;
 fi

return $?
}

# ***
__regenerate_spell_points_stdalone(){
# ***
_debug "__regenerate_spell_points_stdalone:$*"

case $SPELL_KIND in
 cleric)    _draw 4 "Regenerating grace points..";;
 wizzard|*) _draw 4 "Regenerating spell points..";;
esac

while :;
do
#sleep 20s
for i in `seq 1 1 20`; do
 case $SPELL_KIND in
 cleric)    _is 1 1 use_skill praying;;
 wizzard|*) _is 1 1 use_skill meditation;;
 esac
sleep 0.8 # 1 second
done

_watch_food && break 1

case $SPELL_KIND in
 cleric)    _verbose "Still regenerating to gracepoints $GR -> $((GR_MAX)) ..";;
 wizzard|*) _verbose "Still regenerating to spellpoints $SP -> $((SP_MAX)) ..";;
esac

done
}
# ***

___regenerate_spell_points_stdalone(){
# ***
_debug "___regenerate_spell_points_stdalone:$*"

case $SPELL_KIND in
 cleric)    _draw 4 "Regenerating grace points.."
   while :; do
    for i in `seq 1 1 20`; do
    _is 1 1 use_skill praying
    sleep 0.8 # 1 second
    done
   _watch_food && break 1
   _verbose "Still regenerating to gracepoints $GR -> $((GR_MAX)) .."
   done
;;
 wizzard|*) _draw 4 "Regenerating spell points.."
   while :; do
    for i in `seq 1 1 20`; do
    _is 1 1 use_skill meditation
    sleep 0.8 # 1 second
    done
   _watch_food && break 1
   _verbose "Still regenerating to spellpoints $SP -> $((SP_MAX)) .."
   done
;;
esac
}

____regenerate_spell_points_stdalone(){
# ***
_debug "____regenerate_spell_points_stdalone:$*"
 _draw 4 "Regenerating grace and spell points.."

while :;
do

#_watch_food && break 1

#sleep 20s
for i in `seq 1 1 20`; do
  _is 1 1 use_skill praying
  _is 1 1 use_skill meditation
sleep 0.6 # 1 second
done

_watch_food && break 1

 _verbose "Still regenerating to spellpoints $SP -> $((SP_MAX)) .."
 _verbose "Still regenerating to gracepoints $GR -> $((GR_MAX)) .."
done
}

_regenerate_spell_points_stdalone(){
  # __regenerate_spell_points_stdalone
  #___regenerate_spell_points_stdalone
  ____regenerate_spell_points_stdalone
}

# *** both STATS and PROBE
_counter_for_checks_stdalone(){
# ***
_debug "_counter_for_checks_stdalone:$*:$PROBE:$STATS:$ckc"
ckc=$((ckc + 1))

if test "$PROBE" -a "$STATS"; then
#test $ckc -eq $(( (CHECK_COUNT*2) - 1)) || { test $ckc -eq $((CHECK_COUNT*2)) && unset ckc; }
 test $ckc -ge $(( (CHECK_COUNT*2) - 1)) && unset ckc
elif test "$PROBE" -o "$STATS"; then
 test $ckc -eq $CHECK_COUNT && unset ckc
else false
fi
}

# *** STATS
__counter_for_checks_stdalone(){
# ***
ckc=$((ckc+1))
test $ckc -eq $CHECK_COUNT && unset ckc
}

# *** PROBE
__counter_for_checks2_stdalone(){
# ***
ckc2=$((ckc2+1))
test $ckc2 -eq $CHECK_COUNT && unset ckc2
}

# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid $$ $PPID"

# *** main *** #

# ***
_do_loop_stdalone(){  # by _do_program
# ***
_debug "_do_loop_stdalone:$*"

TIMES=`date +%s`

# At the beginning wait to reach max mana and grace
if test "$STATS"; then
 _watch_food
 case $? in 0) :;;
 *) _regenerate_spell_points;;
 esac
fi

while :;
do

 TIMEB=`date +%s`

# user could change range attack while pausing ...
 _set_spell
# TODO: Something blocks your spellcasting.
 _is 1 1 $COMMAND $DIRECTION_NUMBER
 _is 1 1 $COMMAND_STOP
 sleep $COMMAND_PAUSE

 if test "$STATS"; then
  if _counter_for_checks; then
   _watch_food
   case $? in 6) _regenerate_spell_points;;
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

_is 0 0 $COMMAND_STOP
}

_do_program_stdalone(){
# ***
_debug "_do_program_stdalone:$*"

_parse_parameters_stdalone "$@"
readonly SPELL=${SPELL:-"$SPELL_DEFAULT"}
readonly DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}
readonly COMMAND_PAUSE=${COMMAND_PAUSE:-"$COMMAND_PAUSE_DEFAULT"}

_check_have_needed_spell_in_inventory && { _set_spell || _exit 1 "Could not apply spell."; } || _exit 1 "Spell is not in inventory"
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
_do_loop_stdalone $COMMAND_PAUSE
}

# ***

case $@ in
#-h|*help*) _usage_stdalone;;
'') _draw 3 "Script needs <spell> <direction> and <number of $COMMAND pausing> as argument.";;
*) _do_program_stdalone "$@";;
esac

# *** Here ends program *** #
_draw 2 "$0 is finished."
###END###
