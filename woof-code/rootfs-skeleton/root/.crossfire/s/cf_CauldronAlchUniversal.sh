#!/bin/bash
# uses arrays, ++

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

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

g_edit_string_DRAW_INFO=drawinfo  # drawextinfo (old clients) OR drawinfo (new clients) # used for catching msgs watch/unwatch $g_edit_string_DRAW_INFO
g_edit_float_DELAY_DRAWINFO=4  #speed 0.32

g_edit_string_LOG_REPLY_FILE=/tmp/cf_script.rpl

g_edit_nulldigit_COLOURED=0  # either empty or 0 - 12,
# in gtk1 client 0 (black) prints lowerer pane, 1 (black) and 2-12 prints to upper pane

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
echo draw ${g_edit_nulldigit_COLOURED:-5} "Allowed NUMBER will loop for"
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
        exit 0
;;
esac

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


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


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


_probe_if_on_cauldron(){
# *** Check if standing on a $g_edit_string_CAULDRON *** #
echo draw ${g_edit_nulldigit_COLOURED:-2} "Checking if standing on a '$g_edit_string_CAULDRON' .."

echo draw ${g_edit_nulldigit_COLOURED:-5} "Creating UNDER_ME_LIST .."
UNDER_ME='';
echo request items on

while [ 1 ]; do
read -t 1 UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
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

# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***

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
#echo draw ${g_edit_nulldigit_COLOURED:-3} "$INVTRY"
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
# *** g_edit_string_DIRB of the $g_edit_string_CAULDRON.            *** #
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

#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
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
# *** diff marker 6
# *** diff marker 7
# ***
# ***

echo "issue 1 1 pickup 0"  # precaution

rm -f "$g_edit_string_LOG_REPLY_FILE"

sleep 1s

_debug_two && echo monitor; #DEBUG


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

 while [ 1 ]; do
 read -t 1 REPLY
 [ "$DEBUG" ] && echo "$REPLY" >>"$g_edit_string_LOG_REPLY_FILE"
 test "$REPLY" || break
 test "`echo "$REPLY" | grep 'monitor'`" && continue  #TODO
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
 test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

 done

_debug_two || echo unwatch $g_edit_string_DRAW_INFO;

sleep 1s

# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***

echo draw ${g_edit_nulldigit_COLOURED:-2} "Closing cauldron '$g_edit_string_CAULDRON' .."
echo issue 1 1 "$g_edit_string_DIRB"
echo issue 1 1 "$g_edit_string_DIRB"
sleep 1
echo issue 1 1 "$g_auto_string_DIRF"
echo issue 1 1 "$g_auto_string_DIRF"
sleep 1s


# *** TODO: The $g_edit_string_CAULDRON burps and then pours forth monsters!
_debug_two || echo watch $g_edit_string_DRAW_INFO;

echo draw ${g_edit_nulldigit_COLOURED:-5} "Using '$g_edit_string_SKILL' .."
echo issue 1 1 use_skill "$g_edit_string_SKILL"

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
[ "$DEBUG" ] && echo "$REPLY" >>"$g_edit_string_LOG_REPLY_FILE"
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

# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***

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

echo draw ${g_edit_nulldigit_COLOURED:-5} "Opening cauldron ..."
# echo issue 1 1 "apply $g_edit_string_CAULDRON"  ## readys cauldron in inventory: You readied cauldron.
 echo issue 1 1 "apply"
sleep 1s

#echo draw ${g_edit_nulldigit_COLOURED:-5} "Taking 7 ..."
#echo "issue 7 1 take"
 echo draw ${g_edit_nulldigit_COLOURED:-5} "Getting all .."
 echo issue 0 0 "get all"  # "1 1 get all" gets 1 of X items topmost or each line only
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
# *** diff marker 12
# *** diff marker 13
# ***
# ***

toGO=$((g_auto_digit_NUMBER_ALCH-one))
tEND=`/bin/date +%s`
tLAP=$((tEND-tBEG))
echo draw ${g_edit_nulldigit_COLOURED:-8} "time ${tLAP}s used, still $toGO laps.."

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
echo draw ${g_edit_nulldigit_COLOURED:-2} "$0 is finished."
beep -l 500 -f 700

# ***
# ***
# *** diff marker 14
