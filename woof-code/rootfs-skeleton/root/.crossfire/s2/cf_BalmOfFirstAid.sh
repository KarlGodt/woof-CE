#!/bin/ash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

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
# increase carried weight and to prevent similar named ingredient being dropped
# into cauldron another time.
# This version does not adjust player speed after several weight losses.

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

ITEM_RECALL='rod of word of recall' # f_emergency_exit uses this ( staff, scroll, rod of word of recall )

#logging
LOGGING=1
TMP_DIR=/tmp/crossfire_client
  LOG_REPLY_FILE="$TMP_DIR"/cf_bofa.$$.rpl
   LOG_ISON_FILE="$TMP_DIR"/cf_bofa.$$.ion
LOG_REQUEST_FILE="$TMP_DIR"/cf_bofa.$$.req
mkdir -p "$TMP_DIR"
rm -f "$LOG_REPLY_FILE"   # empty old log file

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
done >/dev/null 2>&1
}

_sleepSLEEP(){
[ "$FAST" ] && return 0
sleep ${SLEEP:-1}s
}

_draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local lMSG="$*"
    echo draw $lCOLOUR "$lMSG"
}

__draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local lMSG="$*"
while read -r line
do
   _draw $lCOLOUR "$line"
    done <<EoI
`echo "$lMSG"`
EoI
}

# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***

# ***
_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"$lFILE"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_debug(){
test "$DEBUG" || return 0
_draw ${COL_DEB:-3} "DEBUG:$*"
#__draw ${COL_DEB:-3} "DEBUG:$*"
}

__debug(){
test "$DEBUG" || return 0
#_draw ${COL_DEB:-3} "DEBUG:$*"
__draw ${COL_DEB:-3} "DEBUG:$*"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
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

_draw 5 "$* $TIMEm:$TIMEs minutes."
}

_say_success_fail(){
test "$one" -a "$FAIL" || return 3

if test "$FAIL" -le 0; then
 SUCC=$((one-FAIL))
 _draw 7 "You succeeded $SUCC times of $one ." # green
elif test "$((one/FAIL))" -lt 2;
then
 _draw 8 "You failed $FAIL times of $one ."    # light green
 _draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((one-FAIL))
 _draw 7 "You succeeded $SUCC times of $one ." # green
fi
}

_remove_err_log(){
local lFILE="$1"
lFILE=${lFILE:-/tmp/cf_script.err}

if  test -e "$lFILE"; then
 if test -s "$lFILE"; then
  _draw 3 "Content in '$lFILE'"
 else
  _draw 7 "No content in '$lFILE'"
  [ "$DEBUG" ] || rm -f "$lFILE"
 fi
else
 _draw 5 "Does not exist: '$lFILE'"
fi
}

_say_statistics_end(){
# Now count the whole loop time
TIMELE=`/bin/date +%s`
_say_minutes_seconds "$TIMEB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`/bin/date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"

_remove_err_log
}

# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***

_usage(){
# *** implementing 'help' option *** #
_draw 5 "Script to produce balm of first aid."
_draw 7 "Syntax:"
_draw 7 "$0 < NUMBER >"
_draw 5 "Optional NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Balm of First Aid ."
_draw 4 "If no number given, loops as long"
_draw 4 "as ingredients could be dropped."
_draw 2 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v  to be more talkaktive."
_draw 7 "-F each --fast sleeps 0.2 s less"
_draw 8 "-S each --slow sleeps 0.2 s more"
_draw 3 "-X --nocheck do not check cauldron (faster)"
        exit 0
}

CHECK_DO=1
# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** PARAMETERS *** #
# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."


until test "$#" = 0
do
PARAM_1="$1"

case "$PARAM_1" in
-h|*help|*usage) _usage;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
-F|*fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
-S|*slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
-X|*nocheck) unset CHECK_DO;;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)      DEBUG=$((DEBUG+1));;
      --log*)    LOGGING=$((LOGGING+1));;
      --verbose) VERBOSE=$((VERBOSE+1));;
      --fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
      --slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
      --nocheck) unset CHECK_DO;;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`echo "$PARAM_1" | sed -r 's/^-*//; s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      L) LOGGING=$((LOGGING+1));;
      v) VERBOSE=$((VERBOSE+1));;
      F) SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
      S) SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
      X) unset CHECK_DO;;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

'')
#_draw 3 "Script needs number of alchemy attempts as argument."
#_draw 3 "Need <number> ie: script $0 4 ."
# exit 1
:
;;

[0-9]*)
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1
;;
*) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
esac
shift
sleep 0.1
done


_draw 7 "OK."

# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***

# *** EXIT FUNCTIONS *** #
f_exit(){
RV=${1:-0}
shift

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP

test "$*" && _draw 5 "$*"
_draw 3 "Exiting $0."

echo unwatch
echo unwatch $DRAW_INFO
_beep
#NUMBER=$((one-1))
NUMBER=$one
_say_statistics_end
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

_is "1 1 apply -u $ITEM_RECALL"
_is "1 1 apply -a $ITEM_RECALL"
_is "1 1 fire center"

_draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
_is "1 1 fire_stop"

_beep
_beep
#NUMBER=$((one-1))
NUMBER=$one
_say_statistics_end
test "$*" && _draw 5 "$*"
exit $RV
}

f_exit_no_space(){
RV=${1:-0}
shift

#_say_statistics_end
_draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
_draw 3 "Remove that Item and try again."
_draw 3 "If this is a Wall, try another place."
_beep
test "$*" && _draw 5 "$*"
exit $RV
}


# *** PREREQUISITES *** #
# 1.) _get_player_speed : for the SLEEP value
# 2.) _check_skill : Do i have the skill ?
# 3.) f_check_on_cauldron : Is there a cauldron beneath my character
# 4.) f_check_free_space  : Can I move ?
# 5.) _check_empty_cauldron : Is the cauldron empty ?
# 6.) _prepare_recall : unready $ITEM_RECALL - done before I knew about the apply -u, apply -a options


# *** Does our player possess the skill alchemy ? *** #
_check_skill(){

[ "$CHECK_DO" ] || return 0

local lPARAM="$*"
local lSKILL

echo request skills

while :;
do
 unset REPLY
 sleep 0.1
 read -t 2
  _log "$LOG_REPLY_FILE" "_check_skill:$REPLY"
  _debug "$REPLY"

 case $REPLY in    '') break;;
 'request skills end') break;;
 esac

 if test "$lPARAM"; then
  case $REPLY in *$lPARAM) return 0;; esac
 else # print skill
  lSKILL=`echo "$REPLY" | cut -f4- -d' '`
  _draw 5 "'$lSKILL'"
 fi

done

test ! "$lPARAM" # returns 0 if called without parameter, else 1
}

# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***

f_check_on_cauldron(){
# *** Check if standing on a cauldron *** #

[ "$CHECK_DO" ] || return 0

_draw 5 "Checking if on a cauldron..."

local UNDER_ME='';
local UNDER_ME_LIST='';

echo request items on

while :; do
_ping
read -t 2 UNDER_ME
sleep 0.1s
_log "$LOG_ISON_FILE" "request items on:$UNDER_ME"
_debug "'$UNDER_ME'"
UNDER_ME_LIST="$UNDER_ME_LIST
$UNDER_ME"
case "$UNDER_ME" in "request items on end") break;;
scripttell*)
 case $UNDER_ME in
 *"break") break;;
 *"break "*) BREAKS=`echo "$UNDER_ME" | awk '{print $NF}'`
  test "${BREAKS//[0-9]/}" && BREAKS=2
  break $BREAKS;;
 *"exit"|*"quit"|*"off") exit 1;;
 esac
esac
done

__debug "$UNDER_ME_LIST"
 test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
  _draw 3 "Need to stand upon cauldron!"
  _beep
  exit 1
 }

_draw 7 "OK."
}

f_check_free_space(){
# *** Check for 4 empty space to DIRB *** #

[ "$CHECK_DO" ] || return 0

_draw 5 "Checking for space to move..."

echo request map pos

while :; do
_ping
read -t 2 REPLY
 _log "$LOG_REPLY_FILE" "request map pos:$REPLY"
 _debug "REPLY='$REPLY'"
 case $REPLY in
 '')               break;;
 $OLD_REPLY)       break;;
 esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`
_debug "PL_POS_X='$PL_POS_X' PL_POS_Y='$PL_POS_Y'"

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

_debug "R_X='$R_X' R_Y='$R_Y'"
echo request map $R_X $R_Y

while :; do
_ping
read -t 2 REPLY
_log "$LOG_REPLY_FILE" "request map '$R_X' '$R_Y':$REPLY"
_debug "REPLY='$REPLY'"

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
_log "$LOG_REPLY_FILE" "IS_WALL='$IS_WALL'"
_debug "IS_WALL='$IS_WALL'"
test "$IS_WALL" = 0 || f_exit_no_space 1

case $REPLY in
'')               break;;
$OLD_REPLY)       break;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

done

else

_draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

_draw 3 "Could not get X and Y position of player."
exit 1

fi

_draw 7 "OK."
}

# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***

_prepare_recall(){
# *** Readying $ITEM_RECALL - just in case *** #

[ "$CHECK_DO" ] || return 0

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
_ping
read -t 2 REPLY
_log "$LOG_REPLY_FILE" "request items actv:$REPLY"
_debug "REPLY='$REPLY'"

case $REPLY in
'')                 break;;
$OLD_REPLY)         break;;
*${ITEM_RECALL}*) RECALL=1;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
_is "1 1 apply $ITEM_RECALL"
fi

_draw 6 "Done."
}

# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

[ "$CHECK_DO" ] || return 0

_is "0 1 pickup 0"  # precaution otherwise might pick up cauldron
_sleepSLEEP

_draw 5 "Checking for empty cauldron..."

_is "1 1 apply"
_sleepSLEEP

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo watch $DRAW_INFO
_sleepSLEEP

_is "1 1 get"
_sleepSLEEP

#echo watch $DRAW_INFO

while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "get:$REPLY"
_debug "REPLY='$REPLY'"
case $REPLY in
'')               break;;
$OLD_REPLY)       break;;
esac

REPLY_ALL="$REPLY
$REPLY_ALL"

OLD_REPLY="$REPLY"
sleep 0.1s
done

_debug "$REPLY_ALL"

 test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
  _draw 3 "Cauldron probably NOT empty !!"
  _draw 3 "Please check/empty the cauldron and try again."
  exit 1 # using f_exit would close the cauldron
 }

echo unwatch $DRAW_INFO

_draw 7 "OK ! Cauldron SEEMS empty."

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
}

_get_player_speed(){
# *** Getting Player's Speed *** #

_draw 5 "Processing Player's speed..."

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while :; do
_ping
read -t 2 ANSWER
_log "$LOG_REQUEST_FILE" "request stat cmbt:$ANSWER"
_debug "$ANSWER"

case $ANSWER in
'')               break;;
$OLD_ANSWER)      break;;
esac

OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_debug "Player speed is $PL_SPEED"

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_debug "Player speed set to $PL_SPEED"

if test ! "$PL_SPEED"; then
 _draw 3 "Unable to receive player speed. Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
elif test "$PL_SPEED" -gt 65; then
SLEEP=0.6; DELAY_DRAWINFO=1.1
elif test "$PL_SPEED" -gt 55; then
SLEEP=0.8; DELAY_DRAWINFO=1.3
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
 _draw 3 "PL_SPEED not a number ? Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
fi

SLEEP=${SLEEP:-1}

_debug "SLEEP='$SLEEP'"
test "$SLEEP_ADJ" && { SLEEP=`dc $SLEEP $SLEEP_ADJ \+ p`
 case $SLEEP in -[0-9]*) SLEEP=0.1;; esac
 _debug "SLEEP now set to '$SLEEP'" ; }

SLEEP=${SLEEP:-1}

_draw 6 "Done."
}

_get_player_speed
_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
f_check_on_cauldron
f_check_free_space
_check_empty_cauldron
_prepare_recall

# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***

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


_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}

# *** Now LOOPING *** #

TIMEB=`/bin/date +%s`
_draw 4 "OK... Might the Might be with You!"

FAIL=0; one=0

test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

# ***
# ***
# *** diff marker 16
# *** diff marker 17
# ***
# ***

while :;
do

TIMEC=${TIMEE:-$TIMEB}

_is "1 1 apply"
_sleepSLEEP

echo watch $DRAW_INFO

_is "1 1 drop 1 water of the wise"
_sleepSLEEP

#echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";
DW=0
while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "drop:$REPLY"
_debug "REPLY='$REPLY'"

case "$REPLY" in
$OLD_REPLY) break;;
*"Nothing to drop.")   break 2;; # f_exit 1 "Nothing to drop";;
*"There are only"*)    break 2;; # f_exit 1 "Not enough water of the wise";;
*"There is only"*)     break 2;; # f_exit 1 "Not enough water of the wise";;
*"You put the water"*) DW=$((DW+1)); unset REPLY;;
'') break;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing water of the wise in inventory."
_sleepSLEEP

_is "1 1 drop 1 mandrake root"
_sleepSLEEP

OLD_REPLY="";
REPLY="";
DW=0
while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "drop:$REPLY"
_debug "REPLY='$REPLY'"

case "$REPLY" in
$OLD_REPLY) break;;
*"Nothing to drop.")      break 2;; # f_exit 1 "Nothing to drop";;
*"There are only"*)       break 2;; # f_exit 1 "Not enough mandrake root";;
*"There is only"*)        break 2;; # f_exit 1 "Not enough mandrake root";;
*"You put the mandrake"*) DW=$((DW+1)); unset REPLY;;
'') break;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing mandrake root in inventory."
echo unwatch $DRAW_INFO

_sleepSLEEP
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP

echo watch $DRAW_INFO

_is "1 1 use_skill alchemy"

#echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "alchemy:$REPLY"
_debug "REPLY='$REPLY'"

case $REPLY in
'')         break;;
$OLD_REPLY) break;;
*"pours forth monsters"*)    f_emergency_exit 1;;
*"You unwisely release potent forces"*) break 2;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

_is "1 1 apply"
_sleepSLEEP

# ***
# ***
# *** diff marker 18
# *** diff marker 19
# ***
# ***

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

echo watch $DRAW_INFO

_is "0 0 get all"
_sleepSLEEP

#echo watch $DRAW_INFO

while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "get:$REPLY"
_debug "REPLY='$REPLY'"

case "$REPLY" in
$OLD_REPLY) break;;
*"Nothing to take!")   NOTHING=1;;
*"You pick up the slag.") SLAG=1;;
'') break;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

_sleepSLEEP
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_sleepSLEEP

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
        _is "1 1 use_skill sense curse"
        _is "1 1 use_skill sense magic"
        _is "1 1 use_skill alchemy"
        _sleepSLEEP

        _is "0 1 drop balm"
        else
        _is "0 1 drop slag"
        fi
fi
_sleepSLEEP

sleep ${DELAY_DRAWINFO}s

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP


f_check_on_cauldron

one=$((one+1))

TIMEE=`/bin/date +%s`
TIMER=$((TIMEE-TIMEC))
TIMER=$((TIMER+1))
_draw 4 "Round took '$TIMER' seconds."

if _test_integer $NUMBER; then
 TRIES_STILL=$((NUMBER-one))
 _draw 5 "Still '$TRIES_STILL' attempts to go .."

 TIME_STILL=$((TRIES_STILL*TIMER))
 TIME_STILL=$((TIME_STILL/60))
 _draw 5 "Still '$TIME_STILL' minutes to go..."
else
 TRIES_STILL=$one
 _draw 5 "Completed '$TRIES_STILL' attempts .."

 TIME_STILL=$((TRIES_STILL*TIMER))
 TIME_STILL=$((TIME_STILL/60))
 _draw 5 "Completed '$TIME_STILL' minutes. ..."
fi

test "$one" = "$NUMBER" && break
done  # *** MAINLOOP *** #

_say_statistics_end
# *** Here ends program *** #
_draw 2 "$0 is finished."
_beep


# ***
# ***
# *** diff marker 20
