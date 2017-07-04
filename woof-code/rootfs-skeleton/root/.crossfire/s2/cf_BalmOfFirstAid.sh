#!/bin/ash

# Now count the whole script time
TIMEA=`date +%s`

# *** VARIABLES *** #

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

SLEEP=3           # sleep seconds after codeblocks
DELAY_DRAWINFO=6  # sleep seconds to sync msgs from script with msgs from server

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
southwest) DIRF=northeast;;
northeast) DIRF=southwest;;
southeast) DIRF=northwest;;
esac

#logging
LOGGING=1
TMP_DIR=/tmp/crossfire_client
  LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
   LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
LOG_REQUEST_FILE="$TMP_DIR"/cf_request.$$.log
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
done >/dev/null
}

_draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local MSG="$*"
    echo draw $lCOLOUR "$MSG"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"${lFILE:-/tmp/cf_script.log}"
}

_debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$*"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_is(){
    _verbose "$*"
    echo issue "$*"
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
test "$NUMBER" -a "$FAIL" || return 3

if test "$FAIL" -le 0; then
 SUCC=$((NUMBER-FAIL))
 _draw 7 "You succeeded $SUCC times of $NUMBER ." # green
elif test "$((NUMBER/FAIL))" -lt 2;
then
 _draw 8 "You failed $FAIL times of $NUMBER ."    # light green
 _draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((NUMBER-FAIL))
 _draw 7 "You succeeded $SUCC times of $NUMBER ." # green
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
}

_usage(){
_draw 5 "Script to produce balm of first aid."
_draw 7 "Syntax:"
_draw 7 "$0 <NUMBER>"
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Balm of First Aid ."
_draw 4 "If no number given, loops as long"
_draw 4 "as ingredients could be dropped."
_draw 5 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
}

# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** PARAMETERS *** #
# *** Check for parameters *** #
echo drawnifo 5 "Checking the parameters ($*)..."


until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*help) _usage;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)     DEBUG=$((DEBUG+1));;
      --log*)   LOGGING=$((LOGGING+1));;
      --verb*)  VERBOSE=$((VERBOSE+1));;
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

'')
#_draw 3 "Script needs number of alchemy attempts as argument."
#_draw 3 "Need <number> ie: script $0 4 ."
# exit 1
:
;;

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


_draw 7 "OK."


# *** EXIT FUNCTIONS *** #
f_exit(){
RV=${1:-0}
shift

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep ${SLEEP}s

test "$*" && _draw 5 "$*"
_draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
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
_is "1 1 apply -u rod of word of recall"
_is "1 1 apply -a rod of word of recall"
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

# *** Monitoring function *** #
# *** Todo ...            *** #
f_monitor_malfunction(){

while :; do
read -t 1 ERRORMSGS

sleep 0.1s
done
}

# *** PREREQUISITES *** #
# 1.) f_check_on_cauldron
# 2.) f_check_free_space
# 3.) _prepare_recall
# 4.) _check_empty_cauldron
# 5.) _get_player_speed


f_check_on_cauldron(){
# *** Check if standing on a cauldron *** #

_draw 5 "Checking if on a cauldron..."

local UNDER_ME='';UNDER_ME_LIST='';
echo request items on

while :; do
_ping
read -t 1 UNDER_ME
sleep 0.1s
_log "request items on:$UNDER_ME" #>>"$LOG_ISON_FILE"
_debug "'$UNDER_ME'"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
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


test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
_draw 3 "Need to stand upon cauldron!"
_beep
exit 1
}

_draw 7 "OK."
}

f_check_free_space(){
# *** Check for 4 empty space to DIRB *** #

_draw 5 "Checking for space to move..."

echo request map pos

while :; do
_ping
read -t 1 REPLY
 _log "request map pos:$REPLY"
 _debug "REPLY='$REPLY'"
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
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
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

echo request map $R_X $R_Y

while :; do
_ping
read -t 1 REPLY
_log "request map '$R_X' '$R_Y':$REPLY"
_debug "REPLY='$REPLY'"

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
_log "IS_WALL='$IS_WALL'"
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

_prepare_recall(){
# *** Readying rod of word of recall - just in case *** #

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
_ping
read -t 1 REPLY
_log "request items actv:$REPLY"
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


_draw 6 "Done."
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

_is "0 1 pickup 0"  # precaution otherwise might pick up cauldron
sleep ${SLEEP}s


_draw 5 "Checking for empty cauldron..."

_is "1 1 apply"
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

_is "1 1 get"

echo watch $DRAW_INFO

while :; do
_ping
read -t 1 REPLY
_log "get:$REPLY"
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
_draw 3 "Cauldron probably NOT empty !!"
_draw 3 "Please check/empty the cauldron and try again."
f_exit 1
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
read -t 1 ANSWER
_log "request stat cmbt:$ANSWER"
_debug "$ANSWER"

test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done


#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_draw 7 "Player speed is $PL_SPEED"

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_draw 7 "Player speed set to $PL_SPEED"

  if test $PL_SPEED -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test $PL_SPEED -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
fi

_draw 6 "Done."
}

f_check_on_cauldron
f_check_free_space
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


_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}

# *** Now LOOPING *** #

TIMEB=`date +%s`
_draw 4 "OK... Might the Might be with You!"

FAIL=0

#for one in `seq 1 1 $NUMBER`
while :;
do

TIMEC=${TIMEE:-$TIMEB}

_is "1 1 apply"
sleep ${SLEEP}s

#echo watch $DRAW_INFO

_is "1 1 drop 1 water of the wise"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "drop:$REPLY"
_debug "REPLY='$REPLY'"
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


sleep ${SLEEP}s

_is "1 1 drop 1 mandrake root"

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "drop:$REPLY"
_debug "REPLY='$REPLY'"
#test "$REPLY" = "$OLD_REPLY" && break
case "$REPLY" in
$OLD_REPLY) break;;
*"Nothing to drop.") f_exit 1;;
*"There are only"*) f_exit 1;;
*"There is only"*)  f_exit 1;;
'') break;;
esac
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done


echo unwatch $DRAW_INFO

sleep ${SLEEP}s

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep ${SLEEP}s

#echo watch $DRAW_INFO

_is "1 1 use_skill alchemy"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
_log "alchemy:$REPLY"
_debug "REPLY='$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

_is "1 1 apply"
sleep ${SLEEP}s

#echo watch $DRAW_INFO

_is "1 1 get"

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
_ping
read -t 1 REPLY
_log "get:$REPLY"
_debug "REPLY='$REPLY'"
#test "$REPLY" = "$OLD_REPLY" && break
case "$REPLY" in
$OLD_REPLY) break;;
*"Nothing to take!")   NOTHING=1;;
*"You pick up the slag.") SLAG=1;;
'') break;;
esac
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

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
sleep ${SLEEP}s

if test $NOTHING = 0; then
        if test $SLAG = 0; then
        _is "1 1 use_skill sense curse"
        _is "1 1 use_skill sense magic"
        _is "1 1 use_skill alchemy"
        sleep ${SLEEP}s

        _is "0 1 drop balm"
        else
        _is "0 1 drop slag"
        fi
fi

sleep ${DELAY_DRAWINFO}s

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
sleep ${SLEEP}s


f_check_on_cauldron

one=$((one+1))

TIMEE=`date +%s`
TIMER=$((TIMEE-TIMEC))
TIMER=$((TIMER+1))
_draw 4 "Round took '$TIMER' seconds."

if _test_integer $NUMBER; then
 TRIES_STILL=$((NUMBER-one))
 _draw 4 "Still '$TRIES_STILL' attempts to go .."

 TIME_STILL=$((TRIES_STILL*TIMER))
 TIME_STILL=$((TIME_STILL/60))
 _draw 5 "Still '$TIME_STILL' minutes to go..."
else
 TRIES_STILL=$one
 _draw 4 "Completed '$TRIES_STILL' attempts .."

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
