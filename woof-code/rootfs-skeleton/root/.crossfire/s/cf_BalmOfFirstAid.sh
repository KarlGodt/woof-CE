#!/bin/ash

# Now count the whole script time
TIMEA=`date +%s`

# *** VARIABLES *** #
DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

SLEEP=3.0           # sleep seconds after codeblocks
DELAY_DRAWINFO=6.0  # sleep seconds to sync msgs from script with msgs from server

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup and drop the result(s) to not
# increase carried weight. This version does not adjust player speed after
# several weight losses.

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;   # direction forward
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

_usage(){
echo draw 5 "Script to produce balm of first aid."
echo draw 7 "Syntax:"
echo draw 7 "$0 <NUMBER>"
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Balm of First Aid ."
echo draw 4 "If no number given, loops as long"
echo draw 4 "as ingredients could be dropped."
        exit 0
}

# *** Here begins program *** #
echo draw 2 "$0 is started.."


# *** PARAMETERS *** #

# *** Check for parameters *** #
echo drawnifo 5 "Checking the parameters ($*)..."

#[ "$*" ] && {
until [ "$#" = 0 ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help") _usage;;
[0-9]*)
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1
;;
*) echo draw 3 "Ignoring unhandled option '$PARAM_1'";;
esac
sleep 0.1
shift
done


#} || {
#echo draw 3 "Script needs number of alchemy attempts as argument."
#        exit 1
#}

#test "$1" || {
#echo draw 3 "Need <number> ie: script $0 4 ."
#        exit 1
#}

echo draw 7 "OK."


# *** EXIT FUNCTIONS *** #
f_exit(){
RV=${1:-0}
shift

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s

test "$*" && echo draw 5 "$*"
echo draw 3 "Exiting $0."

echo unwatch
echo unwatch $DRAW_INFO
beep
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

test "$*" && echo draw 5 "$*"
beep
exit $RV
}

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

# *** Monitoring function *** #
# *** Todo ...            *** #
f_monitor_malfunction(){

while [ 1 ]; do
read -t 1 ERRORMSGS

sleep 0.1s
done
}

# *** PREREQUISITES *** #
# 1.) _check_skill
# 2.) _check_if_on_cauldron
# 3.) _check_free_move
# 4.) _prepare_recall
# 5.) _check_empty_cauldron
# 6.) _get_player_speed

# *** Does our player possess the skill alchemy ? *** #
_check_skill(){

local PARAM="$*"

echo request skills

while :;
do
 unset REPLY
 sleep 0.1
 read -t 1
  [ "$LOGGING" ] && echo "_check_skill:$REPLY" >>"$LOG_REPLY_FILE"
  [ "$DEBUG" ] && echo draw 6 "$REPLY"

 case $REPLY in    '') break;;
 'request skills end') break;;
 esac

 if test "$PARAM"; then
  case $REPLY in *$PARAM) return 0;; esac
 else # print skill
  SKILL=`echo "$REPLY" | cut -f4- -d' '`
  echo draw 5 "'$SKILL'"
 fi

done

test ! "$PARAM" # returns 0 if called without parameter, else 1
}

_check_if_on_cauldron(){
# *** Check if standing on a cauldron *** #
echo draw 5 "Checking if on a cauldron..."

UNDER_ME='';
echo request items on

while [ 1 ]; do
read -t 1 UNDER_ME
#echo "request items on:$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
beep
exit 1
}

echo draw 7 "OK."
}

_check_free_move(){
# *** Check for 4 empty space to DIRB *** #
echo draw 5 "Checking for space to move..."

echo request map pos

#echo watch request

while [ 1 ]; do
read -t 1 REPLY
echo "request map pos:$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

#echo unwatch request


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

#echo watch request

while [ 1 ]; do
read -t 1 REPLY
echo "request map $R_X $R_Y:$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
IS_WALL=`echo "$REPLY" | awk '{print $16}'`
echo "$IS_WALL" >>"$LOG_REPLY_FILE"
test "$IS_WALL" = 0 || f_exit_no_space 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

#echo unwatch request

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

_prepare_recall(){
# *** Readying rod of word of recall - just in case *** #
echo draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

#echo watch request

while [ 1 ]; do
read -t 1 REPLY
echo "request items actv:$REPLY" >>"$LOG_REPLY_FILE"
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

#echo unwatch request

echo draw 6 "Done."
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #
echo "issue 0 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s

echo draw 5 "Checking for empty cauldron..."

echo "issue 1 1 apply"
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo "issue 1 1 get"

echo watch $DRAW_INFO

while [ 1 ]; do
read -t 1 REPLY
echo "get:$REPLY" >>"$LOG_REPLY_FILE"
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

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
}

_get_player_speed(){
# *** Getting Player's Speed *** #

echo draw 5 "Processing Player's speed..."

ANSWER=
OLD_ANSWER=

echo request stat cmbt

#echo watch request

while [ 1 ]; do
read -t 1 ANSWER
echo "request stat cmbt:$ANSWER" >>/tmp/cf_request.log
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#echo unwatch request

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
echo draw 7 "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
echo draw 7 "Player speed st to $PL_SPEED"

if test $PL_SPEED -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test $PL_SPEED -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
fi

echo draw 6 "Done."
}

_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
_check_if_on_cauldron
_check_free_move
_prepare_recall
_check_empty_cauldron
_get_player_speed

# *** Actual script to alch the desired balm of first aid *** #
#test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution
test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

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
# *** west of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


# *** Now LOOPING *** #

FAIL=0
TIMEB=`date +%s`
echo draw 4 "OK... Might the Might be with You!"

#for one in `seq 1 1 $NUMBER`
while :;
do

TIMEC=`date +%s`

echo "issue 1 1 apply"
sleep ${SLEEP}s

#echo watch $DRAW_INFO

echo "issue 1 1 drop 1 water of the wise"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
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

sleep ${SLEEP}s

echo "issue 1 1 drop 1 mandrake root"

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
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
echo "alchemy:$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && f_exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
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
echo "get:$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to take\!'`"      && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

sleep ${SLEEP}s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP}s

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
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


##echo watch request

echo request items on

#echo watch request

UNDER_ME='';
UNDER_ME_LIST='';

while [ 1 ]; do
read -t 1 UNDER_ME
echo "request items on:$UNDER_ME" >>/tmp/cf_script.ion
test "$UNDER_ME" || break
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
#test "$UNDER_ME" || break

sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "LOOP BOTTOM: NOT ON CAULDRON!"
f_exit 1
}

#echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEC))

one=$((one+1))
TRIES_STILL=$((NUMBER-one))
case $TRIES_STILL in -*) # negative
TRIES_STILL=${TRIES_STILL#*-}
echo draw 4 "Time $TIME sec., completed ${TRIES_STILL:-$NUMBER} laps.";;
*)
echo draw 4 "Time $TIME sec., still ${TRIES_STILL:-$NUMBER} laps to go...";;
esac

test "$one" = "$NUMBER" && break
done  # *** MAINLOOP *** #

# Now count the whole loop time
TIMELE=`date +%s`
TIMEL=$((TIMELE-TIMEB))
TIMELM=$((TIMEL/60))
TIMELS=$(( TIMEL - (TIMELM*60) ))
case $TIMELS in [0-9]) TIMELS="0$TIMELS";; esac
echo draw 5 "Whole  loop  time : $TIMELM:$TIMELS minutes." # light blue

if test "$FAIL" = 0; then
 echo draw 7 "You succeeded $one times of $NUMBER ." # green
else
if test "$((NUMBER/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $NUMBER ."    # light green
 echo draw 7 "You should increase your Int stat."
else
 SUCC=$((NUMBER-FAIL))
 echo draw 7 "You succeeded $SUCC times of $NUMBER ." # green
fi
fi

# Now count the whole script time
TIMEZ=`date +%s`
TIMEY=$((TIMEZ-TIMEA))
TIMEAM=$((TIMEY/60))
TIMEAS=$(( TIMEY - (TIMEAM*60) ))
case $TIMEAS in [0-9]) TIMEAS="0$TIMEAS";; esac
echo draw 6 "Whole script time : $TIMEAM:$TIMEAS minutes." # dark orange


# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700
