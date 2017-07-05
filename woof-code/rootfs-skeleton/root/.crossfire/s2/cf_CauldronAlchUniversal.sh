#!/bin/bash
# uses arrays, ((c++))

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

# *** Setting defaults *** #

#SKILL=woodsman
SKILL=alchemy

#CAULDRON=stove
CAULDRON=cauldron

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

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

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

_ping(){
    :
}

_sleepSLEEP(){
[ "$FAST" ] && return 0
sleep ${SLEEP:-1}s
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
    lFILE="$1"; shift; } || lFILE="$LOG_REPLY_FILE"
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
test "$DEBUG" || return 0
_draw ${COL_DEB:-3} "DEBUG:$@"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #

case "$PARAM_1" in -h|*"help"|*usage)

_draw 5 "Script to produce alchemy objects."
_draw 7 "Syntax:"
_draw 7 "$0 ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
_draw 5 "Mandatory NUMBER will loop for"
_draw 5 "NUMBER times to produce"
_draw 5 "ARTIFACT alch with"
_draw 5 "INGREDIENTX NUMBERX ie 'water_of_the_wise' '1'"
_draw 2 "INGREDIENTY NUMBERY ie 'mandrake_root' '1'"
_draw 3 "Since the client does split space in words"
_draw 3 "even if quoted, the ingredients with space"
_draw 3 "need space replaced. Replacement is '_' underscore."
_draw 4 "PLEASE MANUALLY EDIT"
_draw 4 "SKILL and CAULDRON variables"
_draw 4 "in header of this script for your needs."
_draw 6 "SKILL variable currently set to '$SKILL'"
_draw 6 "CAULDRON var currently set to '$CAULDRON'"

        exit 0
;;
esac


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***

# *** Here begins program *** #
_draw 2 "$0 is started.."
_draw 5 " with '$*' parameter."

# *** testing parameters for validity *** #

echo "${BASH_ARGC[0]} : ${BASH_ARGV[@]}" >>"$LOG_TEST_FILE"
#WITHOUT_FIRST=$(( ${BASH_ARGC[0]} - 1 ))
for c in `seq $(echo "${BASH_ARGC[0]}") -2 1`;
#for c in `seq $WITHOUT_FIRST -2 1`;
do
vc=$((c-1));ivc=$((vc-1));((C++));
INGRED[$C]=`echo "${BASH_ARGV[$vc]}"  |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
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

echo "INGRED[$C]='${INGRED[$C]}'" >>"$LOG_TEST_FILE"
echo "NUMBER[$C]='${NUMBER[$C]}'" >>"$LOG_TEST_FILE"
done

GOAL=${INGRED[1]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER_ALCH=${NUMBER[1]}


C=1
for c in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do
((C++))
INGRED[$C]=`echo "${INGRED[$C]}" | tr '_' ' '`
echo "INGRED[$C]='${INGRED[$C]}'" >>"$LOG_TEST_FILE"
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
_log "$LOG_ISON_FILE" "$UNDER_ME"
_debug "$UNDER_ME"
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
_log "$LOG_ISON_FILE" "$UNDER_ME"
_debug "$UNDER_ME"
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


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


# *** Check if is in inventory *** #

rm -f "$LOG_INV_FILE" || exit 1
INVTRY='';

echo request items inv

while :; do
INVTRY=""
read -t 1 INVTRY || break
_log "$LOG_INV_FILE" "$INVTRY"
_debugx "$INVTRY"
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
_log "$LOG_INV_FILE" "$INVTRY"
_debugx "$INVTRY"
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


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


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
# *** DIRB of the $CAULDRON.                                        *** #
# *** Do not open the $CAULDRON - this script does it.              *** #
# *** HAPPY ALCHING !!!                                             *** #


f_exit(){
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep ${SLEEP:-1}s
_draw 3 "Exiting $0."
echo unwatch
echo unwatch $DRAW_INFO
_beep
exit $1
}

_is "1 1 pickup 0"  # precaution

rm -f "$LOG_REPLY_FILE"

sleep 1s

for one in `seq 1 1 $NUMBER_ALCH`
do

tBEG=${tEND:-`/bin/date +%s`}

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

 DW=0
 _draw 5 "drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 _is "1 1 drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 while :; do
 read -t 1 REPLY
 _log "$LOG_REPLY_FILE" "$REPLY"
 _debug "$REPLY"
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.")                 f_exit 1 "Nothing to drop";;
 *"There are only"*)                  f_exit 1 "Not enough ${INGRED[$FOR]}";;
 *"There is only"*)                   f_exit 1 "Not enough ${INGRED[$FOR]}";;
 *"You put the"*${INGRED[$FOR]%% *}*) DW=$((DW+1)); unset REPLY;;
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
 _log "$LOG_REPLY_FILE" "$REPLY"
 _debug "$REPLY"
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

 test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing ${INGRED[$FOR]%% *} in inventory."
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
_log "$LOG_REPLY_FILE" "$REPLY"
_debug "$REPLY"
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
#test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
#test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1
case $REPLY in
'')         break;;
$OLD_REPLY) break;;
*"pours forth monsters"*)   f_emergency_exit 1;;
*"You unwisely release potent forces"*) exit 1;;
esac
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

_is "1 1 apply"
_is "7 1 take"
sleep ${SLEEP:-1}s

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
sleep ${SLEEP:-1}s

_is "1 1 use_skill sense curse"
_is "1 1 use_skill sense magic"
_is "1 1 use_skill $SKILL"
sleep ${SLEEP:-6}s

_draw 7 "drop $GOAL"
_is "0 1 drop $GOAL"

for FOR in `seq 2 1 $C`; do

 _draw 7 "drop ${INGRED[$FOR]} (magic)"
 _is "0 1 drop ${INGRED[$FOR]} (magic)"
 _draw 7 "drop ${INGRED[$FOR]}s (magic)"
 _is "0 1 drop ${INGRED[$FOR]}s (magic)"
 sleep ${SLEEP:-2}s
 _draw 7 "drop ${INGRED[$FOR]} (cursed)"
 _is "0 1 drop ${INGRED[$FOR]} (cursed)"
 _draw 7 "drop ${INGRED[$FOR]}s (cursed)"
 _is "0 1 drop ${INGRED[$FOR]}s (cursed)"
 sleep ${SLEEP:-2}s

done

#_is "0 1 drop (magic)"
#_is "0 1 drop (cursed)"

_draw 7 "drop slag"
_is "0 1 drop slag"
#_is "0 1 drop slags"

#DELAY_DRAWINFO=4  #speed 0.32
sleep ${DELAY_DRAWINFO:-2}s

toGO=$((NUMBER_ALCH-one))
tEND=`/bin/date +%s`
tLAP=$((tEND-tBEG))
_draw 5 "time ${tLAP}s used, still $toGO laps.."

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep ${SLEEP:-2}s         #speed 0.32

done

# *** Here ends program *** #
_draw 2 "$0 is finished."
_beep
