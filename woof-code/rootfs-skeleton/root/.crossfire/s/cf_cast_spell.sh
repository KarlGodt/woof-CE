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
PROBE_DO=1  # apply rod of probe in firing direction after firing
PROBE_ITEM='rod of probe'
STATS_DO=1     # check hp, sp and food level
CHECK_COUNT_FOOD=10 # only run every yth time a check for food level and sp points
CHECK_COUNT_PROBE=1 # and probe PROBE_ITEM

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


_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"$lFILE"
}

_debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$@"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

# ***
_usage(){
# *** print usage message to client window and exit

_draw 5 "Script to $COMMAND SPELL DIRECTION COMMAND_PAUSE ."
_draw 5 "Syntax:"
_draw 5 "script $0 <spell> <dir> <pause>"
_draw 5 "For example: 'script $0 firebolt east 10'"
_draw 5 "will issue cast firebolt"
_draw 5 "and will issue the $COMMAND east command"
_draw 5 "with a pause of 10 seconds in between to regenerate mana/grace."
_draw 3 "WARNING:"
_draw 4 "Loops forever - use scriptkill command to terminate :P ."
_draw 5 "Options:"
_draw 2 "-P  for praying spell and to pray between casts."
_draw 2 "-s <OPTION> to pass parameter to spell"
_draw 2 "   ie 'spider' to summon pet monster"
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_FILE ."
_draw 5 "-v to say what is being issued to server."

exit 0
}

# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid:$$ (parentpid:$PPID)"

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
*) _error 2 "Invalid direction '$*'"
esac

}

# ***
__parse_parameters(){
# *** parameters to script: "spell_name" "direction_to_cast_to" "pausing_between_casts"
# *   We do a ^normal^ logic :
# *   Since the spell could contain endless words ie: "summon pet monster water elemental"
# *   it needs to use 'rev' to revert the positional parameter line
# *   and re-set to parameter line using 'set'
# *   and then 'rev' each parameter again
# *   TODO : add more parameters

_debug "__parse_parameters:$*"
PARAMS=`echo $* | rev`
set - $PARAMS
_debug "_parse_parameters:$*"
local c=0

until test $# = 0; do
c=$((c+1))
case $c in
1) #readonly
COMMAND_PAUSE=`echo $1 | rev`;;
2) #readonly
DIRECTION=`echo $1 | rev`;;
3) #readonly
SPELL=`echo $@ | rev`;;
4) :;;
5) :;;
6) :;;
esac
shift
done

_debug "__parse_parameters:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
}

_parse_parameters(){
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

#readonly
DIRECTION="$DIR"
#readonly
SPELL=`echo -n $SPELL`

_debug "_parse_parameters:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
}


# ***
_check_have_needed_spell_in_inventory(){
# *** check if spell is applyable - takes some time ( 16 seconds )

_debug "_check_have_needed_spell_in_inventory:$*"

local lSPELL=${*:-"$SPELL"}
local oneSPELL oldSPELL SPELLS r s ATTYPE LVL rest

_draw 5 "Checking if have '$SPELL' ..."
_draw 5 "Please wait...."

TIMEB=`date +%s`
#echo watch request
echo request spells
while :;
do
read -t 1 oneSPELL
 _log "_check_have_needed_spell_in_inventory:$oneSPELL"
 _debug "$oneSPELL"

 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break

 SPELLS="$SPELLS
$oneSPELL"
 oldSPELL="$oneSPELL"
sleep 0.1
done

#unset oldSPELL oneSPELL
#echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_debug "_check_have_needed_spell_in_inventory:Elapsed '$TIME' s."

#SPELL_LINE=`echo "$SPELLS" | grep -i "$SPELL"`

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$SPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i "$lSPELL"
}

# *** unused - leftover from cf_fire_item.sh
_check_have_needed_spell_applied(){
# ***
_debug "_check_have_needed_spell_applied:$*"

local lSPELL=${*:-"$SPELL"}
local oneSPELL oldSPELL SPELLSA

_draw 5 "Checking if have '$SPELL' applied ..."
_draw 5 "Please wait...."

#echo watch request
echo request spells
while :;
do
read -t 1 oneSPELL
_log "_check_have_needed_spell_applied:$oneSPELL"
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

echo "$SPELLSA" | grep -q -i "$lSPELL"
}

# ***
_probe_enemy(){
# ***
_debug "_probe_enemy:$*"

#if test ! "$HAVE_APPLIED_PROBE"; then
   _is 1 1 apply -u $PROBE_ITEM
    sleep 0.2
   _is 1 1 apply -a $PROBE_ITEM  # 'rod of probe' should also apply heavy rod
   # TODO: read drawinfo if successfull ..
#fi

_is 1 1 fire $DIRECTION_NUMBER
_is 1 1 fire_stop
#HAVE_APPLIED_PROBE=1 # see TODO above
}

# ***
_apply_needed_spell(){
# *** apply the spell that was given as parameter
# *   does not cast - actual casting is done by 'fire'

_is 1 1 cast $SPELL $SPELL_PARAM
}

# *** unused
__watch_food(){
# *** watch food and spellpoint level
# *   apply FOOD if under threshold FOOD_STAT_MIN

#echo watch request
echo request stat hp
read -t 1 statHP
 _debug "$statHP"
   _log "__watch_food:$statHP"

 FOOD_STAT=`echo $statHP | awk '{print $NF}'`
 _debug "FOOD_STAT=$FOOD_STAT"

 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
     _is 0 0 apply $FOOD
   sleep 1
 fi
#echo unwatch request
}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"

local REPLY_RANGE oldREPLY_RANGE

_draw 5 "Checking if have '$SPELL' ready..."
_draw 5 "Please wait...."

#echo watch request range
while :;
do
#_debug "_rotate_range_attack:request range"
echo request range
sleep 1
read -t 1 REPLY_RANGE
 _log "_rotate_range_attack:REPLY_RANGE=$REPLY_RANGE"
 _debug "$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$SPELL"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break

    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done
#echo unwatch request
}

# ***
_do_emergency_recall(){
# *** apply rod of word of recall if hit-points are below HP_MAX /5
# *   fire and fire_stop it
# *   alternatively one could apply rod of heal, scroll of restoration
# *   and ommit exit ( comment 'exit 5' line by setting a '#' before it)
# *   - something like that

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
   : #return 4
 elif [ "$SP" -eq $SP_MAX ]; then
   return 0
 fi

#test "$SP" -ge $((SP_MAX/2)) || return 3
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
 elif [ "$GR" -lt $GR_MAX ]; then
   : #return 4
 elif [ "$GR" -eq $GR_MAX ]; then
   return 0
 fi

#test "$GR" -ge $((GR_MAX/2)) || return 3
test "$GR" -ge $((GR_MAX/2)) || return 6
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
_watch_food(){  # called by _do_loop if _conter_for_checks returns 0
                # called by _regenerate_spell_points and breaks it if returns 0
# *** controlling function : Probably not needed for high-level characters with
# *   high armour class , resistances and high sustainance level
# *   Sends stat hp request
# *   Applies foood if neccessary
# *   Does switch to _do_emergency_recall if necessary
# *   Does switch to _watch_wizard_spellpoints
# *   TODO : implement a counter to call it every Yth time, not every time

#echo watch request

local r s h HP HP_MAX FOOD_STAT

echo request stat hp
read -t 1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_STAT

 _debug "_watch_food:FOOD_STAT=$FOOD_STAT HP=$HP SP=$SP"

 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
     _is 0 0 apply $FOOD
   sleep 1
 fi

#echo unwatch request

 if test $HP -lt $((HP_MAX/5)); then  #
  _do_emergency_recall
 fi

 if test "$PRAY_DO"; then
  _watch_cleric_gracepoints
 else
  _watch_wizard_spellpoints
 fi

return $?
}

# ***
_regenerate_spell_points(){  # called by _do_loop if
# ***

_draw 4 "Regenerating spell points.."
while :;
do

sleep 20s
_watch_food && break
_verbose "Still regenerating to spellpoints $SP -> $((SP_MAX/2)) .."
done

}

# *** both STATS_DO and PROBE_DO
_counter_for_checks(){
# ***
_debug "_counter_for_checks:$*:$PROBE_DO:$STATS_DO:$check_c"

check_c=$((check_c + 1))

if test "$PROBE_DO" -a "$STATS_DO"; then
test $check_c -eq $(( (CHECK_COUNT*2) - 1)) || { test $check_c -eq $((CHECK_COUNT*2)) && unset check_c; }
elif test "$PROBE_DO" -o "$STATS_DO"; then
test $check_c -eq $CHECK_COUNT && unset check_c
else false
fi

#_debug "_counter_for_checks:$*:$PROBE_DO:$STATS_DO:$check_c"
#test $check_c -eq $CHECK_COUNT && unset check_c
}

# *** STATS_DO
_counter_for_checks1(){
# ***
#test "$check_c" -eq $CHECK_COUNT && unset check_c
check_c1=$((check_c1+1))
test $check_c1 -eq $CHECK_COUNT_FOOD && unset check_c1
}

# *** PROBE_DO
_counter_for_checks2(){
# ***
#test "$check_c2" -eq $CHECK_COUNT && unset check_c
check_c2=$((check_c2+1))
test $check_c2 -eq $CHECK_COUNT_PROBE && unset check_c2
}


# ***
_do_loop(){
# ***
_debug "_do_loop:$*"

local sc=0

TIMEB=`date +%s`

while :;
do

 #TIMEB=`date +%s`
 TIMEC=${TIMEE:-$TIMEB}

# user could change range attack while pausing ...
 _apply_needed_spell

# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.

 _is 1 1 $COMMAND $DIRECTION_NUMBER
 _is 1 1 $COMMAND_STOP

 #sleep $COMMAND_PAUSE
 sc=0
 while :; do
  sleep 1
  _debug "PRAY_DO='$PRAY_DO'"
  test "$PRAY_DO" && _is $PRAY_DO 1 use_skill praying
  sc=$((sc+1))
  test "$sc" -le $COMMAND_PAUSE || break
 done

 if test "$STATS_DO"; then
 if _counter_for_checks1; then
 _watch_food  # calls either _watch_cleric_gracepoints OR _watch_wizard_spellpoints
 case $? in 6)
  _regenerate_spell_points;;
 esac
 fi
 fi

 test "$PROBE_DO" && { _counter_for_checks2 && { _probe_enemy; sleep 1.5; }; }

 one=$((one+1))

 #TRIES_STILL=$((NUMBER-one))  # unused
 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEC))
 TIMET=$((TIMEE-TIMEB))
 TIMET=$(( (TIMET/60) +1))


 count=$((count+1))
 _draw 4 "Elapsed $TIME s., finished the $count lap ($TIMET m total time) ..."

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

# ***


case $* in
'') _draw 3 "Script needs <spell> <direction> and <number of $COMMAND pausing> as argument.";;
*) _do_program "$@";;
esac

# *** Here ends program *** #
_draw 2 "$0 is finished."
