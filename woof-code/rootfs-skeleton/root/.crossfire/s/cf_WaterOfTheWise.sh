#!/bin/bash

export PATH=/bin:/usr/bin


# *** Here begins program *** #
echo draw 2 1 1 "$0 is started.."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

echo draw 5 "Script to produce water of the wise."
echo draw 7  "Syntax:"
echo draw 7  "$0 NUMBER"
echo draw 5  "Allowed NUMBER will loop for"
echo draw 5  "NUMBER times to produce NUMBER of"
echo draw 5  "Water of the Wise ."

        exit 0
;; esac

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
}

NUMBER=$PARAM_1

} || {
echo draw 3 "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
echo draw 3 "Need <number> ie: script $0 3 ."
        exit 1
}

# *** Check if standing on a cauldron *** #

echo draw 4 1 1 "Checking if on cauldron..."
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

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
exit 1
}

echo draw 7 "Done."

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

echo draw 4  "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply rod of word of recall"
fi

echo draw 7 "Done."

# *** EXIT FUNCTIONS *** #
f_exit(){
echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep 1s
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawextinfo
exit $1
}

f_emergency_exit(){
echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo draw 3 1 1 "Emergency Exit $0 !"
echo unwatch drawextinfo
echo "issue 1 1 fire_stop"
exit $1
}


# *** Getting Player's Speed *** #

echo draw 4 "Processing Player's Speed..."

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
PL_SPEED="0.${PL_SPEED:0:2}"

echo draw 7 "" "" "Player speed is $PL_SPEED"

PL_SPEED="${PL_SPEED:2:2}"
echo draw 7 "Player speed is $PL_SPEED"

  if test $PL_SPEED -gt 35; then
SLEEP=1; DELAY_DRAWINFO=2
elif test $PL_SPEED -gt 28; then
SLEEP=2; DELAY_DRAWINFO=4
elif test $PL_SPEED -gt 15; then
SLEEP=3; DELAY_DRAWINFO=6
fi

echo draw 7 "Done."


# *** Check if cauldron is empty *** #

echo draw 4  "Checking if cauldron is empty..."

echo "issue 1 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s

echo "issue 1 1 apply"
sleep 0.5s

echo watch drawinfo
echo watch drawextinfo

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo draw 3 "" "Cauldron NOT empty !!"
echo draw 3 " " "Please empty the cauldron and try again."
f_exit 1
}

echo unwatch drawextinfo
echo unwatch drawinfo

echo draw 7 1 2 "OK ! Cauldron IS empty."

sleep ${SLEEP}s

echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep ${SLEEP}s


echo draw 4 2 3 "OK... Might the Might be with You!"

# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"
sleep 0.5s

echo watch drawextinfo

echo "issue 1 1 drop 7 water"


while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done


echo unwatch drawextinfo
sleep ${SLEEP}s

echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep ${SLEEP}s



echo watch drawextinfo

echo "issue 1 1 use_skill alchemy"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawextinfo



echo "issue 1 1 apply"
sleep 0.5s

echo watch drawextinfo

echo "issue 7 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawextinfo

sleep ${SLEEP}s

echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 west"
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

echo "issue 1 1 east"
echo "issue 1 1 east"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep ${SLEEP}s

echo request items on

UNDER_ME='';
UNDER_ME_LIST='';

while [ 1 ]; do
read -t 1 UNDER_ME
echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
test "$UNDER_ME" || break

sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo draw 4 " " " " "Elapsed $TIME s, still $TRIES_STILL to go..."

done

# *** Here ends program *** #
echo draw 2 "$0 is finished."
