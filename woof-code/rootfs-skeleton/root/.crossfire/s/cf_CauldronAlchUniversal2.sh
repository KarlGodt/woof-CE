#!/bin/bash
# uses arrays

rm -f /tmp/cf_*

exec 2>>/tmp/cf_script.err

# TODO Player Speed

# *** Setting defaults *** #
DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup and drop the result(s) to not
# increase carried weight. This version does not adjust player speed after
# several weight losses.

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

LOG_REPLY_FILE=/tmp/cf_script.rpl

# beeping
BEEP_DO=1
BEEP_LENGTH=500
BEEP_FREQ=700

_beep(){
[ "$BEEP_DO" ] || return 0
beep -l $BEEP_LENGTH -f $BEEP_FREQ
}

_ping(){
    :
}

# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 5 " with '$*' parameter."

# *** Check for parameters *** #
[ "$*" ] || {
echo draw 3 "Script needs skill, goal_item_name, numberofalchemyattempts, ingredient and numberofingredient as arguments."
echo draw 3 "See -h --help option for more information."
        exit 1
}


until [ $# = 0 ];
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help|*usage)

echo draw 5 "Script to produce alchemy objects."
echo draw 7 "Syntax:"
echo draw 7 "$0 SKILL ARTIFACT NUMBER INGREDIENTX NUMBERX INGREDIENTY NUMBERY ..."
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce"
echo draw 5 "ARTIFACT alch with"
echo draw 5 "INGREDIENTX NUMBERX ie 'water of the wise' '1'"
echo draw 2 "INGREDIENTY NUMBERY ie 'mandrake root' '1'"
echo draw 5 "by SKILL using cauldron automatically determined by SKILL"
echo draw 5 "If NUMBER is not a digit integer but '-I' --infinite,"
echo draw 5 "loops forever until ingredient runs out."
echo draw 3 "Since the client does split space in words"
echo draw 3 "even if quoted, the ingredients with space"
echo draw 3 "need space replaced. Replacement is '_' underscore."
echo draw 2 "Options:"
echo draw 5 "-d  to turn on debugging."
echo draw 5 "-L  to log to $LOG_REPLY_FILE ."
echo draw 5 "-v  to be more talkaktive."
echo draw 7 "-F each --fast sleeps 0.2 s less"
echo draw 8 "-S each --slow sleeps 0.2 s more"
echo draw 3 "-X --nocheck do not check cauldron (faster)"

        exit 0
;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
-F|*fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
-S|*slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
-X|*nocheck) unset g_nullstring_CHECK_DO;;


alchemy|alchemistry) SKILL=alchemy;     CAULDRON=cauldron;;
bowyer|bowyery)      SKILL=bowyer;      CAULDRON=workbench;;
jeweler)             SKILL=jeweler;     CAULDRON=jeweler_bench;;
smithery|smithing)   SKILL=smithery;    CAULDRON=forge;;
thaumaturgy)         SKILL=thaumaturgy; CAULDRON=thaumaturg_desk;;
woodsman|wood*lore)  SKILL=woodsman;    CAULDRON=stove;;

cauldron)            SKILL=alchemy;     CAULDRON=cauldron;;
workbench)           SKILL=bowyer;      CAULDRON=workbench;;
jeweler_bench)       SKILL=jeweler;     CAULDRON=jeweler_bench;;
forge)               SKILL=smithery;    CAULDRON=forge;;
thaumaturg_desk)     SKILL=thaumaturgy; CAULDRON=thaumaturg_desk;;
stove)               SKILL=woodsman;    CAULDRON=stove;;


*)
# *** testing parameters for validity *** #

C=0 # COUNTER used in arrays, set zero as default

echo "${BASH_ARGC[0]} : ${BASH_ARGV[@]}" >>/tmp/cf_script.test

##WITHOUT_FIRST=$(( ${BASH_ARGC[0]} - 1 ))
#for c in `seq $(echo "${BASH_ARGC[0]}") -2 1`;
##for c in `seq $WITHOUT_FIRST -2 1`;
#do
##vc=$((c-1));ivc=$((vc-1));((C++));
#vc=$((c-0));ivc=$((vc-1));((C++));

for c in `seq 0 2 $(( $# - 1 ))`;
do

vc=$c
ivc=$((vc+1))
((C++))

INGRED[$C]=`echo "${BASH_ARGV[$vc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
#INGRED[$C]=`echo "${BASH_ARGV[$ivc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
[ "$DEBUG" ] && echo draw 3 $C INGRED ${INGRED[$C]}
case ${INGRED[$C]} in -I|*infinite) :;;
 -*|$SKILL|$CAULDRON)
 unset INGRED[$C]
 ((C--))
 continue;;
esac
[ "$DEBUG" ] && echo draw 3 $C INGRED ${INGRED[$C]}

NUMBER[$C]=`echo "${BASH_ARGV[$ivc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
#NUMBER[$C]=`echo "${BASH_ARGV[$vc]}" |sed 's|^"||;s|"$||' |sed "s|^'||;s|'$||"`
[ "$DEBUG" ] && echo draw 3 $C NUMBER ${NUMBER[$C]}
case ${NUMBER[$C]} in -I|*infinite) :;;
 -*|$SKILL|$CAULDRON)
 unset NUMBER[$C] INGRED[$C]
 ((C--))
 continue;;
esac
[ "$DEBUG" ] && echo draw 3 $C NUMBER ${NUMBER[$C]}

# here we could shift syntax 3 water_of_the_wise 7 water
case ${INGRED[$C]} in [0-9]*|-I|*infinite)
 tVAR1=${INGRED[$C]}
 tVAR2=${NUMBER[$C]}
 INGRED[$C]=$tVAR2
 NUMBER[$C]=$tVAR1
 ;;
esac

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

break
;;
esac

sleep 0.1
shift
done

GOAL=${INGRED[$C]}
GOAL=`echo "${GOAL}" | tr '_' ' '`
NUMBER_ALCH=${NUMBER[$C]}

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
*) echo draw 3 "NUMBER_ALCH '$NUMBER_ALCH' incorrect";exit 1;;
esac

if test "$NUMBER_ALCH"; then
 test "$NUMBER_ALCH" = 'I' || test "$NUMBER_ALCH" -ge 1 || NUMBER_ALCH=1 #paranoid precaution
fi

# get rid of underscores
CC=0
for c in `seq 1 1 $((C-1))`
do
((CC++))
INGRED[$CC]=`echo "${INGRED[$CC]}" | tr '_' ' '`
echo "INGRED[$CC]='${INGRED[$CC]}'" >>/tmp/cf_script.test
[ "$DEBUG" ] && echo draw 3 "INGRED[$CC]=${INGRED[$CC]}"
done


test "$SKILL" -a "$GOAL" -a "$NUMBER_ALCH" -a "${INGRED[1]}" -a "${NUMBER[1]}" || {
echo draw 3 "Need <skill> <artifact> <number> <ingredient> <numberof>"
echo draw 3 "ie: script $0 alchemy water_of_the_wise 10 water 7 ."
echo draw 3 "or script $0 alchemy balm_of_first_aid 20 water_of_the_wise 1 mandrake_root 1 ."
        exit 1
}

test "$NUMBER_ALCH" = 'I' && unset NUMBER_ALCH

case $SKILL in
alchemy|bowyer|jeweler|smithery|thaumaturgy|woodsman) :;;
*) echo draw 3 "'$SKILL' not valid!"
echo draw 3 "Valid skills are alchemy, bowyer, jeweler, smithery, thaumaturgy, woodsman"
exit 1
;;
esac
echo draw 7 "OK using $SKILL on $CAULDRON"

case $CAULDRON in
cauldron|workbench|jeweler_bench|forge|thaumaturg_desk|stove) :;;
*) echo draw 3 "'$CAULDRON' not valid!"
echo draw 3 "Valid cauldrons are cauldron, workbench, jeweler_bench, forge, thaumaturg_desk, stove"
exit 1
;;
esac
echo draw 7 "OK using $SKILL on $CAULDRON"


# *** Check if standing on a $CAULDRON *** #
unset UNDER_ME UNDER_ME_LIST

echo request items on

while [ 1 ]; do
read -t 2 UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
test "$UNDER_ME" || break
done

 test "`echo "$UNDER_ME_LIST" | grep "${CAULDRON}$"`" || {
  echo draw 3 "Need to stand upon a '$CAULDRON' to do '$SKILL' !"
  _beep
  exit 1
 }

# *** Check if is in inventory *** #

rm -f /tmp/cf_script.inv || exit 1
INVTRY='';

echo request items inv
while [ 1 ]; do
INVTRY=""
read -t 2 INVTRY || break
echo "$INVTRY" >>/tmp/cf_script.inv
#echo draw 3 "$INVTRY"
test "$INVTRY" = "" && break
test "$INVTRY" = "request items inv end" && break
test "$INVTRY" = "scripttell break" && break
test "$INVTRY" = "scripttell exit" && exit 1
sleep 0.01s
done

rm -f /tmp/cf_script.grep

CC=0
for one in `seq 1 1 $((C-1))`
do

((CC++))
GREP_INGRED[$CC]=`echo "${INGRED[$CC]}" | sed 's/ /\[s \]\*/g'`
echo "GREP_INGRED[$CC]='${GREP_INGRED[$CC]}'" >>/tmp/cf_script.test2

grep "${GREP_INGRED[$CC]}" /tmp/cf_script.inv >>/tmp/cf_script.grep

# *** Check for sufficient amount of ingredient *** #
grepMANY=`grep "${GREP_INGRED[$CC]}" /tmp/cf_script.inv`
if [[ "$grepMANY" ]]; then
 if [ "`echo "$grepMANY" | wc -l`" -gt 1 ]; then
 echo draw 3 "More than 1 of '${INGRED[$CC]}' in inventory."
 exit 1
 else
 echo draw 7 "'${INGRED[$CC]}' in inventory."
 fi
else
echo draw 3 "No '${INGRED[$CC]}' in inventory."
exit 1
fi

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
I|-I|*infinite) NUMBER_ALCH="I";;
[0-9]*) :;;
*) echo draw 3 "'$NUMBER_ALCH' incorrect";exit 1;;
esac


# *** Actual script to alch the desired out_come_product            *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop ingred_1' and 'drop ingred_2'                   *** #
# *** before beginning to alch.                                     *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Then get the number of desired ingredient_1 and               *** #
# *** the number of the other ingredients.                          *** #

# *** Then walk onto the $g_edit_string_CAULDRON and make sure      *** #
# *** there are all the 4 tiles free to move                        *** #
# *** $g_edit_string_DIRB of the $g_edit_string_CAULDRON.           *** #
# *** Do not open the $g_edit_string_CAULDRON, this script does it. *** #
# *** HAPPY ALCHING !!!                                             *** #


echo "issue 1 1 pickup 0"  # precaution

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

echo unwatch
echo watch $DRAW_INFO
_beep
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo draw 3 "Emergency Exit $0 !"
echo watch $DRAW_INFO
echo "issue 1 1 fire_stop"

test "$*" && echo draw 5 "$*"
_beep
exit $RV
}


rm -f "$LOG_REPLY_FILE"

sleep 1s

TIMEB=`/bin/date +%s`
FAIL=0
SUCC=0
one=0
C=$((C-1))

case $NUMBER_ALCH in
[0-9]*) :;;
*) NUMBER_ALCH=infinite;;
esac


while :;
do

tBEG=`/bin/date +%s`

OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"

echo watch $DRAW_INFO

sleep 1s

 for FOR in `seq 1 1 $C`; do

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

 while [ 3 ]; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && break 3 # f_exit 1
 test "`echo "$REPLY" | grep '.*There are only.*'`"  && break 3 # f_exit 1
 test "`echo "$REPLY" | grep '.*There is only.*'`"   && break 3 # f_exit 1
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

 done

echo unwatch $DRAW_INFO
sleep 1s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep 1
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
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && break 2 # exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo watch $DRAW_INFO

echo "issue 1 1 apply"
#echo "issue 7 1 take"
echo issue 0 0 "get all"  # "1 1 get all" gets 1 of X items topmost or each line only
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

for FOR in `seq 1 1 $C`; do

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

#echo "issue 0 1 drop (magic)"
#echo "issue 0 1 drop (cursed)"

echo draw 7 "drop slag"
echo "issue 0 1 drop slag"
#echo "issue 0 1 drop slags"

DELAY_DRAWINFO=4  #speed 0.32
sleep ${DELAY_DRAWINFO}s


echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 2s         #speed 0.32


one=$((one+1))
tEND=`/bin/date +%s`
tLAP=$((tEND-tBEG))

case $NUMBER_ALCH in
infinite)
echo draw 8 "time ${tLAP}s used, $one lap(s) run."
;;
*) toGO=$((NUMBER_ALCH-one))
echo draw 5 "time ${tLAP}s used, still $toGO laps.."
test "$one" = "$NUMBER_ALCH" && break
;;
esac


done  # *** END of Main Loop *** #


# *** Here ends program *** #

# Now count the whole loop time
TIMELE=`/bin/date +%s`
TIMEL=$((TIMELE-TIMEB))
TIMELM=$((TIMEL/60))
TIMELS=$(( TIMEL - (TIMELM*60) ))
case $TIMELS in [0-9]) TIMELS="0$TIMELS";; esac
echo draw 5 "Whole  loop  time : $TIMELM:$TIMELS minutes." # light blue

if test "$FAIL" = 0; then
 echo draw 7 "You succeeded $one times of $one ." # green
else
if test "$((one/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $one ."    # light green
 echo draw 7 "You should increase your Int stat."
else
 SUCC=$((one-FAIL))
 echo draw 7 "You succeeded $SUCC times of $one ." # green
fi
fi

# Now count the whole script time
TIMEZ=`/bin/date +%s`
TIMEY=$((TIMEZ-TIMEA))
TIMEAM=$((TIMEY/60))
TIMEAS=$(( TIMEY - (TIMEAM*60) ))
case $TIMEAS in [0-9]) TIMEAS="0$TIMEAS";; esac
echo draw 6 "Whole script time : $TIMEAM:$TIMEAS minutes." # dark orange


echo draw 2 "$0 is finished."
_beep
