#!/bin/ash

exec 2>/tmp/cf_script.err

# Now count the whole script time
TIMEA=`date +%s`

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


SLEEP=4.0          # sleep seconds after codeblocks
DELAY_DRAWINFO=8.0 # sleep seconds to sync msgs from script with msgs from server

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

ITEM_RECALL='rod of word of recall' # scroll, staff, rod

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

_usage(){
echo draw 5 "Script to produce water of the wise."
echo draw 7 "Syntax:"
echo draw 7 "$0 < NUMBER >"
echo draw 5 "Optional NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of the Wise ."
echo draw 4 "If no number given, loops as long"
echo draw 4 "as ingredient could be dropped."
echo draw 2 "Options:"
echo draw 4 "-d  to turn on debugging."
echo draw 4 "-L  to log to $LOG_REPLY_FILE ."
echo draw 4 "-v  to be more talkaktive."
echo draw 7 "-F each --fast sleeps 0.2 s less"
echo draw 8 "-S each --slow sleeps 0.2 s more"
echo draw 3 "-X --nocheck do not check cauldron (faster)"
        exit 0
}

_ping(){
test "$PING_DO" || return 0

local lFOREVER=''
local lPRV

case $1 in
-I|--infinite) lFOREVER=$((lFOREVER+1));;
esac

while :; do
ping -c 1 -w10 -W10 "$URL" >/dev/null 2>&1
lPRV=$?
 if test "$lFOREVER"; then
  case $lPRV in 0) :;;
  *) echo draw 3 "WARNING: Client seems disconnected.." >&1;;
  esac
  sleep 2
 else
  case $lPRV in 0) return 0;;
  *) :;;
  esac
 fi

 sleep 1
done
}

CHECK_DO=1
# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
until [ "$#" = 0 ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*help|*usage) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
-F|*fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
-S|*slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
-X|*nocheck) unset CHECK_DO;;

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


# *** Common functions *** #

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

echo unwatch
echo unwatch $DRAW_INFO

beep
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

echo "issue 1 1 apply -u $ITEM_RECALL"
echo "issue 1 1 apply -a $ITEM_RECALL"
echo "issue 1 1 fire center"
echo draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
echo "issue 1 1 fire_stop"

test "$*" && echo draw 5 "$*"
beep
exit $RV
}


# *** PREREQUISITES *** #
# 1.) _check_skill
# 2.) f_check_on_cauldron
# 3.) _get_player_speed
# 4.) _ready_rod_of_recall
# 5.) _check_empty_cauldron

_check_skill(){
# *** Does our player possess the skill alchemy ? *** #
[ "$CHECK_DO" ] || return 0

local lPARAM="$*"
local lSKILL

echo request skills

while :;
do
 unset REPLY
 sleep 0.1
 read -t 2
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

f_check_on_cauldron(){
# *** Check if standing on a cauldron *** #
[ "$CHECK_DO" ] || return 0

echo draw 4 "Checking if on cauldron..."

local UNDER_ME='';
local UNDER_ME_LIST='';
echo request items on

while [ 1 ]; do
read -t 2 UNDER_ME
sleep 0.1s
[ "$LOGGING" ] && echo "f_check_on_cauldron:$UNDER_ME" >>/tmp/cf_script.ion
[ "$DEBUG" ] && echo draw 3 "'$UNDER_ME'"

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
beep
exit 1
        }
echo draw 7 "Done."

}

_get_player_speed(){
# *** Getting Player's Speed *** #

echo draw 4 "Processing Player's Speed..."

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while [ 1 ]; do
read -t 2 ANSWER
[ "$LOGGING" ] && echo "request stat cmbt:$ANSWER" >>/tmp/cf_request.log
[ "$DEBUG" ] && echo draw 3 "'$ANSWER'"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2;${PL_SPEED:-40000} / 100000" | bc -l`  #prints .99 if below 1

[ "$DEBUG" ] && echo draw 7 "Player speed is '$PL_SPEED'"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
[ "$DEBUG" ] && echo draw 7 "Player speed set to '$PL_SPEED'"

  if test $PL_SPEED -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=3.0
elif test $PL_SPEED -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test $PL_SPEED -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
fi

[ "$DEBUG" ] && echo draw 3 "SLEEP='$SLEEP'"
SLEEP=`dc ${SLEEP:-1} ${SLEEP_ADJ:-0} \+ p` || SLEEP=1
 case $SLEEP in -[0-9]*) SLEEP=0.1;; esac
[ "$DEBUG" ] && echo draw 3 "SLEEP now set to '$SLEEP'"

echo draw 7 "Done."
}

_ready_rod_of_recall(){
# *** Readying $ITEM_RECALL - just in case *** #
[ "$CHECK_DO" ]    || return 0
[ "$ITEM_RECALL" ] || return 3

echo draw 4 "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 2 REPLY
[ "$LOGGING" ] && echo "request items actv:$REPLY" >>/tmp/cf_request.log
[ "$DEBUG" ] && echo draw 3 "'$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.* $ITEM_RECALL'`" && RECALL=1

OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply $ITEM_RECALL"
fi

sleep ${SLEEP}s
echo draw 7 "Done."
}

_check_free_move(){
# *** Check for 4 empty space to DIRB *** #
[ "$CHECK_DO" ] || return 0

echo draw 5 "Checking for space to move..."

echo request map pos

while [ 1 ]; do
read -t 2 REPLY
[ "$LOGGING" ] && echo "request map pos:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "REPLY='$REPLY'"
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
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
southwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y+nr))
;;
southeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y+nr))
;;
esac

[ "$DEBUG" ] && echo draw 3 "R_X='$R_X' R_Y='$R_Y'"
echo request map $R_X $R_Y

while [ 2 ]; do
read -t 2 REPLY
[ "$LOGGING" ] && echo "request map $R_X $R_Y:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "'$REPLY'"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
[ "$LOGGING" ] && echo "$IS_WALL" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "IS_WALL='$IS_WALL'"
test "$IS_WALL" = 0 || f_exit_no_space 1

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

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #
[ "$CHECK_DO" ] || return 0
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

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "get:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

REPLY_ALL="$REPLY
$REPLY_ALL"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
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
}

_get_player_speed
_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
f_check_on_cauldron
#_get_player_speed
#_ready_rod_of_recall
_check_free_move
_check_empty_cauldron
_ready_rod_of_recall


# *** Actual script to alch the desired water of the wise           *** #

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
# *** DIRB of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

FAIL=0; one=0
TIMEB=`date +%s`
echo draw 4 "OK... Might the Might be with You!"

# *** Now LOOPING *** #

while :;
do

TIMEC=`date +%s`


OLD_REPLY="";
REPLY="";

echo "issue 1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

echo "issue 1 1 drop 7 water"

while [ 2 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "'$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && break 2 #f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && break 2 #f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && break 2 #f_exit 1

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


f_check_on_cauldron

sleep 1
#echo "issue 1 1 use_skill alchemy"
echo "issue 0 0 use_skill alchemy"
one=$((one+1))

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
[ "$LOGGING" ] && echo "alchemy:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "'$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && break 2 #exit 1
test "`echo "$REPLY" | grep '.*Your cauldron .* darker'`" && break 2
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
SLAG=0

while [ 2 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "get:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "'$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to take\!'`"   && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1

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

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep ${SLEEP}s

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


echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP}s


f_check_on_cauldron

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEC))

#one=$((one+1))
TRIES_STILL=$((NUMBER-one))

case $TRIES_STILL in -*) # negative
TRIES_STILL=${TRIES_STILL#*-}
echo draw 4 "Time $TIME sec., completed ${TRIES_STILL:-$NUMBER} laps.";;
*)
echo draw 4 "Time $TIME sec., still ${TRIES_STILL:-$NUMBER} laps to go...";; # light orange
esac

test "$one" = "$NUMBER" && break
done

# Now count the whole loop time
TIMELE=`date +%s`
TIMEL=$((TIMELE-TIMEB))
TIMELM=$((TIMEL/60))
TIMELS=$(( TIMEL - (TIMELM*60) ))
case $TIMELS in [0-9]) TIMELS="0$TIMELS";; esac
echo draw 5 "Whole  loop  time : $TIMELM:$TIMELS minutes." # light blue


if test "$FAIL" = 0; then
 echo draw 7 "You succeeded $one times of $one ." # green
else      # NUMBER/FAIL: division by 0 (error token is "L")
if test "$((one/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $one ."  # light green
 echo draw 7 "You should increase your Int stat."
else
 SUCC=$((one-FAIL))
 echo draw 7 "You succeeded $SUCC times of $one ." # green
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
echo draw 2 "$0 is finished." # blue
beep -l 500 -f 700
