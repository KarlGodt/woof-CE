#!/bin/ash
# *** script to cast wizard spell - praying spells need -P option passed
# *   written May 2015 by Karl Reimer Godt, overhauled April 2017, July 2017
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

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script_err.log

export PATH=/bin:/usr/bin

TIMEA=`/bin/date +%s`

# *** Variables : Most are set or unset ( set meaning have content ( even " " )) , unset no content
# *** common editable variables
#VERBOSE=1  # be a bit talkactive
#DEBUG=1    # print gained values
#LOGGING=1  # print to a file - especially large requests like inv
PROBE_DO=1  # apply rod of probe in firing direction after firing
PROBE_ITEM='rod of probe'
STATS_DO=1     # check hp, sp and food level
CHECK_COUNT_FOOD=10 # only run every yth time a check for food lvl and sp/gr points
CHECK_COUNT_PROBE=2 # only run every yth time a probe of the enemy

# *** common variables
#readonly
TMP_DIR=/tmp/crossfire_client/${0##*/}.dir
mkdir -p "$TMP_DIR"
#readonly
LOG_FILE="$TMP_DIR"/cf_cast_spells.$$.log

# *** uncommon non-editable variables *** #
readonly DIRECTION_DEFAULT=center  # center: if fighting spell suicide ?
readonly NUMBER_DEFAULT=10         # unused
readonly SPELL_DEFAULT='create food'     # casts 'create food' with
readonly SPELL_DEFAULT_PARAM='waybread'  # 'waybread' as parameter
readonly COMMAND=fire
readonly COMMAND_STOP=fire_stop
readonly COMMAND_PAUSE_DEFAULT=4   # seconds between castings
readonly FOOD_STAT_MIN=300         # at 200 starts to beep
readonly FOOD=  # apple, food, haggis, waybread, etc from inventory
# make sure to have enough/amulet of Sustenance if leaving PC for several hours
# if FOOD unset (empty), applies topmost item on the ground
#  you might need to leave stack of food and step upon the stack again,
#  to ensure the apply command works

# player could be low on HP ...
ITEM_RECALL='rod of word of recall' #  [wand], staff, scroll, rod of word of recall

DRAW_INFO=drawinfo # drawinfo (older servers) OR drawextinfo (newer servers)

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


# beeping
BEEP_DO=1
BEEP_LENGTH=500
BEEP_FREQ=700

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}


_draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local lMSG="$@"
    echo draw $lCOLOUR "$lMSG"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"$lFILE"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_debug(){
test "$DEBUG" || return 0
_draw ${COL_DEB:-3} "DEBUG:$@"
}

_debugx(){
test "$DEBUGX" || return 0
    _draw ${COL_DEB:-3} "DEBUGX:$@"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***
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
_draw 3 "Without -n X option, loops forever - use scriptkill command to terminate :P ."
_draw 5 "Options:"
_draw 6 "-n NUMBER to limit to NUMBER times casting the spell."
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

# *** Here begins program *** #
_draw 2 "$0 started <$*> with pid:$$ (parentpid:$PPID)"

# *** functions list

# ***
_direction_word_to_number(){
# *** converts direction-word to global program-understandable number
# * Syntax : _direction_word_to_number WORD
# * return : not used
# * generates : DIRECTION_NUMBER

DIRECTION=${1:-$DIRECTION}
DIRECTION=${DIRECTION:-$DIRECTION_DEFAULT}

case $DIRECTION in
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
#test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _draw 3 "Warning: Using defaults."
}


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


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
      --force) FORCE=$((FORCE+1));;
      --log*)  LOGGING=$((LOGGING+1));;
      --number=*) NUMBER=`echo "$1" | cut -f2 -d'='`;;
      --number)   NUMBER="$2"; shift;;
      --pray*) PRAY_DO=$((PRAY_DO+1));;
      --slow)  SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --spell*=*) SPELL_PARAM=`echo "$PARAM_1" | cut -f2- -d'='`;;
      --spell*)   SPELL_PARAM="$2"; shift;;
      --usage)  _usage;;
      --verb*) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`printf '%s' "$PARAM_1" | sed -r 's/^-*//; s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
    _debug "oneOP='$oneOP'"
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      F) SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      f) FORCE=$((FORCE+1));;
      L) LOGGING=$((LOGGING+1));;
      n) NUMBER="$2"; _debugx "n:$*";shift;_debugx "n:$*";;
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

test "$FORCE" && CHECK_NO=1
_debug "_parse_parameters:SPELL=$SPELL DIR=$DIRECTION COMMAND_PAUSE=$COMMAND_PAUSE"
#test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _error 1 "Missing SPELL -o DIRECTION -o COMMAND_PAUSE"
test "$COMMAND_PAUSE" -a "$DIRECTION" -a "$SPELL" || _draw 3 "Warning: Using defaults."
}


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


# ***
_check_have_needed_spell_in_inventory(){
# *** check if spell is applyable - takes some time ( 16 seconds )
[ "$CHECK_NO" ] && return 0

_debug "_check_have_needed_spell_in_inventory:$*"

local lSPELL=${*:-"$SPELL"}
_debug "_check_have_needed_spell_in_inventory:SPELL='$SPELL' lSPELL='$lSPELL'"
test "$lSPELL" || return 3

local oneSPELL oldSPELL SPELLS r s ATTYPE LVL rest

_draw 5 "Checking if have '$lSPELL' ..."
_draw 5 "Please wait...."

TIMEB=`/bin/date +%s`

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

TIMEE=`/bin/date +%s`
TIME=$((TIMEE-TIMEB))
_debug "_check_have_needed_spell_in_inventory:Elapsed '$TIME' s."

#SPELL_LINE=`echo "$SPELLS" | grep -i "$SPELL"`

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$lSPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i "$lSPELL"
}

# *** unused - leftover from cf_fire_item.sh
_check_have_needed_spell_applied(){
# ***
_debug "_check_have_needed_spell_applied:$*"

_debug "_check_have_needed_spell_applied:SPELL='$SPELL' lSPELL='$lSPELL'"
local lSPELL=${*:-"$SPELL"}
_debug "_check_have_needed_spell_applied:SPELL='$SPELL' lSPELL='$lSPELL'"
test "$lSPELL" || return 3

local oneSPELL oldSPELL SPELLSA

_draw 5 "Checking if have '$lSPELL' applied ..."
_draw 5 "Please wait...."

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

#TODO : Something blocks your magic.

_is 1 1 fire $DIRECTION_NUMBER
_is 1 1 fire_stop
#HAVE_APPLIED_PROBE=1 # see TODO above
}


# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***


# ***
_apply_needed_spell(){  # has no params
# *** apply the spell that was given as parameter
# *   does not cast - actual casting is done by 'fire'

#TODO : Something blocks your magic.

_debug "_apply_needed_spell:$*"

_debug "_apply_needed_spell:SPELL='$SPELL' lSPELL='$lSPELL'"

local lSPELL=${*:-"$SPELL"}

_debug "_apply_needed_spell:SPELL='$SPELL' lSPELL='$lSPELL'"

test "$lSPELL" || return 3

_is 1 1 cast $lSPELL $SPELL_PARAM
}

# *** unused
__watch_food(){
# *** watch food and spellpoint level
# *   apply FOOD if under threshold FOOD_STAT_MIN

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

}

_rotate_range_attack(){
_debug "_rotate_range_attack:$*"

local lSPELL=${*:-"$SPELL"}
_debug "_rotate_range_attack:SPELL='$SPELL' lSPELL='$lSPELL'"
test "$lSPELL" || return 3

local REPLY_RANGE oldREPLY_RANGE
local c=0

_draw 5 "Checking if have '$lSPELL' ready..."
_draw 5 "Please wait...."

while :;
do
#_debug "_rotate_range_attack:request range"
echo request range
sleep 1
read -t 1 REPLY_RANGE
 _log "_rotate_range_attack:REPLY_RANGE=$REPLY_RANGE"
 _debug "$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$lSPELL"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break

    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"

c=$((c+1))
test "$c" -ge 8 && return 10
sleep 2.1

done

}

# ***
_do_emergency_recall(){
# *** apply rod of word of recall if hit-points are below HP_MAX /5
# *   fire and fire_stop it
# *   alternatively one could apply rod of heal, scroll of restoration
# *   and ommit exit ( comment 'exit 5' line by setting a '#' before it)
# *   - something like that

test "$ITEM_RECALL" || return 3

  _is 1 1 apply -u "$ITEM_RECALL"
  _is 1 1 apply -a "$ITEM_RECALL"
  _is 1 1 fire 0
  _is 1 1 fire_stop

## apply bed of reality
# sleep 10
# echo issue 1 1 apply

_beep
exit 5
}


# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***


# *** stub to switch wizard-cleric spells in future
_watch_wizard_spellpoints(){
# ***
_debug "_watch_wizard_spellpoints:$*:SP=$SP SP_MAX=$SP_MAX"

test "$SP" -ge $((SP_MAX/2))
}

# *** stub to switch wizard-cleric spells in future
_watch_cleric_gracepoints(){
# ***
_debug "_watch_cleric_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"

test "$GR" -ge $((GR_MAX/2))
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
test $c = ${PRAYS:-9} && break
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

local r s h HP HP_MAX FOOD_STAT

echo request stat hp
read -t 1 r s h HP HP_MAX SP SP_MAX GR GR_MAX FOOD_STAT

 _debug "_watch_food:FOOD_STAT=$FOOD_STAT HP=$HP SP=$SP"

 if test "$FOOD_STAT" -lt $FOOD_STAT_MIN; then
     _is 0 0 apply $FOOD
   sleep 1
 fi

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


# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***


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

local lCOMMAND_PAUSE=${1:-$COMMAND_PAUSE}
lCOMMAND_PAUSE=${lCOMMAND_PAUSE:-$COMMAND_PAUSE_DEFAULT}

local sc=0

TIMEB=`/bin/date +%s`

while :;
do

 #TIMEB=`/bin/date +%s`
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
 one=$((one+1))

 #sleep $lCOMMAND_PAUSE
 sc=0
 while :; do
  sleep 1
  _debug "PRAY_DO='$PRAY_DO'"
  test "$PRAY_DO" && _is $PRAY_DO 1 use_skill praying
  sc=$((sc+1))
  test "$sc" -le $lCOMMAND_PAUSE || break
 done

 if test "$STATS_DO"; then
 if _counter_for_checks1; then
 _watch_food  # calls either _watch_cleric_gracepoints OR _watch_wizard_spellpoints
 case $? in 1)
  _regenerate_spell_points;;
 esac
 fi
 fi

 test "$PROBE_DO" && { _counter_for_checks2 && { _probe_enemy; sleep 1.5; }; }

 #one=$((one+1))

 #TRIES_STILL=$((NUMBER-one))  # unused
 TIMEE=`/bin/date +%s`
 TIME=$((TIMEE-TIMEC))
 TIMET=$((TIMEE-TIMEB))
 TIMET=$(( (TIMET/60) +1))


 count=$((count+1))
 _draw 5 "Elapsed $TIME s., finished the $count lap ($TIMET m total time) ..."

 test "$one" = "$NUMBER" && break

done
#_debug "_do_loop:issue 0 0 $COMMAND_STOP"
            _is 0 0 $COMMAND_STOP
}


# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***
# ***

_handle_spell_errors(){

local lRV=0
 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   lRV=30;;
 '*Something blocks the magic of your scroll.'*) lRV=30;;
 *'Something blocks your spellcasting.'*)        lRV=10;;
 *'Something blocks your magic.'*)               lRV=10;; # spell_effect.c: int probe( .. )
 *'Something blocks the magic of the spell.'*)   lRV=10;; # spell_effect.c: int dimension_door( .. )
 *'This ground is unholy!'*)                     lRV=20;;
 *'You lack the skill evocation'*)               lRV=11;;
 *'You lack the skill pyromancy'*)               lRV=12;;
 *'You lack the skill sorcery'*)                 lRV=13;;
 *'You lack the skill summoning'*)               lRV=14;;
 *'You lack the skill praying'*)                 lRV=20;;
 *'You lack the skill '*)                        lRV=19;;
 *'You lack the proper attunement to cast '*)    lRV=30;;
 *'That spell path is denied to you.'*)          lRV=40;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *'You are no easier to look at.'*)              lRV=111;; # spell_effect.c: static const char *const no_gain_msgs[NUM_STATS] = {
 *"You don't feel any healthier."*)              lRV=112;;
 *'You grow no more agile.'*)                    lRV=113;;
 *'You grow no stronger.'*)                      lRV=114;;
# *) lRV=1;;
esac

case $lRV in
10) # all magic
unset SPELL_DET_MONST
unset SPELL_FAERYFIRE
unset SPELL_CON SPELL_DET_MAGIC SPELL_DEX SPELL_DISARM SPELL_PROBE
;;
11) # evocation
unset SPELL_DET_MONST
;;
12) # pyro
unset SPELL_FAERYFIRE
;;
13) # sorcery
unset SPELL_CON SPELL_DET_MAGIC SPELL_DEX SPELL_DISARM SPELL_PROBE
;;
14) # summon

;;
19) # unknown skill

;;
20) # all praying
unset SPELL_DET_CURSE SPELL_DET_EVIL SPELL_REST SPELL_SHOW_INV
;;
30) # all magic+praying
unset SPELL_DET_MONST
unset SPELL_FAERYFIRE
unset SPELL_CON SPELL_DET_MAGIC SPELL_DEX SPELL_DISARM SPELL_PROBE
unset SPELL_DET_CURSE SPELL_DET_EVIL SPELL_REST SPELL_SHOW_INV
;;
111) # charisma
unset SPELL_CHA
;;
112) # constitution
unset SPELL_CON
;;
113) # dexterity
unset SPELL_DEX
;;
114) # strength
unset SPELL_STR
;;
esac

case $lRV in 0|1) :;;
*) _write_tmp_settings_file;;
esac

return ${lRV:-1}
}

_check_spell_works(){

_debug "_check_spell_works:$*"

local lSPELL=${*:-"$SPELL"}
test "$lSPELL" || return 3

local lRV=0

_draw 5 "Checking if spell '$lSPELL' works here..."

echo watch $DRAW_INFO

_is 1 1 cast $lSPELL $SPELL_PARAM
_is 1 1 $COMMAND $DIRECTION_NUMBER
_is 1 1 $COMMAND_STOP

 while :; do

 unset REPLY
 sleep 0.1
 read -t 1

 _log "_check_spell_works:$REPLY"
 _debug "$REPLY"

 case $REPLY in ''|$OLD_REPLY) break;;
 *) _handle_spell_errors || lRV=1;;
 esac

 done

echo unwatch $DRAW_INFO

return ${lRV:-4}
}


_error(){
# ***

RV=$1;shift
_draw 3 "$*"
exit $RV
}

_error_break(){
RV=$1;shift
_draw 3 "$*"
break ${RV:-1}
}

# *** main *** #
_do_program(){
# ***

_parse_parameters "$@" # should generate global vars SPELL DIRECTION COMMAND_PAUSE

readonly SPELL=${SPELL:-"$SPELL_DEFAULT"}
readonly COMMAND_PAUSE=${COMMAND_PAUSE:-"$COMMAND_PAUSE_DEFAULT"}

DIRECTION=${DIRECTION:-"$DIRECTION_DEFAULT"}

if test ! "$SPELL_PARAM"; then
 if test "$SPELL" = "$SPELL_DEFAULT"; then
  SPELL_PARAM="$SPELL_DEFAULT_PARAM"
 fi
fi
readonly SPELL_PARAM

while :; do
_check_have_needed_spell_in_inventory && { _apply_needed_spell || _error_break 1 "Could not apply spell."; } || _error 1 "Spell is not in inventory"
sleep 1
_rotate_range_attack
sleep 1
_direction_word_to_number $DIRECTION
readonly DIRECTION
_check_spell_works && _draw 7 "Yup..." || _error_break 1 "Oh NOOOO ... :(" #{ _draw 3 "Oh NOOO ... :("; return 20; }
_do_loop $COMMAND_PAUSE
break
done
}

# ***


case $* in
#'') _draw 3 "Script needs <spell> <direction> and <number of $COMMAND pausing> as argument.";;
*) _do_program "$@";;
esac


# *** Here ends program *** #

rm -f /tmp/cf_script_exit.flag

JOBS=`jobs -p`
test "$JOBS" && kill -15 $JOBS

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

test "$one" && _draw 5 "You $COMMAND '$one' time(s)."

_draw 2 "$0 is finished."
_beep

exit 0

# ***
# ***
# *** diff marker 16
