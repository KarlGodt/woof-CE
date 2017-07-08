#!/bin/ash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

DEF_SEARCH=9
DEF_DISARM=9
DEF_LOCKPICK=9

# FOREVER mode
INF_THRESH=30 # threshold to cast dexterity and probe
INF_TOGGLE=4  # threshold to cast restoration (INF_THRESH * INF_TOGGLE)

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

# REMEMBER spellcasting denials ...
TMP_SETTINGS_FILE=/tmp/cf_unlock_door_conf.tmp

# colours
COL_BLACK=0
COL_WHITE=1
COL_NAVY=2
COL_RED=3
COL_ORANGE=4
COL_BLUE=5
COL_DORANGE=6
COL_GREEN=7
COL_LGREEN=8
COL_GRAY=9
COL_BROWN=10
COL_GOLD=11
COL_TAN=12

_draw(){
test "$*" || return
COLOUR=${1:-0}
shift
while read -r line
do
test "$line" || continue
echo draw $COLOUR "$line"
sleep 0.1
done <<EoI
`echo "$@"`
EoI
}

_verbose(){
[ "$VERBOSE" ] || return 0
_draw ${COL_VERB:-12} "$*"
}

_debug(){
[ "$DEBUG" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOG_REPLY_FILE"
}


# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to lockpick doors."
_draw 2 "Syntax:"
_draw 7 "script $0 <direction> <<number>>"
#_draw 7 "script $0 <<number>> <direction>"
_draw 5 "For example: 'script $0 west 5'"
#_draw 5 "For example: 'script $0 5 west'"
_draw 5 "will issue 5 times search, disarm and use_skill lockpicking in west."
_draw 2 "Options:"
_draw 4 "-c cast detect curse to turn to DIR"
_draw 4 "-C cast constitution"
_draw 4 "-t cast disarm"
_draw 4 "-D cast dexterity"
_draw 4 "-e cast detect evil"
_draw 4 "-f cast faery fire"
_draw 4 "-i cast show invisible"
_draw 4 "-m cast detect magic"
_draw 4 "-M cast detect monster"
_draw 4 "-p cast probe"
_draw 5 "-d set debug"
_draw 4 "-I lockpick forever"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 6 "-N new map to remove spell casting flags"
_draw 5 "-v set verbosity"

        exit 0
}


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


_word_to_number(){

case ${1:-PARAM_1} in

one)            PARAM_1=1;;
two)            PARAM_1=2;;
three)          PARAM_1=3;;
four)           PARAM_1=4;;
five)           PARAM_1=5;;
six)            PARAM_1=6;;
seven)          PARAM_1=7;;
eight)          PARAM_1=8;;
nine)           PARAM_1=9;;
ten)            PARAM_1=10;;
eleven)         PARAM_1=11;;
twelve)         PARAM_1=12;;
thirteen)       PARAM_1=13;;
fourteen)       PARAM_1=14;;
fifteen)        PARAM_1=15;;
sixteen)        PARAM_1=16;;
seventeen)      PARAM_1=17;;
eighteen)       PARAM_1=18;;
nineteen)       PARAM_1=19;;
twenty)         PARAM_1=20;;

esac

}

_number_to_direction(){

case $1 in
[0-8]) DIRN=$1;;
*)    return 1;;
esac

case $1 in

0) DIR=center;;
1) DIR=north;;
2) DIR=northeast;;
3) DIR=east;;
4) DIR=southeast;;
5) DIR=south;;
6) DIR=southwest;;
7) DIR=west;;
8) DIR=northwest;;
*) return 1;;

esac

readonly DIR DIRN;
return $?
}


# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #

_debug "'$#' Parameters: '$*'"

# If there is only one parameter and it is a number
# assume it means direction
if test $# = 1; then

PARAM_1="$1"
_word_to_number "$PARAM_1"

case $PARAM_1 in [0-8])
 _number_to_direction "$PARAM_1"
 shift;;
esac
fi


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


until test $# = 0;
do

PARAM_1="$1"
_debug "PARAM_1=$PARAM_1 #=$#"
sleep 0.1
shift

case $PARAM_1 in
[0-9]*)

  # Check if more numbers to come and if so,
  # assume direction
  unset p FOUND_DIR
  for p in "$@"; do
   case $p in [0-9]*)
    _number_to_direction $PARAM_1 && FOUND_DIR=1;;
   esac
  done

if test "$FOUND_DIR"; then :
#elif test "$DIR"; then
else
        NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
           _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
           readonly NUMBER
       _debug 2 "NUMBER=$NUMBER" #DEBUG

fi

;;

0|c|centre|center) DIR=center;   DIRN=0; readonly DIR DIRN;;
 1|n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
2|ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 3|e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
4|se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 5|s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
6|sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 7|w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
8|nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;

-h|*help|*usage)  _usage;;

-c|*curse)   TURN_SPELL="detect curse";;
-C|*const*)  TURN_SPELL="constitution";;
-t|*disarm)  TURN_SPELL="disarm";;
-D|*dex*)    TURN_SPELL="dexterity";;
-e|*evil)    TURN_SPELL="detect evil";;
-f|*faery)   TURN_SPELL="faery fire";;
-i|*invis*)  TURN_SPELL="show invisible";;
-m|*magic)   TURN_SPELL="detect magic";;
-M|*monster) TURN_SPELL="detect monster";;
-p|*probe)   TURN_SPELL="probe";;

-d|*debug)      DEBUG=$((DEBUG+1));;
-I|*infinite) FOREVER=$((FOREVER+1));;
-L|*logging)  LOGGING=$((LOGGING+1));;
-N|*new*)     REMOVE_FLAGS=$((REMOVE_FLAGS+1));;
-v|*verbose)  VERBOSE=$((VERBOSE+1));;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

done

#readonly NUMBER DIR
_debug "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'"

# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 _draw 3 "Need direction as parameter."
 exit 1
fi



# TODO : find out if turn possible without casting/firing in DIRN

_brace_and_attack_direction(){
# use brace and DIR -- does not work since attacks in DIR; so
# either uses key to unlock door or punches against it and triggers traps

local lDIR=${1:-"$DIR"}

_draw 5 "Bracing .."
_verbose "brace on"
echo issue 1 1 brace on
sleep 1

_draw 4 "Turning $DIR .."
_verbose "$lDIR"
echo issue 1 1 $lDIR
sleep 1

}


# we could add parameters to cast what spell:
# should be low level with few mana/grace point need
# non-attack to avoid triggering traps
# and with some in fantasy/theory usable value
# faery fire and disarm show something at least
# detect magic          - sorcery       1 1  -m
# probe                 - sorcery       1 3  -p
# detect monster        - evocation     2 2  -M
# detect evil           - prayer        3 3  -e
# dexterity             - sorcery       3 9  -D
# disarm                - sorcery       4 7  -d
# constitution          - sorcery       4 12 -C
# faery fire            - pyromancy     4 13 -f
# detect curse          - prayer        5 10 -c
# show invisible        - prayer        7 10 -i

# Handle errors like spellpath or not learned
# set VARIABLES <- functions, to unset them if found not allowed/available
## $CAST_SPELL instead _cast_spell
#_cast_SPELL $SPELL instead _cast_spellname

SPELL_DET_MONST='detect monster'

SPELL_FAERYFIRE='faery fire'

SPELL_CON=constitution
SPELL_DISARM=disarm
SPELL_DET_MAGIC='detect magic'
SPELL_DEX=dexterity
SPELL_PROBE=probe

SPELL_DET_CURSE='detect curse'
SPELL_DET_EVIL='detect_evil'
SPELL_SHOW_INV='show invisible'

SPELL_REST=restoration


_write_tmp_settings_file(){

local lTMP_SETTINGS_FILE=${*:-$TMP_SETTINGS_FILE}
test "$lTMP_SETTINGS_FILE" || return 3

(

echo "SPELL_DET_MONST='$SPELL_DET_MONST'"

echo "SPELL_FAERYFIRE='$SPELL_FAERYFIRE'"

echo "SPELL_CON='$SPELL_CON'"
echo "SPELL_DISARM='$SPELL_DISARM'"
echo "SPELL_DET_MAGIC='$SPELL_DET_MAGIC'"
echo "SPELL_DEX='$SPELL_DEX'"
echo "SPELL_PROBE='$SPELL_PROBE'"

echo "SPELL_DET_CURSE='$SPELL_DET_CURSE'"
echo "SPELL_DET_EVIL='$SPELL_DET_EVIL'"
echo "SPELL_SHOW_INV='$SPELL_SHOW_INV'"

echo "SPELL_REST='$SPELL_REST'"

) >>"$lTMP_SETTINGS_FILE"

}

_parse_tmp_settings_file(){

local lTMP_SETTINGS_FILE=${*:-$TMP_SETTINGS_FILE}
test "$lTMP_SETTINGS_FILE" || return 3

if test "$REMOVE_FLAGS"; then
rm -f "$lTMP_SETTINGS_FILE"
fi
if test -s "$lTMP_SETTINGS_FILE"; then
. "$lTMP_SETTINGS_FILE"
else
rm -f "$lTMP_SETTINGS_FILE"
fi
}

# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


_handle_spell_errors(){
local lRV=0
 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   lRV=30;; #unset SPELL_DEX SPELL_PROBE; break 2;;
 '*Something blocks the magic of your scroll.'*) lRV=30;; #unset SPELL_DEX SPELL_PROBE; break 2;;
 *'Something blocks your spellcasting.'*)        lRV=10;; #unset SPELL_DEX; break 2;;
 *'Something blocks your magic.'*)               lRV=10;; # spell_effect.c: int probe( .. )
 *'Something blocks the magic of the spell.'*)   lRV=10;; # spell_effect.c: int dimension_door( .. )
 *'This ground is unholy!'*)                     lRV=20;; #unset SPELL_REST;break 2;;
 *'You lack the skill evocation'*)               lRV=11;; #unset SPELL_DEX; break 2;;
 *'You lack the skill pyromancy'*)               lRV=12;;
 *'You lack the skill sorcery'*)                 lRV=13;;
 *'You lack the skill summoning'*)               lRV=14;;
 *'You lack the skill praying'*)                 lRV=20;;
 *'You lack the skill '*)                        lRV=19;;
 *'You lack the proper attunement to cast '*)    lRV=30;; #unset SPELL_DEX; break 2;;
 *'That spell path is denied to you.'*)          lRV=40;; #unset SPELL_DEX; break 2;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *'You are no easier to look at.'*)              lRV=111;; # spell_effect.c: static const char *const no_gain_msgs[NUM_STATS] = {
 *"You don't feel any healthier."*)              lRV=112;;
 *'You grow no more agile.'*)                    lRV=113;; #unset SPELL_DEX; break 2;;
 *'You grow no stronger.'*)                      lRV=114;;
 *) lRV=1;;
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

_handle_spell_msgs(){
local lRV=0
 case $REPLY in
 *'You stop using the'*)               :;; #talisman of Missiles *.
 *'You can no longer use the skill:'*) :;;
 *'You ready talisman '*)              :;;
 *'You ready holy symbol'*)            :;;
 *'You can now use the skill:'*)       :;;
 *'You ready the spell'*)              :;;

 *'You seem to look better.'*) :;; # server/common/living.c
 *'You feel healthy.'*)        :;;
 *'You feel more agile.'*)     :;;
 *'You feel smarter.'*)        :;;
 *'You feel more potent.'*)    :;;
 *'You feel stronger.'*)       :;;
 *'You feel wiser.'*)          :;;

 *'The effects of your '*' are draining out.'*)    :;;
 *'The effects of your '*' are about to expire.'*) :;;

 *'You look ugly!'*)         :;;
 *'You feel less healthy!'*) :;;
 *'You feel clumsy!'*)       :;;
 *'You feel stupid!'*)       :;;
 *'You feel less potent!'*)  :;;
 *'You feel weaker!'*)       :;;
 *'You lose some of your memory!'*) :;;

 *'You feel your '*' return'*) :;;

 *'Your face gets distorted!'*)      :;;
 *'You feel less healthy'*)          :;;
 *"You're feeling clumsy!"*)         :;;
 *'Watch out, your mind is going!'*) :;;
 *'Your spirit feels drained!'*)     :;;
 *'Oh no! You are weakened!'*)       :;;
 *'You suddenly begin to lose your memory!'*) :;;

 *) lRV=1;;
esac
return ${lRV:-1}
}

_probe_spell_allowed(){

test "$*" || return 3

local lSPELL="$*"

_parse_tmp_settings_file

case $lSPELL in
"constitution")   test "$SPELL_CON"        || return 13;;
"detect curse")   test "$SPELL_DET_CURSE"  || return 20;;
"detect evil")    test "$SPELL_DET_EVIL"   || return 20;;
"detect magic")   test "$SPELL_DET_MAGIC"  || return 13;;
"detect monster") test "$SPELL_DET_MONST"  || return 11;;
"dexterity")      test "$SPELL_DEX"        || return 13;;
"disarm")         test "$SPELL_DISARM"     || return 13;;
"faery fire")     test "$SPELL_FAERYFIRE"  || return 12;;
"probe")          test "$SPELL_PROBE"      || return 13;;
"show invisible") test "$SPELL_SHOW_INV"   || return 20;;
esac

return 0
}

_turn_direction_all(){

local REPLY c spell

#_parse_tmp_settings_file

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

# using a bunch of spells to increase availability
# downside if many doors - much drain of mana/grace
for spell in "probe" "detect monster" "detect evil"
do

_probe_spell_allowed "$spell" || continue

#_parse_tmp_settings_file
#case $spell in
#"constitution")   test "$SPELL_CON"       || continue;;
#"detect curse")   test "$SPELL_DET_CURSE" || continue;;
#"detect evil")    test "$SPELL_DET_EVIL"  || continue;;
#"detect magic")   test "$SPELL_DET_MAGIC" || continue;;
#"detect monster") test "$SPELL_DET_MONST" || continue;;
#"dexterity")      test "$SPELL_DEX"       || continue;;
#"disarm")         test "$SPELL_DISARM"    || continue;;
#"faery fire")     test "$SPELL_FAERYFIRE" || continue;;
#"probe")          test "$SPELL_PROBE"     || continue;;
#"show invisible") test "$SPELL_SHOW_INV"  || continue;;
#esac

_draw 2 "Casting $spell to turn to $DIR .."

_verbose "cast $spell"
echo issue 1 1 cast $spell
sleep 0.5

_verbose "fire ${DIRN:-0}"
echo issue 1 1 fire ${DIRN:-0}
sleep 0.1

_verbose "fire_stop"
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_turn_direction_all:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'"

 case $REPLY in
 '') break;;
 *)  _handle_spell_errors || _handle_spell_msgs || {
 c=$((c+1)); test "$c" = 9 && break; } ;; # 9 is just chosen as threshold for spam in msg pane
 esac

done


done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***

_turn_direction(){
test "$*" || return 3

local REPLY c spell

spell="$*"

_probe_spell_allowed "$spell" || return $?

#_parse_tmp_settings_file
#case $spell in
#"constitution")   test "$SPELL_CON"        || return 13;;
#"detect curse")   test "$SPELL_DET_CURSE"  || return 20;;
#"detect evil")    test "$SPELL_DET_EVIL"   || return 20;;
#"detect magic")   test "$SPELL_DET_MAGIC"  || return 13;;
#"detect monster") test "$SPELL_DET_MONST"  || return 11;;
#"dexterity")      test "$SPELL_DEX"        || return 13;;
#"disarm")         test "$SPELL_DISARM"     || return 13;;
#"faery fire")     test "$SPELL_FAERYFIRE"  || return 12;;
#"probe")          test "$SPELL_PROBE"      || return 13;;
#"show invisible") test "$SPELL_SHOW_INV"   || return 20;;
#esac

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO
_draw 2 "Casting $spell to turn to $DIR .."

_verbose "cast $spell"
echo issue 1 1 cast $spell
sleep 0.5

_verbose "fire ${DIRN:-0}"
echo issue 1 1 fire ${DIRN:-0}
sleep 0.1

_verbose "fire_stop"
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_turn_direction:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'"

 case $REPLY in
 '') break;;
 *)  _handle_spell_errors || _handle_spell_msgs || {
 c=$((c+1)); test "$c" = 9 && break; } ;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***

_cast_spell(){
# ** cast DEXTERITY ** #

[ "$*" ] || return 3

local lSPELL="$*"
local REPLY c

_probe_spell_allowed "$lSPELL" || return $?

#_parse_tmp_settings_file
#case $lSPELL in
#"constitution")   test "$SPELL_CON"        || return 13;;
#"detect curse")   test "$SPELL_DET_CURSE"  || return 20;;
#"detect evil")    test "$SPELL_DET_EVIL"   || return 20;;
#"detect magic")   test "$SPELL_DET_MAGIC"  || return 13;;
#"detect monster") test "$SPELL_DET_MONST"  || return 11;;
#"dexterity")      test "$SPELL_DEX"        || return 13;;
#"disarm")         test "$SPELL_DISARM"     || return 13;;
#"faery fire")     test "$SPELL_FAERYFIRE"  || return 12;;
#"probe")          test "$SPELL_PROBE"      || return 13;;
#"show invisible") test "$SPELL_SHOW_INV"   || return 20;;
#esac

echo watch $DRAW_INFO

_draw 5 "casting '$lSPELL' .."

_verbose "cast '$lSPELL'"
echo issue 1 1 cast "$lSPELL" # don't mind if mana too low, not capable or bungles for now
sleep 0.5

_verbose "fire ${DIRN:-0}"
echo issue 1 1 fire ${DIRN:-0}
sleep 0.1

_verbose "fire_stop"
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_cast_spell:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'"

 case $REPLY in
 '') break;;
 *)  _handle_spell_errors || _handle_spell_msgs || {
 c=$((c+1)); test "$c" = 9 && break; } ;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_invoke_spell(){
# ** cast DEXTERITY ** #

[ "$*" ] || return 3

local lSPELL="$*"
local REPLY c

_probe_spell_allowed "$lSPELL" || return $?

#_parse_tmp_settings_file
#case $lSPELL in
#"constitution")   test "$SPELL_CON"        || return 13;;
#"detect curse")   test "$SPELL_DET_CURSE"  || return 20;;
#"detect evil")    test "$SPELL_DET_EVIL"   || return 20;;
#"detect magic")   test "$SPELL_DET_MAGIC"  || return 13;;
#"detect monster") test "$SPELL_DET_MONST"  || return 11;;
#"dexterity")      test "$SPELL_DEX"        || return 13;;
#"disarm")         test "$SPELL_DISARM"     || return 13;;
#"faery fire")     test "$SPELL_FAERYFIRE"  || return 12;;
#"probe")          test "$SPELL_PROBE"      || return 13;;
#"show invisible") test "$SPELL_SHOW_INV"   || return 20;;
#esac

echo watch $DRAW_INFO

_draw 5 "invoking '$lSPELL' .."

_verbose "invoke '$lSPELL'"
echo issue 1 1 cast "$lSPELL" # don't mind if mana too low, not capable or bungles for now
sleep 0.5

#_verbose "fire ${DIRN:-0}"
#echo issue 1 1 fire ${DIRN:-0}
#sleep 0.5

#_verbose "fire_stop"
#echo issue 1 1 fire_stop
#sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_invoke_spell:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'"

 case $REPLY in
 '') break;;
 *)  _handle_spell_errors || _handle_spell_msgs || {
 c=$((c+1)); test "$c" = 9 && break; } ;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_find_traps_search(){
# ** search or use_skill find traps ** #

local NUM=${NUMBER:-$DEF_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

TIME_SEARCHB=`/bin/date +%s`

while :;
do

unset TRAPS

_verbose "$NUM:search"
echo issue 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
 _log "_find_traps:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Unable to find skill '*)   break 2;;

   *'You spot a '*) TRAPS="${TRAPS}
$REPLY";;

#   *'Your '*)       :;; # Your monster beats monster
#   *'You killed '*) :;;
    *'You search the area.'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

test "$TRAPS" && TRAPS_BACKUP="$TRAPS"
NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1

test ! "$TRAPS" && test "$TRAPS_BACKUP" && TRAPS="$TRAPS_BACKUP"
TRAPS=`echo "$TRAPS" | sed '/^$/d'`

if test "$DEBUG"; then
_draw 5 "TRAPS='$TRAPS'"
fi

test "$TRAPS" && TRAPS_NUM=`echo "$TRAPS" | wc -l`
TRAPS_NUM=${TRAPS_NUM:-0}
SUCC_SEARCH=$TRAPS_NUM

echo $TRAPS_NUM >/tmp/cf_pipe.$$

TIME_SEARCHE=`/bin/date +%s`
TIME_SEARCH=$((TIME_SEARCHE-TIME_SEARCHB))
}

# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***

_disarm_traps_use_skill(){
# ** disarm use_skill disarm traps ** #

# REM: For now, it ignores handling of triggered traps.
# Usuallay, there is only one trap each tile or object,
# but at few occasions, there are more than one in a chest or door.
# Especially Confusion and Paralyses traps could be handled,
# since they tend to multiplify and disturbing the correct
# commit of commands or reading of DRAW_INFO .
# NOTE: cf_open_chest.sh handles it atm.

local NUM CNT
unset NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$DEF_DISARM}

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0

TIME_DISARMB=`/bin/date +%s`

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

CNT=0

while :;
do

_verbose "$NUM:$CNT:use_skill disarm traps"
echo issue 1 1 use_skill "disarm traps"
# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
   _log "_disarm_traps:$REPLY"
   _debug $COL_GREEN "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*)   break 2;;
#  *'You fail to disarm '*) continue;;
   *'You successfully disarm '*)
   SUCC_DISARM=$((SUCC_DISARM+1))
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break;;
   *'In fact, you set it off!'*)
    NUM=$((NUM-1)); test "$NUM" -gt 0 && break 1 || break 2;
    break ;;

# src/lib/archetypes
#   *'You detonate '**)
#    NUM=$((NUM-1)); test "$NUM" -gt 0 || break 2;
#    break;;
#  *'RUN!  The timer's ticking!'*)
#  *'You feel depleted of psychic energy!'*)
#  *'You set off '*)


#   *'Your '*)       :;;  # Your monster beats monster
#   *'You killed '*) :;;

  '') CNT=$((CNT+1)); break;;
  esac
 done

test "$CNT" -gt 9 && break
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
TIME_DISARME=`/bin/date +%s`
TIME_DISARM=$((TIME_DISARME-TIME_DISARMB))
}

# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***

_lockpick_door_use_skill(){
# ** open door with use_skill lockpicking ** #

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

c=0; cc=0
NUM=$NUMBER

TIMEB=`/bin/date +%s`
while :;
do

_verbose "$NUM:$c:$cc:use_skill lockpicking"
echo issue 1 1 use_skill lockpicking
LOCKPICK_ATT=$((LOCKPICK_ATT+1))

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "lockpicking:$REPLY"
  _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
  *'Unable to find skill '*)     break 2;;
  *'The door has no lock!'*)     break 2;;
  *'There is no lock there.'*)   break 2;;
  *"You can't pick that lock!"*) break 2;;  # special key
  *' no door'*)                  break 2;;
  *'You unlock'*)                break 2;;
  *'You pick the lock.'*)        break 2;;
  *scripttell*) case $REPLY in *abort*|*break*|*exit*|*halt*|*kill*|*quit*|*stop*|*term*) break 2;; esac;;
  *'Your '*)        :;;  # Your monster beats monster
  *'You killed '*)  :;;
  *'You find '*)    :;;
  *'You pick up '*) :;;
  *' tasted '*)     :;;  # food tasted good
  *) break;;
  esac
 done

if test "$FOREVER"; then
 cc=$((cc+1))
 test "$cc" = $INF_THRESH && {
  if test "$TOGGLE" = $INF_TOGGLE; then
   _cast_spell $SPELL_REST
       TOGGLE=0;
  else TOGGLE=$((TOGGLE+1));
  fi
  _cast_spell $SPELL_DEX
  _cast_spell $SPELL_PROBE
  _draw 3 "Infinite loop. Use 'scriptkill $0' to abort."; cc=0;
 }

elif test "$NUMBER"; then
NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
c=$((c+1)); test "$c" -lt $DEF_LOCKPICK || break;
fi

sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_parse_tmp_settings_file

if test "$TURN_SPELL"; then
 _turn_direction $TURN_SPELL
else
 _turn_direction_all
fi

_invoke_spell $SPELL_DEX

_find_traps_search
_disarm_traps_use_skill && _lockpick_door_use_skill


# *** Here ends program *** #

#_draw 4 "Unbracing .."
#echo issue 1 1 brace off
#sleep 1

_count_time(){

test "$*" || return 3

TIMEE=`/bin/date +%s` || return 4

TIMEX=$((TIMEE - $*)) || return 5
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

test "$TIME_SEARCH"       && _draw 8 "Searched '$TIME_SEARCH' second(s) for traps."
test "$SUCC_SEARCH" -gt 0 && _draw 7 "Found '$SUCC_SEARCH' trap(s)."

test "$TIME_DISARM" && _draw 5 "Disarming trap(s) took '$TIME_DISARM' second(s)."
test "$SUCC_DISARM" && _draw 2 "Successfully disarmed '$SUCC_DISARM' trap(s)."

_count_time $TIMEB && _draw 7 "Looped for $TIMEM:$TIMES minutes"
_count_time $TIMEA && _draw 7 "Script ran $TIMEM:$TIMES minutes"

test "${LOCKPICK_ATT:-0}" -gt 0 && _draw 5 "You did $LOCKPICK_ATT lockpicking attempt(s)."


_draw 2 "$0 is finished."
beep -f 700 -l 1000


# ***
# ***
# *** diff marker 16
