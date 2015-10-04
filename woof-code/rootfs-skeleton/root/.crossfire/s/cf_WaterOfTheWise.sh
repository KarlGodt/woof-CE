#!/bin/bash

export PATH=/bin:/usr/bin

# *** Here begins program *** #
echo drawextinfo 2 "$0 is started.."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

echo drawextinfo 5  "Script to produce water of the wise."
echo drawextinfo 7  "Syntax:"
echo drawextinfo 7  "$0 NUMBER"
echo drawextinfo 5  "Allowed NUMBER will loop for"
echo drawextinfo 5  "NUMBER times to produce NUMBER of"
echo drawextinfo 5  "Water of the Wise ."

        exit 0
;; esac

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo drawextinfo 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1

} || {
echo drawextinfo 3  "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
echo drawextinfo 3  "Need <number> ie: script $0 3 ."
        exit 1
}

# *** Check if standing on a cauldron *** #

echo drawextinfo 4  "Checking if on cauldron..."
UNDER_ME='';
echo request items on

while :; do
read UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo drawextinfo 3  "Need to stand upon cauldron!"
exit 1
}

echo drawextinfo 7  "Done."

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

echo drawextinfo 4  "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
issue 1 1 apply rod of word of recall
fi

echo drawextinfo 7 "Done."

issue(){
    echo issue "$@"
    sleep 0.2
}

# *** EXIT FUNCTIONS *** #
f_exit(){
issue 1 1 west
issue 1 1 west
issue 1 1 east
issue 1 1 east
sleep 1s
echo drawextinfo 3  "Exiting $0."
echo unwatch
echo unwatch drawinfo
exit $1
}

f_emergency_exit(){
issue 1 1 apply rod of word of recall
issue 1 1 fire center
echo drawextinfo 3 "Emergency Exit $0 !"
echo unwatch drawinfo
issue 1 1 fire_stop
exit $1
}


# *** Getting Player's Speed *** #

echo drawextinfo 4 "Processing Player's Speed..."

SLEEP=4           # setting defaults
DELAY_DRAWINFO=8

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while :; do
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

echo drawextinfo 7 "" "" "Player speed is $PL_SPEED"

PL_SPEED="${PL_SPEED:2:2}"
echo drawextinfo 7  "Player speed is $PL_SPEED"
  if test $PL_SPEED -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0
elif test $PL_SPEED -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2
elif test $PL_SPEED -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6
elif test $PL_SPEED -gt 35; then
SLEEP=1; DELAY_DRAWINFO=2
elif test $PL_SPEED -gt 28; then
SLEEP=2; DELAY_DRAWINFO=4
elif test $PL_SPEED -gt 15; then
SLEEP=3; DELAY_DRAWINFO=6
elif test $PL_SPEED -gt 10; then
SLEEP=4; DELAY_DRAWINFO=8
elif test $PL_SPEED -ge 0; then
SLEEP=5; DELAY_DRAWINFO=10
fi

echo drawextinfo 7  "Done."


# *** Check if cauldron is empty *** #

echo drawextinfo 4  "Checking if cauldron is empty..."

issue 1 1 pickup 0  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s

issue 1 1 apply
sleep 0.5s

#echo watch drawextinfo
echo watch drawinfo

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "TEST if cauldron is empty:" >>/tmp/cf_script.rpl
issue 1 1 get

while :; do
read -t 2 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo drawextinfo 3 "" "Cauldron NOT empty !!"
echo drawextinfo 3 " " "Please empty the cauldron and try again."
f_exit 1
}

#echo unwatch drawextinfo
echo unwatch drawinfo

echo drawextinfo 7  "OK ! Cauldron IS empty."

sleep ${SLEEP}s

issue 1 1 west
issue 1 1 west
issue 1 1 east
issue 1 1 east

sleep ${SLEEP}s


echo drawextinfo 4 "OK... Might the Might be with You!"

# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

OLD_REPLY="";
REPLY="";

issue 1 1 apply
sleep 0.5s

#echo watch drawextinfo
echo watch drawinfo

issue 1 1 drop 7 water

while :; do
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

echo unwatch drawinfo
#echo unwatch drawextinfo
sleep ${SLEEP}s

issue 1 1 west
issue 1 1 west

issue 1 1 east
issue 1 1 east

sleep ${SLEEP}s

#echo watch drawextinfo
echo watch drawinfo

issue 1 1 use_skill alchemy

OLD_REPLY="";
REPLY="";
NOTHING=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

#echo unwatch drawextinfo
echo unwatch drawinfo


issue 1 1 apply
sleep 0.5s

#echo watch drawextinfo
echo watch drawinfo

issue 7 1 get

OLD_REPLY="";
REPLY="";
NOTHING=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

#echo unwatch drawextinfo
echo unwatch drawinfo

sleep ${SLEEP}s

issue 1 1 west
issue 1 1 west
issue 1 1 west
issue 1 1 west

sleep ${SLEEP}s

if test "$NOTHING" = 0; then

issue 1 1 use_skill sense curse
issue 1 1 use_skill sense magic
issue 1 1 use_skill alchemy

sleep ${SLEEP}s

issue 0 1 drop water of the wise    # issue 1 1 drop drops only one water
issue 0 1 drop waters of the wise

issue 0 1 drop water "(cursed)"
issue 0 1 drop waters "(cursed)"

issue 0 1 drop water "(magic)"
issue 0 1 drop waters "(magic)"

issue 0 1 drop water "(cursed) (magic)"
issue 0 1 drop waters "(cursed) (magic)"

#issue 0 1 drop water (magic) (cursed)
#issue 0 1 drop waters (magic) (cursed)
#issue 0 1 drop water (unidentified)
#issue 0 1 drop waters (unidentified)

issue 0 1 drop slag
#issue 0 1 drop slags"

fi

sleep ${DELAY_DRAWINFO}s

issue 1 1 east
issue 1 1 east
issue 1 1 east
issue 1 1 east


sleep ${SLEEP}s
sleep ${DELAY_DRAWINFO}s

echo request items on

UNDER_ME='';
UNDER_ME_LIST='';

while :; do
read -t 2 UNDER_ME
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
echo drawextinfo 3 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo drawextinfo 4 " " " " "Elapsed $TIME s, still $TRIES_STILL to go..."

done

# *** Here ends program *** #
echo drawextinfo 2  "$0 is finished."
