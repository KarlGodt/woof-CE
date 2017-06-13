#!/bin/bash
# uses arrays

TIMEA=`date +%s`

exec 2>/tmp/cf_script.err

# WARNING : NO CHECKS if cauldron still empty, monsters did not work ...

# *** Setting defaults *** #
#set empty default
C=0 # used in arrays, set zero as default

# Set here SKILL and CAULDRON you want to use ** #
#SKILL=woodsman
SKILL=alchemy
# etc.

#CAULDRON=stove
CAULDRON=cauldron
# etc.

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup and drop the result(s) to not
# increase carried weight, and to prevent created items being dropped into
# cauldron, thus failing the recipe.
#This version does not adjust player speed after several weight losses.

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

DRAW_INFO=drawinfo  # drawinfo OR drawextinfo

DELAY_DRAWINFO=4  #speed 0.32

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

_ping(){ # TODO
    :
}

_usage(){

echo draw 5 "Script to produce alchemy objects."
echo draw 7 "Syntax:"
echo draw 7 "$0 ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
echo draw 5 "Allowed NUMBER will loop to produce"
echo draw 2 "ARTIFACT ie 'balm_of_first_aid'"
echo draw 2 "NUMBER times ie '10' with"
echo draw 2 "INGREDIENTX NUMBERX ie 'water_of_the_wise' '1'"
echo draw 2 "INGREDIENTY NUMBERY ie 'mandrake_root' '1'"
echo draw 5 "NUMBER can be set to '-I' to run infinte."
echo draw 4 "PLEASE MANUALLY EDIT SKILL and CAULDRON variables"
echo draw 4 "in header of this script for your needs."
echo draw 6 "SKILL variable currently set to '$SKILL'"
echo draw 6 "CAULDRON var currently set to '$CAULDRON'"
echo draw 3 "Space in ARTIFACT and INGREDIENT need to be substituted by Underscore"
echo draw 3 "ie 'balm of first aid' as 'balm_of_first_aid'"

        exit 0
}


# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 5 " with '$*' parameter."

# *** Check for parameters *** #
[ "$*" ] || {
echo draw 3 "Script needs goal_item_name, numberofalchemyattempts, ingredient and numberofingredient as arguments."
        exit 1
}


PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"|*usage)
 _usage
;;
esac

# *** testing parameters for validity *** #

echo "${BASH_ARGC[0]} : ${BASH_ARGV[@]}" >>/tmp/cf_script.test

#WITHOUT_FIRST=$(( ${BASH_ARGC[0]} - 1 ))
#for c in `seq $WITHOUT_FIRST -2 1`;
 for c in `seq $(echo "${BASH_ARGC[0]}") -2 1`;
do

vc=$((c-1));ivc=$((vc-1));((C++));

INGRED[$C]=`echo "${BASH_ARGV[$vc]}"  |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
NUMBER[$C]=`echo "${BASH_ARGV[$ivc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`  # /root/cf/s/AU: line 73: BASH_ARGV: bad array subscript

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

echo "INGRED[$C]='${INGRED[$C]}'" >>/tmp/cf_script.test
echo "NUMBER[$C]='${NUMBER[$C]}'" >>/tmp/cf_script.test
done

GOAL=${INGRED[1]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER_ALCH=${NUMBER[1]}

# fallback
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
-I|*infinite) NUMBER_ALCH="I";;
*) _draw 3 "NUMBER_ALCH '$NUMBER_ALCH' incorrect";exit 1;;
esac

if test "$NUMBER_ALCH"; then
 test "$NUMBER_ALCH" = 'I' || test "$NUMBER_ALCH" -ge 1 || NUMBER_ALCH=1 #paranoid precaution
fi
test "$NUMBER_ALCH" = 'I' && unset NUMBER_ALCH


#DEBUG
C=1
for c in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do
((C++))
INGRED[$C]=`echo "${INGRED[$C]}" | tr '_' ' '`
echo "INGRED[$C]='${INGRED[$C]}'" >>/tmp/cf_script.test
done

_probe_inventory(){
# *** Check if is in inventory *** #

rm -f /tmp/cf_script.inv || exit 1
INVTRY='';

echo request items inv
while [ 1 ]; do
INVTRY=""
read -t 1 INVTRY || break
echo "$INVTRY" >>/tmp/cf_script.inv
#echo draw 3 "$INVTRY"
test "$INVTRY" = "" && break
test "$INVTRY" = "request items inv end" && break
test "$INVTRY" = "scripttell break" && break
test "$INVTRY" = "scripttell exit" && exit 1
sleep 0.01s
done

C2=1
for one in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do

((C2++))
GREP_INGRED[$C2]=`echo "${INGRED[$C2]}" | sed 's/ /\[s \]\*/g'`


echo "GREP_INGRED[$C2]='${GREP_INGRED[$C2]}'" >>/tmp/cf_script.test2
grep "${GREP_INGRED[$C2]}" /tmp/cf_script.inv >>/tmp/cf_script.grep

#if [[ "`grep "${GREP_INGRED[$C2]}" /tmp/cf_script.inv`" ]]; then
grepMANY=`grep "${GREP_INGRED[$C2]}" /tmp/cf_script.inv`
if [[ "$grepMANY" ]]; then
 if [ "`echo "$grepMANY" | wc -l`" -gt 1 ]; then
 echo draw 3 "More than 1 of '${INGRED[$C2]}' in inventory."
 exit 1
 else
 echo draw 7 "${INGRED[$C2]} in inventory."
 fi
else
echo draw 3 "No ${INGRED[$C2]} in inventory."
exit 1
fi

done
}
_probe_inventory

test "$1" -a "$2" -a "$3" -a "$4" || {
echo draw 3 "Need <artifact> <number> <ingredient> <numberof> ie: script $0 water_of_the_wise 10 water 7 ."
echo draw 3 "or script $0 balm_of_first_aid 20 water_of_the_wise 1 mandrake_root 1 ."
        exit 1
}

# ** exit funcs ** #
f_exit(){
RV=${1:-0}
shift

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s

test "$*" && echo draw 5 "$*"
echo draw 3 "Exiting $0."

#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch $DRAW_INFO
beep -l 500 -f 900
_say_statistics_end
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
echo "issue 1 1 fire_stop"

test "$*" && echo draw 5 "$*"
beep -l 999 -f 999
_say_statistics_end
exit $RV
}

# *** pre-requisites *** #

_check_if_on_cauldron(){
# *** Check if standing on a $CAULDRON *** #
echo draw 2 "Checking if standing on '$CAULDRON' .."

unset UNDER_ME UNDER_ME_LIST
echo request items on

 while [ 1 ]; do
 read -t 1 UNDER_ME
 sleep 0.1s
 [ "$LOGGING" ] && echo "$UNDER_ME" >>/tmp/cf_script.ion
 UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
 test "$UNDER_ME" = "request items on end" && break
 test "$UNDER_ME" = "scripttell break" && break
 test "$UNDER_ME" = "scripttell exit" && exit 1
 done

 test "`echo "$UNDER_ME_LIST" | grep "${CAULDRON}$"`" || {
 echo draw 3 "Need to stand upon a $CAULDRON!"
 exit 1
 }
}

_probe_empty_cauldron_yes(){

echo draw 2 "Probing for empty $CAULDRON .."
local lRV=1

echo watch $DRAW_INFO

echo issue 0 0 apply

echo issue 0 0 get all

 while :; do
 unset REPLY
 sleep 0.1
 read -t 1
 #
 #
 case $REPLY in
 *Nothing*to*take*) lRV=0;;
 '') break;;
 *) :;;
 esac

 done

echo unwatch $DRAW_INFO

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"

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


echo "issue 1 1 pickup 0"  # precaution

rm -f "$LOG_REPLY_FILE"

sleep 1s

TIMEB=`date +%s`
one=0

#for one in `seq 1 1 $NUMBER_ALCH`
while :;
do

tBEG=`date +%s`

OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"

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

 echo draw 5 "drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 echo "issue 1 1 drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"

 while [ 1 ]; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1 "No ${INGRED[$FOR]} to drop"
 test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1 "Not enough ${INGRED[$FOR]}"
 test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1 "Not enough ${INGRED[$FOR]}"

 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

 done

echo unwatch $DRAW_INFO
sleep 1s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s

echo "issue 1 1 use_skill $SKILL"

# *** TODO: The $CAULDRON burps and then pours forth monsters!
echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1

OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

echo "issue 1 1 apply"
echo "issue 0 0 get all" # TODO: cauldron is gone: You can't pick up a [wood]* floor.

sleep 1s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep 1s

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill $SKILL"
sleep 6s

echo draw 7 "drop $GOAL"
echo "issue 0 1 drop $GOAL"

for FOR in `seq 2 1 $C`; do

 echo draw 7 "drop ${INGRED[$FOR]} (magic)"
 echo "issue 0 1 drop ${INGRED[$FOR]} (magic)"
 echo draw 7 "drop ${INGRED[$FOR]}s (magic)"
 echo "issue 0 1 drop ${INGRED[$FOR]}s (magic)"
 sleep 2s
 echo draw 7 "drop ${INGRED[$FOR]} (cursed)"
 echo "issue 0 1 drop ${INGRED[$FOR]} (cursed)"
 echo draw 7 "drop ${INGRED[$FOR]}s (cursed)"
 echo "issue 0 1 drop ${INGRED[$FOR]}s (cursed)"
 sleep 2s

done


echo draw 7 "drop slag"  # debug
echo "issue 0 1 drop slag"


sleep ${DELAY_DRAWINFO}s


echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 2s         #speed 0.32


_check_if_on_cauldron || exit 2


one=$((one+1))
tEND=`date +%s`
tLAP=$((tEND-tBEG))

if test "$NUMBER_ALCH"; then
 toGO=$((NUMBER_ALCH-one))
 echo draw 5 "time ${tLAP}s used, still $toGO laps.."
 test "$one" = "$NUMBER_ALCH" && break
else
 _draw 5 "time ${tLAP}seconds"
 _draw "Infinite loop, use scriptkill to abort.."
fi

done


# *** Here ends program *** #

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
test "$NUMBER" -a "$FAIL" || return 3

if test "$FAIL" -le 0; then
 SUCC=$((NUMBER-FAIL))
 echo draw 7 "You succeeded $SUCC times of $NUMBER ." # green
elif test "$((NUMBER/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $NUMBER ."    # light green
 echo draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((NUMBER-FAIL))
 echo draw 7 "You succeeded $SUCC times of $NUMBER ." # green
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
}

_say_statistics_end


echo draw 2 "$0 is finished."
beep -l 500 -f 700
