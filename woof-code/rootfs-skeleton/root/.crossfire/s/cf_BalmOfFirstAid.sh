#!/bin/ash

TIMEA=`/bin/date +%s`

DRAW=drawinfo      # draw
DRAW_INFO=drawinfo # drawinfo OR drawextinfo


DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"   # empty old log file

# *** Here begins program *** #
echo draw 2 "$0 is started with pid $$ ppid $PPID"

# *** PARAMETERS *** #

# *** Check for parameters *** #
echo drawnifo 5 "Checking the parameters ($*)..."

[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help|*usage)

echo draw 5 "Script to produce water of the wise."
echo draw 7 "Syntax:"
echo draw 7 "$0 NUMBER"
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Balm of First Aid ."

        exit 0
;;

esac

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
echo draw 3 "Need <number> ie: script $0 4 ."
        exit 1
}

echo $DRAW 7 "OK."

# *** EXIT FUNCTIONS *** #
f_exit(){
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch $DRAW_INFO
exit $1
}

f_emergency_exit(){
echo "issue 1 1 apply -u rod of word of recall"
echo "issue 1 1 apply -a rod of word of recall"
echo "issue 1 1 fire center"
echo draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
echo "issue 1 1 fire_stop"
exit $1
}

f_exit_no_space(){
echo draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
echo draw 3 "Remove that Item and try again."
echo draw 3 "If this is a Wall, try another place."
exit $1
}

_get_player_speed(){
# *** Getting Player's Speed *** #

echo $DRAW 5 "Processing Player's speed..."

SLEEP=3           # setting defaults
DELAY_DRAWINFO=6

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

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED="0.${PL_SPEED:0:2}"

echo $DRAW 7 "Player speed is $PL_SPEED"

PL_SPEED="${PL_SPEED:2:2}"
echo $DRAW 7 "Player speed is $PL_SPEED"

if test $PL_SPEED -gt 35; then
SPEED=1; DELAY_DRAWINFO=2
elif test $PL_SPEED -gt 25; then
SPEED=2; DELAY_DRAWINFO=4
fi

echo $DRAW 6 "Done."
}

_probe_if_on_cauldron(){
# *** Check if standing on a cauldron *** #

echo $DRAW 5 "Checking if on a cauldron..."

UNDER_ME='';
echo request items on

while [ 1 ]; do
read -t 1 UNDER_ME
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
exit 1
}

echo $DRAW 7 "OK."
}

_probe_free_move(){
# *** Check for 4 empty space to DIRB ***#

echo $DRAW 5 "Checking for space to move..."

echo request map pos

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 4`; do

case $DIRB in
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

echo request map $R_X $R_Y

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
echo "$IS_WALL" >>"$LOG_REPLY_FILE"
test "$IS_WALL" = 0 || f_exit_no_space 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

done

else

echo $DRAW 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

echo $DRAW 3 "Could not get X and Y position of player."
exit 1

fi

echo $DRAW 7 "OK."
}

_probe_empty_cauldron(){
# *** Check if cauldron is empty *** #

echo "issue 0 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s


echo $DRAW 5 "Checking for empty cauldron..."

echo "issue 1 1 apply"
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

echo watch $DRAW_INFO

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
REPLY_ALL="$REPLY
$REPLY_ALL"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
echo $DRAW 3 "Cauldron NOT empty !!"
echo $DRAW 3 "Please empty the cauldron and try again."
f_exit 1
}

echo unwatch $DRAW_INFO

echo $DRAW 7 "OK ! Cauldron IS empty."

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
}

_prepare_recall(){
# *** Readying rod of word of recall - just in case *** #

echo $DRAW 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply rod of word of recall"
fi

echo $DRAW 6 "Done."
}

_get_player_speed
_probe_if_on_cauldron
_probe_free_move
_probe_empty_cauldron
_prepare_recall

# *** Actual script to alch the desired balm of first aid           *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' and                                      *** #
# *** drop mandrake root   before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water and mandrake root --      *** #
# *** only one inventory line with water(s) and                     *** #
# *** mandrake root are allowed !!                                  *** #

# *** Now get the number of desired water of the wise and           *** #
# *** same times the number of mandrake root .                      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** DIRB of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

echo "issue 1 1 pickup 0"  # precaution

# *** Now LOOPING *** #
TIMEB=`date +%s`
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

for one in `seq 1 1 $NUMBER`
do

TIMEC=${TIMEE:-$TIMEB}

echo "issue 1 1 apply"
sleep ${SLEEP}s

#echo watch $DRAW_INFO

echo "issue 1 1 drop 1 water of the wise"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

sleep ${SLEEP}s

echo "issue 1 1 drop 1 mandrake root"

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
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

#echo watch $DRAW_INFO

echo "issue 1 1 use_skill alchemy"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

echo "issue 1 1 apply"
sleep ${SLEEP}s

#echo watch $DRAW_INFO

echo "issue 1 1 get"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>"$LOG_REPLY_FILE"
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
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
        if test $SLAG = 0; then
        echo "issue 1 1 use_skill sense curse"
        echo "issue 1 1 use_skill sense magic"
        echo "issue 1 1 use_skill alchemy"
        sleep ${SLEEP}s

        echo "issue 0 1 drop balm"
       else
       echo "issue 0 1 drop slag"
      fi
fi

sleep ${DELAY_DRAWINFO}s

echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s


#echo watch request

echo request items on

#echo watch request

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
echo $DRAW 3 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}

#echo unwatch request


TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEC))
echo draw 5 "Elapsed $TIME s, still $TRIES_STILL to go..."

done  # *** MAINLOOP *** #


# *** Here ends program *** #
_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}

_count_time(){

test "$*" || return 3
_test_integer "$*" || return 4

TIMEE=`/bin/date +%s` || return 5

TIMEX=$((TIMEE - $*)) || return 6
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

_count_time $TIMEB && echo draw 7 "Looped for $TIMEM:$TIMES minutes"
_count_time $TIMEA && echo draw 7 "Script ran $TIMEM:$TIMES minutes"

echo draw 2 "$0 is finished."
beep -f 700 -l 1000
