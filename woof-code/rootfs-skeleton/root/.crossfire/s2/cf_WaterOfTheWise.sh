#!/bin/ash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

# Now count the whole script time
TIMEA=`/bin/date +%s`

# *** VARIABLES *** #

DEBUG=  # set to anything to enable

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

#logging
LOGGING=1
TMP_DIR=/tmp/crossfire_client
  LOG_REPLY_FILE="$TMP_DIR"/cf_wotw.$$.rpl
   LOG_ISON_FILE="$TMP_DIR"/cf_wotw.$$.ion
LOG_REQUEST_FILE="$TMP_DIR"/cf_wotw.$$.req
mkdir -p "$TMP_DIR"
rm -f "$LOG_REPLY_FILE" # empty old log file

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
    local lMSG="$@"
    echo draw $lCOLOUR "$lMSG"
}

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
_draw ${COL_DEB:-3} "DEBUG:$@"
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
        exit 0
}


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


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


# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #


until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #

case "$PARAM_1" in
-h|*help|*usage)     _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)      DEBUG=$((DEBUG+1));;
      --log*)    LOGGING=$((LOGGING+1));;
      --verbose) VERBOSE=$((VERBOSE+1));;
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
# *** diff marker 4
# *** diff marker 5
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
sleep 1s

test "$*" && _draw 5 "$*"
_draw 3 "Exiting $0."

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

_is "1 1 apply rod of word of recall"
_is "1 1 fire center"
_draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
_is "1 1 fire_stop"

NUMBER=$((one-1))
_say_statistics_end
test "$*" && _draw 5 "$*"
_beep
_beep
exit $RV
}

# *** PREREQUISITES *** #
# 1.) f_check_on_cauldron
# 2.) _get_player_speed
# 3.) _ready_recall
# 4.) _check_empty_cauldron

# *** Check if standing on a cauldron *** #

f_check_on_cauldron(){

_draw 4 "Checking if on cauldron..."
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
_draw 3 "Need to stand upon cauldron!"
_beep
exit 1
        }

_draw 7 "Done."
}


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


# *** Getting Player's Speed *** #
_get_player_speed(){
_draw 4 "Processing Player's Speed..."


ANSWER=
OLD_ANSWER=

echo request stat cmbt

while :; do
read -t 1 ANSWER
_log "$LOG_REQUEST_FILE" "$ANSWER"
_debug "'$ANSWER'"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_debug "Player speed is $PL_SPEED"  #DEBUG

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_debug "Player speed is $PL_SPEED"  #DEBUG

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

_draw 7 "Done."
}

# *** Readying rod of word of recall - just in case *** #
_ready_recall(){
_draw 4 "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "request items actv:$REPLY"
_debug "REPLY='$REPLY'"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.* rod of word of recall'`" && RECALL=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
_is "1 1 apply rod of word of recall"
fi

_sleepSLEEP
_draw 7 "Done."
}


# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***


# *** Check if cauldron is empty *** #
_check_empty_cauldron(){
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

while :; do
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "get:$REPLY"
_debug "REPLY='$REPLY'"

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
_draw 3 "Cauldron NOT empty !!"
_draw 3 "Please empty the cauldron and try again."
_beep
f_exit 1
}

echo unwatch $DRAW_INFO

_draw 7 "OK ! Cauldron SEEMS empty."

_sleepSLEEP

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP
}

f_check_on_cauldron
_get_player_speed
_ready_recall
_check_empty_cauldron

# *** Actual script to alch the desired water of the wise *** #
#test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution
test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

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


# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***


# *** Now LOOPING *** #

_draw 4 "OK... Might the Might be with You!"
TIMEB=`/bin/date +%s`

FAIL=0

while :;
do

TIMEC=${TIMEE:-$TIMEB}


OLD_REPLY="";
REPLY="";
DW=0

_is "1 1 apply"
_sleepSLEEP

echo watch $DRAW_INFO

_is "1 1 drop 7 water"
_sleepSLEEP

while :; do
 read -t 1 REPLY
[ "$LOGGING" ] &&  echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
_debug "REPLY='$REPLY'"
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.")   f_exit 1 "Nothing to drop ..?";;
 *"There are only"*)    f_exit 1 "Not enough water ..";;
 *"There is only"*)     f_exit 1 "Only one water .";;
 *"You put the water"*) DW=$((DW+1)); unset REPLY;;
 '') break;;
 esac
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing water in inventory."

echo unwatch $DRAW_INFO
_sleepSLEEP

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP

f_check_on_cauldron
_sleepSLEEP

#_is "1 1 use_skill alchemy"
_is "0 0 use_skill alchemy"

# TOTO monsters
echo watch $DRAW_INFO
_sleepSLEEP

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "alchemy:$REPLY"
_debug "REPLY='$REPLY'"
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

_sleepSLEEP
_is "1 1 apply"
_sleepSLEEP


echo watch $DRAW_INFO

#_is "7 1 get"
echo issue 0 0 "get all"
_sleepSLEEP

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
read -t 1 REPLY
 _log "$LOG_REPLY_FILE" "get:$REPLY"
 _debug "REPLY='$REPLY'"

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
_sleepSLEEP

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi


# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***


_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_sleepSLEEP


if test "$NOTHING" = 0; then

_is "1 1 use_skill sense curse"
_is "1 1 use_skill sense magic"
_is "1 1 use_skill alchemy"
_sleepSLEEP

#if test $NOTHING = 0; then
#for drop in `seq 1 1 7`; do  # unfortunately does not work without this nasty loop
_is "0 1 drop water of the wise"    # issue 1 1 drop drops only one water
_is "0 1 drop waters of the wise"
_sleepSLEEP
# else if (level < 40) {                 /* MAKE TAINTED ITEM */
_is "0 1 drop water (cursed)"
_is "0 1 drop waters (cursed)"
_sleepSLEEP
_is "0 1 drop water (magic)"
_is "0 1 drop waters (magic)"
_sleepSLEEP
#_is "0 1 drop water (magic) (cursed)"
#_is "0 1 drop waters (magic) (cursed)"
_is "0 1 drop water (cursed) (magic)"
_is "0 1 drop waters (cursed) (magic)"
_sleepSLEEP
#_is "0 1 drop water (unidentified)"
#_is "0 1 drop waters (unidentified)"

# if (level < 25) {         /* INGREDIENTS USED/SLAGGED */
_is "0 1 drop slag"               # many times draws 'But there is only 1 slags' ...
#_is "0 1 drop slags"
_sleepSLEEP
fi

sleep ${DELAY_DRAWINFO}s
#done                         # to drop all water of the wise at once ...


_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP


f_check_on_cauldron

one=$((one+1))

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
done

_say_statistics_end

# *** Here ends program *** #
_draw 2 "$0 is finished."
_beep


# ***
# ***
# *** diff marker 14
