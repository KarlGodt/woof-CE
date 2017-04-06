#!/bin/ash

# Now count the whole script time
TIMEA=`date +%s`

# *** VARIABLES *** #

DEBUG=  # set to anything to enable

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

SLEEP=4           # sleep seconds after codeblocks
DELAY_DRAWINFO=8  # sleep seconds to sync msgs from script with msgs from server

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
esac

#logging
LOGGING=1
TMP_DIR=/tmp/crossfire_client
LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
LOG_REQUEST_FILE="$TMP_DIR"/cf_request.$$.log
mkdir -p "$TMP_DIR"

# beeping
BEEP_DO=1
BEEP_LENGTH=500
BEEP_FREQ=700

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}

# ping if connection is dropping once a while
PING_DO=
URL=crossfire.metalforge.net
_ping(){
test "$PING_DO" || return 0
while :; do
ping -c1 -w10 -W10 "$URL" && break
sleep 1
done >/dev/null
}


# times
_say_minutes_seconds(){
#_say_minutes_seconds "500" "600" "Loop run:"
test "$1" -a "$2" || return 1

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
_say_minutes_seconds "$TIMELB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"
}


# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to produce water of the wise."
echo draw 7 "Syntax:"
echo draw 7 "$0 NUMBER"
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of the Wise ."

        exit 0
        }

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

echo draw 4 "Checking if on cauldron..."

f_check_on_cauldron(){
UNDER_ME='';
echo request items on

while :; do
read UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>"$LOG_ISON_FILE"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in "request items on end") break;;
"scripttell break") break;;
"scripttell exit") exit 1;;
esac
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
exit 1
        }

}
f_check_on_cauldron

echo draw 7 "Done."

# *** Actual script to alch the desired water of the wise *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

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

rm -f "$LOG_REPLY_FILE" # empty old log file


# *** Getting Player's Speed *** #

echo draw 4 "Processing Player's Speed..."


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
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
echo draw 7 "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
echo draw 7 "Player speed is $PL_SPEED"

  if test $PL_SPEED -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test $PL_SPEED -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test $PL_SPEED -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
fi

echo draw 7 "Done."


# *** Readying rod of word of recall - just in case *** #

echo draw 4 "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
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

sleep ${SLEEP}s
echo draw 7 "Done."


# *** EXIT FUNCTIONS *** #
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

NUMBER=$((one-1))
_say_statistics_end
_beep
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

NUMBER=$((one-1))
_say_statistics_end
test "$*" && echo draw 5 "$*"
_beep
_beep
exit $RV
}


# *** Check if cauldron is empty *** #

echo draw 4 "Checking if cauldron is empty..."

echo "issue 1 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s

echo "issue 1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
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

echo unwatch $DRAW_INFO

echo draw 7 "OK ! Cauldron SEEMS empty."

sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s


# *** Now LOOPING *** #

echo draw 4 "OK... Might the Might be with You!"
TIMELB=`date +%s`

FAIL=0

for one in `seq 1 1 $NUMBER`
do

TIMEB=${TIMEE:-`date +%s`}


OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

echo "issue 1 1 drop 7 water"

while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.") f_exit 1;;
 *"There are only"*)  f_exit 1;;
 *"There is only"*)   f_exit 1;;
 '') break;;
 esac
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

__old_loop(){
while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done
}

echo unwatch $DRAW_INFO
sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s

f_check_on_cauldron

sleep 1
#echo "issue 1 1 use_skill alchemy"
echo "issue 0 0 use_skill alchemy"

# TOTO monsters
echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
# (level < 100) {                /* WHAMMY the CAULDRON */
#        if (!QUERY_FLAG(cauldron, FLAG_CURSED)) {
test "`echo "$REPLY" | grep 'Your cauldron .* darker'`" && exit 1
# (level < 110) {                /* SUMMON EVIL MONSTERS */
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
# /* MANA STORM - watch out!! */
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

sleep 0.5s
echo "issue 1 1 apply"
sleep 0.5s


echo watch $DRAW_INFO

echo "issue 7 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
# else if (level < 60) {                 /* CREATE MONSTER */
#        draw_ext_info_format(NDI_UNIQUE, 0, op, MSG_TYPE_SKILL, MSG_TYPE_SKILL_FAILURE,
#                             "The %s %s.", cauldron->name, cauldron_sound());
#        remove_contents(cauldron->inv, NULL);
#        return;
test "`echo "$REPLY" | grep '.*Nothing to take\!'`"   && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO
sleep ${SLEEP}s

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP}s


if test "$NOTHING" = 0; then

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep ${SLEEP}s

#if test $NOTHING = 0; then
#for drop in `seq 1 1 7`; do  # unfortunately does not work without this nasty loop
echo "issue 0 1 drop water of the wise"    # issue 1 1 drop drops only one water
echo "issue 0 1 drop waters of the wise"
# else if (level < 40) {                 /* MAKE TAINTED ITEM */
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
# if (level < 25) {         /* INGREDIENTS USED/SLAGGED */
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


f_check_on_cauldron


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo draw 4 "Time $TIME sec., still $TRIES_STILL laps to go..."


done

_say_statistics_end

# *** Here ends program *** #
echo draw 2 "$0 is finished."
_beep
