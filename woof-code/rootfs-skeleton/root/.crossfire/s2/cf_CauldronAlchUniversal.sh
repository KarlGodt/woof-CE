#!/bin/bash
# uses arrays, ((c++))
# WARNING : NO CHECKS if cauldron still available, empty, monsters did not work ...

exec 2>>/tmp/cf_script.err

# *** Setting defaults *** #

SKILL=woodsman
#SKILL=alchemy

CAULDRON=stove
#CAULDRON=cauldron

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


# *** Here begins program *** #
_draw 2 "$0 is started.."
_draw 5 " with '$*' parameter."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"|*usage)

_draw 5 "Script to produce alchemy objects."
_draw 7 "Syntax:"
_draw 7 "$0 ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce"
_draw 5 "ARTIFACT with"
_draw 5 "INGREDIENTX NUMBERX ie 'water of the wise' '1'"
_draw 2 "INGREDIENTY NUMBERY ie 'mandrake root' '1'"

        exit 0
;;
esac

# *** testing parameters for validity *** #

_log -file="$LOG_TEST_FILE" "${BASH_ARGC[0]} : ${BASH_ARGV[@]}"
#WITHOUT_FIRST=$(( ${BASH_ARGC[0]} - 1 ))
for c in `seq $(echo "${BASH_ARGC[0]}") -2 1`;
#for c in `seq $WITHOUT_FIRST -2 1`;
do
vc=$((c-1));ivc=$((vc-1));((C++));
INGRED[$C]=`echo "${BASH_ARGV[$vc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
NUMBER[$C]=`echo "${BASH_ARGV[$ivc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`

case ${NUMBER[$C]} in
1) NUMBER[$C]=one;;
2) NUMBER[$C]=two;;
3) NUMBER[$C]=three;;
4) NUMBER[$C]=four;;
5) NUMBER[$C]=five;;
6) NUMBER[$C]=six;;
7) NUMBER[$C]=seven;;
8) NUMBER[$C]=eight;;
9) NUMBER[$C]=nine;;
10) NUMBER[$C]=ten;;
11) NUMBER[$C]=eleven;;
12) NUMBER[$C]=twelve;;
13) NUMBER[$C]=thirteen;;
14) NUMBER[$C]=fourteen;;
15) NUMBER[$C]=fifteen;;
16) NUMBER[$C]=sixteen;;
17) NUMBER[$C]=seventeen;;
18) NUMBER[$C]=eightteen;;
19) NUMBER[$C]=nineteen;;
20) NUMBER[$C]=twenty;;
esac

_log -file="$LOG_TEST_FILE" "INGRED[$C]='${INGRED[$C]}'"
_log -file="$LOG_TEST_FILE" "NUMBER[$C]='${NUMBER[$C]}'"
done

GOAL=${INGRED[1]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER_ALCH=${NUMBER[1]}


C=1
for c in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do
((C++))
INGRED[$C]=`echo "${INGRED[$C]}" | tr '_' ' '`
_log -file="$LOG_TEST_FILE" "INGRED[$C]='${INGRED[$C]}'"
done


} || {
_draw 3 "Script needs goal_item_name, numberofalchemyattempts, ingredient and numberofingredient as arguments."
        exit 1
}

test "$1" -a "$2" -a "$3" -a "$4" || {
_draw 3 "Need <artifact> <number> <ingredient> <numberof> ie: script $0 water_of_the_wise 10 water 7 ."
_draw 3 "or script $0 balm_of_first_aid 20 water_of_the_wise 1 mandrake_root 1 ."
        exit 1
}


# *** Check if standing on a $CAULDRON *** #
UNDER_ME='';
echo request items on

while :; do
read UNDER_ME
sleep 0.1s
_log -file="$LOG_ISON_FILE" "$UNDER_ME"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in "request items on end") break;;
"scripttell break") break;;
"scripttell exit") exit 1;;
esac
done

__old_loop(){
while [ 1 ]; do
read -t 1 UNDER_ME
sleep 0.1s
_log -file="$LOG_ISON_FILE" "$UNDER_ME"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done
}

test "`echo "$UNDER_ME_LIST" | grep "${CAULDRON}$"`" || {
_draw 3 "Need to stand upon a $CAULDRON!"
_beep
exit 1
}

# *** Check if is in inventory *** #

rm -f "$LOG_INV_FILE" || exit 1
INVTRY='';

echo request items inv

while :; do
INVTRY=""
read -t 1 INVTRY || break
echo "$INVTRY" >>"$LOG_INV_FILE" # grep ingred further down, not otional
#_log -file="$LOG_INV_FILE" "$INVTRY"
#_draw 3 "$INVTRY"
case "$INVTRY" in "") break;;
"request items inv end") break;;
"scripttell break") break;;
"scripttell exit") exit 1;;
esac
sleep 0.01s
done

__old_loop(){
while [ 1 ]; do
INVTRY=""
read -t 1 INVTRY || break
echo "$INVTRY" >>"$LOG_INV_FILE"  # grep ingred further down, not otional
#_log -file="$LOG_INV_FILE" "$INVTRY"
#_draw 3 "$INVTRY"
test "$INVTRY" = "" && break
test "$INVTRY" = "request items inv end" && break
test "$INVTRY" = "scripttell break" && break
test "$INVTRY" = "scripttell exit" && exit 1
sleep 0.01s
done
}

C2=1
for one in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do

((C2++))
GREP_INGRED[$C2]=`echo "${INGRED[$C2]}" | sed 's/ /\[s \]\*/g'`

# DEBUG
echo "GREP_INGRED[$C2]='${GREP_INGRED[$C2]}'" >>"$LOG_TEST2_FILE"
grep "${GREP_INGRED[$C2]}" "$LOG_INV_FILE" >>/tmp/cf_script.grep

if [[ "`grep "${GREP_INGRED[$C2]}" "$LOG_INV_FILE"`" ]]; then
_draw 7 "${INGRED[$C2]} in inventory."
else
_draw 3 "No ${INGRED[$C2]} in inventory."
exit 1
fi

# *** Check for suffizient amount of ingredient *** #
# *** TODO

done


case $NUMBER_ALCH in
one)   NUMBER_ALCH=1;;
two)   NUMBER_ALCH=2;;
three) NUMBER_ALCH=3;;
four)  NUMBER_ALCH=4;;
five)  NUMBER_ALCH=5;;
six)   NUMBER_ALCH=6;;
seven) NUMBER_ALCH=7;;
eight) NUMBER_ALCH=8;;
nine)  NUMBER_ALCH=9;;
ten)   NUMBER_ALCH=10;;
eleven)    NUMBER_ALCH=11;;
twelve)    NUMBER_ALCH=12;;
thirteen)  NUMBER_ALCH=13;;
fourteen)  NUMBER_ALCH=14;;
fifteen)   NUMBER_ALCH=15;;
sixteen)   NUMBER_ALCH=16;;
seventeen) NUMBER_ALCH=17;;
eightteen) NUMBER_ALCH=18;;
nineteen)  NUMBER_ALCH=19;;
twenty)    NUMBER_ALCH=20;;
esac


test "$NUMBER_ALCH" -ge 1 || NUMBER_ALCH=1 #paranoid precaution

# *** Actual script to alch the desired water of gem *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the $CAULDRON and make sure there are 4 tiles    *** #
# *** west of the $CAULDRON.                                         *** #
# *** Do not open the $CAULDRON - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


_is "1 1 pickup 0"  # precaution

f_exit(){
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep 1s
_draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch $DRAW_INFO
_beep
exit $1
}


rm -f "$LOG_REPLY_FILE"

sleep 1s

for one in `seq 1 1 $NUMBER_ALCH`
do

tBEG=${tEND:-`date +%s`}

OLD_REPLY="";
REPLY="";

_is "1 1 apply"

echo watch $DRAW_INFO

sleep 1s

 for FOR in `seq 2 1 $C`; do

 case ${NUMBER[$FOR]} in
 one)   NUMBER[$FOR]=1;;
 two)   NUMBER[$FOR]=2;;
 three) NUMBER[$FOR]=3;;
 four)  NUMBER[$FOR]=4;;
 five)  NUMBER[$FOR]=5;;
 six)   NUMBER[$FOR]=6;;
 seven) NUMBER[$FOR]=7;;
 eight) NUMBER[$FOR]=8;;
 nine)  NUMBER[$FOR]=9;;
 ten)   NUMBER[$FOR]=10;;
 eleven)    NUMBER[$FOR]=11;;
 twelve)    NUMBER[$FOR]=12;;
 thirteen)  NUMBER[$FOR]=13;;
 fourteen)  NUMBER[$FOR]=14;;
 fifteen)   NUMBER[$FOR]=15;;
 sixteen)   NUMBER[$FOR]=16;;
 seventeen) NUMBER[$FOR]=17;;
 eightteen) NUMBER[$FOR]=18;;
 nineteen)  NUMBER[$FOR]=19;;
 twenty)    NUMBER[$FOR]=20;;
esac

 _draw 5 "drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 _is "1 1 drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 while :; do
 read -t 1 REPLY
 _log "$REPLY"
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.") f_exit 1;;
 *"There are only"*)  f_exit 1;;
 *"There is only"*)   f_exit 1;;
 '') break;;
 esac
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

 __old_loop(){
 while [ 1 ]; do
 read -t 1 REPLY
 _log "$REPLY"
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
 test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done
 }

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
_log "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

_is "1 1 apply"
#_is "7 1 take"  # TODO: cauldron is gone: You can't pick up a wood floor.
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

_draw 7 "drop $GOAL"
_is "0 1 drop $GOAL"

for FOR in `seq 2 1 $C`; do

 _draw 7 "drop ${INGRED[$FOR]} (magic)"
 _is "0 1 drop ${INGRED[$FOR]} (magic)"
 _draw 7 "drop ${INGRED[$FOR]}s (magic)"
 _is "0 1 drop ${INGRED[$FOR]}s (magic)"
 sleep 2s
 _draw 7 "drop ${INGRED[$FOR]} (cursed)"
 _is "0 1 drop ${INGRED[$FOR]} (cursed)"
 _draw 7 "drop ${INGRED[$FOR]}s (cursed)"
 _is "0 1 drop ${INGRED[$FOR]}s (cursed)"
 sleep 2s

done

#_is "0 1 drop (magic)"
#_is "0 1 drop (cursed)"

_draw 7 "drop slag"
_is "0 1 drop slag"


sleep ${DELAY_DRAWINFO}s

toGO=$((NUMBER_ALCH-one))
tEND=`date +%s`
tLAP=$((tEND-tBEG))
_draw 5 "time ${tLAP}s used, still $toGO laps.."

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep 2s         #speed 0.32

done

# *** Here ends program *** #
_draw 2 "$0 is finished."
_beep
