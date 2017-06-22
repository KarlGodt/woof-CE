#!/bin/ash

exec 2>/tmp/cf_script.err

# Now count the whole script time
TIMEA=`date +%s`

# *** VARIABLES *** #

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

SLEEP=4           # sleep seconds after codeblocks
DELAY_DRAWINFO=8  # sleep seconds to sync msgs from script with msgs from server
                  # the slower the player's speed, the more sleep delay needed;
          # also 2G Quality connections delays up to one second;
          # if the connection drops for 1-2 seconds once a while, a high value could buffer it

ITEM_RECALL='rod of word of recall' # f_emergency_exit uses this ( staff, scroll, rod of word of recall )

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup to empty the cauldron for next attempt
# and drop the result(s) to not increase carried weight.
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
TMP_DIR=/tmp/crossfire_client
  LOG_REPLY_FILE="$TMP_DIR"/cf_woth.$$.rpl
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
    lFILE="$1"; shift; } || lFILE="${LOG_REPLY_FILE}"
  lFILE="${lFILE:-/tmp/cf_script.log}"
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
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v  to be more talkaktive."
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
test "${NUMBER:+$one}" -a "$FAIL" || return 3

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
TIMELE=`date +%s`
_say_minutes_seconds "$TIMEB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"

_remove_err_log
}

CHECK_DO=1
# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #

case "$PARAM_1" in
-h|*help)     _usage;;
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

#NUMBER=$((one-1))
_say_statistics_end
_beep
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

#NUMBER=$((one-1))
_say_statistics_end
test "$*" && _draw 5 "$*"
_beep
_beep
exit $RV
}

# *** PREREQUISITES *** #
# 1.) _get_player_speed
# 2.) _check_skill alchemy || f_exit 1 "You seem not to have the skill alchemy."
# 3.) _check_on_cauldron
# 4.) _check_free_move
# 5.) _check_empty_cauldron
# 6.) _ready_recall

_get_player_speed(){
# *** Getting Player's Speed *** #

_draw 4 "Processing Player's Speed..."


ANSWER=
OLD_ANSWER=

echo request stat cmbt

while :; do
read -t 2 ANSWER
_log "$LOG_REQUEST_FILE" "$ANSWER"
_debug "'$ANSWER'"

case $ANSWER in ''|$OLD_ANSWER) break;;
*request*stat*cmbt*end*) break;; esac

OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash
PL_SPEED=${PL_SPEED:-40000}
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_debug "Player speed is $PL_SPEED"  #DEBUG

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_debug "Player speed is $PL_SPEED"  #DEBUG

  if test "$PL_SPEED" -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test "$PL_SPEED" -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test "$PL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
fi

_debug "SLEEP='$SLEEP'"
SLEEP=`dc ${SLEEP:-1} ${SLEEP_ADJ:-0} \+ p` || SLEEP=1
 case $SLEEP in -[0-9]*) SLEEP=0.1;; esac
_debug "SLEEP now set to '$SLEEP'"

SLEEP=${SLEEP:-1}

_draw 7 "Done."
}

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
  _log "$LOG_REQUEST_FILE" "_check_skill:$REPLY"
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

_check_on_cauldron(){
# *** Check if standing on a cauldron *** #
[ "$CHECK_DO" ] || return 0
_draw 4 "Checking if on cauldron..."
unset UNDER_ME UNDER_ME_LIST

echo request items on

while :; do
read -t 2 UNDER_ME
sleep 0.1s
_log "$LOG_ISON_FILE" "$UNDER_ME"
_debug "$UNDER_ME"

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

case "$UNDER_ME" in
"request items on end") break;;
"scripttell break")     break;;
"scripttell exit")     exit 1;;
esac
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
_draw 3 "Need to stand upon cauldron!"
_beep
f_exit 1
        }

_draw 7 "Done."
}

_check_free_move(){
# *** Check for 4 empty space to DIRB *** #
[ "$CHECK_DO" ] || return 0
_draw 4 "Checking for space to move..."

echo request map pos

while :; do
_ping
read -t 2 REPLY
 _log "$LOG_REQUEST_FILE" "request map pos:$REPLY"
 _debug "REPLY='$REPLY'"

case $REPLY in ''|$OLD_REPLY) break;;
*request*map*pos*end*) break;; esac

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
_log "$LOG_REQUEST_FILE" "request map '$R_X' '$R_Y':$REPLY"
_debug "REPLY='$REPLY'"

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
_log "$LOG_REQUEST_FILE" "IS_WALL='$IS_WALL'"
_debug "IS_WALL='$IS_WALL'"

test "$IS_WALL" = 0 || f_exit_no_space 1

case $REPLY in ''|$OLD_REPLY) break;;
*request*map*end*) break;; esac

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

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #
[ "$CHECK_DO" ] || return 0
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

case $REPLY in ''|$OLD_REPLY) break;; esac

REPLY_ALL="$REPLY
$REPLY_ALL"

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

_ready_recall(){
# *** Readying $ITEM_RECALL - just in case *** #
[ "$CHECK_DO" ] || return 0
_draw 4 "Preparing for recall..."
RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t 2 REPLY
_log "$LOG_REQUEST_FILE" "request items actv:$REPLY"
_debug "REPLY='$REPLY'"

case $REPLY in ''|$OLD_REPLY) break;;
*request*items*actv*end*) break;;
*$ITEM_RECALL*) RECALL=1;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
_is "1 1 apply $ITEM_RECALL"
fi

_sleepSLEEP
_draw 7 "Done."
}

# *** PREREQUISITES *** #
_get_player_speed
_check_skill alchemy || f_exit 1 "You seem not to have the skill alchemy."
_check_on_cauldron
_check_free_move
_check_empty_cauldron
_ready_recall


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

# *** Now LOOPING *** #


test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

_draw 4 "OK... Might the Might be with You!"
TIMEB=`date +%s`

FAIL=0; one=0

while :;
do

TIMEC=${TIMEE:-$TIMEB}


OLD_REPLY="";
REPLY="";

_is "1 1 apply"
sleep 0.5s

echo watch $DRAW_INFO

_is "1 1 drop 7 water"

while :; do
 read -t 1 REPLY
_log "$LOG_REPLY_FILE" "drop:$REPLY"
_debug "REPLY='$REPLY'"
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.") break 2;; #f_exit 1;;
 *"There are only"*)  break 2;; #f_exit 1;;
 *"There is only"*)   break 2;; #f_exit 1;;
 '') break;;
 esac

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

_check_on_cauldron

_sleepSLEEP
#_is "1 1 use_skill alchemy"
_is "0 0 use_skill alchemy"
one=$((one+1))

# TOTO monsters
echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "alchemy:$REPLY"
_debug "REPLY='$REPLY'"
case $REPLY in ''|$OLD_REPLY) break;;
*Your*cauldron*darker*) break 2;;
# (level < 100) {                /* WHAMMY the CAULDRON */
#        if (!QUERY_FLAG(cauldron, FLAG_CURSED)) {
*pours*forth*monsters*) f_emergency_exit 1;;
# (level < 110) {                /* SUMMON EVIL MONSTERS */
*You*unwisely*release*) break 2;;        # potent forces
# /* MANA STORM - watch out!! */
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

sleep 0.5s
_is "1 1 apply"
sleep 0.5s


echo watch $DRAW_INFO

_is "7 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
read -t 1 REPLY
_log "$LOG_REPLY_FILE" "get:$REPLY"
_debug "REPLY='$REPLY'"

# else if (level < 60) {                 /* CREATE MONSTER */
#        draw_ext_info_format(NDI_UNIQUE, 0, op, MSG_TYPE_SKILL, MSG_TYPE_SKILL_FAILURE,
#                             "The %s %s.", cauldron->name, cauldron_sound());
#        remove_contents(cauldron->inv, NULL);
#        return;

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
_sleepSLEEP

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

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

_is "0 1 drop water of the wise"    # issue 1 1 drop drops only one water
_is "0 1 drop waters of the wise"
# else if (level < 40) {                 /* MAKE TAINTED ITEM */
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
fi

if test "$SLAG" = 1; then
# if (level < 25) {         /* INGREDIENTS USED/SLAGGED */
_is "0 1 drop slag"               # many times draws 'But there is only 1 slags' ...
#_is "0 1 drop slags"
fi

sleep ${DELAY_DRAWINFO}s

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP


_check_on_cauldron

#one=$((one+1))

TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEC))

case $TRIES_STILL in -*) # negative
TRIES_STILL=${TRIES_STILL#*-}
_draw 4 "Time $TIME sec., completed ${TRIES_STILL:-$NUMBER} laps.";;
*)
_draw 4 "Time $TIME sec., still $TRIES_STILL laps to go...";;
esac

test "$one" = "$NUMBER" && break
done  # *** MAIN LOOP *** #

_say_statistics_end

# *** Here ends program *** #
_draw 2 "$0 is finished."
_beep
