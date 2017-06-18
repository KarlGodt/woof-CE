#!/bin/ash

# *** diff marker 1
# ***
# ***

# Now count the whole script time
TIMEA=`/bin/date +%s`

# *** VARIABLES *** #
DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

SLEEP=3.0           # sleep seconds after codeblocks
DELAY_DRAWINFO=6.0  # sleep seconds to sync msgs from script with msgs from server

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup and drop the result(s) to not
# increase carried weight and to prevent similar named ingredient
# being dropped into cauldron another time.
# This version does not adjust player speed after several weight losses.

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;   # direction forward
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
northwest) DIRF=southeast;;
northeast) DIRF=southwest;;
southwest) DIRF=northeast;;
southeast) DIRF=northwest;;
esac

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

_usage(){
echo draw 5 "Script to produce balm of first aid."
echo draw 7 "Syntax:"
echo draw 7 "$0 < NUMBER >"
echo draw 5 "Optional NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Balm of First Aid ."
echo draw 4 "If no number given, loops as long"
echo draw 4 "as ingredients could be dropped."
        exit 0
}

_debug_two(){
[ "$DEBUG" ]       || return 3
[ "$DEBUG" -ge 2 ] || return 4
}

# *** Here begins program *** #
echo draw 2 "$0 is started.."


# *** PARAMETERS *** #

# *** Check for parameters *** #
echo drawnifo 5 "Checking the parameters ($*)..."

until [ "$#" = 0 ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"|*usage) _usage;;
[0-9]*)
PARAM_1test="${PARAM_1//[0-9]/}"
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

echo draw 7 "OK."


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


# *** EXIT FUNCTIONS *** #
f_exit(){
RV=${1:-0}
shift

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP:-1}s

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

local lPARAM="$*"
local lSKILL

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

 if test "$lPARAM"; then
  case $REPLY in *$lPARAM) return 0;; esac
 else # print skill
  lSKILL=`echo "$REPLY" | cut -f4- -d' '`
  echo draw 5 "'$lSKILL'"
 fi

done

test ! "$lPARAM" # returns 0 if called without parameter, else 1
}


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


_check_if_on_cauldron(){
# *** Check if standing on a cauldron *** #
echo draw 5 "Checking if on a cauldron..."

UNDER_ME='';
echo request items on

while [ 1 ]; do
read -t 1 UNDER_ME
[ "$LOGGING" ] && echo "_check_if_on_cauldron:$UNDER_ME" >>/tmp/cf_script.ion
[ "$DEBUG" ] && echo draw 6 "$UNDER_ME"
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

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "_check_free_move:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done


PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`
[ "$DEBUG" ] && echo draw 3 "PL_POS_X='$PL_POS_X' PL_POS_Y='$PL_POS_Y'"

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

[ "$DEBUG" ] && echo draw 3 "R_X='$R_X' R_Y='$R_Y'"
echo request map $R_X $R_Y

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "request map $R_X $R_Y:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
IS_WALL=`echo "$REPLY" | awk '{print $16}'`
[ "$LOGGING" ] && echo "IS_WALL='$IS_WALL'" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "IS_WALL='$IS_WALL'"
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
# *** diff marker 6
# *** diff marker 7
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
[ "$DEBUG" ] && echo draw 6 "$REPLY"
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

echo watch $DRAW_INFO

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "_check_empty_cauldron:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
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


# ***
# ***
# *** diff marker 8
# *** diff marker 9
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
[ "$DEBUG" ] && echo draw 6 "$ANSWER"
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
 echo draw 3 "Unable to receive player speed. Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
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

_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
_check_if_on_cauldron
_check_free_move
_check_empty_cauldron
_get_player_speed
_prepare_recall


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
# *** to walk on DIRB of the cauldron.                              *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***


# *** Now LOOPING *** #

FAIL=0
TIMEB=`/bin/date +%s`
echo draw 4 "OK... Might the Might be with You!"
_debug_two && echo monitor; #DEBUG

while :;
do

TIMEC=`/bin/date +%s`

echo draw 2 "Opening cauldron ..."
echo "issue 1 1 apply"
sleep ${SLEEP:-1}s

#_debug_two || echo watch $DRAW_INFO
echo draw 4 "Dropping water of the wise ..."
echo "issue 1 1 drop 1 water of the wise"

_debug_two || echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";
DW=0
while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1 "Nothing to drop"
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1 "Not enough water of the wise"
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1 "Not enough water of the wise"
test "`echo "$REPLY" | grep '.*You put the water.*'`" && { DW=$((DW+1)); unset REPLY; } #s in cauldron (open) (active).
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing water in inventory."
sleep ${SLEEP:-1}s

echo draw 4 "Dropping mandrake root ..."
echo "issue 1 1 drop 1 mandrake root"

OLD_REPLY="";
REPLY="";
DW=0
while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1 "Nothing to drop"
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1 "Not enough mandrake root"
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1 "Not enough mandrake root"
test "`echo "$REPLY" | grep '.*You put the mandrake.*'`" && { DW=$((DW+1)); unset REPLY; } #s in cauldron (open) (active).
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing mandrake root in inventory."

_debug_two || echo unwatch $DRAW_INFO
sleep ${SLEEP:-1}s

echo draw 2 "Closing cauldron .."
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP:-1}s
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP:-1}s

_check_if_on_cauldron

#_debug_two || echo watch $DRAW_INFO

echo "issue 1 1 use_skill alchemy"

_debug_two || echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "use_skill alchemy:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"
test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && f_exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

_debug_two || echo unwatch $DRAW_INFO

sleep ${SLEEP:-1}s
echo draw 2 "Opening cauldron .."
echo "issue 1 1 apply"
sleep ${SLEEP:-1}s


# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***


#_debug_two || echo watch $DRAW_INFO

echo draw 5 "Getting content .."
#echo "issue 1 1 get"
echo issue 0 0 "get all"

_debug_two || echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "get:$REPLY" >>"$LOG_REPLY_FILE"
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

_debug_two || echo unwatch $DRAW_INFO

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

sleep ${SLEEP:-1}s

echo draw 2 "Dropping balm ...."
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP:-1}s

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
        echo draw ${g_edit_nulldigit_COLOURED:-5} "Identifying .."
        echo "issue 1 1 use_skill sense curse"
        echo "issue 1 1 use_skill sense magic"
        echo "issue 1 1 use_skill alchemy"
        sleep ${SLEEP:-1}s

        echo "issue 0 1 drop balm"
        else
        echo "issue 0 1 drop slag"
        fi
sleep ${SLEEP:-1}s
fi

sleep ${DELAY_DRAWINFO:-1}s


echo draw 2 "Returning to cauldron ...."
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP:-1}s

_check_if_on_cauldron

__check_if_on_cauldron__(){
echo request items on

UNDER_ME='';
UNDER_ME_LIST='';

while [ 1 ]; do
read -t 1 UNDER_ME
[ "$LOGGING" ] && echo "request items on:$UNDER_ME" >>/tmp/cf_script.ion
[ "$DEBUG" ] && echo draw 6 "$UNDER_ME"
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

}


# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***


TIMEE=`/bin/date +%s`
TIME=$((TIMEE-TIMEC))

one=$((one+1))
TRIES_STILL=$((NUMBER-one))
case $TRIES_STILL in -*) # negative
TRIES_STILL=${TRIES_STILL#*-}
echo draw 4 "Time $TIME sec., completed ${TRIES_STILL:-$NUMBER} laps.";;
*)
echo draw 4 "Time $TIME sec., still ${TRIES_STILL:-$NUMBER} laps to go...";;
esac


 _debug_two && {
 # log monitor msgs
  while [ 2 ]
  do
  unset REPLY
  read -t 1
  echo "$REPLY" >>"$LOG_REPLY_FILE"
  test "$REPLY" || break
  done

 echo unwatch $DRAW_INFO
 sleep 1
 }

test "$one" = "$NUMBER" && break
done  # *** MAINLOOP *** #

# Now count the whole loop time
TIMELE=`/bin/date +%s`
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
TIMEZ=`/bin/date +%s`
TIMEY=$((TIMEZ-TIMEA))
TIMEAM=$((TIMEY/60))
TIMEAS=$(( TIMEY - (TIMEAM*60) ))
case $TIMEAS in [0-9]) TIMEAS="0$TIMEAS";; esac
echo draw 6 "Whole script time : $TIMEAM:$TIMEAS minutes." # dark orange


# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700


# ***
# ***
# *** diff marker 16
