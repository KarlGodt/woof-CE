#!/bin/bash

# Who:
# Created by Karl Reimer Godt
# First version 2018-01-06
# Time elapsed for the crossfire client
# while writing the script was 5,5 hours;
# which included fixes to cf_open_chests_simple.sh .
# Most time took error fixes after testing the script.
# Bugs are still likely :( !
#
# About:
# Script to open door
# for the roleplaying game Crossfire.
# Simple script that does not finetune
# trap handling.
# In case of detonating a trap while
# disarming, it does just exit.
#
# Reason:
# I wrote this script because of lazyness,
# since such scripts to open a door already exist
# in my repositories, but I was too lazy to
# search for these similar scripts.
#
# Style:
# This script was written mainly from memory,
# using the script cf_open_chests_simple.sh .
# Also used the existing functions
# _is, _draw, _debug, _log, _set_global_variables,
# _say_start_msg, _say_end_msg from cf_functions.sh .

VERSION=0.0
VERSION=0.1 # code reorderings, smaller bugfixes
VERSION=0.2 # instead using _debug now using a MSGLEVEL

VERSION=1.0 # added option to choose between
# use_skill, cast and invoke to disarm traps
VERSION=1.1 # bugfix in _open_door_with_standard_key_stdalone()
# was missing a '-' in ${1:-$DIRECTION}
VERSION=1.2 # bugfixes in regards to unexpected
# settings of variables
VERSION=1.3 # Recognize *help and *version options
VERSION=2.0 # use sourced functions files
VERSION=2.1 # bugfixes for calls to _move_* functions
VERSION=2.1.1 # bugfixes
VERSION=3.0 # make it standalone possible again
VERSION=3.1 # bugfixing
VERSION=3.2 # Use standard sound directories

LOCKPICK_ATTEMPTS_DEFAULT=9
SEARCH_ATTEMPTS_DEFAULT=9

#DISARM variable set to skill, invokation OR cast
DISARM=skill

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
MY_DIR=${MY_SELF%/*}

DRAWINFO=drawinfo # client 1.12.svn seems to accept both drawinfo and drawextinfo
# client gtk1 1.12.svn needs drawinfo, but gtk2 1.12.svn needs drawextinfo
DEBUG=1
LOGGING=1
MSGLEVEL=6 # Message Levels 1-7 to print to the msg pane


_say_help_stdalone(){
_draw_stdalone 6  "$MY_BASE"
_draw_stdalone 7  "Script to search for traps,"
_draw_stdalone 7  "disarming them,"
_draw_stdalone 7  "and lockpick a door."
_draw_stdalone 2  "To be used in the crossfire roleplaying game client."
_draw_stdalone 6  "Syntax:"
_draw_stdalone 7  "$0 <<Options>>"
_draw_stdalone 8  "Options:"
_draw_stdalone 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw_stdalone 9  "-L # :Number of lockpick attempts, deflt $LOCKPICK_ATTEMPTS_DEFAULT"
_draw_stdalone 9  "-D # :Direction <0-8|n-e-s-w> to lockpick to."
_draw_stdalone 10 "-I   :Do infinte attempts to lockpick door,"
_draw_stdalone 10 "      use scriptkill command to terminate."
_draw_stdalone 9  "-M   :Do not break search when found first trap,"
_draw_stdalone 9  "      usefull if doors have more than one trap."
_draw_stdalone 11 "-V   :Print version information."
_draw_stdalone 12 "-c   :cast spell disarm"
_draw_stdalone 12 "-i   :invoke spell disarm"
_draw_stdalone 12 "-u   :use_skill disarm"
_draw_stdalone 10 "-d   :Print debugging to msgpane."

exit ${1:-2}
}

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to search for traps,"
_draw 7  "disarming them,"
_draw 7  "and lockpick a door."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 6  "Syntax:"
_draw 7  "$0 <<Options>>"
_draw 8  "Options:"
_draw 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw 9  "-L # :Number of lockpick attempts, deflt $LOCKPICK_ATTEMPTS_DEFAULT"
_draw 9  "-D # :Direction <0-8|n-e-s-w> to lockpick to."
_draw 10 "-I   :Do infinte attempts to lockpick door,"
_draw 10 "      use scriptkill command to terminate."
_draw 9  "-M   :Do not break search when found first trap,"
_draw 9  "      useful if doors have more than one trap."
_draw 11 "-V   :Print version information."
_draw 12 "-c   :cast spell disarm"
_draw 12 "-i   :invoke spell disarm"
_draw 12 "-u   :use_skill disarm"
_draw 10 "-d   :Print debugging to msgpane."

exit ${1:-2}
}

__say_version_stdalone(){
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
FUNCTION_CHECK_FOR_SPACE=_check_for_space # request map pos works
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
FUNCTION_CHECK_FOR_SPACE=_check_for_space_old_client # needs request map near
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

# *** Color numbers found in common/shared/newclient.h : *** #
NDI_BLACK=0
NDI_WHITE=1
NDI_NAVY=2
NDI_RED=3
NDI_ORANGE=4
NDI_BLUE=5       #/**< Actually, it is Dodger Blue */
NDI_DK_ORANGE=6  #/**< DarkOrange2 */
NDI_GREEN=7      #/**< SeaGreen */
NDI_LT_GREEN=8   #/**< DarkSeaGreen, which is actually paler
#                  *   than seagreen - also background color. */
NDI_GREY=9
NDI_BROWN=10     #/**< Sienna. */
NDI_GOLD=11
NDI_TAN=12       #/**< Khaki. */
#define NDI_MAX_COLOR   12      /**< Last value in. */

CF_DATADIR=/usr/local/share/crossfire-client
SOUND_DIR="$HOME"/.crossfire/cf_sounds
USER_SOUNDS_PATH="$HOME"/.crossfire/sound.cache
CF_SOUND_DIR="$CF_DATADIR"/sounds

# Log file path in /tmp
#MY_SELF=`realpath "$0"` ## needs to be in main script
#MY_BASE=${MY_SELF##*/}  ## needs to be in main script
TMP_DIR=/tmp/crossfire_client
mkdir -p "$TMP_DIR"
    LOGFILE=${LOGFILE:-"$TMP_DIR"/"$MY_BASE".$$.log}
  REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
     ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion
  ERROR_LOG="$TMP_DIR"/"$MY_BASE".$$.err
exec 2>>"$ERROR_LOG"
}

_draw_stdalone(){
    local lCOLOUR="${1:-$COLOUR}"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    echo draw $lCOLOUR $@ # no double quotes here,
# multiple lines are drawn using __draw below
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

_debug_stdalone(){
test "$DEBUG" || return 0
    echo draw 10 "DEBUG:$@"
}

__debug_stdalone(){  ##+++2018-01-06
test "$DEBUG" || return 0
dcnt=0
echo "$*" | while read line
do
dcnt=$((dcnt+1))
    echo draw 3 "__DEBUG:$dcnt:$line"
done
unset dcnt line
}

_info_stdalone(){
test "$INFO" || return 0
    echo draw 7 "INFO:$@"
}

_notice_stdalone(){
test "$NOTICE" || return 0
    echo draw 2 "NOTICE:$@"
}

_warn_stdalone(){
test "$WARN" || return 0
    echo draw 6 "WARNING:$@"
}

_error_stdalone(){
test "$ERROR" || return 0
    echo draw 4 "ERROR:$@"
}

_log_stdalone(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOGFILE"
   echo "$*" >>"$lFILE"
}

_sound_stdalone(){
    local lDUR
test "$2" && { lDUR="$1"; shift; }
lDUR=${lDUR:-0}
#test -e "$SOUND_DIR"/${1}.raw && \
#           aplay $Q $VERB -d $lDUR "$SOUND_DIR"/${1}.raw
if   test -e                 "$SOUND_DIR"/${1}.raw; then
     aplay $Q $VERB -d $lDUR "$SOUND_DIR"/${1}.raw
elif test -e                 "$USER_SOUNDS_PATH"/${1}.raw; then
     aplay $Q $VERB -d $lDUR "$USER_SOUNDS_PATH"/${1}.raw
elif test -e                 "$CF_SOUND_DIR"/${1}.raw; then
     aplay $Q $VERB -d $lDUR "$CF_SOUND_DIR"/${1}.raw
fi
}

_fanfare_stdalone(){
 _sound_stdalone 0 su-fanf
}

_sleep_stdalone(){
SLEEP=${SLEEP//,/.}
sleep ${SLEEP:-1}
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

_beep_std_stdalone(){
beep -l 1000 -f 700
}

_just_exit_stdalone(){
_draw_stdalone 3 "Exiting $0. Pid was $$ ."
_unwatch_stdalone
_beep_std_stdalone
exit ${1:-0}
}

_exit_stdalone(){
case $1 in
[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) RV=$1; shift;;
esac

test "$*" && _draw_stdalone 3 $@
_draw_stdalone 3 "Exiting $0. PID was $$"

_unwatch_stdalone ""
_beep_std_stdalone
test ${RV//[0-9]/} && RV=3
exit ${RV:-0}
}

_check_if_already_running_ps_stdalone(){

local lPROGS=`ps -o pid,ppid,args | grep -w $PPID | grep -v -w $$`
__debug_stdalone "$lPROGS"
lPROGS=`echo "$lPROGS" | grep -vE "^$PPID[[:blank:]]+|^[[:blank:]]+$PPID[[:blank:]]+" | grep -vE '<defunct>|grep|cfsndserv'`
__debug_stdalone "$lPROGS"
test ! "$lPROGS"
}

_check_drawinfo_stdalone(){  ##+++2018-02-18
_msg_stdalone 7 "_check_drawinfo_stdalone:$*"
_log_stdalone   "_check_drawinfo_stdalone:$*"

oDEBUG=$DEBUG;       DEBUG=${DEBUG:-''}
oLOGGING=$LOGGING; LOGGING=${LOGGING:-1}

_msg_stdalone 6  "Checking drawinfo ..."

echo watch

while :;
do

# I use search here to provoke
# a response from the server
__is_stdalone 1 1 save
__is_stdalone 1 1 ready_skill xxx

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
_msg_stdalone 6  "Done."
test "$DRAWINFO"
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

__is_stdalone(){
_msg_stdalone 7 "__is_stdalone:$*"
Z1=$1; shift
Z2=$1; shift
_msg_stdalone 7 "__is_stdalone:$*"
echo issue $Z1 $Z2 $*
unset Z1 Z2
sleep 0.2
}

_say_end_msg_stdalone(){
# *** Here ends program *** #
__is_stdalone 1 1 fire_stop
#test -f "$SOUND_DIR"/su-fanf.raw && aplay $Q "$SOUND_DIR"/su-fanf.raw & aPID=$!
_fanfare_stdalone & aPID=$!

_tell_script_time_stdalone || _say_script_time_stdalone

test "$DEBUG" || { test -s "$ERROR_LOG" || rm -f "$ERROR_LOG"; }
test "$DEBUG" -o "$INFO" || rm -f "$TMP_DIR"/*.$$*

test "$aPID" && wait $aPID
_draw_stdalone 2  "$0 $$ has finished."
}

_check_counter_stdalone(){
ckc=$((ckc+1))
test "$ckc" -lt $COUNT_CHECK_FOOD && return $ckc
ckc=0
return $ckc
}

_empty_message_stream_stdalone(){
local lREPLY
while :;
do
read -t $TMOUT lREPLY
_log_stdalone "$REPLY_LOG" "_empty_message_stream:$lREPLY"
test "$lREPLY" || break
case $lREPLY in
*scripttell*break*)     break ${lREPLY##*?break};;
*scripttell*exit*)      _exit_stdalone 1 $lREPLY;;
*'YOU HAVE DIED.'*) _just_exit_stdalone;;
esac
_msg_stdalone 7 "_empty_message_stream:$lREPLY"
unset lREPLY
 sleep 0.01
#sleep 0.1
done
}

_request_stdalone(){  # for one line replies
_msg_stdalone 7 "_request_stdalone:$*"
_log_stdalone   "_request_stdalone:$*"

test "$*" || return 254

local lANSWER=''

_empty_message_stream_stdalone
echo request $*
read -t $TMOUT lANSWER
 _log_stdalone "$REQUEST_LOG" "_request $*:$lANSWER"
 _msg_stdalone 7 "$lANSWER"

ANSWER="$lANSWER"
test "$ANSWER"
}

_round_up_and_down_stdalone(){  ##+++2018-01-08
[ "$DEBUG" ] && echo "_round_up_and_down_stdalone:$1" >&2
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
_msg_stdalone 7 "_set_sync_sleep_stdalone:$*"
_log_stdalone   "_set_sync_sleep_stdalone:$*"

local lPL_SPEED=${1:-$PL_SPEED}
lPL_SPEED=${lPL_SPEED:-50000}

  if test "$lPL_SPEED"  =  "";    then
_draw_stdalone 3 "WARNING: Could not set player speed. Using defaults."
elif test "$lPL_SPEED" -gt 60000; then
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
else
_exit_stdalone 1 "ERROR while processing player speed."
fi

_msg_stdalone 5 "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

__set_sync_sleep_stdalone(){
_msg_stdalone 7 "__set_sync_sleep_stdalone:$*"
_log_stdalone   "__set_sync_sleep_stdalone:$*"

local lPL_SPEED=${1:-$PL_SPEED1}
lPL_SPEED=${lPL_SPEED:-50}

  if test "$lPL_SPEED"  =  ""; then
_draw_stdalone 3 "WARNING: Could not set player speed. Using defaults."
elif test "$lPL_SPEED" -gt 60; then
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
else
_exit_stdalone 1 "ERROR while processing player speed."
fi

_msg_stdalone 5 "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

_player_speed_to_human_readable_stdalone(){
_msg_stdalone 7 "_player_speed_to_human_readable_stdalone:$*"
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

PL_SPEED_POST=`_round_up_and_down $PL_SPEED_POST`
_msg_stdalone 7 "Rounded Player speed is '${PL_SPEED_PRE}$PL_SPEED_POST'"
PL_SPEED_POST=${PL_SPEED_POST:0:2}
_msg_stdalone 7 "Rounded Player speed is '${PL_SPEED_PRE}$PL_SPEED_POST'"

PL_SPEED1="${PL_SPEED_PRE}${PL_SPEED_POST}"
_msg_stdalone 7 "Rounded Player speed is '$PL_SPEED1'"

PL_SPEED1=`echo "$PL_SPEED1" | sed 's!\.!!g;s!\,!!g;s!^0*!!'`
LC_NUMERIC=$oLC_NUMERIC
}

_get_player_speed_stdalone(){
_msg_stdalone 7 "_get_player_speed_stdalone:$*"
_log_stdalone   "_get_player_speed_stdalone:$*"

if test "$1" = '-l'; then # loop counter
 _check_counter_stdalone || return 1
 shift
fi

_msg_stdalone 5 "Processing Player's speed..."
_request_stdalone stat cmbt
test "$ANSWER" && PL_SPEED0=`echo "$ANSWER" | awk '{print $7}'`
PL_SPEED=${PL_SPEED0:-$PL_SPEED}

PL_SPEED=${PL_SPEED:-50000} # 0.50

_player_speed_to_human_readable $PL_SPEED
_msg_stdalone 6 "Using player speed '$PL_SPEED1'"

_msg_stdalone 5 "Done."
return 0
}

__search_traps_stdalone(){
_msg_stdalone 7 "__search_traps_stdalone:$*"
_log_stdalone   "__search_traps_stdalone:$*"

cnt=${SEARCH_ATTEMPTS:-$SEARCH_ATTEMPTS_DEFAULT}
_draw_stdalone 5 "Searching traps ..."

TRAPS_ALL=0
TRAPS_ALL_OLD=$TRAPS_ALL

while :
do

_draw_stdalone 5 "Searching traps $cnt time(s) ..."

_watch_stdalone $DRAWINFO
__is_stdalone 0 0 search
_sleep_stdalone

 while :
 do
 unset REPLY
 read -t $TMOUT
   _log_stdalone "__search_traps:$REPLY"
 _msg_stdalone 7 "$REPLY"

#You spot a Rune of Burning Hands!
#You spot a poison needle!
#You spot a spikes!
#You spot a Rune of Shocking!
#You spot a Rune of Icestorm!
#You search the area.

 case $REPLY in
 *'You spot a Rune of Ball Lightning!'*) _just_exit_stdalone 0;;
 *' spot '*) FOUND_TRAP=$((FOUND_TRAP+1));;
 *'You search the area.'*) break 1;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)  _just_exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') break 1;;
 *) :;;
 esac

 _sleep_stdalone
 done

test "$FOUND_TRAP" && _draw_stdalone 2 "Found $FOUND_TRAP trap(s)."
TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
test "$TRAPS_ALL_OLD" -gt $TRAPS_ALL && TRAPS_ALL=$TRAPS_ALL_OLD
TRAPS_ALL_OLD=${TRAPS_ALL:-0}

unset FOUND_TRAP

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$MULTIPLE_TRAPS" || {
    test "$TRAPS_ALL" -ge 1 && break 1; }

cnt=$((cnt-1))
test "$cnt" -gt 0 || break 1

done

unset cnt
}

__cast_disarm_stdalone(){
_msg_stdalone 7 "__cast_disarm_stdalone:$*"
_log_stdalone   "__cast_disarm_stdalone:$*"

test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw_stdalone 5 "${TRAPS:-0} trap(s) to disarm ..."

_watch_stdalone $DRAWINFO
_turn_direction $DIRECTION cast disarm

# TODO: checks for enough mana
#_watch_stdalone $DRAWINFO
#__is_stdalone 0 0 cast disarm
#_sleep_stdalone
#__is_stdalone 0 0 fire ${DIRN:-$DIRECTION}
#__is_stdalone 0 0 fire_stop
#_sleep_stdalone

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
   _log_stdalone "__cast_disarm_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) _just_exit_stdalone 1;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)  _just_exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac

 sleep 0.1
 done

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$TRAPS" -gt 0 || break 1
done
}

__invoke_disarm_stdalone(){ ## invoking does to a direction
_msg_stdalone 7 "__invoke_disarm_stdalone:$*"
_log_stdalone   "__invoke_disarm_stdalone:$*"

test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw_stdalone 5 "${TRAPS:-0} trap(s) to disarm ..."

#_turn_direction $DIRECTION

_watch_stdalone $DRAWINFO
__is_stdalone 0 0 invoke disarm
_sleep_stdalone

#There's nothing there!
#You fail to disarm the diseased needle.
#You successfully disarm the diseased needle!
 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
   _log_stdalone "__invoke_disarm_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) _just_exit_stdalone 1;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)  _just_exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac
 done

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$TRAPS" -gt 0 || break 1
done

}

__use_skill_disarm_stdalone(){
_msg_stdalone 7 "__use_skill_disarm_stdalone:$*"
_log_stdalone   "__use_skill_disarm_stdalone:$*"

test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw_stdalone 5 "Disarming ${TRAPS:-0} trap(s) ..."

_watch_stdalone $DRAWINFO
__is_stdalone 0 0 use_skill disarm
_sleep_stdalone

 unset REPLY
 while :
 do
 read -t $TMOUT
   _log_stdalone "__use_skill_disarm_stdalone:$REPLY"
 _msg_stdalone 7 "$REPLY"

#You fail to disarm the Rune of Burning Hands.
#In fact, you set it off!
#You detonate a Rune of Burning Hands!
#You successfully disarm the spikes!
#You fail to disarm the Rune of Icestorm.

 case $REPLY in
 *'You successfully disarm'*)  TRAPS=$((TRAPS-1));;
 *'You fail to disarm'*) :;;
 *'In fact, you set it off!'*) TRAPS=$((TRAPS-1));;
 *'You detonate'*) _just_exit_stdalone 1;;
 *'You are pricked'*) :;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)  _just_exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac

 _sleep_stdalone
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

__disarm_traps_stdalone(){
_msg_stdalone 7 "__disarm_traps_stdalone:$*"
_log_stdalone   "__disarm_traps_stdalone:$*"

_msg_stdalone 6 "Disarming ${TRAPS_ALL:-0} trap(s) ..."
case "$DISARM" in
invokation) _invoke_disarm;;
cast|spell) case "$DIRECTION" in '') _invoke_disarm_stdalone;; *) _cast_disarm_stdalone;; esac;;
            # _cast_disarm_stdalone;;
skill|'') __use_skill_disarm_stdalone;;
*) _error_stdalone "DISARM variable set not to skill, invokation OR cast'";;
esac
}

__lockpick_door_stdalone(){
_msg_stdalone 7 "__lockpick_door_stdalone:$*"
_log_stdalone   "__lockpick_door_stdalone:$*"

one=${LOCKPICK_ATTEMPTS:-$LOCKPICK_ATTEMPTS_DEFAULT}
test "$one" -gt 0 || return 1  # to trigger _open_door_with_standard_key

_msg_stdalone 6 "Attempting to lockpick the door ..."

unset RV cnt1
while :
do

cnt1=$((cnt1+1))
test "$INFINITE" && _draw_stdalone 5 "${cnt1}. attempt .." || _draw_stdalone 5 "$one attempts in lockpicking skill left .."

_watch_stdalone $DRAWINFO
__is_stdalone 1 1 use_skill lockpicking

 unset cnt0
 while :;
 do
 cnt0=$((cnt0+1))
 unset REPLY
 read -t ${TMOUT:-1}
   _log_stdalone "__lockpick_door_stdalone:$REPLY"
 _msg_stdalone 7 "__lockpick_door_stdalone:$REPLY"

 case $REPLY in
 *there*is*no*door*) RV=4; break 2;; #return 4;;

 *'There is no lock there.'*) RV=0; break 2;; #return 0;;
 *'You pick the lock.'*)      RV=0; break 2;; #return 0;;
 *'The door has no lock!'*)   RV=0; break 2;; #return 0;;

 *'You fail to pick the lock.'*) break 1;;

 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)  _just_exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') break 1;; # :;;
 *)  :;;
 esac

 test "$cnt0" -gt 9 && break 1 # emergency break
 _sleep_stdalone
 done

_unwatch_stdalone $DRAWINFO

test "$INFINITE" || {
    one=$((one-1))
    test "$one" -gt 0 || break 1
}

_sleep_stdalone
done

#DEBUG=1 _msg_stdalone 7 "RV=$RV"
return ${RV:-1}
}

__open_door_with_standard_key_stdalone(){
 _msg_stdalone 7 "__open_door_with_standard_key_stdalone:$*"
 _log_stdalone   "__open_door_with_standard_key_stdalone:$*"

DIRECTION=${1:-$DIRECTION}
 _msg_stdalone 7 "DIRECTION=$DIRECTION"
test "$DIRECTION" || return 254
__number_to_direction_stdalone "$DIRECTION"
#DEBUG=1 _msg_stdalone 7 "DIRECTION=$DIRECTION"
__is_stdalone 0 0 $DIRECTION
}

__direction_to_number_stdalone(){
    _msg_stdalone 7 "__direction_to_number_stdalone:$*"
    _log_stdalone   "__direction_to_number_stdalone:$*"

DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 254

DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=0; DIRB=;          DIRF=;;
1|north|n)         DIRECTION=1; DIRB=south;     DIRF=north;;
2|northeast|ne)    DIRECTION=2; DIRB=southwest; DIRF=northeast;;
3|east|e)          DIRECTION=3; DIRB=west;      DIRF=east;;
4|southeast|se)    DIRECTION=4; DIRB=northwest; DIRF=southeast;;
5|south|s)         DIRECTION=5; DIRB=north;     DIRF=south;;
6|southwest|sw)    DIRECTION=6; DIRB=northeast; DIRF=southwest;;
7|west|w)          DIRECTION=7; DIRB=east;      DIRF=west;;
8|northwest|nw)    DIRECTION=8; DIRB=southeast; DIRF=northwest;;
*) ERROR=1 _error "Not recognized: '$DIRECTION'";;
esac
DIRN=$DIRECTION
DIRECTION_NUMBER=$DIRN
return ${DIRN:-255}
}

__number_to_direction_stdalone(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 254
DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=center;    DIRN=0; DIRB=;          DIRF=;;
1|north|n)         DIRECTION=north;     DIRN=1; DIRB=south;     DIRF=north;;
2|northeast|ne)    DIRECTION=northeast; DIRN=2; DIRB=southwest; DIRF=northeast;;
3|east|e)          DIRECTION=east;      DIRN=3; DIRB=west;      DIRF=east;;
4|southeast|se)    DIRECTION=southeast; DIRN=4; DIRB=northwest; DIRF=southeast;;
5|south|s)         DIRECTION=south;     DIRN=5; DIRB=north;     DIRF=south;;
6|southwest|sw)    DIRECTION=southwest; DIRN=6; DIRB=northeast; DIRF=southwest;;
7|west|w)          DIRECTION=west;      DIRN=7; DIRB=east;      DIRF=west;;
8|northwest|nw)    DIRECTION=northwest; DIRN=8; DIRB=southeast; DIRF=northwest;;
*) ERROR=1 _error "Not recognized: '$DIRECTION'";;
esac
DIRECTION_NUMBER=$DIRN
return ${DIRN:-255}
}

__turn_direction_stdalone(){
    _msg_stdalone 7 "__turn_direction_stdalone:$*"
    _log_stdalone   "__turn_direction_stdalone:$*"

test "$3" && { DIRECTION=${1:-DIRECTION}; shift; }
test "$DIRECTION" || return 254

__direction_to_number_stdalone $DIRECTION
__is_stdalone 0 0 ${1:-ready_skill} ${2:-lockpicking}
__is_stdalone 0 0 fire ${DIRN:-$DIRECTION}
__is_stdalone 0 0 fire_stop
}

_do_parameters_stdalone(){
# don't forget to pass parameters when invoking this function
_msg_stdalone 7 "_do_parameters_stdalone:$*"
_log_stdalone   "_do_parameters_stdalone:$*"

test "$*" || return 0

case $1 in
*help)    _say_help_stdalone 0;;
*version) __say_version_stdalone 0;;
esac

# S # :Search attempts
# D # :Direction to open door
# I   :Infinte lockpick attempts
while getopts S:D:L:IVMhabcdefgijklmnopqrstuvwxyzABCEFGHJKNOPQRTUWXYZ oneOPT
do
case $oneOPT in
D) DIRECTION=${OPTARG:-0};;
I) INFINITE=1;;
L) LOCKPICK_ATTEMPTS=${OPTARG:-$LOCKPICK_ATTEMPTS_DEFAULT};;
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;

M) MULTIPLE_TRAPS=$((MULTIPLE_TRAPS+1));;

c) DISARM=cast;;
i) DISARM=invokation;;
u) DISARM=skill;;

d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;

h) _say_help_stdalone 0;;
V) __say_version_stdalone 0;;

'') _draw_stdalone 2 "FIXME: Empty positional parameter ...?";;
*) _draw_stdalone 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

_do_parameters(){
# don't forget to pass parameters when invoking this function
_debug "_do_parameters:$*"
_log   "_do_parameters:$*"

test "$*" || return 0

case $1 in
*help)    _say_help 0;;
*version) __say_version 0;;
--?*)  _exit 3 "No other long options than help and version recognized.";;
--*)   _exit 3 "Unhandled first parameter '$1' .";;
-?*) :;;
esac

# S # :Search attempts
# D # :Direction to open door
# I   :Infinte lockpick attempts
while getopts S:D:L:IVMhabcdefgijklmnopqrstuvwxyzABCEFGHJKNOPQRTUWXYZ oneOPT
do
case $oneOPT in
D) DIRECTION=${OPTARG:-0};;
I) INFINITE=1;;
L) LOCKPICK_ATTEMPTS=${OPTARG:-$LOCKPICK_ATTEMPTS_DEFAULT};;
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;

M) MULTIPLE_TRAPS=$((MULTIPLE_TRAPS+1));;

c) DISARM=cast;;
i) DISARM=invokation;;
u) DISARM=skill;;

d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;

h) _say_help 0;;
V) __say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

#MAIN
_main_search_disarm_lockpick_stdalone(){
_msg_stdalone 7 "_main_search_disarm_lockpick_stdalone:$*"
_log_stdalone   "_main_search_disarm_lockpick_stdalone:$*"

_set_global_variables_stdalone $*
_do_parameters_stdalone $*

if test "$ATTACKS_SPOT" -a "$COUNT_CHECK_FOOD"; then
 COUNT_CHECK_FOOD=$((COUNT_CHECK_FOOD/ATTACKS_SPOT))
 test "$COUNT_CHECK_FOOD" -le 0 && COUNT_CHECK_FOOD=1
fi

_say_start_msg_stdalone $*


_get_player_speed_stdalone
#_set_sync_sleep_stdalone ${PL_SPEED1:-$PL_SPEED}
test "$PL_SPEED1" && __set_sync_sleep_stdalone ${PL_SPEED1} || _set_sync_sleep_stdalone "$PL_SPEED"

__turn_direction_stdalone $DIRECTION cast "show invisible"
unset DIRB DIRF

__search_traps_stdalone
__disarm_traps_stdalone
__lockpick_door_stdalone
RV=$?
#DEBUG=1 _debug_stdalone "RV=$RV"
case $RV in
0) :;;
*) __open_door_with_standard_key_stdalone $DIRECTION;;
esac

_unwatch_stdalone $DRAWINFO
_say_end_msg_stdalone
}

_main_search_disarm_lockpick_funcs(){

 _source_library_files(){
  . $MY_DIR/cf_funcs_common.sh || { echo draw 3 "$MY_DIR/cf_funcs_common.sh failed to load."; exit 4; }
  . $MY_DIR/cf_funcs_traps.sh  || _exit 5 "$MY_DIR/cf_funcs_traps.sh  failed to load."
  . $MY_DIR/cf_funcs_move.sh   || _exit 6 "$MY_DIR/cf_funcs_move.sh   failed to load."
  . $MY_DIR/cf_funcs_chests.sh || _exit 7 "$MY_DIR/cf_funcs_chests.sh failed to load."
 }
 _source_library_files

_debug "_main_search_disarm_lockpick_funcs:$*"
_log   "_main_search_disarm_lockpick_funcs:$*"

_set_global_variables $*
_do_parameters $*
_say_start_msg $*


_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"

_turn_direction $DIRECTION ready_skill "literacy"
unset DIRB DIRF

_search_traps
_disarm_traps
_lockpick_door
RV=$?
#DEBUG=1 _debug "RV=$RV"
case $RV in
0) :;;
*) _open_door_with_standard_key $DIRECTION;;
esac

_unwatch $DRAWINFO
_say_end_msg
}

#_main_search_disarm_lockpick_stdalone $*
_main_search_disarm_lockpick_funcs $*

###END###




