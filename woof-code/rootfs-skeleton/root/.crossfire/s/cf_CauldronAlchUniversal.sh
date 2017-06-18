#!/bin/bash
# uses arrays, ++

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

# *** Setting defaults *** #

# Set here g_edit_string_SKILL and g_edit_string_CAULDRON you want to use ** #
#g_edit_string_SKILL=woodsman
g_edit_string_SKILL=alchemy
# etc.

#g_edit_string_CAULDRON=stove
g_edit_string_CAULDRON=cauldron
# etc.

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup and drop the result(s) to not
# increase carried weight. This version does not adjust player speed after
# several weight losses.

g_edit_string_DIRB=west  # direction back to go

case $g_edit_string_DIRB in
west)  g_auto_string_DIRF=east;;
east)  g_auto_string_DIRF=west;;
north) g_auto_string_DIRF=south;;
south) g_auto_string_DIRF=north;;
northwest) g_auto_string_DIRF=southeast;;
northeast) g_auto_string_DIRF=southwest;;
southwest) g_auto_string_DIRF=northeast;;
southeast) g_auto_string_DIRF=northwest;;
esac

g_edit_string_DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                                  # OR drawextinfo (new servers)
# used for catching msgs watch/unwatch $g_edit_string_DRAW_INFO

g_edit_float_DELAY_DRAWINFO=4  #speed 0.32

g_edit_string_LOG_REPLY_FILE=/tmp/cf_script.rpl

g_edit_nulldigit_COLOURED=0  # either empty or 0 - 12,
# in gtk1 client 0 (black) prints lowerer pane, 1 (black) and 2-12 prints to upper pane

DEBUG=1
LOGGING=

_ping(){
    :
}

_debug_two(){
[ "$DEBUG" ]       || return 3
[ "$DEBUG" -ge 2 ] || return 4
}

# *** Here begins program *** #
echo draw ${g_edit_nulldigit_COLOURED:-2} "$0 is started.."
echo draw ${g_edit_nulldigit_COLOURED:-5} " with '$*' parameter."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"|*usage)

echo draw ${g_edit_nulldigit_COLOURED:-0} ""
echo draw ${g_edit_nulldigit_COLOURED:-1} ""
echo draw ${g_edit_nulldigit_COLOURED:-5} "Script to produce alchemy objects."
echo draw ${g_edit_nulldigit_COLOURED:-7} "Syntax:"
echo draw ${g_edit_nulldigit_COLOURED:-7} "$0 ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
echo draw ${g_edit_nulldigit_COLOURED:-5} "Mandatory NUMBER will loop for"
echo draw ${g_edit_nulldigit_COLOURED:-5} "NUMBER times to produce"
echo draw ${g_edit_nulldigit_COLOURED:-5} "ARTIFACT alch with"
echo draw ${g_edit_nulldigit_COLOURED:-2} "INGREDIENTX NUMBERX ie 'water_of_the_wise' '1'"
echo draw ${g_edit_nulldigit_COLOURED:-2} "INGREDIENTY NUMBERY ie 'mandrake_root' '1'"
echo draw ${g_edit_nulldigit_COLOURED:-3} "Since the client does split space in words"
echo draw ${g_edit_nulldigit_COLOURED:-3} "even if quoted, the ingredients with space"
echo draw ${g_edit_nulldigit_COLOURED:-3} "need space replaced. Replacement is '_' underscore."
echo draw ${g_edit_nulldigit_COLOURED:-4} "PLEASE MANUALLY EDIT g_edit_string_SKILL"
echo draw ${g_edit_nulldigit_COLOURED:-4} "and g_edit_string_CAULDRON variables"
echo draw ${g_edit_nulldigit_COLOURED:-4} "in header of this script for your needs."
echo draw ${g_edit_nulldigit_COLOURED:-6} "g_edit_string_SKILL variable currently set to '$g_edit_string_SKILL'"
echo draw ${g_edit_nulldigit_COLOURED:-6} "g_edit_string_CAULDRON var currently set to '$g_edit_string_CAULDRON'"
echo draw ${g_edit_nulldigit_COLOURED:-0} ""
echo draw ${g_edit_nulldigit_COLOURED:-1} ""
        exit 0
;;
esac


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


# *** testing parameters for validity *** #
g_noedit_digit_C=0 # used in ingredients arrays, set zero as default here,
# gets changed again, set to 1 to skip result, after g_auto_string_GOAL and g_auto_digit_NUMBER_ALCH are defined

echo "${BASH_ARGC[0]} : ${BASH_ARGV[@]}" >>/tmp/cf_script.test
#WITHOUT_FIRST=$(( ${BASH_ARGC[0]} - 1 ))
for c in `seq $(echo "${BASH_ARGC[0]}") -2 1`;
#for c in `seq $WITHOUT_FIRST -2 1`;
do
vc=$((c-1));ivc=$((vc-1));((g_noedit_digit_C++));

g_auto_string_INGRED[$g_noedit_digit_C]=`echo "${BASH_ARGV[$vc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
echo draw ${g_edit_nulldigit_COLOURED:-3} "g_auto_string_INGRED $g_noedit_digit_C : ${g_auto_string_INGRED[$g_noedit_digit_C]}"

g_auto_digit_NUMBER[$g_noedit_digit_C]=`echo "${BASH_ARGV[$ivc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
echo draw ${g_edit_nulldigit_COLOURED:-3} "g_auto_digit_NUMBER $g_noedit_digit_C :${g_auto_digit_NUMBER[$g_noedit_digit_C]}"

case ${g_auto_digit_NUMBER[$g_noedit_digit_C]} in
1) g_auto_digit_NUMBER[$g_noedit_digit_C]=one;;
2) g_auto_digit_NUMBER[$g_noedit_digit_C]=two;;
3) g_auto_digit_NUMBER[$g_noedit_digit_C]=three;;
4) g_auto_digit_NUMBER[$g_noedit_digit_C]=four;;
5) g_auto_digit_NUMBER[$g_noedit_digit_C]=five;;
6) g_auto_digit_NUMBER[$g_noedit_digit_C]=six;;
7) g_auto_digit_NUMBER[$g_noedit_digit_C]=seven;;
8) g_auto_digit_NUMBER[$g_noedit_digit_C]=eight;;
9) g_auto_digit_NUMBER[$g_noedit_digit_C]=nine;;
10) g_auto_digit_NUMBER[$g_noedit_digit_C]=ten;;
11) g_auto_digit_NUMBER[$g_noedit_digit_C]=eleven;;
12) g_auto_digit_NUMBER[$g_noedit_digit_C]=twelve;;
13) g_auto_digit_NUMBER[$g_noedit_digit_C]=thirteen;;
14) g_auto_digit_NUMBER[$g_noedit_digit_C]=fourteen;;
15) g_auto_digit_NUMBER[$g_noedit_digit_C]=fifteen;;
16) g_auto_digit_NUMBER[$g_noedit_digit_C]=sixteen;;
17) g_auto_digit_NUMBER[$g_noedit_digit_C]=seventeen;;
18) g_auto_digit_NUMBER[$g_noedit_digit_C]=eightteen;;
19) g_auto_digit_NUMBER[$g_noedit_digit_C]=nineteen;;
20) g_auto_digit_NUMBER[$g_noedit_digit_C]=twenty;;
esac

echo "g_auto_string_INGRED[$g_noedit_digit_C]='${g_auto_string_INGRED[$g_noedit_digit_C]}'" >>/tmp/cf_script.test
echo " g_auto_digit_NUMBER[$g_noedit_digit_C]='${g_auto_digit_NUMBER[$g_noedit_digit_C]}'"  >>/tmp/cf_script.test
done

g_auto_string_GOAL=${g_auto_string_INGRED[1]}
g_auto_string_GOAL=`echo "${g_auto_string_GOAL}" | tr '_' ' '`
g_auto_digit_NUMBER_ALCH=${g_auto_digit_NUMBER[1]}


g_noedit_digit_C=1
for c in `seq $(echo "${BASH_ARGC[0]}") -2 3`;
do
((g_noedit_digit_C++))
g_auto_string_INGRED[$g_noedit_digit_C]=`echo "${g_auto_string_INGRED[$g_noedit_digit_C]}" | tr '_' ' '`
echo "g_auto_string_INGRED[$g_noedit_digit_C]='${g_auto_string_INGRED[$g_noedit_digit_C]}'" >>/tmp/cf_script.test
done
g_auto_digit_C=$g_noedit_digit_C

} || {
echo draw ${g_edit_nulldigit_COLOURED:-3} "Script needs goal_item_name, numberofalchemyattempts, ingredient and numberofingredient as arguments."
echo draw ${g_edit_nulldigit_COLOURED:-3} "See -h --help option for more information."
        exit 1
}

test "$g_auto_string_GOAL" -a "$g_auto_digit_NUMBER_ALCH" -a "${g_auto_string_INGRED[2]}" -a "${g_auto_digit_NUMBER[2]}" || {
echo draw ${g_edit_nulldigit_COLOURED:-3} "Need <artifact> <number> <ingredient> <numberof>"
echo draw ${g_edit_nulldigit_COLOURED:-3} "ie: script $0 water_of_the_wise 10 water 7 ."
echo draw ${g_edit_nulldigit_COLOURED:-3} "or: script $0 balm_of_first_aid 20 water_of_the_wise 1 mandrake_root 1 ."
echo draw ${g_edit_nulldigit_COLOURED:-3} "See -h --help option for more information."
        exit 1
}

# *** Check if is in inventory *** #
echo draw ${g_edit_nulldigit_COLOURED:-2} "Checking if ingred(s) in inventory .."

echo draw ${g_edit_nulldigit_COLOURED:-5} "Creating /tmp/cf_script.inv -- this may take some time .."

rm -f /tmp/cf_script.inv || exit 1
INVTRY='';

# to write the /tmp/cf_script.inv is actually considerably fast,
# probably because have set sleep to 1/10th of the usual 0.1 ( 0.01 ) ...
# but if DEBUG draw to msg pane slow, like 20 seconds for 400 items ...
echo request items inv

while [ 1 ]; do
INVTRY=""
read -t 1 INVTRY || break
echo "$INVTRY" >>/tmp/cf_script.inv
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-3} "$INVTRY"
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
GREP_INGRED[$C2]=`echo "${g_auto_string_INGRED[$C2]}" | sed 's/ /\[s \]\*/g'`

echo draw ${g_edit_nulldigit_COLOURED:-5} "Probing ${g_auto_string_INGRED[$C2]} by ${GREP_INGRED[$C2]} ..."

echo "GREP_INGRED[$C2]='${GREP_INGRED[$C2]}'" >>/tmp/cf_script.test2

grep "${GREP_INGRED[$C2]}" /tmp/cf_script.inv >>/tmp/cf_script.grep

if [[ "`grep "${GREP_INGRED[$C2]}" /tmp/cf_script.inv`" ]]; then
echo draw ${g_edit_nulldigit_COLOURED:-7} "${g_auto_string_INGRED[$C2]} in inventory."
else
echo draw ${g_edit_nulldigit_COLOURED:-3} "No ${g_auto_string_INGRED[$C2]} in inventory."
exit 1
fi

# *** Check for sufficient amount(s) of ingredient(s) *** #
# *** TODO

done


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


case $g_auto_digit_NUMBER_ALCH in
one)   g_auto_digit_NUMBER_ALCH=1;;
two)   g_auto_digit_NUMBER_ALCH=2;;
three) g_auto_digit_NUMBER_ALCH=3;;
four)  g_auto_digit_NUMBER_ALCH=4;;
five)  g_auto_digit_NUMBER_ALCH=5;;
six)   g_auto_digit_NUMBER_ALCH=6;;
seven) g_auto_digit_NUMBER_ALCH=7;;
eight) g_auto_digit_NUMBER_ALCH=8;;
nine)  g_auto_digit_NUMBER_ALCH=9;;
ten)   g_auto_digit_NUMBER_ALCH=10;;
eleven)    g_auto_digit_NUMBER_ALCH=11;;
twelve)    g_auto_digit_NUMBER_ALCH=12;;
thirteen)  g_auto_digit_NUMBER_ALCH=13;;
fourteen)  g_auto_digit_NUMBER_ALCH=14;;
fifteen)   g_auto_digit_NUMBER_ALCH=15;;
sixteen)   g_auto_digit_NUMBER_ALCH=16;;
seventeen) g_auto_digit_NUMBER_ALCH=17;;
eightteen) g_auto_digit_NUMBER_ALCH=18;;
nineteen)  g_auto_digit_NUMBER_ALCH=19;;
twenty)    g_auto_digit_NUMBER_ALCH=20;;
esac
test "$g_auto_digit_NUMBER_ALCH" -ge 1 || g_auto_digit_NUMBER_ALCH=1 #paranoid precaution


f_exit_no_space(){
RV=${1:-0}
shift

echo draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
echo draw 3 "Remove that Item and try again."
echo draw 3 "If this is a Wall, try another place."

test "$*" && echo draw 5 "$*"
beep
exit $RV
}

# *** Does our player possess the skill alchemy ? *** #
_check_skill(){

local l_auto_string_PARAM="$*"
local l_SKILL

echo request skills

while :;
do
 unset REPLY
 sleep 0.1
 read -t 1
  [ "$LOGGING" ] && echo "_check_skill:$REPLY" >>"$LOG_REPLY_FILE"
  [ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$REPLY"

 case $REPLY in    '') break;;
 'request skills end') break;;
 esac

 if test "$l_auto_string_PARAM"; then
  case $REPLY in *"$l_auto_string_PARAM") return 0;; esac
 else # print skill
  l_SKILL=`echo "$REPLY" | cut -f4- -d' '`
  echo draw 5 "'$l_SKILL'"
 fi

done

test ! "$l_auto_string_PARAM" # returns 0 if called without parameter, else 1
}


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


_probe_if_on_cauldron(){
# *** Check if standing on a $g_edit_string_CAULDRON *** #
echo draw ${g_edit_nulldigit_COLOURED:-2} "Checking if standing on a '$g_edit_string_CAULDRON' .."

echo draw ${g_edit_nulldigit_COLOURED:-5} "Creating UNDER_ME_LIST .."
UNDER_ME='';
echo request items on

while [ 1 ]; do
read -t 1 UNDER_ME
sleep 0.1s
[ "$LOGGING" ] && echo "$UNDER_ME" >>/tmp/cf_script.ion
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$UNDER_ME"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done
echo draw ${g_edit_nulldigit_COLOURED:-7} "Done."

 test "`echo "$UNDER_ME_LIST" | grep "${g_edit_string_CAULDRON}$"`" || {
  echo draw ${g_edit_nulldigit_COLOURED:-3} "Need to stand upon a $g_edit_string_CAULDRON!"
  exit 1
 }

echo draw ${g_edit_nulldigit_COLOURED:-7} "OK, am on '$g_edit_string_CAULDRON' ."
}

_check_free_move(){
# *** Check for 4 empty space to DIRB *** #
echo draw 5 "Checking for space to move..."

echo request map pos

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "_check_free_move:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done


PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`

[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-3} "PL_POS_X='$PL_POS_X' PL_POS_Y='$PL_POS_Y'"

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

for nr in `seq 1 1 4`; do

case $g_edit_string_DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
esac

[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-3} "R_X='$R_X' R_Y='$R_Y'"
echo request map $R_X $R_Y

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "request map $R_X $R_Y:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
IS_WALL=`echo "$REPLY" | awk '{print $16}'`
[ "$LOGGING" ] && echo "IS_WALL='$IS_WALL'" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw  ${g_edit_nulldigit_COLOURED:-3} "IS_WALL='$IS_WALL'"
test "$IS_WALL" = 0 || f_exit_no_space 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

done

else

echo draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

echo draw 3 "Could not get X and Y position of player."
exit 1

fi

echo draw 7 "OK."
}


# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***


_prepare_recall(){
# *** Readying rod of word of recall - just in case *** #
echo draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "_prepare_recall:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply rod of word of recall"
fi

echo draw 6 "Done."
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #
echo "issue 0 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP:-1}s

echo draw 5 "Checking for empty cauldron..."

echo "issue 1 1 apply"
sleep ${SLEEP:-1}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

echo watch $g_edit_string_DRAW_INFO

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "_check_empty_cauldron:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
REPLY_ALL="$REPLY
$REPLY_ALL"
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo draw 3 "Cauldron NOT empty !!"
echo draw 3 "Please empty the cauldron and try again."
f_exit 1
}

echo unwatch $g_edit_string_DRAW_INFO

echo draw 7 "OK ! Cauldron SEEMS empty."

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
}


# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***


_get_player_speed(){
# *** Getting Player's Speed *** #

echo draw 5 "Processing Player's speed..."

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while [ 1 ]; do
read -t 1 ANSWER
[ "$LOGGING" ] && echo "_get_player_speed:$ANSWER" >>/tmp/cf_request.log
[ "$DEBUG" ] && echo draw ${g_edit_nulldigit_COLOURED:-6} "$ANSWER"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done


#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
echo draw 7 "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
echo draw 7 "Player speed set to $PL_SPEED"

if test ! "$PL_SPEED"; then
 echo draw ${g_edit_nulldigit_COLOURED:-3} "Unable to receive player speed. Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
elif test "$PL_SPEED" -gt 65; then
SLEEP=0.2; DELAY_DRAWINFO=1.0
elif test "$PL_SPEED" -gt 55; then
SLEEP=0.5; DELAY_DRAWINFO=1.2
elif test "$PL_SPEED" -gt 45; then
SLEEP=1.0; DELAY_DRAWINFO=1.5
elif test "$PL_SPEED" -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test "$PL_SPEED" -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test "$PL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
elif test "$PL_SPEED" -ge  0; then
SLEEP=4.0; DELAY_DRAWINFO=9.0
else
 echo draw 3 "PL_SPEED not a number ? Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
fi

echo draw 6 "Done."
}


_check_skill $g_edit_string_SKILL || f_exit 1 "You do not have the skill '$SKILL'."
_probe_if_on_cauldron
_check_free_move
_check_empty_cauldron
_get_player_speed
_prepare_recall


# *** Actual script to alch the desired water of gem *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the $g_edit_string_CAULDRON and make sure       *** #
# *** there are all the 4 tiles free                                *** #
# *** $g_edit_string_DIRB of the $g_edit_string_CAULDRON.           *** #
# *** Do not open the $g_edit_string_CAULDRON, this script does it. *** #
# *** HAPPY ALCHING !!!                                             *** #


echo "issue 1 1 pickup 0"  # precaution

f_exit(){
RV=${1:-0}
shift

echo "issue 1 1 $g_edit_string_DIRB"
echo "issue 1 1 $g_edit_string_DIRB"
echo "issue 1 1 $g_auto_string_DIRF"
echo "issue 1 1 $g_auto_string_DIRF"
sleep 1s


echo draw ${g_edit_nulldigit_COLOURED:-3} "Exiting $0."

echo unwatch
echo unwatch $g_edit_string_DRAW_INFO
beep
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo draw ${g_edit_nulldigit_COLOURED:-3} "Emergency Exit $0 !"
echo unwatch $g_edit_string_DRAW_INFO
echo "issue 1 1 fire_stop"

test "$*" && echo draw ${g_edit_nulldigit_COLOURED:-5} "$*"
beep
exit $RV
}


# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***


echo "issue 1 1 pickup 0"  # precaution

rm -f "$g_edit_string_LOG_REPLY_FILE"

sleep 1s

_debug_two && echo monitor; #DEBUG

TIMEB=`/bin/date +%s`
FAIL=0
SUCC=0

for one in `seq 1 1 $g_auto_digit_NUMBER_ALCH`
do

tBEG=`/bin/date +%s`

OLD_REPLY="";
REPLY="";
_probe_if_on_cauldron


OLD_REPLY="";
REPLY="";

echo watch $g_edit_string_DRAW_INFO

echo draw ${g_edit_nulldigit_COLOURED:-2} "Opening cauldron '$g_edit_string_CAULDRON' .."
#echo issue 1 1 "apply $g_edit_string_CAULDRON" ## readys cauldron in inventory: You readied cauldron.
echo issue 1 1 "apply"

sleep 1s

 for FOR in `seq 2 1 $g_auto_digit_C`; do

 case ${g_auto_digit_NUMBER[$FOR]} in
 one)   g_auto_digit_NUMBER[$FOR]=1;;
 two)   g_auto_digit_NUMBER[$FOR]=2;;
 three) g_auto_digit_NUMBER[$FOR]=3;;
 four)  g_auto_digit_NUMBER[$FOR]=4;;
 five)  g_auto_digit_NUMBER[$FOR]=5;;
 six)   g_auto_digit_NUMBER[$FOR]=6;;
 seven) g_auto_digit_NUMBER[$FOR]=7;;
 eight) g_auto_digit_NUMBER[$FOR]=8;;
 nine)  g_auto_digit_NUMBER[$FOR]=9;;
 ten)   g_auto_digit_NUMBER[$FOR]=10;;
 eleven)    g_auto_digit_NUMBER[$FOR]=11;;
 twelve)    g_auto_digit_NUMBER[$FOR]=12;;
 thirteen)  g_auto_digit_NUMBER[$FOR]=13;;
 fourteen)  g_auto_digit_NUMBER[$FOR]=14;;
 fifteen)   g_auto_digit_NUMBER[$FOR]=15;;
 sixteen)   g_auto_digit_NUMBER[$FOR]=16;;
 seventeen) g_auto_digit_NUMBER[$FOR]=17;;
 eightteen) g_auto_digit_NUMBER[$FOR]=18;;
 nineteen)  g_auto_digit_NUMBER[$FOR]=19;;
 twenty)    g_auto_digit_NUMBER[$FOR]=20;;
 esac

 echo draw ${g_edit_nulldigit_COLOURED:-5} "drop ${g_auto_digit_NUMBER[$FOR]} ${g_auto_string_INGRED[$FOR]}"

 echo issue 1 1 drop ${g_auto_digit_NUMBER[$FOR]} "${g_auto_string_INGRED[$FOR]}"
 DW=0
 while [ 1 ]; do
 read -t 1 REPLY
 [ "$LOGGING" ] && echo "drop:$REPLY" >>"$g_edit_string_LOG_REPLY_FILE"
 [ "$DEBUG" ] && echo draw 6 "$REPLY"
 test "$REPLY" || break
 test "`echo "$REPLY" | grep 'monitor'`" && continue  #TODO
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1 "Nothing to drop"
 test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1 "Not enough ${g_auto_string_INGRED[$FOR]}"
 test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1 "Not enough ${g_auto_string_INGRED[$FOR]}"
 test "`echo "$REPLY" | grep ".*You put the .* ${g_auto_string_INGRED[$FOR]%% *}.*"`" && { DW=$((DW+1)); unset REPLY; } #s in cauldron (open) (active).
 test "`echo "$REPLY" | grep ".*You put the ${g_auto_string_INGRED[$FOR]%% *}.*"`"    && { DW=$((DW+1)); unset REPLY; } #s in cauldron (open) (active).
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done
 test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing ${g_auto_string_INGRED[$FOR]%% *} in inventory."

 done

_debug_two || echo unwatch $g_edit_string_DRAW_INFO;

sleep 1s


# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***


echo draw ${g_edit_nulldigit_COLOURED:-2} "Closing cauldron '$g_edit_string_CAULDRON' .."
echo issue 1 1 "$g_edit_string_DIRB"
echo issue 1 1 "$g_edit_string_DIRB"
sleep 1
echo issue 1 1 "$g_auto_string_DIRF"
echo issue 1 1 "$g_auto_string_DIRF"
sleep 1s

_probe_if_on_cauldron

# *** TODO: The $g_edit_string_CAULDRON burps and then pours forth monsters!
_debug_two || echo watch $g_edit_string_DRAW_INFO;

echo draw ${g_edit_nulldigit_COLOURED:-5} "Using '$g_edit_string_SKILL' .."
echo issue 1 1 use_skill "$g_edit_string_SKILL"

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
[ "$LOGGING" ] && echo "use_skill $SKILL:$REPLY" >>"$g_edit_string_LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

_debug_two || echo unwatch $g_edit_string_DRAW_INFO;

#TODO: gtk2 client the code works.
# Today in the gtk1 1.12 client "nothing" works:
# 1) When apply on cauldron after use_skill alchemy on it,
#    it opens the cauldron and also applys (drinks)
#    one of the topmost result,
#    which in real would be 2x apply.
#   Just 'take' picks up the empty bottle on top of the stack,
#    but nothing below. Have changed to 'get all' ..
# 2) Then after returning from drop tile spot to the cauldron,
#     when use_skill alchemy, it identifies nearby items,
#     but (then) not does alchemy on the cauldron ...
# 3) When disabling apply to open the cauldron before get all (or take?)
#     then it does not pick up anything, even not the cauldron ...

# The cauldron burps.
#  Ahhh...that water tasted good.
#  You pick up the empty bottle.
# You close cauldron (open) (active).


echo draw ${g_edit_nulldigit_COLOURED:-2} "Closing cauldron '$g_edit_string_CAULDRON' .."
echo issue 1 1 "$g_edit_string_DIRB"
echo issue 1 1 "$g_edit_string_DIRB"
sleep 1
echo issue 1 1 "$g_auto_string_DIRF"
echo issue 1 1 "$g_auto_string_DIRF"
sleep 1s

#monitor 1 1 apply
#watch drawinfo 0 You open cauldron.
#monitor 1 1 drop 7 water
#watch drawinfo 0 You put the waters in cauldron (open) (active).
#watch drawinfo 0 You put the waters in cauldron (open) (active).
#monitor 1 1 west
#monitor 1 1 west
#monitor 1 1 east
#monitor 1 1 east
#monitor apply 135756062
#monitor 1 1 use_skill alchemy
#watch drawinfo 0 The cauldron hiccups loudly.
#watch drawinfo 0 The cauldron hiccups loudly.
#monitor 1 1 west
#monitor 1 1 west
#monitor 1 1 east
#monitor 1 1 east
#monitor apply 135756062
#monitor 1 1 apply
#monitor 0 0 get all
#monitor 1 1 west
#monitor 1 1 west
#monitor 1 1 west
#monitor 1 1 west
#monitor apply 135756062
#monitor 1 1 use_skill sense curse
#monitor 1 1 use_skill sense magic
#monitor 1 1 use_skill alchemy
#monitor 0 1 drop water of the wise

#request items inv 135756062 1 80.000000 0 51 cauldron


# ***
# ***
# *** diff marker 16
# *** diff marker 17
# ***
# ***


_probe_if_on_cauldron

echo draw ${g_edit_nulldigit_COLOURED:-5} "Opening cauldron ..."
# echo issue 1 1 "apply $g_edit_string_CAULDRON"  ## readys cauldron in inventory: You readied cauldron.
 echo issue 1 1 "apply"
sleep 1s

#echo draw ${g_edit_nulldigit_COLOURED:-5} "Taking 7 ..."
#echo "issue 7 1 take"
 echo draw ${g_edit_nulldigit_COLOURED:-5} "Getting all .."
 echo issue 0 0 "get all"  # "1 1 get all" gets 1 of X items topmost or each line only

_debug_two || echo watch $g_edit_string_DRAW_INFO

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "get:$REPLY" >>"$g_edit_string_LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to take\!'`"      && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

_debug_two || echo unwatch $g_edit_string_DRAW_INFO

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

sleep 1s


echo draw ${g_edit_nulldigit_COLOURED:-2} "Going to storage tile .."
echo issue 1 1 "$g_edit_string_DIRB"
echo issue 1 1 "$g_edit_string_DIRB"
sleep 1
echo issue 1 1 "$g_edit_string_DIRB"
echo issue 1 1 "$g_edit_string_DIRB"
sleep 1s

echo draw ${g_edit_nulldigit_COLOURED:-5} "Identifying .."
echo issue 1 1 use_skill "sense curse"
echo issue 1 1 use_skill "sense magic"
echo issue 1 1 use_skill "$g_edit_string_SKILL"
sleep 6s

echo draw ${g_edit_nulldigit_COLOURED:-2} "dropping '$g_auto_string_GOAL' ..."
echo issue 0 1 drop "$g_auto_string_GOAL"

for FOR in `seq 2 1 $g_auto_digit_C`; do

 echo draw ${g_edit_nulldigit_COLOURED:-5} "drop ${g_auto_string_INGRED[$FOR]} (magic)"
 echo issue 0 1 drop "${g_auto_string_INGRED[$FOR]} (magic)"
 echo draw ${g_edit_nulldigit_COLOURED:-5} "drop ${g_auto_string_INGRED[$FOR]}s (magic)"
 echo issue 0 1 drop "${g_auto_string_INGRED[$FOR]}s (magic)"
 sleep 2s
 echo draw ${g_edit_nulldigit_COLOURED:-5} "drop ${g_auto_string_INGRED[$FOR]} (cursed)"
 echo issue 0 1 drop "${g_auto_string_INGRED[$FOR]} (cursed)"
 echo draw ${g_edit_nulldigit_COLOURED:-5} "drop ${g_auto_string_INGRED[$FOR]}s (cursed)"
 echo issue 0 1 drop "${g_auto_string_INGRED[$FOR]}s (cursed)"
 sleep 2s

done

#echo "issue 0 1 drop (magic)"
#echo "issue 0 1 drop (cursed)"

echo draw ${g_edit_nulldigit_COLOURED:-2} "drop slag"  # verbose
echo issue 0 1 drop "slag"
#echo issue 0 1 drop "slags"

sleep ${g_edit_float_DELAY_DRAWINFO}s


# ***
# ***
# *** diff marker 18
# *** diff marker 19
# ***
# ***


toGO=$((g_auto_digit_NUMBER_ALCH-one))
tEND=`/bin/date +%s`
tLAP=$((tEND-tBEG))
echo draw ${g_edit_nulldigit_COLOURED:-8} "time ${tLAP}s used, still $toGO laps.."

echo draw ${g_edit_nulldigit_COLOURED:-2} "Returning to cauldron ...."
echo issue 1 1 "$g_auto_string_DIRF"
echo issue 1 1 "$g_auto_string_DIRF"
sleep 1
echo issue 1 1 "$g_auto_string_DIRF"
echo issue 1 1 "$g_auto_string_DIRF"
sleep 2s         #speed 0.32


_debug_two && {
 # log monitor msgs
  while [ 2 ]
  do
  unset REPLY
  read -t 1
  echo "$REPLY" >>"$g_edit_string_LOG_REPLY_FILE"
  test "$REPLY" || break
  done

 echo unwatch $g_edit_string_DRAW_INFO
 sleep 1
 }

done

# *** Here ends program *** #

# Now count the whole loop time
TIMELE=`/bin/date +%s`
TIMEL=$((TIMELE-TIMEB))
TIMELM=$((TIMEL/60))
TIMELS=$(( TIMEL - (TIMELM*60) ))
case $TIMELS in [0-9]) TIMELS="0$TIMELS";; esac
echo draw 5 "Whole  loop  time : $TIMELM:$TIMELS minutes." # light blue

if test "$FAIL" = 0; then
 echo draw 7 "You succeeded $one times of $g_auto_digit_NUMBER_ALCH ." # green
else
if test "$((g_auto_digit_NUMBER_ALCH/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $g_auto_digit_NUMBER_ALCH ."    # light green
 echo draw 7 "You should increase your Int stat."
else
 SUCC=$((g_auto_digit_NUMBER_ALCH-FAIL))
 echo draw 7 "You succeeded $SUCC times of $g_auto_digit_NUMBER_ALCH ." # green
fi
fi

# Now count the whole script time
TIMEZ=`/bin/date +%s`
TIMEY=$((TIMEZ-TIMEA))
TIMEAM=$((TIMEY/60))
TIMEAS=$(( TIMEY - (TIMEAM*60) ))
case $TIMEAS in [0-9]) TIMEAS="0$TIMEAS";; esac
echo draw 6 "Whole script time : $TIMEAM:$TIMEAS minutes." # dark orange


echo draw ${g_edit_nulldigit_COLOURED:-2} "$0 is finished."
beep -l 500 -f 700


# ***
# ***
# *** diff marker 20
