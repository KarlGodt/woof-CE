#!/bin/bash

export PATH=/bin:/usr/bin

# *** Setting defaults *** #
#set empty default
C=0 # Bash Array Counter - set zero as default


MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_common.sh   && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_move.sh    && . "${MY_SELF%/*}"/cf_funcs_move.sh
test -f "${MY_SELF%/*}"/cf_funcs_food.sh    && . "${MY_SELF%/*}"/cf_funcs_food.sh
test -f "${MY_SELF%/*}"/cf_funcs_alchemy.sh && . "${MY_SELF%/*}"/cf_funcs_alchemy.sh

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

# *** Here begins program *** #
_say_start_msg "$@"

while :;
do
case "$1" in
-version) shift;;
*.*) shift;;
*) break;;
esac
done

# *** Check for parameters *** #
#_draw 5 "Checking the parameters ($*)..."
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*)

_draw 5 "Script to produce alchemy objects."
_draw 7 "Syntax:"
_draw 7 "$0 [ -version VERSION ] ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce"
_draw 2 "ARTIFACT alch ie 'balm_of_first_aid' '10' with"
_draw 2 "INGREDIENTX NUMBERX ie 'water_of_the_wise' '1'"
_draw 2 "INGREDIENTY NUMBERY ie 'mandrake_root' '1'"
_draw 4  "Option -version 1.12.0 and lesser"
_draw 4  "turns on some compatibility switches."
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
INGRED[$C]=`echo "${BASH_ARGV[$vc]}"  |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
NUMBRI[$C]=`echo "${BASH_ARGV[$ivc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`

echo "
INGRED[$C]='${INGRED[$C]}'"       >>/tmp/cf_script.test
echo "NUMBRI[$C]='${NUMBRI[$C]}'" >>/tmp/cf_script.test

case ${INGRED[$C]} in
-version) ((C--));ivc=$((ivc+2));vc=$((vc+2)); continue
esac

case ${NUMBRI[$C]} in
1) NUMBRI[$C]=one;;
2) NUMBRI[$C]=two;;
3) NUMBRI[$C]=three;;
4) NUMBRI[$C]=four;;
5) NUMBRI[$C]=five;;
6) NUMBRI[$C]=six;;
7) NUMBRI[$C]=seven;;
8) NUMBRI[$C]=eight;;
9) NUMBRI[$C]=nine;;
10) NUMBRI[$C]=ten;;
11) NUMBRI[$C]=eleven;;
12) NUMBRI[$C]=twelve;;
13) NUMBRI[$C]=thirteen;;
14) NUMBRI[$C]=fourteen;;
15) NUMBRI[$C]=fifteen;;
16) NUMBRI[$C]=sixteen;;
17) NUMBRI[$C]=seventeen;;
18) NUMBRI[$C]=eightteen;;
19) NUMBRI[$C]=nineteen;;
20) NUMBRI[$C]=twenty;;
esac

echo "INGRED[$C]='${INGRED[$C]}'" >>/tmp/cf_script.test
echo "NUMBRI[$C]='${NUMBRI[$C]}'
"                                 >>/tmp/cf_script.test
done

GOAL=${INGRED[1]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER=${NUMBRI[1]}

echo "GOAL='$GOAL'"     >>/tmp/cf_script.test
echo "NUMBER='$NUMBER'" >>/tmp/cf_script.test

C=1
for c in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do
((C++))
INGRED[$C]=`echo "${INGRED[$C]}" | tr '_' ' '`
echo "INGRED[$C]='${INGRED[$C]}'" >>/tmp/cf_script.test
case ${INGRED[$C]} in '') ((C--)); break;;esac
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
#_check_for_space
$FUNCTION_CHECK_FOR_SPACE
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
_debug 3 "$INVTRY"
case $INVTRY in
'') break;;
*request*items*inv*end*) break;;
*scripttell*break*)      break;;
*scripttell*exit*) _exit 1;;
esac

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
_unapply_rod_of_recall

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

case $NUMBER in
one)   NUMBER=1;;
two)   NUMBER=2;;
three) NUMBER=3;;
four)  NUMBER=4;;
five)  NUMBER=5;;
six)   NUMBER=6;;
seven) NUMBER=7;;
eight) NUMBER=8;;
nine)  NUMBER=9;;
ten)   NUMBER=10;;
eleven)    NUMBER=11;;
twelve)    NUMBER=12;;
thirteen)  NUMBER=13;;
fourteen)  NUMBER=14;;
fifteen)   NUMBER=15;;
sixteen)   NUMBER=16;;
seventeen) NUMBER=17;;
eightteen) NUMBER=18;;
nineteen)  NUMBER=19;;
twenty)    NUMBER=20;;
esac
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution
_debug "NUMBER=$NUMBER"

TIMEA=`date +%s`
success=0
# *** MAIN LOOP *** #
for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep 0.5
#sleep ${SLEEP}s

 for FOR in `seq 2 1 $C`; do

 echo "FOR=$FOR C=$C" >>/tmp/cf_script.test
 case ${NUMBRI[$FOR]} in
 one)   NUMBRI[$FOR]=1;;
 two)   NUMBRI[$FOR]=2;;
 three) NUMBRI[$FOR]=3;;
 four)  NUMBRI[$FOR]=4;;
 five)  NUMBRI[$FOR]=5;;
 six)   NUMBRI[$FOR]=6;;
 seven) NUMBRI[$FOR]=7;;
 eight) NUMBRI[$FOR]=8;;
 nine)  NUMBRI[$FOR]=9;;
 ten)   NUMBRI[$FOR]=10;;
 eleven)    NUMBRI[$FOR]=11;;
 twelve)    NUMBRI[$FOR]=12;;
 thirteen)  NUMBRI[$FOR]=13;;
 fourteen)  NUMBRI[$FOR]=14;;
 fifteen)   NUMBRI[$FOR]=15;;
 sixteen)   NUMBRI[$FOR]=16;;
 seventeen) NUMBRI[$FOR]=17;;
 eightteen) NUMBRI[$FOR]=18;;
 nineteen)  NUMBRI[$FOR]=19;;
 twenty)    NUMBRI[$FOR]=20;;
 esac

 _debug "drop ${NUMBRI[$FOR]} ${INGRED[$FOR]}"

case ${NUMBRI[$FOR]} in '') break;;esac
case ${INGRED[$FOR]} in '') break;;esac
 _drop_in_cauldron ${NUMBRI[$FOR]} ${INGRED[$FOR]}

 done
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
 sleep ${SLEEP}s

 _is 0 1 drop $GOAL
 success=$((success+1))
 else
 _failure &
 _is 0 1 drop slag
 fi
else
 _disaster &
fi

_return_to_cauldron
_loop_counter

done

# *** Here ends program *** #
_say_end_msg
