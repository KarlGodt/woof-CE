#!/bin/bash

export PATH=/bin:/usr/bin

# *** Setting defaults *** #
#set empty default
C=0 #set zero as default


MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh

_set_global_variables

# *** Here begins program *** #
_draw 2 "$0 is started.."
_draw 2 "PID is $$ - parentPID is $PPID"
#_draw 5 " with '$*' parameter."

# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

_draw 5 "Script to produce alchemy objects."
_draw 7 "Syntax:"
_draw 7 "$0 ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce"
_draw 2 "ARTIFACT alch ie 'balm_of_first_aid' '10' with"
_draw 2 "INGREDIENTX NUMBERX ie 'water_of_the_wise' '1'"
_draw 2 "INGREDIENTY NUMBERY ie 'mandrake_root' '1'"

        exit 0
;; esac


# *** testing parameters for validity *** #

echo "${BASH_ARGC[0]} : ${BASH_ARGV[@]}" >>/tmp/cf_script.test

#WITHOUT_FIRST=$(( ${BASH_ARGC[0]} - 1 ))
for c in `seq $(echo "${BASH_ARGC[0]}") -2 2`;
#for c in `seq $WITHOUT_FIRST -2 1`;
do
vc=$((c-1));ivc=$((vc-1));((C++));
#vc=$c;ivc=$((vc-1));((C++))
echo C=$C ivc=$ivc vc=$vc >&2
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

echo "INGRED[$C]='${INGRED[$C]}'" >>/tmp/cf_script.test
echo "NUMBER[$C]='${NUMBER[$C]}'" >>/tmp/cf_script.test
done

GOAL=${INGRED[1]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER_ALCH=${NUMBER[1]}


C=1
for c in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do
((C++))
INGRED[$C]=`echo "${INGRED[$C]}" | tr '_' ' '`
echo "INGRED[$C]='${INGRED[$C]}'" >>/tmp/cf_script.test
done


} || {
_draw 3 "Script needs goal_item_name, number_of_alchemy_attempts, ingredient and numberofingredient as arguments."
        exit 1
}

test "$1" -a "$2" -a "$3" -a "$4" || {
_draw 3 "Need <artifact> <number> <ingredient> <numberof> ie: script $0 water_of_the_wise 10 water 7 ."
_draw 3 "or script $0 balm_of_first_aid 20 'water_of_the_wise' 1 'mandrake_root' 1 ."
        exit 1
}

# *** Getting Player's Speed *** #
_get_player_speed
# *** Check if standing on a cauldron *** #
#_is 1 1 pickup 0  # precaution
_check_if_on_cauldron
# *** Check if there are 4 walkable tiles in $DIRB *** #
_check_for_space
# *** Check if cauldron is empty *** #
_check_empty_cauldron

# *** Check if is in inventory *** #
__check_if_in_inv(){
rm -f /tmp/cf_script.inv || exit 1
INVTRY='';
#echo watch request items inv
echo request items inv
while [ 1 ]; do
INVTRY=""
read -t 1 INVTRY || break
echo "$INVTRY" >>/tmp/cf_script.inv
#_draw 3 "$INVTRY"
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

if [[ "`grep "${GREP_INGRED[$C2]}" /tmp/cf_script.inv`" ]]; then
_draw 3 "${INGRED[$C2]} in inventory."
else
_draw 3 "No ${INGRED[$C2]} in inventory."
exit 1
fi

# *** Check for suffizient amount of ingredient *** #
# *** TODO

done

}

#__check_if_in_inv

# *** Unreadying rod of word of recall - just in case *** #
_prepare_rod_of_recall

# *** Actual script to alch the desired water of gem *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Then get the number of needed ingredients.                    *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** $DIRB of the cauldron.                                        *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"

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
test $NUMBER_ALCH -ge 1 || NUMBER_ALCH=1 #paranoid precaution
_debug "NUMBER_ALCH=$NUMBER_ALCH"

success=0
# *** MAIN LOOP *** #
for one in `seq 1 1 $NUMBER_ALCH`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep ${SLEEP}s

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


 _debug "drop ${NUMBER[$FOR]} ${INGRED[$FOR]}"
 echo watch drawinfo
 #_is 1 1 drop ${NUMBER[$FOR]} ${INGRED[$FOR]}
 _drop ${NUMBER[$FOR]} ${INGRED[$FOR]}

 __check_drop_or_exit(){
 while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$REPLY_LOG"
 test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && _exit 1
 test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
 test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
 test "$REPLY" || break
 unset REPLY
 sleep 0.1s
 done
 }

 _check_drop_or_exit

 done

#echo unwatch drawinfo

#sleep 1s

_close_cauldron
#sleep 1s

_alch_and_get
#sleep 1s

_go_cauldron_drop_alch_yeld
#sleep 1s

if test "$NOTHING" = 0; then
 if test "$SLAG" = 0; then
 _success &
 _is 1 1 use_skill sense curse
 _is 1 1 use_skill sense magic
 _is 1 1 use_skill alchemy
 sleep 1s

 _is 0 1 drop $GOAL
 success=$((success+1))
 else
 _failure &
 _is 0 1 drop slag
 fi
else
 _disaster &
fi

_check_food_level
sleep ${DELAY_DRAWINFO}s

#sleep 1s
#sleep ${DELAY_DRAWINFO}s

_go_drop_alch_yeld_cauldron

_check_if_on_cauldron

TRIES_STILL=$((NUMBER_ALCH-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_STILL to go..."

done

# *** Here ends program *** #
#test -f /root/.crossfire/sounds/su-fanf.raw && aplay /root/.crossfire/sounds/su-fanf.raw
#_draw 2 "$0 is finished."
_say_end_msg
