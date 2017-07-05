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

SLEEP=4           # sleep seconds after codeblocks
DELAY_DRAWINFO=8  # sleep seconds to sync msgs from script with msgs from server
                  # the slower the player's speed, the more sleep delay needed;
          # also 2G Quality connections delays up to one second;
          # if the connection drops for 1-2 seconds once a while, a high value could buffer it

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup to empty the cauldron for next attempt
# and drop the result(s) to not increase carried weight and to prevent
# similar named ingredient being dropped into cauldron another time.
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

PRINT=draw         # print command to msg pane - was using drawextinfo which worked too


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

_sleepSLEEP(){
[ "$FAST" ] && return 0
sleep ${SLEEP:-1}s
}

_draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local lMSG="$*"
    echo $PRINT $lCOLOUR "$lMSG"
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

_usage(){
_draw 5 "Script to produce water of the wise."
_draw 7 "Syntax:"
_draw 7 "$0 < NUMBER >"
_draw 5 "Optional NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Water of the Wise ."
_draw 4 "If no number given, loops as long"
_draw 4 "as ingredient could be dropped."
_draw 2 "Options:"
_draw 4 "-d  to turn on debugging."
_draw 4 "-L  to log to $LOG_REPLY_FILE ."
_draw 4 "-v  to be more talkaktive."
_draw 7 "-F each --fast sleeps 0.2 s less"
_draw 8 "-S each --slow sleeps 0.2 s more"
_draw 3 "-X --nocheck do not check cauldron (faster)"
        exit 0
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

# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***

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


CHECK_DO=1
# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #
#[ "$*" ] && {
until test "$#" = 0
do
PARAM_1="$1"

case "$PARAM_1" in
-h|*help|*usage)     _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
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

'') :;;

[0-9]*)
PARAM_1test="${PARAM_1//[[:digit:]]/}"
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

# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***

#} || {
#_draw 3 "Script needs number of alchemy attempts as argument."
#        exit 1
#}

#test "$1" || {
#_draw 3 "Need <number> ie: script $0 3 ."
#        exit 1
#}


# *** EXIT FUNCTIONS *** #
f_exit(){
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep 1s
_draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch $DRAW_INFO
exit $1
}

f_emergency_exit(){
_is "1 1 apply rod of word of recall"
_is "1 1 fire center"
_draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
_is "1 1 fire_stop"
exit $1
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
# 1.) _get_player_speed
# 2.) _check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
# 3.) f_check_on_cauldron
# 4.) _check_free_move
# 5.) _check_empty_cauldron
# 6.) _ready_recall

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
 read -t 1
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

_draw 4 "Checking if on cauldron..."
UNDER_ME='';
echo request items on

while [ 1 ]; do
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
_draw 3 "Need to stand upon cauldron!"
exit 1
}

_draw 7 "Done."
}
_check_free_move(){
# *** Check for 4 empty space to DIRB *** #

[ "$CHECK_DO" ] || return 0

_draw 5 "Checking for space to move..."

echo request map pos

while :; do
_ping
read -t 2 REPLY
 _log "$LOG_REPLY_FILE" "request map pos:$REPLY"
 _debug "REPLY='$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`
_debug "PL_POS_X='$PL_POS_X' PL_POS_Y='$PL_POS_Y'"

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

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
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "request map '$R_X' '$R_Y':$REPLY"
_debug "REPLY='$REPLY'"

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
_log "$LOG_REPLY_FILE" "IS_WALL='$IS_WALL'"
_debug "IS_WALL='$IS_WALL'"

test "$IS_WALL" = 0 || f_exit_no_space 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
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

_get_player_speed(){
# *** Getting Player's Speed *** #

_draw 4 "Processing Player's Speed..."

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

_draw 7 "" "" "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's/\.//g;s/^0*//'`

_draw 7 "Player speed is $PL_SPEED"

  if test $PL_SPEED -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0
elif test $PL_SPEED -gt 28; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test $PL_SPEED -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
fi

_draw 7 "Done."
}

_ready_recall(){
# *** Readying rod of word of recall - just in case *** #

_draw 4 "Preparing for recall..."
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
_is "1 1 apply rod of word of recall"
fi

_draw 7 "Done."
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

_draw 4 "Checking if cauldron is empty..."

_is "1 1 pickup 0"  # precaution otherwise might pick up cauldron
_sleepSLEEP

_is "1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

_is "1 1 get"

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
_draw 3 "" "Cauldron seems NOT empty !!"
_draw 3 " " "Please check/empty the cauldron and try again."
f_exit 1
}

echo unwatch $DRAW_INFO

_draw 7 "OK ! Cauldron IS empty."

_sleepSLEEP

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP
}

_get_player_speed
_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
f_check_on_cauldron
_check_free_move
_check_empty_cauldron
_ready_recall

# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***

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

rm -f /tmp/cf_script.rpl # empty old log file


test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

TIMEB=`/bin/date +%s`

FAIL=0; one=0

_draw 4 "OK... Might the Might be with You!"

# *** Now LOOPING *** #

#for one in `seq 1 1 $NUMBER`
while :;
do

TIMEC=${TIMEE:-$TIMEB}

OLD_REPLY="";
REPLY="";

_is "1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

_is "1 1 drop 7 water"


while [ 2 ]; do
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


echo unwatch $DRAW_INFO
_sleepSLEEP

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP



echo watch $DRAW_INFO

_is "1 1 use_skill alchemy"
one=$((one+1))

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 2 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO



_is "1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

_is "7 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 2 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
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

if test $NOTHING = 0; then

_is "1 1 use_skill sense curse"
_is "1 1 use_skill sense magic"
_is "1 1 use_skill alchemy"
_sleepSLEEP

#if test $NOTHING = 0; then
#for drop in `seq 1 1 7`; do  # unfortunately does not work without this nasty loop
_is "0 1 drop water of the wise"    # issue 1 1 drop drops only one water
_is "0 1 drop waters of the wise"
_is "0 1 drop water (cursed)"
_is "0 1 drop waters (cursed)"
_is "0 1 drop water (magic)"
_is "0 1 drop waters (magic)"
#_is "0 1 drop water (magic) (cursed)"
#_is "0 1 drop waters (magic) (cursed)"
_is "0 1 drop water (cursed) (magic)"
_is "0 1 drop waters (cursed) (magic)"
#_is "0 1 drop water (unidentified)"
#_is "0 1 drop waters (unidentified)"

_is "0 1 drop slag"               # many times draws 'But there is only 1 slags' ...
#_is "0 1 drop slags"

fi

sleep ${DELAY_DRAWINFO}s
#done                         # to drop all water of the wise at once ...

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP

sleep 1
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
_draw 3 "LOOP BOTTOM: SEEMS NOT ON CAULDRON!"
f_exit 1
}


TRIES_STILL=$((NUMBER-one))
TIMEE=`/bin/date +%s`
TIME=$((TIMEE-TIMEC))

case $TRIES_STILL in -*) # negative
TRIES_STILL=${TRIES_STILL#*-}
_draw 4 "Time $TIME sec., completed ${TRIES_STILL:-$NUMBER} laps.";;
*)
_draw 4 "Time $TIME sec., still $TRIES_STILL laps to go...";;
esac

test "$one" = "$NUMBER" && break
done  # *** MAIN LOOP *** #

# *** Here ends program *** #
_say_statistics_end
_draw 2 "$0 is finished."
_beep

# ***
# ***
# *** diff marker 20
