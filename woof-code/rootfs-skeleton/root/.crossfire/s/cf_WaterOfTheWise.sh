#!/bin/bash

export PATH=/bin:/usr/bin

# *** PARAMETERS *** #

TMOUT=1    # read -t timeout

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

# Log file path in /tmp
MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err

# *** Here begins program *** #
echo drawextinfo 2 "$0 is started.."
echo draw 2 "PID is $$ - parentPID is $PPID"

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

test -f "${MY_SELF%/*}"/cf_functions.sh && . "${MY_SELF%/*}"/cf_functions.sh




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

# *** instead echo issue all the time make it a function


rm -f "$REPLY_LOG" # empty old log file
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"

_check_if_on_cauldron

_check_space_to_move

# *** Readying rod of word of recall - just in case *** #

echo drawextinfo 4  "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
issue 1 1 apply rod of word of recall
fi

echo drawextinfo 7 "Done."



# *** Getting Player's Speed *** #
_get_player_speed


# *** Check if cauldron is empty *** #
_check_if_cauldron_empty

sleep ${SLEEP}s

issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRF
issue 1 1 $DIRF

sleep ${SLEEP}s


echo drawextinfo 4 "OK... Might the Might be with You!"

success=0
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
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo
#echo unwatch drawextinfo
sleep ${SLEEP}s

issue 1 1 $DIRB
issue 1 1 $DIRB

issue 1 1 $DIRF
issue 1 1 $DIRF

sleep ${SLEEP}s

#echo watch drawextinfo
echo watch drawinfo

issue 1 1 use_skill alchemy

OLD_REPLY="";
REPLY="";
NOTHING=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
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
SLAG=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1 || :
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

#echo unwatch drawextinfo
echo unwatch drawinfo

sleep ${SLEEP}s

issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRB
issue 1 1 $DIRB

sleep ${SLEEP}s

if test "$NOTHING" = 0; then
 if test "$SLAG" = 0; then
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
 success=$((success+1))
 else
 issue 0 1 drop slag
 #issue 0 1 drop slags"
 fi
fi

sleep ${DELAY_DRAWINFO}s

issue 1 1 $DIRF
issue 1 1 $DIRF
issue 1 1 $DIRF
issue 1 1 $DIRF


sleep ${SLEEP}s
sleep ${DELAY_DRAWINFO}s

echo request items on

UNDER_ME='';
UNDER_ME_LIST='';

while :; do
read -t 2 UNDER_ME
echo "$UNDER_ME" >>"$ON_LOG"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
test "$UNDER_ME" || break
unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo drawextinfo 3 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo drawextinfo 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_STILL to go..."

done

# *** Here ends program *** #
echo drawextinfo 2  "$0 is finished."
