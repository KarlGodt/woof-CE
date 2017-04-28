#!/bin/ash
# *** script to cast wizard spell - praying spells need -P option passed
# *   written May 2015 by Karl Reimer Godt, overhauled April 2017
# * Uses busybox almquist shell as interpreter - should work with bash
# * busybox ash can be configured with options - and some internal functions
# * may not be implemented by the distribution
# * Use 'scripts' to check if it is still running
# * This script loops forever,
# * use 'scriptkill' to terminate it -
# * otherwise should be terminated when the computer shuts down,
# * but your character may die of starvation if FOOD runs out
# * Purpose : Place the character in a chamber with generators and
# * where the character cannot be killed by monsters.
# * Then fire a spell in the desired direction all the time until termination.
# * Syntax : script_name <spell name <option>> <direction to cast to> <pause between firings>
# * spell name option is space delimited;
# * direction to cast to are center, north, northeast, east, southeast, south, southwest, west, northwest,
# * direction to cast to is a whole word without delimter;
# * pause between firing is used to pause between firings,
# * pause between firing is an integer value: 1,2,3,4,5 are usable for me,
# * larger pause values make monsters regenerate hp too much, smaller may not generate enough monsters to be effective ( cone spells )
# * - Remember : Dependent on the complexity of the code the pausing sleep value given can increase by one to three seconds currently.
# * CAUTION : Does not handle "You bungle the spell" events (yet) - so make sure no two-handed weapon applied
# * Also high armour class and armour resistances may be of some use
# * While the script is running, the character can level up, while you are multi-tasking or taking a shower :)
# * This script applies PROBE_ITEM if PROBE_DO is set

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

# *** Variables : Most are set or unset ( set meaning have content ( even " " )) , unset no content
# *** common editable variables
#VERBOSE=1  # be a bit talkactive
#DEBUG=1    # print gained values
#LOGGING=1  # print to a file - especially large requests like inv
PROBE_DO=1     # apply PROBE_ITEM in firing direction after firing
PROBE_ITEM='rod of probe'
STATS_DO=1     # check hp, sp and food level
CHECK_COUNT=1  # only run every yth time a check for food and probe

# *** common variables
#readonly
TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
#readonly
LOG_FILE="$TMP_DIR"/cf_spells.$$.log


# *** uncommon non-editable variables *** #
readonly DIRECTION_DEFAULT=center  # center: if fighting spell suicide ?
readonly NUMBER_DEFAULT=10         # unused
readonly SPELL_DEFAULT='create food'     # casts 'create food'
readonly SPELL_DEFAULT_PARAM='waybread'  # with 'waybread' as parameter
readonly COMMAND=fire
readonly COMMAND_STOP=fire_stop
readonly COMMAND_PAUSE_DEFAULT=4   # seconds between castings
readonly FOOD_STAT_MIN=300         # at 200 starts to beep
readonly FOOD=waybread  # make sure to have enough/amulet of Sustenance if leaving PC for several hours

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
#ls "${MY_SELF%/*}"/cf_functions.sh
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

# ***
_usage(){
# *** print usage message to client window and exit

_draw 5 "Script to $COMMAND SPELL DIRECTION COMMAND_PAUSE ."
_draw 5 "Syntax:"
_draw 5 "script $0 <<spell>> <<dir>> <<pause>>"
_draw 5 "For example: 'script $0 firebolt east 10'"
_draw 5 "will issue cast firebolt"
_draw 5 "and will issue the $COMMAND east command"
_draw 5 "with a pause of 10 seconds in between to regenerate mana/grace."
_draw 8 "Defaults:"
_draw 8 " Without any parameters would use these defaults:"
_draw 8 " $SPELL_DEFAULT $SPELL_DEFAULT_PARAM $DIRECTION_DEFAULT $COMMAND_PAUSE_DEFAULT"
_draw 3 "WARNING:"
_draw 3 "Loops forever - use scriptkill command to terminate :P ."
_draw 5 "Options:"
_draw 2 "-P  for praying spell and to pray between casts."
_draw 2 "-s <OPTION> to pass parameter to spell"
_draw 2 "   ie 'spider' to summon pet monster"
_draw 2 "-f  to not check if spell is known (force)"
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_FILE ."
_draw 5 "-v to say what is being issued to server."

exit 0
}

# *** functions list

# ***
_direction_word_to_number(){  # cast by _do_program before _do_loop
# *** converts direction-word to global program-understandable number
# * Syntax : _direction_word_to_number WORD
# * return : not used
# * generates : DIRECTION_NUMBER

local lDIRECTION
lDIRECTION=${1:-$DIRECTION}
lDIRECTION=${lDIRECTION:-$DIRECTION_DEFAULT}

case $lDIRECTION in
 0|c|center)    readonly DIRECTION_NUMBER=0;;
 1|n|north)     readonly DIRECTION_NUMBER=1;;
2|ne|northeast) readonly DIRECTION_NUMBER=2;;
 3|e|east)      readonly DIRECTION_NUMBER=3;;
4|se|southeast) readonly DIRECTION_NUMBER=4;;
 5|s|south)     readonly DIRECTION_NUMBER=5;;
6|sw|southwest) readonly DIRECTION_NUMBER=6;;
 7|w|west)      readonly DIRECTION_NUMBER=7;;
8|nw|northwest) readonly DIRECTION_NUMBER=8;;
*) _error 2 "Invalid direction '$*'"
esac

return 0
}

_parse_parameters(){  # first function run by _do_program
_debug "_parse_parameters:$*"

until [ $# = 0 ];
do
PARAM_1="$1"
case $PARAM_1 in

[0-9]*) #readonly
COMMAND_PAUSE=$PARAM_1;;

*help|*usage)   _usage;;
 c|center)      DIR=center;    DIRN=0;; # readonly DIR DIRN;;
 n|north)       DIR=north;     DIRN=1;; # readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2;; # readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3;; # readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4;; # readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5;; # readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6;; # readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7;; # readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8;; # readonly DIR DIRN;;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)    DEBUG=$((DEBUG+1));;
      --fast)  SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --force) FORCE=$((FORCE+1));;
      --log*)  LOGGING=$((LOGGING+1));;
      --pray*) PRAY_DO=$((PRAY_DO+1));;
      --slow)  SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --spell*=*) SPELL_PARAM=`echo "$PARAM_1" | cut -f2- -d'='`;;
      --spell*)   SPELL_PARAM="$2"; shift;;
      --usage)  _usage;;
      --verb*) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`echo "$PARAM_1" | sed -r 's/^-*//; s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
    _debug "oneOP='$oneOP'"
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      F) SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      f) FORCE=$((FORCE+1));;
      L) LOGGING=$((LOGGING+1));;
      P) PRAY_DO=$((PRAY_DO+1));;
      s) SPELL_PARAM="$2"; shift;;
      S) SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

[a-z]|[A-Z]) _red "Ignoring unrecognized option '$PARAM_1'";;

*) SPELL="${SPELL}$PARAM_1 ";;

esac
sleep 0.1
shift
done

DIRECTION="$DIR"
SPELL=`echo -n $SPELL`

test "$FORCE" && CHECK_NO=1
_debug "_parse_parameters:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _draw 3 "Warning: Using defaults."
}

# ***
_do_loop(){  # last function call of _do_program
# ***
_debug "_do_loop:$*"

local lCOMMAND_PAUSE
lCOMMAND_PAUSE=${1:-$COMMAND_PAUSE}
lCOMMAND_PAUSE=${lCOMMAND_PAUSE:-$COMMAND_PAUSE_DEFAULT}
lCOMMAND_PAUSE=${lCOMMAND_PAUSE:-10}

local sc=0

TIMEB=`date +%s`

while :;
do

 TIMEC=${TIMEE:-$TIMEB}

# user could change range attack while pausing ...
 _apply_needed_spell

# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.

#TODO : Something blocks your magic.

 _is 1 1 $COMMAND $DIRECTION_NUMBER
 _is 1 1 $COMMAND_STOP

 sc=0
 while :; do
  sleep 1
  _debug "PRAY_DO='$PRAY_DO'"
  test "$PRAY_DO" && _is $PRAY_DO 1 use_skill praying
  sc=$((sc+1))
  test "$sc" -le $lCOMMAND_PAUSE || break
 done

 if _counter_for_checks; then

 if test "$STATS_DO"; then
 _watch_food  # calls either _watch_cleric_gracepoints OR _watch_wizard_spellpoints
 case $? in 6)
  _regenerate_spell_points;;
 esac
 fi

 if test "$PROBE_DO"; then
  _probe_enemy; sleep 1.5;
 fi

 fi

 one=$((one+1))

 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEC))
 TIMET=$((TIMEE-TIMEB))
 TIMET=$(( (TIMET/60) +1))

 _draw 4 "Elapsed $TIME s., finished the $one lap ($TIMET m total time) ..."

done

 _is 0 0 $COMMAND_STOP
}

# ***
_error(){ # cast by _do_program, _direction_word_to_number, _parse_parameters
# ***

RV=$1;shift
_draw 3 "$*"
exit $RV
}

# *** main *** #
_do_program(){
# ***

_parse_parameters "$@" # should generate global vars SPELL DIRECTION COMMAND_PAUSE
readonly SPELL=${SPELL:-"$SPELL_DEFAULT"}
readonly DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}
readonly COMMAND_PAUSE=${COMMAND_PAUSE:-"$COMMAND_PAUSE_DEFAULT"}

if test ! "$SPELL_PARAM"; then
 if test "$SPELL" = "$SPELL_DEFAULT"; then
  SPELL_PARAM="$SPELL_DEFAULT_PARAM"
 fi
fi
readonly SPELL_PARAM

_check_have_needed_spell_in_inventory && { _apply_needed_spell || _error 1 "Could not apply spell."; } || _error 1 "Spell is not in inventory"
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
_do_loop $COMMAND_PAUSE
}


# *** Here begins program *** #
_say_start_msg

case $* in
*) _do_program "$@";;
esac

# *** Here ends program *** #
_say_end_msg
