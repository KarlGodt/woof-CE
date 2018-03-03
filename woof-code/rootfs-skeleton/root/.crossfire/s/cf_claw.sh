#!/bin/sh

# 2018-02-10
# cf_claw.sh :
# script to level up the skill clawing

VERSION=0.0 # Initial version,
VERSION=1.0 # release ready 2018-02-11
VERSION=2.0 # made library cf_funcs_*.sh ready
VERSION=3.0 # add healing codes, more logging
VERSION=3.1 # exit early if already running or no DRAWINFO

HEAL_ITEM='rod of heal'

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
MY_DIR=${MY_SELF%/*}

_say_help_stdalone(){
_draw_stdalone 6  "$MY_BASE"
_draw_stdalone 7  "Script to fire killing monsters"
_draw_stdalone 7  "by skill clawing."
_draw_stdalone 2  "To be used in the crossfire roleplaying game client."
_draw_stdalone 6  "Syntax:"
_draw_stdalone 7  "$0 <<NUMBER>> <<Options>>"
_draw_stdalone 8  "Options:"
_draw_stdalone 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw_stdalone 10 "-C # :like above, just make NUMBER loop rounds."
_draw_stdalone 9  "-A # :Number of attack attempts per spot."
_draw_stdalone 9  "-B : brace character."
_draw_stdalone 9  "-Z : turn anti-clockwise."
_draw_stdalone 8  "-D word :Direction to fire to,"
_draw_stdalone 8  " as n, ne, e, se, s, sw, w, nw."
_draw_stdalone 8  " If no direction, turns clockwise all around on the spot."
_draw_stdalone 11 "-V   :Print version information."
_draw_stdalone 10 "-d   :Print debugging to msgpane."
_draw_stdalone 10 "-L   :Turn on logging."
exit ${1:-2}
}

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to fire killing monsters"
_draw 7  "by skill clawing."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 6  "Syntax:"
_draw 7  "$0 <<NUMBER>> <<Options>>"
_draw 8  "Options:"
_draw 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw 10 "-C # :like above, just make NUMBER loop rounds."
_draw 9  "-A # :Number of attack attempts per spot."
_draw 9  "-B : brace character."
_draw 9  "-Z : turn anti-clockwise."
_draw 8  "-D word :Direction to fire to,"
_draw 8  " as n, ne, e, se, s, sw, w, nw."
_draw 8  " If no direction, turns clockwise all around on the spot."
_draw 11 "-V   :Print version information."
_draw 10 "-d   :Print debugging to msgpane."
_draw 10 "-L   :Turn on logging."
exit ${1:-2}
}

_say_version_stdalone(){
_draw_stdalone 6 "$MY_BASE Version:$VERSION"
exit ${1:-2}
}

_set_global_variables_stdalone(){
LOGGING=${LOGGING:-''}  #bool, set to ANYTHING ie "1" to enable, empty to disable
#DEBUG=${DEBUG:-''}      #bool, set to ANYTHING ie "1" to enable, empty to disable
MSGLEVEL=${MSGLEVEL:-6} #integer 1 emergency - 7 debug
#case $MSGLEVEL in
#7) DEBUG=${DEBUG:-1};; 6) INFO=${INFO:-1};; 5) NOTICE=${NOTICE:-1};; 4) WARN=${WARN:-1};;
#3) ERROR=${ERROR:-1};; 2) ALERT=${ALERT:-1};; 1) EMERG=${EMERG:-1};;
#esac
DEBUG=1; INFO=1; NOTICE=1; WARN=1; ERROR=1; ALERT=1; EMERG=1; Q=-q; VERB=-v
case $MSGLEVEL in
7) unset Q;; 6) unset DEBUG Q;; 5) unset DEBUG INFO VERB;; 4) unset DEBUG INFO NOTICE VERB;;
3) unset DEBUG INFO NOTICE WARN VERB;; 2) unset DEBUG INFO NOTICE WARN ERROR VERB;;
1) unset DEBUG INFO NOTICE WARN ERROR ALERT VERB;;
*) _error_stdalone "MSGLEVEL variable not set from 1 - 7";;
esac

TMOUT=${TMOUT:-1}      # read -t timeout, integer, seconds
SLEEP=${SLEEP:-1}      #default sleep value, float, seconds, refined in _get_player_speed()
DELAY_DRAWINFO=${DELAY_DRAWINFO:-2}  #default pause to sync, float, seconds, refined in _get_player_speed()

DRAWINFO=${DRAWINFO:-drawinfo} #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
FUNCTION_CHECK_FOR_SPACE=_check_for_space_stdalone # request map pos works
case $* in
*-version" "*) CLIENT_VERSION="$2"
case $CLIENT_VERSION in 0.*|1.[0-9].*|1.1[0-2].*)
# Some older clients use both formattings by drawinfo and drawextinfo,
# especially the gtk+-2.0 clients v1.11.0 and earlier.
# So setting the DRAWINFO variable here is of no real use.
# _check_drawinfo() should take care of this now.
DRAWINFO=drawextinfo #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
                     #     except use_skill alchemy :watch drawinfo 0 The cauldron emits sparks.
                     # and except apply             :watch drawinfo 0 You open cauldron.
                     #
                     # and probably more ...? TODO!
FUNCTION_CHECK_FOR_SPACE=_check_for_space_old_client_stdalone # needs request map near
;;
esac
;;
esac

COUNT_CHECK_FOOD=${COUNT_CHECK_FOOD:-10} # number between attempts to check foodlevel.
                    #  1 would mean check every single time, which is too much
EAT_FOOD=${EAT_FOOD:-waybread}   # set to desired food to eat ie food, mushroom, booze, .. etc.
FOOD_DEF=haggis     # default
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
    INV_LOG="$TMP_DIR"/"$MY_BASE".$$.inv
  ERROR_LOG="$TMP_DIR"/"$MY_BASE".$$.err
exec 2>>"$ERROR_LOG"
}

_check_if_already_running_ps_stdalone(){

local lPROGS=`ps -o pid,ppid,args | grep -w $PPID | grep -v -w $$`
__debug_stdalone "$lPROGS"
lPROGS=`echo "$lPROGS" | grep -vE "^$PPID[[:blank:]]+|^[[:blank:]]+$PPID[[:blank:]]+" | grep -vE '<defunct>|grep'`
__debug_stdalone "$lPROGS"
test ! "$lPROGS"
}

_say_start_msg_stdalone(){
# *** Here begins program *** #
_draw_stdalone 2 "$0 has started.."
_draw_stdalone 2 "PID is $$ - parentPID is $PPID"

_check_if_already_running_ps_stdalone || _exit_stdalone 1 "Another $MY_BASE is already running."
_check_drawinfo_stdalone || _exit_stdalone 1 "Unable to fetch the DRAWINFO variable. Please try again."

# *** Check for parameters *** #
_draw_stdalone 5 "Checking the parameters ($*)..."
}

__check_drawinfo_stdalone(){  ##+++2018-01-08
_debug_stdalone "__check_drawinfo_stdalone:$*"

oDEBUG=$DEBUG;       DEBUG=${DEBUG:-''}
oLOGGING=$LOGGING; LOGGING=${LOGGING:-1}

_draw_stdalone 2 "Checking drawinfo ..."

echo watch

while :;
do

# I use search here to provoke
# a response from the server
# like You search the area.
# It could be something else,
# but I have no better idea for the moment.
_is_stdalone 0 0 search
_is_stdalone 0 0 examine

 unset cnt0 TICKS
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log_stdalone "$REPLY_LOG" "__check_drawinfo_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

 case $REPLY in
 *drawinfo*'You search'*|*drawinfo*'You spot'*)       DRAWINFO0=drawinfo;    break 2;;
 *drawextinfo*'You search'*|*drawextinfo*'You spot'*) DRAWINFO0=drawextinfo; break 2;;
 *drawinfo*'That is'*|*drawinfo*'Those are'*)         DRAWINFO0=drawinfo;    break 2;;
 *drawextinfo*'That is'*|*drawextinfo*'Those are'*)   DRAWINFO0=drawextinfo; break 2;;
 *drawinfo*'This is'*|*drawinfo*'These are'*)         DRAWINFO0=drawinfo;    break 2;;
 *drawextinfo*'This is'*|*drawextinfo*'These are'*)   DRAWINFO0=drawextinfo; break 2;;
 *tick*) TICKS=$((TICKS+1)); test "$TICKS" -gt 19 && break 1;;
 '') break 1;;
 *) :;;
 esac

 sleep 0.001
 done

_sleep_stdalone
done

echo unwatch
_empty_message_stream_stdalone
unset cnt0

test "$DRAWINFO0" = "$DRAWINFO" || {
    _msg_stdalone 5 "Changing internally from $DRAWINFO to $DRAWINFO0"
    DRAWINFO=$DRAWINFO0
}

DEBUG=$oDEBUG
LOGGING=$oLOGGING
_draw_stdalone 6 "Done."
test "$DRAWINFO"
}

_check_drawinfo_stdalone(){  ##+++2018-02-18
_debug_stdalone "_check_drawinfo_stdalone:$*"

oDEBUG=$DEBUG;       DEBUG=${DEBUG:-''}
oLOGGING=$LOGGING; LOGGING=${LOGGING:-1}

_draw_stdalone 2 "Checking drawinfo ..."

echo watch

while :;
do

# I use search here to provoke
# a response from the server
_is_stdalone 1 1 save
_is_stdalone 1 1 ready_skill xxx

 unset cnt0 TICKS
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log_stdalone "$REPLY_LOG" "_check_drawinfo_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

 case $REPLY in
 *drawinfo*)         HAVE_DRAWINFO=drawinfo;;
 *drawextinfo*)   HAVE_DRAWEXTINFO=drawextinfo;;
 *tick*) TICKS=$((TICKS+1)); test "$TICKS" -gt 39 && break 2;;  # 5 seconds
 '') break 1;;
 *) :;;
 esac

 sleep 0.001
 done

_sleep_stdalone
done

echo unwatch
_empty_message_stream_stdalone
unset cnt0

_msg_stdalone 5 "Client recognizes '$HAVE_DRAWINFO' '$HAVE_DRAWEXTINFO'"
DRAWINFO="$HAVE_DRAWINFO $HAVE_DRAWEXTINFO"
DRAWINFO=`echo $DRAWINFO`

DEBUG=$oDEBUG
LOGGING=$oLOGGING
_draw_stdalone 6 "Done."
test "$DRAWINFO"
}

_tell_script_time_stdalone(){
test "$TIMEA" || return 1

 TIMEE=`date +%s`
 TIME=$((TIMEE-TIMEA))
 TIMEM=$((TIME/60))
 TIMES=$(( TIME - (TIMEM*60) ))
 _draw_stdalone 4 "Loop of script had run a total of $TIMEM minutes and $TIMES seconds."
}

_say_script_time_stdalone(){ ##+++2018-01-07
TIME_ELAPSED=`ps -o pid,etime,args | grep -w "$$" | grep -vwE "grep|ps|${TMP_DIR:-/tmp}"`
__debug_stdalone "$TIME_ELAPSED"
TIME_ELAPSED=`echo "$TIME_ELAPSED" | awk '{print $2}'`
__debug_stdalone "$TIME_ELAPSED"
case $TIME_ELAPSED in
*:*:*) _draw_stdalone 5 "Script had run a time of $TIME_ELAPSED h:m:s .";;
*:*)   _draw_stdalone 5 "Script had run a time of $TIME_ELAPSED m:s .";;
*)     _draw_stdalone 5 "Script had run a time of $TIME_ELAPSED s .";;
esac
}

_say_end_msg_stdalone(){
# *** Here ends program *** #
_is_stdalone 1 1 fire_stop
test -f "$HOME"/.crossfire/sounds/su-fanf.raw && aplay $Q "$HOME"/.crossfire/sounds/su-fanf.raw & aPID=$!

_tell_script_time_stdalone || _say_script_time_stdalone

test "$DEBUG" || { test -s "$ERROR_LOG" || rm -f "$ERROR_LOG"; }
test "$DEBUG" -o "$INFO" || rm -f "$TMP_DIR"/*.$$*

test "$aPID" && wait $aPID
_draw_stdalone 2  "$0 $$ has finished."
}

# *** EXIT FUNCTIONS *** #
_exit_stdalone(){
case $1 in
[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) RV=$1; shift;;
esac

#_move_back_and_forth_stdalone 2 ##unused to move in this script
_sleep_stdalone
test "$*" && _draw_stdalone 3 $@
_draw_stdalone 3 "Exiting $0. PID was $$"
#echo unwatch
_unwatch_stdalone ""
_beep_std_stdalone
test ${RV//[0-9]/} && RV=3
exit ${RV:-0}
}

_just_exit_stdalone(){
_draw_stdalone 3 "Exiting $0."
_unwatch_stdalone
_beep_std_stdalone
exit ${1:-0}
}

_emergency_exit_stdalone(){
RV=${1:-4}; shift
local lRETURN_ITEM=${*:-"$RETURN_ITEM"}

case $lRETURN_ITEM in
''|*rod*|*staff*|*wand*|*horn*)
_is_stdalone 1 1 apply -u ${lRETURN_ITEM:-'rod of word of recall'}
_is_stdalone 1 1 apply -a ${lRETURN_ITEM:-'rod of word of recall'}
_is_stdalone 1 1 fire center
_is_stdalone 1 1 fire_stop
;;
*scroll*) _is_stdalone 1 1 apply ${lRETURN_ITEM};;
*) invoke "$lRETURN_ITEM";; # assuming spell
esac

_draw_stdalone 3 "Emergency Exit $0 !"
_unwatch_stdalone

# apply bed of reality
 sleep 6
_is_stdalone 1 1 apply

_beep_std_stdalone
exit ${RV:-0}
}

_draw_stdalone(){
    local lCOLOUR="${1:-$COLOUR}"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    echo draw $lCOLOUR $@ # no double quotes here,
# multiple lines are drawn using __draw below
}

__draw_stdalone(){
case $1 in [0-9]|1[0-2])
    lCOLOUR="$1"; shift;; esac
    local lCOLOUR=${lCOLOUR:-1} #set default
dcnt=0
echo -e "$*" | while read line
do
dcnt=$((dcnt+1))
    echo draw $lCOLOUR "$line"
done
unset dcnt line
}

_debug_stdalone(){
test "$DEBUG" || return 0
    echo draw 10 "DEBUG:"$@
}

__debug_stdalone(){  ##+++2018-01-06
test "$DEBUG" || return 0
cnt=0
echo "$*" | while read line
do
cnt=$((cnt+1))
    echo draw 3 "__DEBUG:$cnt:$line"
done
unset cnt line
}

__msg_stdalone(){  ##+++2018-01-08
local LVL=$1; shift
case $LVL in
7|debug) test "$DEBUG"  && _debug_stdalone  "$*";;
6|info)  test "$INFO"   && _info_stdalone   "$*";;
5|note)  test "$NOTICE" && _notice_stdalone "$*";;
4|warn)  test "$WARN"   && _warn_stdalone   "$*";;
3|err)   test "$ERROR"  && _error_stdalone  "$*";;
2|alert) test "$ALERT"  && _alert_stdalone  "$*";;
1|emerg) test "$EMERG"  && _emerg_stdalone  "$*";;
*) _debug_stdalone "$*";;
esac
}

_msg_stdalone(){  ##+++2018-01-08
local LVL=$1; shift
case $LVL in
7|debug) _debug_stdalone  "$*";;
6|info)  _info_stdalone   "$*";;
5|note)  _notice_stdalone "$*";;
4|warn)  _warn_stdalone   "$*";;
3|err)   _error_stdalone  "$*";;
2|alert) _alert_stdalone  "$*";;
1|emerg) _emerg_stdalone  "$*";;
*) _debug_stdalone "$*";;
esac
}

_info_stdalone(){
test "$INFO" || return 0
    echo draw 7 "INFO:"$@
}

_notice_stdalone(){
test "$NOTICE" || return 0
    echo draw 2 "NOTICE:"$@
}

_warn_stdalone(){
test "$WARN" || return 0
    echo draw 6 "WARNING:"$@
}

_error_stdalone(){
test "$ERROR" || return 0
    echo draw 4 "ERROR:"$@
}

_alert_stdalone(){
test "$ALERT" || return 0
    echo draw 3 "ALERT:"$@
}

_ermerg_stdalone(){
test "$EMERG" || return 0
    echo draw 3 "EMERGENCY:"$@
}

_log_stdalone(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOGFILE"
   echo "$*" >>"$lFILE"
}

_set_sound_stdalone(){
if test -e "$SOUND_DIR"/${1}.raw; then
 alias _sound_stdalone=_sound_stdalone
else
 alias _sound_stdalone=_beep_std_stdalone
fi
}

_sound_stdalone(){
    local lDUR
test "$2" && { lDUR="$1"; shift; }
lDUR=${lDUR:-0}
#test -e "$SOUND_DIR"/${1}.raw && \
#           aplay $Q $VERB -d $lDUR "$SOUND_DIR"/${1}.raw
if test -e "$SOUND_DIR"/${1}.raw; then
 aplay $Q $VERB -d $lDUR "$SOUND_DIR"/${1}.raw
else
 _beep_std_stdalone
fi
}

_beep_std_stdalone(){
beep -l 1000 -f 700
}

_empty_message_stream_stdalone(){
local lREPLY
while :;
do
read -t $TMOUT lREPLY
_log_stdalone "$REPLY_LOG" "_empty_message_stream_stdalone:$lREPLY"
test "$lREPLY" || break
case $lREPLY in
*scripttell*break*)     break ${lREPLY##*?break};;
*scripttell*exit*)      _exit_stdalone 1 $lREPLY;;
*'YOU HAVE DIED.'*) _just_exit_stdalone;;
esac
_msg_stdalone 7 "_empty_message_stream_stdalone:$lREPLY"
unset lREPLY
 sleep 0.01
done
}

_watch_stdalone(){
echo unwatch ${*:-$DRAWINFO}
sleep 0.4
echo   watch ${*:-$DRAWINFO}
}

_unwatch_stdalone(){
echo unwatch ${*:-$DRAWINFO}
}

_watch_stdalone(){
case $* in
'')
 echo unwatch
 sleep 0.2
 echo watch;;
*)
for i in $*; do
 echo unwatch $i
 sleep 0.2
 echo   watch $i
done;;
esac
}

_unwatch_stdalone(){
case $* in
'') echo unwatch;;
*)
for i in $*; do
 echo unwatch $i
done;;
esac
}

_is_stdalone(){
# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.
    _debug_stdalone "_is_stdalone:$*"
    _log_stdalone   "_is_stdalone:$*"
    echo issue "$@"
    sleep 0.2
}

__is_stdalone(){
_msg_stdalone 7 "__is_stdalone:$*"
_log_stdalone "__is_stdalone:$*"
Z1=$1; shift
Z2=$1; shift
_msg_stdalone 7 "$*"
echo issue $Z1 $Z2 $*
unset Z1 Z2
sleep 0.2
}


_check_counter_stdalone(){
ckc=$((ckc+1))
test "$ckc" -lt ${COUNT_CHECK_FOOD:-11} && return 1
ckc=0
return 0
}

_check_skill_available_stdalone(){
_debug_stdalone "_check_skill_available_stdalone:$*"
_log_stdalone   "_check_skill_available_stdalone:$*"

local lSKILL=${*:-"$SKILL"}
test "$lSKILL" || return 254

local lRV=

_empty_message_stream_stdalone
_watch_stdalone $DRAWINFO
_is_stdalone 1 1 ready_skill punching  # force response, because when not changing
_is_stdalone 1 1 ready_skill "$lSKILL" # range attack, no message is printed

while :; do unset REPLY
read -t $TMOUT
  _log_stdalone "$REPLY_LOG" "_check_skill_available_stdalone:$REPLY"
_debug_stdalone "$REPLY"

 case $REPLY in
 '') break 1;;
 *'Readied skill: '"$lSKILL"*) lRV=0; break 1;;   # if (!(aflags & AP_NOPRINT))
 # server/apply.c:          new_draw_info_format (NDI_UNIQUE, 0, who, "Readied skill: %s.",
 # server/apply.c-                    op->skill? op->skill:op->name);
 *'Unable to find skill '*)    lRV=1; break 1;; # new_draw_info_format(NDI_UNIQUE, 0, op,
 # server/skill_util.c:          "Unable to find skill %s", string);
 # server/skill_util.c- return 0;
 *scripttell*break*)     break ${REPLY##*?break};;
 *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac

sleep 0.01
done

_unwatch_stdalone $DRAWINFO
_empty_message_stream_stdalone

return ${lRV:-3}
}

_request_stat_cmbt_stdalone(){
#Return wc,ac,dam,speed,weapon_sp
_debug_stdalone "_request_stat_cmbt_stdalone:$*"
_log_stdalone   "_request_stat_cmbt_stdalone:$*"

_empty_message_stream_stdalone

unset WC AC DAM SPEED WP_SPEED REST
echo request stat cmbt
read -t ${TMOUT:-1} r s c WC AC DAM SPEED WP_SPEED REST
#request stat cmbt %d %d %d %d %d\n",
#cpl.stats.wc,cpl.stats.ac,cpl.stats.dam,cpl.stats.speed,cpl.stats.weapon_sp)
 _log_stdalone "$REQUEST_LOG" "_request_stat_cmbt_stdalone $*:$WC $AC $DAM $SPEED $WP_SPEED $REST"
 _msg_stdalone 7 "$WC $AC $DAM $SPEED $WP_SPEED $REST"

PL_SPEED=$SPEED
test "x$WC" != 'x' -a "x$AC" != 'x' -a "x$DAM" != 'x' -a "x$SPEED" != 'x' -a "x$WP_SPEED" != 'x'
}


__get_player_speed_stdalone(){
_debug_stdalone "__get_player_speed_stdalone:$*"
_log_stdalone   "__get_player_speed_stdalone:$*"

if test "$1" = '-l'; then # loop counter
 _check_counter_stdalone || return 1
 shift
fi

_draw_stdalone 5 "Processing Player's speed..."

 _request_stdalone stat cmbt
 test "$ANSWER" && PL_SPEED0=`echo "$ANSWER" | awk '{print $7}'`
PL_SPEED=${PL_SPEED0:-$PL_SPEED}
PL_SPEED=${PL_SPEED:-50000} # 0.50

_player_speed_to_human_readable_stdalone $PL_SPEED
_msg_stdalone 6 "Using player speed '$PL_SPEED1'"

_draw_stdalone 6 "Done."
return 0
}

_get_player_speed_stdalone(){
_debug_stdalone "_get_player_speed_stdalone:$*"
_log_stdalone   "_get_player_speed_stdalone:$*"

if test "$1" = '-l'; then # loop counter
 _check_counter_stdalone || return 1
 shift
fi

_draw_stdalone 5 "Processing Player's speed..."

_request_stat_cmbt_stdalone
PL_SPEED=${PL_SPEED:-50000} # 0.50

_player_speed_to_human_readable_stdalone $PL_SPEED
_msg_stdalone 6 "Using player speed '$PL_SPEED1'"

_draw_stdalone 6 "Done."
return 0
}

_player_speed_to_human_readable_stdalone(){
_debug_stdalone "_player_speed_to_human_readable_stdalone:$*"
_log_stdalone   "_player_speed_to_human_readable_stdalone:$*"

local lPL_SPEED=${1:-$PL_SPEED}
test "$lPL_SPEED" || return 254

local PL_SPEED_PRE PL_SPEED_POST

oLC_NUMERIC=$oLC_NUMERIC
LC_NUMERIC=C
case ${#lPL_SPEED} in
7) PL_SPEED1="${lPL_SPEED:0:5}"; PL_SPEED1=`dc $PL_SPEED1 1000 \/ p`;;
6) PL_SPEED1="${lPL_SPEED:0:4}"; PL_SPEED1=`dc $PL_SPEED1 1000 \/ p`;;
5) PL_SPEED1="0.${lPL_SPEED:0:3}";;
4) PL_SPEED1="0.0.${lPL_SPEED:0:2}";;
*) :;;
esac

_msg_stdalone 7 "Player speed is '$PL_SPEED1'"

case $PL_SPEED1 in
*.*)
PL_SPEED_PRE="${PL_SPEED1%.*}."
PL_SPEED_POST="${PL_SPEED1##*.}"
;;
*,*)
PL_SPEED_PRE="${PL_SPEED1%,*},"
PL_SPEED_POST="${PL_SPEED1##*,}"
;;
[0-9]*)
PL_SPEED_PRE="${PL_SPEED1}."
PL_SPEED_POST=00
;;
esac
case ${#PL_SPEED_POST} in 1) PL_SPEED_POST="${PL_SPEED_POST}0";; esac

PL_SPEED_POST=`_round_up_and_down_stdalone $PL_SPEED_POST`
_msg_stdalone 7 "Rounded Player speed is '${PL_SPEED_PRE}$PL_SPEED_POST'"
PL_SPEED_POST=${PL_SPEED_POST:0:2}
_msg_stdalone 7 "Rounded Player speed is '${PL_SPEED_PRE}$PL_SPEED_POST'"

PL_SPEED1="${PL_SPEED_PRE}${PL_SPEED_POST}"
_msg_stdalone 7 "Rounded Player speed is '$PL_SPEED1'"

PL_SPEED1=`echo "$PL_SPEED1" | sed 's!\.!!g;s!\,!!g;s!^0*!!'`
LC_NUMERIC=$oLC_NUMERIC
}

_round_up_and_down_stdalone(){  ##+++2018-01-08
[ "$DEBUG" ] && echo "_round_up_and_down_stdalone:$1" >&2
_log_stdalone "_round_up_and_down_stdalone:$*"
               #123
STELLEN=${#1}  #3
[ "$DEBUG" ] && echo "STELLEN=$STELLEN" >&2

LETZTSTELLE=${1:$((STELLEN-1))} #123:2
[ "$DEBUG" ] && echo "LETZTSTELLE=$LETZTSTELLE" >&2

VORLETZTSTELLE=${1:$((STELLEN-2)):1} #123:1:1
[ "$DEBUG" ] && echo "VORLETZTSTELLE=$VORLETZTSTELLE" >&2

GERUNDET_BASIS=${1:0:$((STELLEN-1))} #123:0:2
[ "$DEBUG" ] && echo "GERUNDET_BASIS=$GERUNDET_BASIS" >&2

case $LETZTSTELLE in
0)     GERUNDET="${GERUNDET_BASIS}0";;
[5-9]) GERUNDET="$((GERUNDET_BASIS+1))0";;
[1-4]) GERUNDET="${GERUNDET_BASIS}0";;
*) :;;
esac

echo $GERUNDET
}

_set_sync_sleep_stdalone(){
_debug_stdalone "_set_sync_sleep_stdalone:$*"
_log_stdalone   "_set_sync_sleep_stdalone:$*"

local lPL_SPEED=${1:-$PL_SPEED}
lPL_SPEED=${lPL_SPEED:-50000}

  if test "$lPL_SPEED" -gt 60000; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$lPL_SPEED" -gt 55000; then
SLEEP=0.5; DELAY_DRAWINFO=1.1; TMOUT=1
elif test "$lPL_SPEED" -gt 50000; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$lPL_SPEED" -gt 45000; then
SLEEP=0.7; DELAY_DRAWINFO=1.4; TMOUT=1
elif test "$lPL_SPEED" -gt 40000; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$lPL_SPEED" -gt 35000; then
SLEEP=1.0; DELAY_DRAWINFO=2.0; TMOUT=2
elif test "$lPL_SPEED" -gt 30000; then
SLEEP=1.5; DELAY_DRAWINFO=3.0; TMOUT=2
elif test "$lPL_SPEED" -gt 25000; then
SlEEP=2.0; DELAY_DRAWINFO=4.0; TMOUT=2
elif test "$lPL_SPEED" -gt 20000; then
SlEEP=2.5; DELAY_DRAWINFO=5.0; TMOUT=2
elif test "$lPL_SPEED" -gt 15000; then
SLEEP=3.0; DELAY_DRAWINFO=6.0; TMOUT=2
elif test "$lPL_SPEED" -gt 10000; then
SLEEP=4.0; DELAY_DRAWINFO=8.0; TMOUT=2
elif test "$lPL_SPEED" -ge 0;  then
SLEEP=5.0; DELAY_DRAWINFO=10.0; TMOUT=2
elif test "$lPL_SPEED" = "";   then
_draw_stdalone 3 "WARNING: Could not set player speed. Using defaults."
else
_exit_stdalone 1 "ERROR while processing player speed."
fi

_info_stdalone "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

__set_sync_sleep_stdalone(){
_debug_stdalone "__set_sync_sleep_stdalone:$*"
_log_stdalone   "__set_sync_sleep_stdalone:$*"

local lPL_SPEED=${1:-$PL_SPEED1}
lPL_SPEED=${lPL_SPEED:-50}

  if test "$lPL_SPEED" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$lPL_SPEED" -gt 55; then
SLEEP=0.5; DELAY_DRAWINFO=1.1; TMOUT=1
elif test "$lPL_SPEED" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$lPL_SPEED" -gt 45; then
SLEEP=0.7; DELAY_DRAWINFO=1.4; TMOUT=1
elif test "$lPL_SPEED" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$lPL_SPEED" -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0; TMOUT=2
elif test "$lPL_SPEED" -gt 30; then
SLEEP=1.5; DELAY_DRAWINFO=3.0; TMOUT=2
elif test "$lPL_SPEED" -gt 25; then
SlEEP=2.0; DELAY_DRAWINFO=4.0; TMOUT=2
elif test "$lPL_SPEED" -gt 20; then
SlEEP=2.5; DELAY_DRAWINFO=5.0; TMOUT=2
elif test "$lPL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0; TMOUT=2
elif test "$lPL_SPEED" -gt 10; then
SLEEP=4.0; DELAY_DRAWINFO=8.0; TMOUT=2
elif test "$lPL_SPEED" -ge 0;  then
SLEEP=5.0; DELAY_DRAWINFO=10.0; TMOUT=2
elif test "$lPL_SPEED" = "";   then
_draw_stdalone 3 "WARNING: Could not set player speed. Using defaults."
else
_exit_stdalone 1 "ERROR while processing player speed."
fi

_info_stdalone "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

_sleep_stdalone(){
SLEEP=${SLEEP//,/.}
sleep ${SLEEP:-1}
}

_direction_to_number_stdalone(){ # cf_funcs_common.sh
local lDIRECTION=${1:-$DIRECTION}
test "$lDIRECTION" || return 0

lDIRECTION=`echo "$lDIRECTION" | tr '[A-Z]' '[a-z]'`
case $lDIRECTION in
0|center|centre|c) DIRECTION=0; DIRB=;          DIRF=;;
1|north|n)         DIRECTION=1; DIRB=south;     DIRF=north;;
2|northeast|ne)    DIRECTION=2; DIRB=southwest; DIRF=northeast;;
3|east|e)          DIRECTION=3; DIRB=west;      DIRF=east;;
4|southeast|se)    DIRECTION=4; DIRB=northwest; DIRF=southeast;;
5|south|s)         DIRECTION=5; DIRB=north;     DIRF=south;;
6|southwest|sw)    DIRECTION=6; DIRB=northeast; DIRF=southwest;;
7|west|w)          DIRECTION=7; DIRB=east;      DIRF=west;;
8|northwest|nw)    DIRECTION=8; DIRB=southeast; DIRF=northwest;;
*) ERROR=1 _error_stdalone "Not recognized: '$lDIRECTION'";;
esac
DIRECTION_NUMBER=$DIRECTION
DIRN=$DIRECTION
}

_number_to_direction_stdalone(){ # cf_funcs_common.sh
local lDIRECTION=${1:-$DIRECTION}
test "$lDIRECTION" || return 0

lDIRECTION=`echo "$lDIRECTION" | tr '[A-Z]' '[a-z]'`
case $lDIRECTION in
0|center|centre|c) DIRECTION=center;    DIRN=0; DIRB=;          DIRF=;;
1|north|n)         DIRECTION=north;     DIRN=1; DIRB=south;     DIRF=north;;
2|northeast|ne)    DIRECTION=northeast; DIRN=2; DIRB=southwest; DIRF=northeast;;
3|east|e)          DIRECTION=east;      DIRN=3; DIRB=west;      DIRF=east;;
4|southeast|se)    DIRECTION=southeast; DIRN=4; DIRB=northwest; DIRF=southeast;;
5|south|s)         DIRECTION=south;     DIRN=5; DIRB=north;     DIRF=south;;
6|southwest|sw)    DIRECTION=southwest; DIRN=6; DIRB=northeast; DIRF=southwest;;
7|west|w)          DIRECTION=west;      DIRN=7; DIRB=east;      DIRF=west;;
8|northwest|nw)    DIRECTION=northwest; DIRN=8; DIRB=southeast; DIRF=northwest;;
*) ERROR=1 _error_stdalone "Not recognized: '$lDIRECTION'";;
esac
DIRECTION_NUMBER=$DIRN
}

__kill_monster_stdalone(){
_debug_stdalone "__kill_monster_stdalone:$*"
_log_stdalone   "__kill_monster_stdalone:$*"

local lATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

# TODO:
#*'You withhold your attack'*)  _set_next_direction_stdalone; break 1;;
#*'You avoid attacking '*)      _set_next_direction_stdalone; break 1;;

for i in `seq 1 1 ${lATTACKS:-1}`; do
_is_stdalone 1 1 $DIRECTION
done
_empty_message_stream_stdalone
}

_kill_monster_stdalone(){
_debug_stdalone "_kill_monster_stdalone:$*"
_log_stdalone   "_kill_monster_stdalone:$*"

local lATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

# TODO:
#*'You withhold your attack'*)  _set_next_direction_stdalone; break 1;;
#*'You avoid attacking '*)      _set_next_direction_stdalone; break 1;;

for i in `seq 1 1 ${lATTACKS:-1}`; do
_is_stdalone 1 1 fire $DIRN
_is_stdalone 1 1 fire_stop
done
_empty_message_stream_stdalone
}

_brace_stdalone(){
_debug_stdalone "_brace_stdalone:$*"
_log_stdalone   "_brace_stdalone:$*"

_watch_stdalone $DRAWINFO
while :
do
_is_stdalone 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log_stdalone "$REPLY_LOG" "_brace_stdalone:$REPLY"
 _debug_stdalone "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 2;;
 *'Not braced.'*)     break 1;;
 *scripttell*break*)     break ${REPLY##*?break};;
 *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch_stdalone $DRAWINFO
_empty_message_stream_stdalone
}

_unbrace_stdalone(){
_debug_stdalone "_unbrace_stdalone:$*"
_log_stdalone   "_unbrace_stdalone:$*"

_watch_stdalone $DRAWINFO
while :
do
_is_stdalone 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log_stdalone "$REPLY_LOG" "_unbrace_stdalone:$REPLY"
 _debug_stdalone "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 1;;
 *'Not braced.'*)     break 2;;
 *scripttell*break*)     break ${REPLY##*?break};;
 *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch_stdalone $DRAWINFO
_empty_message_stream_stdalone
}

_set_next_direction_stdalone(){
_debug_stdalone "_set_next_direction_stdalone:$*:$DIRN"
_log_stdalone   "_set_next_direction_stdalone:$*:$DIRN"

if test "$DO_CLOCKWISE"; then
 DIRN=$((DIRN-1))
 test "$DIRN" -le 0 && DIRN=8
else
 DIRN=$((DIRN+1))
 test "$DIRN" -ge 9 && DIRN=1
fi
_number_to_direction_stdalone $DIRN
_draw_stdalone 2 "Will turn to direction $DIRECTION .."
}

_check_food_level_stdalone(){
_debug_stdalone "_check_food_level_stdalone:$*"
_log_stdalone   "_check_food_level_stdalone:$*"

test "$*" && MIN_FOOD_LEVEL="$@"
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-$MIN_FOOD_LEVEL_DEF}
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-300}

local FOOD_LVL=''
local REPLY

while :;
do

_request_stat_hp_stdalone # FOOD_LVL

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 _cast_create_food_and_eat_stdalone $EAT_FOOD || _eat_food_from_inventory_stdalone $EAT_FOOD
 _request_stat_hp_stdalone
  break
else true
fi

test "$FOOD_LVL" && break

sleep 0.1
done
}

_eat_food_from_inventory_stdalone(){
_debug_stdalone "_eat_food_from_inventory_stdalone:$*"
_log_stdalone   "_eat_food_from_inventory_stdalone:$*"

local lEAT_FOOD="${@:-$EAT_FOOD}"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
test "$lEAT_FOOD" || return 254

_check_have_item_in_inventory_stdalone $lEAT_FOOD && _is_stdalone 1 1 apply $lEAT_FOOD
}

_check_have_item_in_inventory_stdalone(){
_debug_stdalone "_check_have_item_in_inventory_stdalone:$*"
_log_stdalone   "_check_have_item_in_inventory_stdalone:$*"

local oneITEM oldITEM ITEMS ITEMSA lITEM
lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

TIMEB=`date +%s`

unset oneITEM oldITEM ITEMS ITEMSA

_empty_message_stream_stdalone
echo request items inv
while :;
do
read -t ${TMOUT:-1} oneITEM
 _log_stdalone "$INV_LOG" "_check_have_item_in_inventory_stdalone:$oneITEM"
 _debug_stdalone "$oneITEM"

 case $oneITEM in
 $oldITEM|'') break 1;;
 *"$lITEM"*|*"${lITEM// /?*}"*) _draw_stdalone 7 "Got that item $lITEM in inventory.";;
 *scripttell*break*)  break ${oneITEM##*?break};;
 *scripttell*exit*)   _exit_stdalone 1 $oneITEM;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac
 ITEMS="${ITEMS}${oneITEM}\n"
 oldITEM="$oneITEM"
sleep 0.01
done
unset oldITEM oneITEM


TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_debug_stdalone 4 "Fetching Inventory List: Elapsed $TIME sec."

echo -e "$ITEMS" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"
}

_request_stat_hp_stdalone(){
#Return hp,maxhp,sp,maxsp,grace,maxgrace,food
_debug_stdalone "_request_stat_hp_stdalone:$*"
_log_stdalone   "_request_stat_hp_stdalone:$*"

_empty_message_stream_stdalone

unset HP MHP SP MSP GR MGR FOOD_LVL REST
echo request stat hp
read -t ${TMOUT:-1} r s hp HP MHP SP MSP GR MGR FOOD_LVL REST
#request stat hp %d %d %d %d %d %d %d\n",
#cpl.stats.hp,cpl.stats.maxhp,cpl.stats.sp,cpl.stats.maxsp,cpl.stats.grace,cpl.stats.maxgrace,cpl.stats.food)
 _log_stdalone "$REQUEST_LOG" "_request_stat_hp_stdalone $*:$HP $MHP $SP $MSP $GR $MGR $FOOD_LVL $REST"
 _msg_stdalone 7 "$HP $MHP $SP $MSP $GR $MGR $FOOD_LVL $REST"

MAXHP=$MHP
MAXSP=$MSP
MAXGR=$MGR
test "x$HP" != 'x' -a "x$MHP" != 'x' -a "x$SP" != 'x' -a "x$MSP" != 'x' -a "x$GR" != 'x' -a "x$MGR" != 'x' -a "x$FOOD_LVL" != 'x'
}

_cast_create_food_and_eat_stdalone(){
_debug_stdalone "_cast_create_food_and_eat_stdalone:$*"
_log_stdalone   "_cast_create_food_and_eat_stdalone:$*"

local lEAT_FOOD BUNGLE

lEAT_FOOD="${*:-$EAT_FOOD}"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
lEAT_FOOD=${lEAT_FOOD:-food}

 _set_pickup_stdalone 0

_unwatch_stdalone $DRAWINFO
_empty_message_stream_stdalone
_watch_stdalone $DRAWINFO

unset HAVE_NOT_SPELL
# TODO: Check MANA
_is_stdalone 1 1 cast create food $lEAT_FOOD
while :;
 do
 unset REPLY
 read -t $TMOUT
 _log_stdalone "$REPLY_LOG" "_cast_create_food_and_eat_stdalone:$REPLY"
 _msg_stdalone 7 "$REPLY"
 case $REPLY in
 *Cast*what*spell*) HAVE_NOT_SPELL=1; break 1;; #Cast what spell?  Choose one of:
 *ready*the*spell*)  break 1;;                  #You ready the spell create food
 '')                 break 1;;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac
sleep 0.01
done

test "$HAVE_NOT_SPELL" && return 253

_empty_message_stream_stdalone

while :;
do
_is_stdalone 1 1 fire_stop # precaution
sleep 0.1

 while :;
 do
  _check_mana_for_create_food_stdalone && break
  sleep 10
 done

# _check_mana_for_create_food_stdalone returns early
_unwatch_stdalone $DRAWINFO
_empty_message_stream_stdalone
sleep 0.2

_watch_stdalone $DRAWINFO
_is_stdalone 1 1 fire center ## TODO: handle bungling the spell
_is_stdalone 1 1 fire_stop

 while :; do
  unset BUNGLE
  read -t $TMOUT BUNGLE
  _log_stdalone "$REPLY_LOG" "_cast_create_food_and_eat_stdalone:$BUNGLE"
  _msg_stdalone 7 "BUNGLE=$BUNGLE"
  case $BUNGLE in
  *bungle*|*fumble*) break 1;;
  '') break 2;;
  *scripttell*break*) break ${BUNGLE##*?break};;
  *scripttell*exit*)  _exit_stdalone 1 $BUNGLE;;
  *'YOU HAVE DIED.'*) _just_exit_stdalone;;
  *) :;;
  esac
 sleep 0.01
 done

sleep 0.2
done

_unwatch_stdalone $DRAWINFO
_is_stdalone 1 1 fire_stop
_empty_message_stream_stdalone
_sleep_stdalone

_check_if_on_item_stdalone -l ${lEAT_FOOD:-haggis} && _is_stdalone 1 1 apply ## TODO: check if food is there on tile
_empty_message_stream_stdalone
}

_set_pickup_stdalone(){
# Usage: pickup <0-7> or <value_density> .
 _is_stdalone 1 1 pickup ${*:-0}
}

_check_if_on_item_stdalone(){
_debug_stdalone "_check_if_on_item_stdalone:$*"
_log_stdalone   "_check_if_on_item_stdalone:$*"

local DO_LOOP TOPMOST lMSG lRV
unset DO_LOOP TOPMOST lMSG lRV

while [ "$1" ]; do
case $1 in
-l) DO_LOOP=1;;
-t) TOPMOST=1;;
-lt|-tl) DO_LOOP=1; TOPMOST=1;;
*) break;;
esac
shift
done

local lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

_draw_stdalone 5 "Checking if standing on $lITEM ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream_stdalone
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log_stdalone "$ON_LOG" "_check_if_on_item_stdalone:$UNDER_ME"
_msg_stdalone 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)      _exit_stdalone 1 $REPLY;;
*'YOU HAVE DIED.'*) _just_exit_stdalone;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug_stdalone "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_ITEM=`echo "$UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}" | wc -l`

unset TOPMOST_MSG
case "$UNDER_ME_LIST" in
*"$lITEM"|*"${lITEM}s"|*"${lITEM}es"|*"${lITEM// /?*}")
 TOPMOST_MSG='some'
;;
esac
test "$TOPMOST" && { UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | tail -n1`; TOPMOST_MSG=${TOPMOST_MSG:-topmost}; }

case "$UNDER_ME_LIST" in
*"$lITEM"|*"${lITEM}s"|*"${lITEM}es"|*"${lITEM// /?*}")
   lRV=0;;
*) lMSG="You appear not to stand on $TOPMOST_MSG $lITEM!"
   lRV=1;;
esac

if test $lRV = 0; then
 case "$UNDER_ME_LIST" in
 *cursed*)
   lMSG="You appear to stand upon $TOPMOST_MSG cursed $lITEM!"
   lRV=1;;
 *damned*)
   lMSG="You appear to stand upon $TOPMOST_MSG damned $lITEM!"
   lRV=1;;
 esac
fi

test "$lRV" = 0 && return 0

_beep_std_stdalone
_draw_stdalone 3 $lMSG
test "$DO_LOOP" && return 1 || _exit_stdalone 1 $lMSG
}

_check_mana_for_create_food_stdalone(){
_debug_stdalone "_check_mana_for_create_food_stdalone:$*"
_log_stdalone   "_check_mana_for_create_food_stdalone:$*"

local lSP=${*:-$SP}
test "$lSP" || return 254

local REPLY

# This function forces drawing of
# all spells that start witch 'create'
# to the message panel and the reads the
# drawinfo lines.
# It needs the SP variable set by
# _check_food_level()
_watch_stdalone $DRAWINFO
_is_stdalone 1 0 cast create

while :;
do

read -t ${TMOUT:-1}
   _log_stdalone "$REPLY_LOG" "_check_mana_for_create_food_stdalone:$REPLY"
 _msg_stdalone 7 "_check_mana_for_create_food_stdalone:$REPLY"

 case $REPLY in
 *ready*the*spell*create*food*) return 0;;
 *create*food*)
 MANA_NEEDED=`echo "$REPLY" | awk '{print $NF}'`
 _debug_stdalone "MANA_NEEDED=$MANA_NEEDED"
 test "$lSP" -ge "$MANA_NEEDED" && return 0 || break 1
 ;;
 *'Something blocks your spellcasting.'*) _exit_stdalone 1 "Not possible on this spot.";;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') break 1;;
 *) :;;
 esac

sleep 0.01
unset REPLY
done

_unwatch_stdalone $DRAWINFO
return 1
}


#** we may get attacked and die **#
_check_hp_and_return_home_stdalone(){
_debug_stdalone "_check_hp_and_return_home_stdalone:$*"
_log_stdalone   "_check_hp_and_return_home_stdalone:$*"

local currHP currHPMin
currHP=${1:-$HP}
currHPMin=${2:-$HP_MIN_DEF}
currHPMin=${currHPMin:-$((MHP/10))}

unset HP
_msg_stdalone 7 "currHP=$currHP currHPMin=$currHPMin"
if test "$currHP" -le ${currHPMin:-20}; then
_emergency_exit_stdalone
fi
}

_do_parameters_stdalone(){
_debug_stdalone "_do_parameters_stdalone:$*"
_log_stdalone   "_do_parameters_stdalone:$*"

# dont forget to pass parameters when invoking this function
test "$*" || return 0

case $1 in
*help)    _say_help_stdalone 0;;
*version) _say_version_stdalone 0;;
--?*)  _exit_stdalone 3 "No other long options than help and version recognized.";;
--*)   _exit_stdalone 3 "Unhandled first parameter '$1' .";;
-?*) :;;
[0-9]*) NUMBER=$1
        test "${NUMBER//[[:digit:]]/}" && _exit_stdalone 3 "NUMBER '$1' is not an integer digit."
        shift;;
*) _exit_stdalone 3 "Unknown first parameter '$1' .";;
esac

# C # :Count loop rounds

# d   :debugging output
while getopts A:BC:D:LZdVhabdefgijklmnopqrstuvwxyzEFGHIJKMNOPQRSTUWXY oneOPT
do
case $oneOPT in
A) ATTACKS_SPOT=$OPTARG;;
B) DO_BRACE=1;;
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
L) LOGGING=$((LOGGING+1));;
Z) DO_CLOCKWISE=1;;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help_stdalone 0;;
V) _say_version_stdalone 0;;

'') _draw_stdalone 2 "FIXME: Empty positional parameter ...?";;
*) _draw_stdalone 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

_do_parameters(){
_debug "_do_parameters:$*"
_log   "_do_parameters:$*"

# dont forget to pass parameters when invoking this function
test "$*" || return 0

case $1 in
*help)    _say_help 0;;
*version) _say_version 0;;
--?*)  _exit 3 "No other long options than help and version recognized.";;
--*)   _exit 3 "Unhandled first parameter '$1' .";;
-?*) :;;
[0-9]*) NUMBER=$1
        test "${NUMBER//[[:digit:]]/}" && _exit 3 "NUMBER '$1' is not an integer digit."
        shift;;
*) _exit 3 "Unknown first parameter '$1' .";;
esac

# C # :Count loop rounds

# d   :debugging output
while getopts A:BC:D:LZdVhabdefgijklmnopqrstuvwxyzEFGHIJKMNPOQRSTUWXY oneOPT
do
case $oneOPT in
A) ATTACKS_SPOT=$OPTARG;;
B) DO_BRACE=1;;
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
L) LOGGING=$((LOGGING+1));;
Z) DO_CLOCKWISE=1;;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

__check_hp_stdalone(){
_debug_stdalone "__check_hp_stdalone:$*"
_log_stdalone   "__check_hp_stdalone:$*"

while :; do
 unset HP MAXHP
 _request_stat_hp_stdalone
 case $HP in '') :;; *) break 1;; esac
done

  if test $MAXHP -le 20; then return 0
elif test $HP -le 100; then
     test $HP -gt $(( ( MAXHP / 10 ) * 9 ))
else test $HP -gt $(( ( MAXHP / 100 ) * 90 ))
fi
}

_heal_stdalone(){
_debug_stdalone "_heal_stdalone:$*"
_log_stdalone   "_heal_stdalone:$*"

local lITEM=${*:-"$HEAL_ITEM"}

case $lITEM in
*rod*|*staff*|*wand*|*horn*|*scroll*) _check_have_item_in_inventory_stdalone $lITEM || return 1;;
*) :;;
esac

case $lITEM in
*rod*|*staff*|*wand*|*horn*)
 _is_stdalone 1 1 apply -u $lITEM
 _is_stdalone 1 1 apply -a $lITEM
 _is_stdalone 1 1 fire 0
 _is_stdalone 1 1 fire_stop
 ;;
*scroll*) _is_stdalone 1 1 apply $lITEM;;
'') :;;
*) _is_stdalone 1 1 invoke $lITEM;;
esac

}

_check_hp_stdalone(){
_debug_stdalone "_check_hp_stdalone:$*"
_log_stdalone   "_check_hp_stdalone:$*"

while :;
do
 __check_hp_stdalone && return 0
 _heal_stdalone
 _sleep_stdalone
done

}

# loop to
# brace and
# attack around
# with skill clawing

_claw_around_stdalone(){
_debug_stdalone "_claw_around_stdalone:$*"
_log_stdalone   "_claw_around_stdalone:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction_stdalone $DIRECTION_OPT || _set_next_direction_stdalone

_kill_monster_stdalone $ATTACKS_SPOT

case $NUMBER in $one) break;; esac
#case $CLAW_ATTEMPTS in $CLAW_ATTEMPTS_DONE) break;; esac

if _check_counter_stdalone; then
_check_food_level_stdalone
_check_hp_stdalone
_check_hp_and_return_home_stdalone $HP
_check_skill_available_stdalone clawing || return 1
fi

_say_script_time_stdalone

done
}

# MAIN

_main_claw_stdalone(){
_debug_stdalone "_main_claw_stdalone:$*"
_log_stdalone   "_main_claw_stdalone:$*"

_set_global_variables_stdalone $*
_say_start_msg_stdalone $*
_do_parameters_stdalone $*

_get_player_speed_stdalone
test "$PL_SPEED1" && __set_sync_sleep_stdalone ${PL_SPEED1} || _set_sync_sleep_stdalone "$PL_SPEED"


_direction_to_number_stdalone $DIRECTION_OPT

if _check_skill_available_stdalone clawing; then
[ "$DO_BRACE" ] && _brace_stdalone
_claw_around_stdalone
_unbrace_stdalone
fi

_say_end_msg_stdalone
}

_main_claw_func(){

_source_library_files(){
. $MY_DIR/cf_funcs_common.sh   || { echo draw 3 "$MY_DIR/cf_funcs_common.sh   failed to load."; exit 4; }
. $MY_DIR/cf_funcs_food.sh     ||       _exit 5 "$MY_DIR/cf_funcs_food.sh     failed to load."
. $MY_DIR/cf_funcs_move.sh     ||       _exit 7 "$MY_DIR/cf_funcs_move.sh     failed to load."
. $MY_DIR/cf_funcs_skills.sh   ||       _exit 9 "$MY_DIR/cf_funcs_skills.sh   failed to load."
. $MY_DIR/cf_funcs_fight.sh    ||      _exit 10 "$MY_DIR/cf_funcs_fight.sh    failed to load."
. $MY_DIR/cf_funcs_requests.sh ||      _exit 12 "$MY_DIR/cf_funcs_requests.sh failed to load."
. $MY_DIR/cf_funcs_heal.sh     ||      _exit 13 "$MY_DIR/cf_funcs_heal.sh     failed to load."
}
_source_library_files

_debug "_main_claw_func:$*"
_log   "_main_claw_func:$*"

_set_global_variables $*
_say_start_msg $*
_do_parameters $*

_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"


_direction_to_number $DIRECTION_OPT

if _check_skill_available clawing; then
[ "$DO_BRACE" ] && _brace
_claw_around
_unbrace
fi

_say_end_msg
}


 _main_claw_stdalone "$@"
#_main_claw_func "$@"



###END###
