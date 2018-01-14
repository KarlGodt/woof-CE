#!/bin/ash

[ "$HAVE_FUNCS_COMMON" ] && return 0

# *** Color numbers found in common/shared/newclient.h : *** #
#define NDI_BLACK       0
#define NDI_WHITE       1
#define NDI_NAVY        2
#define NDI_RED         3
#define NDI_ORANGE      4
#define NDI_BLUE        5       /**< Actually, it is Dodger Blue */
#define NDI_DK_ORANGE   6       /**< DarkOrange2 */
#define NDI_GREEN       7       /**< SeaGreen */
#define NDI_LT_GREEN    8       /**< DarkSeaGreen, which is actually paler
#                                 *   than seagreen - also background color. */
#define NDI_GREY        9
#define NDI_BROWN       10      /**< Sienna. */
#define NDI_GOLD        11
#define NDI_TAN         12      /**< Khaki. */
#define NDI_MAX_COLOR   12      /**< Last value in. */

_set_global_variables(){
LOGGING=${LOGGING:-''}  #bool, set to ANYTHING ie "1" to enable, empty to disable
#DEBUG=${DEBUG:-''}      #bool, set to ANYTHING ie "1" to enable, empty to disable
MSGLEVEL=${MSGLEVEL:-7} #integer 1 emergency - 7 debug
#case $MSGLEVEL in
#7) DEBUG=${DEBUG:-1};; 6) INFO=${INFO:-1};; 5) NOTICE=${NOTICE:-1};; 4) WARN=${WARN:-1};;
#3) ERROR=${ERROR:-1};; 2) ALERT=${ALERT:-1};; 1) EMERG=${EMERG:-1};;
#esac
DEBUG=1; INFO=1; NOTICE=1; WARN=1; ERROR=1; ALERT=1; EMERG=1; Q=-q; VERB=-v
case $MSGLEVEL in
7) unset Q;; 6) unset DEBUG Q;; 5) unset DEBUG INFO VERB;; 4) unset DEBUG INFO NOTICE VERB;;
3) unset DEBUG INFO NOTICE WARN VERB;; 2) unset DEBUG INFO NOTICE WARN ERROR VERB;;
1) unset DEBUG INFO NOTICE WARN ERROR ALERT VERB;;
*) _error "MSGLEVEL variable not set from 1 - 7";;
esac

TMOUT=${TMOUT:-1}      # read -t timeout, integer, seconds
SLEEP=${SLEEP:-1}      #default sleep value, float, seconds, refined in _get_player_speed()
DELAY_DRAWINFO=${DELAY_DRAWINFO:-2}  #default pause to sync, float, seconds, refined in _get_player_speed()

DRAWINFO=${DRAWINFO:-drawinfo} #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
FUNCTION_CHECK_FOR_SPACE=_check_for_space # request map pos works
case $* in
*-version" "*) CLIENT_VERSION="$2"
case $CLIENT_VERSION in 0.*|1.[0-9].*|1.1[0-2].*)
DRAWINFO=drawextinfo #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
                     #     except use_skill alchemy :watch drawinfo 0 The cauldron emits sparks.
                     # and except apply             :watch drawinfo 0 You open cauldron.
                     #
                     # and probably more ...? TODO!
FUNCTION_CHECK_FOR_SPACE=_check_for_space_old_client # needs request map near
;;
esac
;;
esac

COUNT_CHECK_FOOD=${COUNT_CHECK_FOOD:-10} # number between attempts to check foodlevel.
                    #  1 would mean check every single time, which is too much
EAT_FOOD=${EAT_FOOD:-waybread}   # set to desired food to eat ie food, mushroom, booze, .. etc.
FOOD_DEF=$EAT_FOOD     # default
MIN_FOOD_LEVEL_DEF=${MIN_FOOD_LEVEL_DEF:-300} # default minimum. 200 starts to beep.
                       # waybread has foodvalue of 500
                       # 999 is max foodlevel

HP_MIN_DEF=${HP_MIN_DEF:-20}          # minimum HP to return home. Lowlevel charakters probably need this set.

DIRB=${DIRB:-west}  # direction back to go
case $DIRB in
west)      DIRF=east;;
east)      DIRF=west;;
north)     DIRF=south;;
northwest) DIRF=southeast;;
northeast) DIRF=southwest;;
south)     DIRF=north;;
southwest) DIRF=northeast;;
southeast) DIRF=northwest;;
esac

SOUND_DIR="$HOME"/.crossfire/sounds

# Log file path in /tmp
#MY_SELF=`realpath "$0"` ## needs to be in main script
#MY_BASE=${MY_SELF##*/}  ## needs to be in main script
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
    LOGFILE=${LOGFILE:-"$TMP_DIR"/"$MY_BASE".$$.log}
  REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
     ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion
  ERROR_LOG="$TMP_DIR"/"$MY_BASE".$$.err
exec 2>>"$ERROR_LOG"
}

_watch(){
echo unwatch ${*:-$DRAWINFO}
sleep 0.4
echo   watch ${*:-$DRAWINFO}
}

_unwatch(){
echo unwatch ${*:-$DRAWINFO}
}

_sleep(){
sleep ${SLEEP:-1}
}

_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

__msg(){  ##+++2018-01-08
local LVL=$1; shift
case $LVL in
7|debug) test "$DEBUG"  && _debug  "$*";;
6|info)  test "$INFO"   && _info   "$*";;
5|note)  test "$NOTICE" && _notice "$*";;
4|warn)  test "$WARN"   && _warn   "$*";;
3|err)   test "$ERROR"  && _error  "$*";;
2|alert) test "$ALERT"  && _alert  "$*";;
1|emerg) test "$EMERG"  && _emerg  "$*";;
*) _debug "$*";;
esac
}

_msg(){  ##+++2018-01-08
local LVL=$1; shift
case $LVL in
7|debug) _debug  "$*";;
6|info)  _info   "$*";;
5|note)  _notice "$*";;
4|warn)  _warn   "$*";;
3|err)   _error  "$*";;
2|alert) _alert  "$*";;
1|emerg) _emerg  "$*";;
*) _debug "$*";;
esac
}

_debug(){
test "$DEBUG" || return 0
    echo draw 10 "DEBUG:$@"
}

__debug(){  ##+++2018-01-06
test "$DEBUG" || return 0
dcnt=0
echo "$*" | while read line
do
dcnt=$((dcnt+1))
    echo draw 3 "__DEBUG:$dcnt:$line"
done
unset dcnt line
}

_info(){
test "$INFO" || return 0
    echo draw 7 "INFO:$@"
}

_notice(){
test "$NOTICE" || return 0
    echo draw 2 "NOTICE:$@"
}

_warn(){
test "$WARN" || return 0
    echo draw 6 "WARNING:$@"
}

_error(){
test "$ERROR" || return 0
    echo draw 4 "ERROR:$@"
}

_alert(){
test "$ALERT" || return 0
    echo draw 3 "ALERT:$@"
}

_ermerg(){
test "$EMERG" || return 0
    echo draw 3 "EMERGENCY:$@"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOGFILE"
   echo "$*" >>"$lFILE"
}

_sound(){
    local lDUR
test "$2" && { DUR="$1"; shift; }
lDUR=${lDUR:-0}
test -e "$SOUND_DIR"/${1}.raw && \
           aplay $Q $VERB -d $lDUR "$SOUND_DIR"/${1}.raw
}

_success(){
 _sound 0 bugle_charge
}

_failure(){
 _sound 0 ouch1
}

_disaster(){
 _sound 0 Missed
}

_unknown(){
 _sound 0 TowerClock
}

_say_start_msg(){
# *** Here begins program *** #
_draw 2 "$0 has started.."
_draw 2 "PID is $$ - parentPID is $PPID"

_check_drawinfo

# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."
}

_tell_script_time(){
test "$TIMEA" || return 1

 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEA))
 TIMEM=$((TIME/60))
 TIMES=$(( TIME - (TIMEM*60) ))
 _draw 4 "Loop of script had run a total of $TIMEM minutes and $TIMES seconds."
}

_say_script_time(){ ##+++2018-01-07
TIME_ELAPSED=`ps -o pid,etime,args | grep -w "$$" | grep -vwE 'grep|ps'`
__debug "$TIME_ELAPSED"
TIME_ELAPSED=`echo "$TIME_ELAPSED" | awk '{print $2}'`
__debug "$TIME_ELAPSED"
case $TIME_ELAPSED in
*:*:*) _draw 5 "Script had run a time of $TIME_ELAPSED h:m:s .";;
*:*)   _draw 5 "Script had run a time of $TIME_ELAPSED m:s .";;
*)     _draw 5 "Script had run a time of $TIME_ELAPSED s .";;
esac
}

_say_end_msg(){
# *** Here ends program *** #
_is 1 1 fire_stop
test -f "$HOME"/.crossfire/sounds/su-fanf.raw && aplay $Q "$HOME"/.crossfire/sounds/su-fanf.raw & aPID=$!

_tell_script_time || _say_script_time

test "$DEBUG" || { test -s "$ERROR_LOG" || rm -f "$ERROR_LOG"; }
test "$DEBUG" -o "$INFO" || rm -f "$TMP_DIR"/*.$$*

test "$aPID" && wait $aPID
_draw 2  "$0 $$ has finished."
}

_loop_counter(){
test "$TIMEA" -a "$TIMEB" -a "$NUMBER" -a "$one" || return 0
TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
TIMEZ=$((TIMEE-TIMEA))
TIMEAV=$((TIMEZ/one))
TIMEEST=$(( (TRIES_STILL*TIMEAV) / 60 ))
_draw 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_STILL ($TIMEEST m) to go..."
}

#** the messages in the msgpane may pollute **#
#** need to catch msg to discard them into an unused variable **#
_empty_message_stream(){
local REPLY
while :;
do
read -t $TMOUT
_log "$REPLY_LOG" "_empty_message_stream:$REPLY"
test "$REPLY" || break
_msg 7 "_empty_message_stream:$REPLY"
unset REPLY
 sleep 0.01
#sleep 0.1
done
}

_check_drawinfo(){  ##+++2018-01-08
_debug "_check_drawinfo:$*"

DEBUG0=$DEBUG;       DEBUG=${DEBUG:-''}
LOGGING0=$LOGGING; LOGGING=${LOGGING:-1}

_draw 2 "Checking drawinfo ..."

echo watch

while :;
do

# I use search here to provoke
# a response from the server
# like You search the area.
# It could be something else,
# but I have no better idea for the moment.
#__is 0 0 search
_is 0 0 examine

 unset cnt0 TICKS
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "_check_drawinfo:$cnt0:$REPLY"
    _msg 7 "$cnt0:$REPLY"
 #_debug 3 "$cnt0:$REPLY"

 case $REPLY in
 #*drawinfo*'You search'*|*drawinfo*'You spot'*)       DRAWINFO0=drawinfo;    break 2;;
 #*drawextinfo*'You search'*|*drawextinfo*'You spot'*) DRAWINFO0=drawextinfo; break 2;;
 *drawinfo*'That is'*|*drawinfo*'These are'*)       DRAWINFO0=drawinfo;    break 2;;
 *drawextinfo*'That is'*|*drawextinfo*'These are'*) DRAWINFO0=drawextinfo; break 2;;
 *drawinfo*'This is'*|*drawinfo*'Those are'*)       DRAWINFO0=drawinfo;    break 2;;
 *drawextinfo*'This is'*|*drawextinfo*'Those are'*) DRAWINFO0=drawextinfo; break 2;;
 *tick*) TICKS=$((TICKS+1)); test "$TICKS" -gt 19 && break 1;;
 '') break 1;;
 *) :;;
 esac

 sleep 0.1
 done

_sleep
done

echo unwatch
_empty_message_stream
unset cnt0

test "$DRAWINFO0" = "$DRAWINFO" || {
    _msg 5 "Changing internally from $DRAWINFO to $DRAWINFO0"
    DRAWINFO=$DRAWINFO0
}

DEBUG=$DEBUG0
LOGGING=$LOGGING0
_draw 6 "Done."
}

# *** EXIT FUNCTIONS *** #
_exit(){
case $1 in
[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) RV=$1; shift;;
esac

_move_back_and_forth 2
sleep ${SLEEP}s
_draw 3 "Exiting $0. $@"
echo unwatch
echo unwatch $DRAWINFO
beep -l 1000 -f 700
test ${RV//[0-9]/} && RV=3
exit ${RV:-0}
}

_just_exit(){
echo draw 3 "Exiting $0."
echo unwatch
exit ${1:-0}
}

_emergency_exit(){
_is 1 1 apply -u rod of word of recall
_is 1 1 apply -a rod of word of recall
_is 1 1 fire center
_draw 3 "Emergency Exit $0 !"
_unwatch $DRAWINFO
_is 1 1 fire_stop
beep -l 1000 -f 700
exit ${1:-0}
}

_exit_no_space(){
_draw 3 "On position $nr $DIRB there is something ($IS_WALL)!"
_draw 3 "Remove that item and try again."
_draw 3 "If this is a wall, try on another place."
beep -l 1000 -f 700
exit ${1:-0}
}

# ***
__error(){  # _error 1 "Some error occured"
# ***

RV=$1;shift
eMSG=`echo -e "$*"`
__draw 3 "$eMSG"
exit ${RV:-1}
}

_direction_to_number(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 0

DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=0;;
1|north|n)         DIRECTION=1;;
2|northeast|ne)    DIRECTION=2;;
3|east|e)          DIRECTION=3;;
4|southeast|se)    DIRECTION=4;;
5|south|s)         DIRECTION=5;;
6|southwest|sw)    DIRECTION=6;;
7|west|w)          DIRECTION=7;;
8|northwest|nw)    DIRECTION=8;;
*) ERROR=1 _error "Not recognized: '$DIRECTION'"
esac
}

_number_to_direction(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 0
DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=center;;
1|north|n)         DIRECTION=north;;
2|northeast|ne)    DIRECTION=northeast;;
3|east|e)          DIRECTION=east;;
4|southeast|se)    DIRECTION=southeast;;
5|south|s)         DIRECTION=south;;
6|southwest|sw)    DIRECTION=southwest;;
7|west|w)          DIRECTION=west;;
8|northwest|nw)    DIRECTION=northwest;;
*) ERROR=1 _error "Not recognized: '$DIRECTION'"
esac
}

_round_up_and_down(){  ##+++2018-01-08
echo "_round_up_and_down:$1" >&2
               #123
STELLEN=${#1}  #3
echo "STELLE=$STELLEN" >&2

LETZTSTELLE=${1:$((STELLEN-1))} #123:2
echo "LETZTSTELLE=$LETZTSTELLE" >&2

VORLETZTSTELLE=${1:$((STELLEN-2)):1} #123:1:1
echo "VORLETZTSTELLE=$VORLETZTSTELLE" >&2

GERUNDET_BASIS=${1:0:$((STELLEN-1))} #123:0:2
echo "GERUNDET_BASIS=$GERUNDET_BASIS" >&2

case $LETZTSTELLE in
0)     GERUNDET="${GERUNDET_BASIS}0";;
[5-9]) GERUNDET="$((GERUNDET_BASIS+1))0";;
[1-4]) GERUNDET="${GERUNDET_BASIS}0";;
*) :;;
esac

echo $GERUNDET
}

_set_sync_sleep(){
_debug "_set_sync_sleep:$*"

PL_SPEED1=${1:-$PL_SPEED1}
PL_SPEED1=${PL_SPEED1:-50}

  if test "$PL_SPEED1" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$PL_SPEED1" -gt 55; then
SLEEP=0.5; DELAY_DRAWINFO=1.1; TMOUT=1
elif test "$PL_SPEED1" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$PL_SPEED1" -gt 45; then
SLEEP=0.7; DELAY_DRAWINFO=1.4; TMOUT=1
elif test "$PL_SPEED1" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$PL_SPEED1" -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0; TMOUT=2
elif test "$PL_SPEED1" -gt 30; then
SLEEP=1.5; DELAY_DRAWINFO=3.0; TMOUT=2
elif test "$PL_SPEED1" -gt 25; then
SlEEP=2.0; DELAY_DRAWINFO=4.0; TMOUT=2
elif test "$PL_SPEED1" -gt 20; then
SlEEP=2.5; DELAY_DRAWINFO=5.0; TMOUT=2
elif test "$PL_SPEED1" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0; TMOUT=2
elif test "$PL_SPEED1" -gt 10; then
SLEEP=4.0; DELAY_DRAWINFO=8.0; TMOUT=2
elif test "$PL_SPEED1" -ge 0;  then
SLEEP=5.0; DELAY_DRAWINFO=10.0; TMOUT=2
elif test "$PL_SPEED1" = "";   then
_draw 3 "WARNING: Could not set player speed. Using defaults."
else
_exit 1 "ERROR while processing player speed."
fi

_info "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

_get_player_speed(){
_debug "_get_player_speed:$*"

if test "$1" = '-l'; then
 spdcnt=$((spdcnt+1))
 test "$spdcnt" -ge ${COUNT_CHECK_FOOD:-10} || return 1
 spdcnt=0
fi

_draw 5 "Processing Player's speed..."

local ANSWER OLD_ANSWER PL_SPEED
ANSWER=
OLD_ANSWER=

echo request stat cmbt # only one line

while :; do
read -t $TMOUT ANSWER
_log "$REQUEST_LOG" "request stat cmbt:$ANSWER"
_msg 7 "$ANSWER"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
test "$ANSWER" && PL_SPEED0=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED=${PL_SPEED0:-$PL_SPEED}
PL_SPEED=${PL_SPEED:-50000} # 0.50

case ${#PL_SPEED} in
6) PL_SPEED1="${PL_SPEED:0:4}"; PL_SPEED1=`dc $PL_SPEED1 1000 \/ p`;;
5) PL_SPEED1="0.${PL_SPEED:0:3}";;
4) PL_SPEED1="0.0.${PL_SPEED:0:2}";;
*) :;;
esac

_msg 7 "Player speed is '$PL_SPEED1'"

PL_SPEED_PRE="${PL_SPEED1%.*}."
PL_SPEED_POST="${PL_SPEED1##*.}"
PL_SPEED_POST=`_round_up_and_down $PL_SPEED_POST`
_msg 7 "Rounded Player speed is '$PL_SPEED_POST'"
PL_SPEED_POST=${PL_SPEED_POST:0:2}
_msg 7 "Rounded Player speed is '$PL_SPEED_POST'"

PL_SPEED1="${PL_SPEED_PRE}${PL_SPEED_POST}"
_msg 7 "Rounded Player speed is '$PL_SPEED1'"

PL_SPEED1=`echo "$PL_SPEED1" | sed 's!\.!!g;s!^0*!!'`
_msg 6 "Using player speed '$PL_SPEED1'"

_draw 6 "Done."
return 0
}

_prepare_rod_of_recall(){
# *** Unreadying rod of word of recall - just in case *** #
_debug "_prepare_rod_of_recall:$*"

local RECALL OLD_REPLY REPLY

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t $TMOUT
_log "$REPLY_LOG" "_prepare_rod_of_recall:request items actv:$REPLY"
case $REPLY in
*rod*of*word*of*recall*) RECALL=1;;
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , _emergency_exit applies again
_is 1 1 apply -u rod of word of recall
fi

_draw 6 "Done."
}

#** we may get attacked and die **#
_check_hp_and_return_home(){
_debug "_check_hp_and_return_home:$*"

hpcnt=$((hpcnt+1))
test "$hpcnt" -lt $COUNT_CHECK_FOOD && return
hpcnt=0

local REPLY

local currHP currHPMin
currHP=$1
currHPMin=$2

currHP=${currHP:-$HP}
currHPMin=${HP_MIN_DEF:-$((MHP/10))}

_msg 7 "currHP=$currHP currHPMin=$currHPMin"
if test "$currHP" -le $currHPMin; then

_empty_message_stream
_is 1 1 apply -u rod of word of recall
_is 1 1 apply -a rod of word of recall
_empty_message_stream

_is 1 1 fire center ## TODO: check if already applied and in inventory
_is 1 1 fire_stop
_empty_message_stream

_unwatch $DRAWINFO
exit
fi

unset HP
}

_is(){
    _debug "issue $*"
    echo issue "$@"
    sleep 0.2
}

_drop(){
 _sound 0 drip &
 _is 1 1 drop "$@"
}

###END###
HAVE_FUNCS_COMMON=1