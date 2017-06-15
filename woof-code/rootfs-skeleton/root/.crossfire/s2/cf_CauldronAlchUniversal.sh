#!/bin/bash
# uses arrays, ((c++))
# WARNING : NO CHECKS if cauldron still empty, monsters did not work ...

TIMEA=`date +%s`


exec 2>/tmp/cf_script.err

# *** Setting defaults *** #

#SKILL=woodsman
SKILL=alchemy
# etc ..

#CAULDRON=stove
CAULDRON=cauldron
# etc ..

DEBUG=

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
northwest) DIRF=southeast;;
northeast) DIRF=southwest;;
southwest) DIRF=northeast;;
southeast) DIRF=northwest;;
esac

DELAY_DRAWINFO=4  #seconds 4=speed 0.32

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

ITEM_RECALL='rod of word of recall'  # rod / scroll of word of recall

#set empty default
C=0 #set zero as default

#logging
LOGGING=1
TMP_DIR=/tmp/crossfire_client
LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
 LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
 LOG_TEST_FILE="$TMP_DIR"/cf_script.$$.test
LOG_TEST2_FILE="$TMP_DIR"/cf_script.$$.test2
  LOG_INV_FILE="$TMP_DIR"/cf_script.$$.inv

mkdir -p "$TMP_DIR"

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
beep -l $BEEP_LENGTH -f $BEEP_FREQ
}

# ping if connection is dropping once a while
PING_DO=
URL=crossfire.metalforge.net
_ping(){
test "$PING_DO" || return 0
while :; do
ping -c1 -w10 -W10 "$URL" && break
sleep 1
done >/dev/null
}

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

COL_VERB=$COL_TAN  # verbose
COL_DBG=$COL_GOLD  # debug

_draw(){
test "$*" || return

case $1 in [0-9]|1[0-2])
COLOUR=${1:-0}
shift
;;
esac
local lCOLOUR=${COLOUR:-0}

while read -r line
do
test "$line" || continue
echo draw $lCOLOUR "$line"
sleep 0.1
done <<EoI
`echo "$*"`
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

_debugx(){
[ "$DEBUGX" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
local lLOG_FILE=${LOG_PREPLY_FILE}
case $1 in -file=*) lLOG_FILE=${1#*=}; shift;; esac
lLOG_FILE=${lLOG_FILE:-/tmp/cf_script.log}
echo "$*" >>"${lLOG_FILE}"
}

_is(){
_verbose "$*"
echo issue "$@"
sleep 0.2
}

_number_to_word(){
unset NUMBER2WORD
test "$1" || return 3

case $1 in
1)  NUMBER2WORD=one;;
2)  NUMBER2WORD=two;;
3)  NUMBER2WORD=three;;
4)  NUMBER2WORD=four;;
5)  NUMBER2WORD=five;;
6)  NUMBER2WORD=six;;
7)  NUMBER2WORD=seven;;
8)  NUMBER2WORD=eight;;
9)  NUMBER2WORD=nine;;
10) NUMBER2WORD=ten;;
11) NUMBER2WORD=eleven;;
12) NUMBER2WORD=twelve;;
13) NUMBER2WORD=thirteen;;
14) NUMBER2WORD=fourteen;;
15) NUMBER2WORD=fifteen;;
16) NUMBER2WORD=sixteen;;
17) NUMBER2WORD=seventeen;;
18) NUMBER2WORD=eightteen;;
19) NUMBER2WORD=nineteen;;
20) NUMBER2WORD=twenty;;
*)  :;;
esac
test "$NUMBER2WORD"
}

_word_to_number(){
unset WORD2NUMBER
test "$1" || return 3

case $1 in
one)   WORD2NUMBER=1;;
two)   WORD2NUMBER=2;;
three) WORD2NUMBER=3;;
four)  WORD2NUMBER=4;;
five)  WORD2NUMBER=5;;
six)   WORD2NUMBER=6;;
seven) WORD2NUMBER=7;;
eight) WORD2NUMBER=8;;
nine)  WORD2NUMBER=9;;
ten)   WORD2NUMBER=10;;
eleven)    WORD2NUMBER=11;;
twelve)    WORD2NUMBER=12;;
thirteen)  WORD2NUMBER=13;;
fourteen)  WORD2NUMBER=14;;
fifteen)   WORD2NUMBER=15;;
sixteen)   WORD2NUMBER=16;;
seventeen) WORD2NUMBER=17;;
eightteen) WORD2NUMBER=18;;
nineteen)  WORD2NUMBER=19;;
twenty)    WORD2NUMBER=20;;
*) :;;
esac
test "$WORD2NUMBER"
}

_probe_err_log(){
local lERR_FILE=${*:-$ERR_LOG}
lERR_FILE=${lERR_FILE:-/tmp/cf_script.err}

if test -s "$lERR_FILE"; then
 _draw 0 ""
 _draw 3 "WARNING: $lERR_FILE contains :"
 _draw 2 "`cat $lERR_FILE`"
 _draw 0 ""
else
 _draw 7 "No content detected in $lERR_FILE"
 [ "$DEBUG" ] || rm -f "$lERR_FILE"
fi
}

# times
_say_minutes_seconds(){
#_say_minutes_seconds "500" "600" "Loop run:"
test "$1" -a "$2" || return 3

local TIMEa TIMEz TIMEy TIMEm TIMEs

TIMEa="$1"
shift
TIMEz="$1"
shift

TIMEy=$((TIMEz-TIMEa))
TIMEm=$((TIMEy/60))
TIMEs=$(( TIMEy - (TIMEm*60) ))
case $TIMEs in [0-9]) TIMEs="0$TIMEs";; esac

echo draw 5 "$* $TIMEm:$TIMEs minutes."
}

_say_success_fail(){
test "$one" -a "$FAIL" || return 3

if test "$FAIL" -le 0; then
 SUCC=$((one-FAIL))
 echo draw 7 "You succeeded $SUCC times of $one ." # green
elif test "$((one/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $one ."    # light green
 echo draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((one-FAIL))
 echo draw 7 "You succeeded $SUCC times of $one ." # green
fi
}

_say_statistics_end(){
# Now count the whole loop time
TIMELE=`date +%s`
_say_minutes_seconds "$TIMEB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"

_probe_err_log
}

_usage(){

_draw 0 ""
_draw 5 "Script to produce alchemy objects."
_draw 8 "Syntax:"
_draw 7 "$0 ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce"
_draw 5 "ARTIFACT with"
_draw 2 "INGREDIENTX NUMBERX ie 'water of the wise' '1'"
_draw 2 "INGREDIENTY NUMBERY ie 'mandrake root' '1'"
_draw 5 "NUMBER can be set to '-I' to run infinite,"
_draw 5 "until one ingredient runs out."
_draw 3 "Space in ARTIFACT and INGREDIENT need to be substituted by Underscore"
_draw 3 "ie 'balm of first aid' as 'balm_of_first_aid'"
_draw 4 "PLEASE MANUALLY EDIT SKILL and CAULDRON variables"
_draw 4 "in header of this script for your needs."
_draw 6 "SKILL variable currently set to '$SKILL'"
_draw 6 "CAULDRON var currently set to '$CAULDRON'"
_draw 0 ""

        exit 0
}


# *** Here begins program *** #
_draw 2 "$0 is started.."
_draw 5 " with '$*' parameter."

# *** Check for parameters *** #
[ "$*" ] || {
_draw 3 "Script needs goal_item_name, numberofalchemyattempts, ingredient and numberofingredient as arguments."
        exit 1
}

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*help|*usage) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

#-s|*skill)     SKILL=$2; shift;;
#-c|*cauldron)  SKILL=$2; shift;;
#-c|*cauldron)  CAULDRON=$2; shift;;

-*) _draw 3 "Ignoring option '$PARAM_1'";;
'') :;;

*) # *** testing parameters for validity *** #

_log -file="$LOG_TEST_FILE" "${BASH_ARGC[0]} : ${BASH_ARGV[@]}"

_debug "${BASH_ARGC[0]} : ${BASH_ARGV[@]}"

_debug 0 ${BASH_ARGV[0]}
_debug 1 ${BASH_ARGV[1]}
_debug 2 ${BASH_ARGV[2]}
_debug 3 ${BASH_ARGV[3]}
_debug 4 ${BASH_ARGV[4]}
_debug 5 ${BASH_ARGV[5]}
_debug 6 ${BASH_ARGV[6]}
_debug 7 ${BASH_ARGV[7]}

for c in `seq 0 2 $(( $# - 1 ))`;
do

vc=$c
ivc=$((vc+1))
((C++))

INGRED[$C]=`echo "${BASH_ARGV[$ivc]}"  |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
_debug $C INGRED ${INGRED[$C]}
case ${INGRED[$C]} in -I|*infinite) :;;
 -*|$SKILL|$CAULDRON)
 unset INGRED[$C]
 ((C--))
 continue;;
esac
_debug $C INGRED ${INGRED[$C]}

NUMBER[$C]=`echo "${BASH_ARGV[$vc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
_debug $C NUMBER ${NUMBER[$C]}
case ${NUMBER[$C]} in -I|*infinite) :;;
 -*|$SKILL|$CAULDRON)
 unset NUMBER[$C] INGRED[$C]
 ((C--))
 continue;;
esac
_debug $C NUMBER ${NUMBER[$C]}

# here we could shift syntax 3 water_of_the_wise 7 water
case ${INGRED[$C]} in [0-9]*|-I|*infinite)
 tVAR1=${INGRED[$C]}
 tVAR2=${NUMBER[$C]}
 INGRED[$C]=$tVAR2
 NUMBER[$C]=$tVAR1
 ;;
esac

_number_to_word ${NUMBER[$C]} && NUMBER[$C]=$NUMBER2WORD

_log -file="$LOG_TEST_FILE" "INGRED[$C]='${INGRED[$C]}'"
_log -file="$LOG_TEST_FILE" "NUMBER[$C]='${NUMBER[$C]}'"

done

_debug 1  ${INGRED[1]}  ${NUMBER[1]}
_debug $C ${INGRED[$C]} ${NUMBER[$C]}
GOAL=${INGRED[$C]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER_ALCH=${NUMBER[$C]}

# fallback
case $NUMBER_ALCH in
[0-9]*) :;;
-I|*infinite) NUMBER_ALCH="I";;
*) _word_to_number $NUMBER_ALCH && NUMBER_ALCH=$WORD2NUMBER
   ;;
#*) _draw 3 "NUMBER_ALCH '$NUMBER_ALCH' incorrect";exit 1;;
esac

if test "$NUMBER_ALCH"; then
 test "$NUMBER_ALCH" = 'I' || test "$NUMBER_ALCH" -ge 1 || NUMBER_ALCH=1 #paranoid precaution
fi
test "$NUMBER_ALCH" = 'I' && unset NUMBER_ALCH

# get rid of underscores
CC=0
for c in `seq 1 1 $((C-1))`
do
((CC++))
INGRED[$CC]=`echo "${INGRED[$CC]}" | tr '_' ' '`
_debug "INGRED[$CC]=${INGRED[$CC]}"
_log -file="$LOG_TEST_FILE" "INGRED[$CC]='${INGRED[$CC]}'"
done

_probe_inventory(){
# *** Check if is in inventory *** #

rm -f "$LOG_INV_FILE" || exit 1
INVTRY='';

echo request items inv

while :; do
 INVTRY=""
 read -t 1 INVTRY || break
 echo "$INVTRY" >>"$LOG_INV_FILE" # grep ingred further down, not otional
 _debugx "$INVTRY"
 case "$INVTRY" in "")    break;;
 "request items inv end") break;;
 "scripttell break")      break;;
 "scripttell exit")      exit 1;;
 esac
 sleep 0.01s
done


rm -f /tmp/cf_script.grep

CC=0
for one in `seq 1 1 $((C-1))`
do

((CC++))
GREP_INGRED[$CC]=`echo "${INGRED[$CC]}" | sed 's/ /\[s \]\*/g'`

# DEBUG
echo "GREP_INGRED[$CC]='${GREP_INGRED[$CC]}'" >>"$LOG_TEST2_FILE"
grep "${GREP_INGRED[$CC]}" "$LOG_INV_FILE" >>/tmp/cf_script.grep

grepMANY=`grep "${GREP_INGRED[$CC]}" "$LOG_INV_FILE"`
if [[ "$grepMANY" ]]; then
 if [ "`echo "$grepMANY" | wc -l`" -gt 1 ]; then
 echo draw 3 "More than 1 of '${INGRED[$CC]}' in inventory."
 exit 1
 else
 _draw 7 "${INGRED[$CC]} in inventory."
 fi
else
_draw 3 "No ${INGRED[$CC]} in inventory."
exit 1
fi

done
}
_probe_inventory

break
;;

esac
shift
sleep 0.1
done


test "$GOAL" -a "${INGRED[1]}" -a "${NUMBER[1]}" || {
 _draw 3 "Missing Parameter(s)"
 _draw 3 "Need <artifact> <number> <ingredient> <numberof>"
 _draw 3 "ie: script $0 water_of_the_wise 10 water 7 ."
 _draw 3 "or  script $0 balm_of_first_aid 20 water_of_the_wise 1 mandrake_root 1 ."
 exit 1
}

# ** exit funcs ** #
f_exit(){
RV=${1:-0}
shift

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep 1s

test "$*" && _draw 5 "$*"
_draw 3 "Exiting $0."

echo unwatch
echo unwatch $DRAW_INFO

_beep
_say_statistics_end
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

_is "1 1 apply $ITEM_RECALL"
_is "1 1 fire center"
_draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
_is "1 1 fire_stop"

test "$*" && _draw 5 "$*"
_beep
_say_statistics_end
exit $RV
}

# *** pre-requisites *** #

_check_if_on_cauldron(){
# *** Check if standing on a $CAULDRON *** #
_draw 2 "Checking if standing on '$CAULDRON' .."

unset UNDER_ME UNDER_ME_LIST
echo request items on

while :; do
 read -t 1 UNDER_ME
 sleep 0.1s
 _log -file="$LOG_ISON_FILE" "_check_if_on_cauldron:$UNDER_ME"
 _debug "$UNDER_ME"
 UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
 case "$UNDER_ME" in "request items on end") break;;
 "scripttell break") break;;
 "scripttell exit") exit 1;;
 esac
done

 test "`echo "$UNDER_ME_LIST" | grep "${CAULDRON}$"`" || {
 _draw 3 "Need to stand upon a $CAULDRON!"
 _beep
 exit 1
 }

}

_probe_empty_cauldron_yes(){

_draw 2 "Probing for empty $CAULDRON .."
local lRV=1

echo watch $DRAW_INFO

_is 0 0 apply

_is 0 0 get all

 while :; do
 unset REPLY
 sleep 0.1
 read -t 1
 _log "_probe_empty_cauldron_yes:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *Nothing*to*take*) lRV=0;;
 '') break;;
 *) :;;
 esac

 done

echo unwatch $DRAW_INFO

_is "1 1 $DIRB"
_is "1 1 $DIRF"

return ${lRV:-4}
}

_check_if_on_cauldron || exit 2
_probe_empty_cauldron_yes || f_exit 1


# *** Actual script to alch the desired water of gem *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the $CAULDRON and make sure there are 4 tiles   *** #
# *** $DIRB of the $CAULDRON.                                       *** #
# *** Do not open the $CAULDRON - this script does it.              *** #
# *** HAPPY ALCHING !!!                                             *** #


_is "1 1 pickup 0"  # precaution

rm -f "$LOG_REPLY_FILE"

sleep 1s

TIMEB=`date +%s`
one=0


while :;
do

tBEG=${tEND:-`date +%s`}

OLD_REPLY="";
REPLY="";

_is "1 1 apply"

echo watch $DRAW_INFO

sleep 1s


 for FOR in `seq 1 1 $((C-1))`; do

 case ${NUMBER[$FOR]} in
 [0-9]*) :;;
 *) _word_to_number ${NUMBER[$FOR]} && NUMBER[$FOR]=$WORD2NUMBER
    ;;
 esac

 _is "1 1 drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 while :; do
 read -t 1 REPLY
 _log "drop:$REPLY"
 _debug "$REPLY"
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.") break 3 ;; #f_exit 1 "No ${INGRED[$FOR]} to drop";;
 *"There are only"*)  break 3 ;; #f_exit 1 "Not enough ${INGRED[$FOR]}";;
 *"There is only"*)   break 3 ;; #f_exit 1 "Not enough ${INGRED[$FOR]}";;
 '') break;;
 esac

 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

 done

echo unwatch $DRAW_INFO
sleep 1s

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep 1s

_is "1 1 use_skill $SKILL"

# *** TODO: The $CAULDRON burps and then pours forth monsters!

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "use_skill $SKILL:$REPLY"
_debug "$REPLY"

 case $REPLY in '') break;;
 $OLD_REPLY)        break;;
 *pours*forth*monsters*)   f_emergency_exit 1;;
 *You*unwisely*release*potent*forces*) exit 1;;
 esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

_is "1 1 apply"
# TODO: cauldron is gone: You can't pick up a wood floor.
_is "0 0 get all"

sleep 1s

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
sleep 1s

_is "1 1 use_skill sense curse"
_is "1 1 use_skill sense magic"
_is "1 1 use_skill $SKILL"
sleep 6s

_is "0 1 drop $GOAL"

for FOR in `seq 1 1 $((C-1))`; do

 _is "0 1 drop ${INGRED[$FOR]} (magic)"
 _is "0 1 drop ${INGRED[$FOR]}s (magic)"  # TODO: waters of the wise, not water of the wises ...
 sleep 2s
 _is "0 1 drop ${INGRED[$FOR]} (cursed)"
 _is "0 1 drop ${INGRED[$FOR]}s (cursed)" # TODO: waters of the wise, not water of the wises ...
 sleep 2s

done

_is "0 1 drop slag"


sleep ${DELAY_DRAWINFO}s


_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep 2s         #speed 0.32

_check_if_on_cauldron || exit 2


one=$((one+1))
tEND=`date +%s`
tLAP=$((tEND-tBEG))

if test "$NUMBER_ALCH"; then
 toGO=$((NUMBER_ALCH-one))
 _draw 5 "time ${tLAP}s used, still $toGO laps.."
 test "$one" = "$NUMBER_ALCH" && break
else
 _draw 5 "time ${tLAP}seconds"
 _draw 5 "Infinite loop $one, use scriptkill to abort.."
fi

done


# *** Here ends program *** #

_say_statistics_end


_draw 2 "$0 is finished."
_beep
