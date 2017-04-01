#!/bin/bash


# ** VARIABLES ** #
DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

PRINT=draw         # print command to msg pane - was using drawextinfo which worked too
DRAW_INFO=drawinfo # drawextinfo

# *** Here begins program *** #
echo $PRINT 2 "$0 is started.."


# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo $PRINT 5 "Script to produce water of the wise."
echo $PRINT 7 "Syntax:"
echo $PRINT 7 "$0 NUMBER"
echo $PRINT 5 "Allowed NUMBER will loop for"
echo $PRINT 5 "NUMBER times to produce NUMBER of"
echo $PRINT 5 "Water of the Wise ."

        exit 0
        }

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo $PRINT 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1

} || {
echo $PRINT 3 "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
echo $PRINT 3 "Need <number> ie: script $0 3 ."
        exit 1
}

_scripttell_check(){
local STRING="$*"
STRING=${STRING:-"$REPLY"}
case $STRING in
*scripttell*) :;;
*) return 0;;
esac

case $STRING in
"scripttell break") return 1;;
"scripttell exit")  exit 1;;
*) echo draw 3 "got '$STRING' - dont know what to do with it.";;
esac
return 0
}

# *** Check if standing on a cauldron *** #

echo $PRINT 4 "Checking if on cauldron..."
UNDER_ME='';
echo request items on

while [ 1 ]; do
read UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in
 "request items on end") break;;
esac
#test "$UNDER_ME" = "scripttell break" && break
#test "$UNDER_ME" = "scripttell exit" && exit 1
_scripttell_check "$UNDER_ME" || break
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo $PRINT 3 "Seems not to stand upon cauldron!"
exit 1
}

echo $PRINT 7 "Done."

# *** Actual script to alch the desired water of the wise           *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water --                        *** #
# *** only one inventory line with water(s) allowed !!              *** #

# *** Now get the number of desired water of                        *** #
# *** seven times the number of the desired water of the wise.      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** west of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

rm -f /tmp/cf_script.rpl # empty old log file


# *** Readying rod of word of recall - just in case *** #

echo $PRINT 4 "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*'rod of word of recall'*) RECALL=1;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply rod of word of recall"
fi

echo $PRINT 7 "Done."

# *** EXIT FUNCTIONS *** #
f_exit(){
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s
echo $PRINT 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch $DRAW_INFO
exit $1
}

f_emergency_exit(){
echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo $PRINT 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
echo "issue 1 1 fire_stop"
exit $1
}


# *** Getting Player's Speed *** #

echo $PRINT 4 "Processing Player's Speed..."

SLEEP=4           # setting defaults
DELAY_DRAWINFO=8

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while [ 1 ]; do
read -t 1 ANSWER
echo "$ANSWER" >>/tmp/cf_request.log
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

echo unwatch request

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2; $PL_SPEED / 100000" | bc -l`

echo $PRINT 7 "" "" "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's/\.//g;s/^0*//'`
test "${PL_SPEED//[0-9]/}" && PL_SPEED=50
PL_SPEED=${PL_SPEED:-50}

echo $PRINT 7 "Player speed is $PL_SPEED"

  if test $PL_SPEED -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test $PL_SPEED -gt 28; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test $PL_SPEED -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
fi

echo $PRINT 7 "Done."


# *** Check if cauldron is empty *** #

echo $PRINT 4 "Checking if cauldron is empty..."

echo "issue 1 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s

echo "issue 1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"
#sleep 1s

while [ 1 ]; do
read -t 1 REPLY
echo "REPLY=$REPLY" >>/tmp/cf_script.rpl
#echo $PRINT 4 REPLY=$REPLY
REPLY_ALL="$REPLY
$REPLY_ALL"
case "$REPLY" in
'') break;;
"$OLD_REPLY") break;;
esac
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo $PRINT 3 "" "Cauldron seems NOT empty !!"
echo $PRINT 3 " " "Please check or empty the cauldron and try again."
f_exit 1
}

echo unwatch $DRAW_INFO

echo $PRINT 7 "OK ! Seems cauldron IS empty."

sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s


echo $PRINT 4 "OK... Might the Might be with You!"

# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=${TIMEE:-`date +%s`}

OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

echo "issue 1 1 drop 7 water"


while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*'Nothing to drop.') f_exit 1;;
*'There are only'*)  f_exit 1;;
*'There is only'*)   f_exit 1;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check

OLD_REPLY="$REPLY"
sleep 0.1s
done


echo unwatch $DRAW_INFO
sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s



echo watch $DRAW_INFO

echo "issue 1 1 use_skill alchemy"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*'pours forth monsters!') f_exit 1;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO



echo "issue 1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

echo "issue 7 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
case "$REPLY" in
*'Nothing to take!') NOTHING=1;;
'') break;;
"$OLD_REPLY") break;;
esac
_scripttell_check
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP}s

if test $NOTHING = 0; then

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep ${SLEEP}s

#if test $NOTHING = 0; then
#for drop in `seq 1 1 7`; do  # unfortunately does not work without this nasty loop
echo "issue 0 1 drop water of the wise"    # issue 1 1 drop drops only one water
echo "issue 0 1 drop waters of the wise"
echo "issue 0 1 drop water (cursed)"
echo "issue 0 1 drop waters (cursed)"
echo "issue 0 1 drop water (magic)"
echo "issue 0 1 drop waters (magic)"
#echo "issue 0 1 drop water (magic) (cursed)"
#echo "issue 0 1 drop waters (magic) (cursed)"
echo "issue 0 1 drop water (cursed) (magic)"
echo "issue 0 1 drop waters (cursed) (magic)"
#echo "issue 0 1 drop water (unidentified)"
#echo "issue 0 1 drop waters (unidentified)"

echo "issue 0 1 drop slag"               # many times draws 'But there is only 1 slags' ...
#echo "issue 0 1 drop slags"

fi

sleep ${DELAY_DRAWINFO}s
#done                         # to drop all water of the wise at once ...

echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s

echo request items on

UNDER_ME='';
UNDER_ME_LIST='';

while [ 1 ]; do
read -t 1 UNDER_ME
echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in
"request items on end") break;;
'') break;;
esac
#test "$UNDER_ME" = "scripttell break" && break
#test "$UNDER_ME" = "scripttell exit" && exit 1
#test "$UNDER_ME" || break
_scripttell_check

sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo $PRINT 3 "LOOP BOTTOM: SEEMS NOT ON CAULDRON!"
f_exit 1
}


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo $PRINT 4 " " " " "Elapsed $TIME s, still $TRIES_STILL to go..."

done

# *** Here ends program *** #
echo $PRINT 2 "$0 is finished."
