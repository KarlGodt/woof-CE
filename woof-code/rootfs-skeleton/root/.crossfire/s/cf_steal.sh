#!/bin/ash

# 2018-02-10
# cf_steal.sh :
# script to level up the skill stealing

VERSION=0.0 # Initial version, taken from cf_orate.sh
VERSION=0.1 # exit early if already running or no DRAWINFO
VERSION=0.2 # bugfixing
VERSION=0.3 # Use standard sound directories

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
MY_DIR=${MY_SELF%/*}

LOGGING=1

# ATTACK_ATTEMPTS_DEFAULT=1
#ORATORY_ATTEMPTS_DEFAULT=1
#SINGING_ATTEMPTS_DEFAULT=1

_say_help_stdalone(){
_draw_stdalone 6  "$MY_BASE"
_draw_stdalone 7  "Script to calm down monsters"
_draw_stdalone 7  "by skill singing and then"
_draw_stdalone 7  "stealing from them by skill stealing."
_draw_stdalone 2  "To be used in the crossfire roleplaying game client."
_draw_stdalone 6  "Syntax:"
_draw_stdalone 7  "$0 <<NUMBER>> <<Options>>"
_draw_stdalone 8  "Options:"
_draw_stdalone 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw_stdalone 10 "-C # :like above, just make NUMBER loop rounds."
#_draw_stdalone 9  "-O # :Number of oratory attempts." #, default $ORATORY_ATTEMPTS_DEFAULT"
_draw_stdalone 9  "-S # :Number of singing attempts." #, default $SINGING_ATTEMPTS_DEFAULT"
_draw_stdalone 8  "-D word :Direction to sing and orate to,"
_draw_stdalone 8  " as n, ne, e, se, s, sw, w, nw."
_draw_stdalone 8  " If no direction, turns clockwise all around on the spot."
_draw_stdalone 11 "-V   :Print version information."
_draw_stdalone 10 "-d   :Print debugging to msgpane."
exit ${1:-2}
}

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to calm down monsters"
_draw 7  "by skill singing and then"
_draw 7  "stealing from them by skill stealing."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 6  "Syntax:"
_draw 7  "$0 <<NUMBER>> <<Options>>"
_draw 8  "Options:"
_draw 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw 10 "-C # :like above, just make NUMBER loop rounds."
#_draw 9  "-O # :Number of oratory attempts." #, default $ORATORY_ATTEMPTS_DEFAULT"
_draw 9  "-S # :Number of singing attempts." #, default $SINGING_ATTEMPTS_DEFAULT"
_draw 8  "-D word :Direction to sing and orate to,"
_draw 8  " as n, ne, e, se, s, sw, w, nw."
_draw 8  " If no direction, turns clockwise all around on the spot."
_draw 11 "-V   :Print version information."
_draw 10 "-d   :Print debugging to msgpane."
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

_check_if_already_running_ps_stdalone(){

local lPROGS=`ps -o pid,ppid,args | grep -w $PPID | grep -v -w $$`
__debug_stdalone "$lPROGS"
lPROGS=`echo "$lPROGS" | grep -vE "^$PPID[[:blank:]]+|^[[:blank:]]+$PPID[[:blank:]]+" | grep -vE '<defunct>|grep|cfsndserv'`
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

_check_drawinfo_stdalone(){  ##+++2018-01-08
_msg_stdalone 7 "_check_drawinfo_stdalone:$*"
_log_stdalone   "_check_drawinfo_stdalone:$*"

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
 _log_stdalone "_check_drawinfo_stdalone:$cnt0:$REPLY"
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
#test -f "$SOUND_DIR"/su-fanf.raw && aplay $Q "$SOUND_DIR"/su-fanf.raw & aPID=$!
_fanfare_stdalone & aPID=$!

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

_is_stdalone 1 1 fire_stop
_sleep_stdalone

test "$*" && _draw_stdalone 3 $@
_draw_stdalone 3 "Exiting $0. PID was $$"

_unwatch_stdalone ""
_beep_std_stdalone
test "${RV//[0-9]/}" && RV=3
exit ${RV:-0}
}

_just_exit_stdalone(){
_draw_stdalone 3 "Exiting $0."
_is_stdalone 1 1 fire_stop
_unwatch_stdalone
_beep_std_stdalone
exit ${1:-0}
}

_emergency_exit_stdalone(){
_msg_stdalone 7 "_emergency_exit_stdalone:$*"
_log_stdalone   "_emergency_exit_stdalone:$*"

RV=${1:-4}; shift
local lRETURN_ITEM=${*:-"$RETURN_ITEM"}

_is_stdalone 1 1 fire_stop

case $lRETURN_ITEM in
''|*rod*|*staff*|*wand*|*horn*)
_is_stdalone 1 1 apply -u ${lRETURN_ITEM:-'rod of word of recall'}
_is_stdalone 1 1 apply -a ${lRETURN_ITEM:-'rod of word of recall'}
_is_stdalone 1 1 fire center
_is_stdalone 1 1 fire_stop
;;
*scroll*) _is_stdalone 1 1 apply ${lRETURN_ITEM};;
*) _is_stdalone 1 1 invoke "$lRETURN_ITEM";; # assuming spell
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

_sound_or_beep_stdalone(){
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
sleep 0.2
echo   watch ${*:-$DRAWINFO}
}

_unwatch_stdalone(){
echo unwatch ${*:-$DRAWINFO}
}

_is_stdalone(){
# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.
    _msg_stdalone 7 "_is_stdalone:$*"
    _log_stdalone   "_is_stdalone:$*"
    echo issue "$@"
    sleep 0.2
}

__is_stdalone(){
_msg_stdalone 7 "$*"
Z1=$1; shift
Z2=$1; shift
_msg_stdalone 7 "$*"
echo issue $Z1 $Z2 $*
unset Z1 Z2
sleep 0.2
}

_set_pickup_stdalone(){
# Usage: pickup <0-7> or <value_density> .
# pickup 0:Don't pick up.
 _is_stdalone 1 1 pickup ${*:-0}
}

_check_counter_stdalone(){
ckc=$((ckc+1))
test "$ckc" -lt ${COUNT_CHECK_FOOD:-11} && return 1
ckc=0
return 0
}

_check_if_on_item_stdalone(){
_msg_stdalone 7 "_check_if_on_item_stdalone:$*"
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
*bed*to*reality*)   _just_exit_stdalone;;
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

#** we may get attacked and die **#
_check_hp_and_return_home_stdalone(){
_msg_stdalone 7 "_check_hp_and_return_home_stdalone:$*"
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

_check_mana_for_create_food_stdalone(){
_msg_stdalone 7 "_check_mana_for_create_food_stdalone:$*"
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
_watch_stdalone
_is_stdalone 1 0 cast create

while :;
do

read -t ${TMOUT:-1}
   _log_stdalone "_check_mana_for_create_food_stdalone:$REPLY"
 _msg_stdalone 7 "_check_mana_for_create_food_stdalone:$REPLY"

 case $REPLY in
 *ready*the*spell*create*food*) return 0;;
 *create*food*)
 MANA_NEEDED=`echo "$REPLY" | awk '{print $NF}'`
 _msg_stdalone 7 "MANA_NEEDED=$MANA_NEEDED"
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

_unwatch_stdalone
return 1
}

__check_food_level_stdalone(){
_msg_stdalone 7 "__check_food_level_stdalone:$*"
_log_stdalone   "__check_food_level_stdalone:$*"

test "$*" && MIN_FOOD_LEVEL="$@"
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-$MIN_FOOD_LEVEL_DEF}
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-300}

local FOOD_LVL=''
local REPLY

_empty_message_stream_stdalone
_sleep_stdalone

echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset HP MHP SP MSP GR MGR FOOD_LVL
read -t ${TMOUT:-1} Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
   _log_stdalone "__check_food_level_stdalone:HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL"
 _msg_stdalone 7 "HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL" #DEBUG

test "$Re" = request || continue
test "$FOOD_LVL" || break
test "${FOOD_LVL//[[:digit:]]/}" && break

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food_from_inventory
 _cast_create_food_and_eat_stdalone $EAT_FOOD || _eat_food_from_inventory_stdalone $EAT_FOOD

 _sleep_stdalone
 _empty_message_stream_stdalone
 _sleep_stdalone
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 _sleep_stdalone
 read -t ${TMOUT:-1} Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
   _log_stdalone "__check_food_level_stdalone:HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL"
 _msg_stdalone 7 "HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL" #DEBUG
 break
fi

test "${FOOD_LVL//[[:digit:]]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done
}

_check_food_level_stdalone(){
_msg_stdalone 7 "_check_food_level_stdalone:$*"
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
 #_eat_food_from_inventory_stdalone
 _cast_create_food_and_eat_stdalone $EAT_FOOD || _eat_food_from_inventory_stdalone $EAT_FOOD
 _request_stat_hp_stdalone
  break
else true
fi

test "$FOOD_LVL" && break

sleep 0.1
done
}

_request_stat_hp_stdalone(){
#Return hp,maxhp,sp,maxsp,grace,maxgrace,food
_msg_stdalone 7 "_request_stat_hp_stdalone:$*"
_log_stdalone   "_request_stat_hp_stdalone:$*"

#test "$*" || return 254

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
test "$HP" -a "$MHP" -a "$SP" -a "$MSP" -a "$GR" -a "$MGR" -a "$FOOD_LVL"
}

_cast_create_food_and_eat_stdalone(){
_msg_stdalone 7 "_cast_create_food_and_eat_stdalone:$*"
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
 _log_stdalone "_cast_create_food_and_eat_stdalone:$REPLY"
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
  _log_stdalone "_cast_create_food_and_eat_stdalone:$BUNGLE"
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

_request_stdalone(){  # for one line replies
_msg_stdalone 7 "_request_stdalone:*"
_log_stdalone   "_request_stdalone:*"

test "$*" || return 254

local lANSWER=''

_empty_message_stream_stdalone
echo request $*
read -t $TMOUT lANSWER
 _log_stdalone "$REQUEST_LOG" "_request_stdalone $*:$lANSWER"
 _msg_stdalone 7 "$lANSWER"

ANSWER="$lANSWER"
test "$ANSWER"
}

_request_stat_cmbt_stdalone(){
#Return wc,ac,dam,speed,weapon_sp
_msg_stdalone 7 "_request_stat_cmbt_stdalone:$*"
_log_stdalone   "_request_stat_cmbt_stdalone:$*"

#test "$*" || return 254

_empty_message_stream_stdalone

unset WC AC DAM SPEED WP_SPEED REST
echo request stat cmbt
read -t ${TMOUT:-1} r s c WC AC DAM SPEED WP_SPEED REST
#request stat cmbt %d %d %d %d %d\n",
#cpl.stats.wc,cpl.stats.ac,cpl.stats.dam,cpl.stats.speed,cpl.stats.weapon_sp)
 _log_stdalone "$REQUEST_LOG" "_request_stat_cmbt_stdalone $*:$WC $AC $DAM $SPEED $WP_SPEED $REST"
 _msg_stdalone 7 "$WC $AC $DAM $SPEED $WP_SPEED $REST"

PL_SPEED=$SPEED
test "$WC" -a "$AC" -a "$DAM" -a "$SPEED" -a "$WP_SPEED"
}

__get_player_speed_stdalone(){
_msg_stdalone 7 "__get_player_speed_stdalone:$*"
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
_msg_stdalone 7 "_get_player_speed_stdalone:$*"
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

_info_stdalone "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

__set_sync_sleep_stdalone(){
_msg_stdalone 7 "__set_sync_sleep_stdalone:$*"
_log_stdalone   "__set_sync_sleep_stdalone:$*"

local lPL_SPEED=${1:-$PL_SPEED1}
lPL_SPEED=${lPL_SPEED:-50}

  if test "$lPL_SPEED" = "";   then
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

_do_parameters_stdalone(){
_msg_stdalone 7 "_do_parameters_stdalone:$*"
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
while getopts C:O:S:D:dVhabdefgijklmnopqrstuvwxyzABEFGHIJKLMNPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
#O) ORATORY_ATTEMPTS=${OPTARG:-$ORATORY_ATTEMPTS_DEFAULT};;
#S) SINGING_ATTEMPTS=${OPTARG:-$SINGING_ATTEMPTS_DEFAULT};;
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
while getopts C:O:S:D:dVhabdefgijklmnopqrstuvwxyzABEFGHIJKLMNPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
#O) ORATORY_ATTEMPTS=${OPTARG:-$ORATORY_ATTEMPTS_DEFAULT};;
#S) SINGING_ATTEMPTS=${OPTARG:-$SINGING_ATTEMPTS_DEFAULT};;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

_say_skill_stealing_code_(){
cat >&1 <<EoI
file : server/server/skills.c
/* adj_stealchance() - increased values indicate better attempts */
static int adj_stealchance (object *op, object *victim, int roll) {
    object *equip;

    if(!op||!victim||!roll) return -1;

    /* Only prohibit stealing if the player does not have a free
     * hand available and in fact does have hands.
     */
    if(op->type==PLAYER && op->body_used[BODY_ARMS] <=0 &&
       op->body_info[BODY_ARMS]) {
    new_draw_info(NDI_UNIQUE, 0,op,"But you have no free hands to steal with!");
    return -1;
    }

    /* ADJUSTMENTS */

    /* Its harder to steal from hostile beings! */
    if(!QUERY_FLAG(victim, FLAG_UNAGGRESSIVE)) roll = roll/2;

    /* Easier to steal from sleeping beings, or if the thief is
     * unseen */
    if(QUERY_FLAG(victim, FLAG_SLEEP))
    roll = roll*3;
    else if(op->invisible)
    roll = roll*2;

    /* check stealing 'encumberance'. Having this equipment applied makes
     * it quite a bit harder to steal.
     */
    for(equip=op->inv;equip;equip=equip->below) {
    if(equip->type==WEAPON&&QUERY_FLAG(equip,FLAG_APPLIED)) {
        roll -= equip->weight/10000;
    }
    if(equip->type==BOW&&QUERY_FLAG(equip,FLAG_APPLIED))
        roll -= equip->weight/5000;
    if(equip->type==SHIELD&&QUERY_FLAG(equip,FLAG_APPLIED)) {
        roll -= equip->weight/2000;
    }
    if(equip->type==ARMOUR&&QUERY_FLAG(equip,FLAG_APPLIED))
        roll -= equip->weight/5000;
    if(equip->type==GLOVES&&QUERY_FLAG(equip,FLAG_APPLIED))
        roll -= equip->weight/100;
    }
    if(roll<0) roll=0;
    return roll;
}

/*
 * When stealing: dependent on the intelligence/wisdom of whom you're
 * stealing from (op in attempt_steal), offset by your dexterity and
 * skill at stealing. They may notice your attempt, whether successful
 * or not.
 * op is the target (person being pilfered)
 * who is the person doing the stealing.
 * skill is the skill object (stealing).
 */

static int attempt_steal(object* op, object* who, object *skill)
{
    object *success=NULL, *tmp=NULL, *next;
    int roll=0, chance=0, stats_value;
    rv_vector   rv;

    stats_value = ((who->stats.Dex + who->stats.Int) * 3) / 2;

    /* if the victim is aware of a thief in the area (FLAG_NO_STEAL set on them)
     * they will try to prevent stealing if they can. Only unseen theives will
     * have much chance of success.
     */
    if(op->type!=PLAYER && QUERY_FLAG(op,FLAG_NO_STEAL)) {
    if(can_detect_enemy(op,who,&rv)) {
        npc_call_help(op);
        CLEAR_FLAG(op, FLAG_UNAGGRESSIVE);
        new_draw_info(NDI_UNIQUE, 0,who,"Your attempt is prevented!");
        return 0;
    } else /* help npc to detect thief next time by raising its wisdom */
        op->stats.Wis += (op->stats.Int/5)+1;
        if (op->stats.Wis > MAX_STAT) op->stats.Wis = MAX_STAT;
    }
    if (op->type == PLAYER && QUERY_FLAG(op, FLAG_WIZ)) {
    new_draw_info(NDI_UNIQUE, 0, who, "You can't steal from the dungeon master!\n");
    return 0;
    }
    if(op->type == PLAYER && who->type == PLAYER && settings.no_player_stealing) {
      new_draw_info(NDI_UNIQUE, 0, who, "You can't steal from other players!\n");
      return 0;
    }


    /* Ok then, go thru their inventory, stealing */
    for(tmp = op->inv; tmp != NULL; tmp = next) {
    next = tmp->below;

    /* you can't steal worn items, starting items, wiz stuff,
     * innate abilities, or items w/o a type. Generally
     * speaking, the invisibility flag prevents experience or
     * abilities from being stolen since these types are currently
     * always invisible objects. I was implicit here so as to prevent
     * future possible problems. -b.t.
     * Flesh items generated w/ fix_flesh_item should have FLAG_NO_STEAL
     * already  -b.t.
     */

    if (QUERY_FLAG(tmp,FLAG_WAS_WIZ) || QUERY_FLAG(tmp, FLAG_APPLIED)
        || !(tmp->type)
        || tmp->type == EXPERIENCE || tmp->type == SPELL
        || QUERY_FLAG(tmp,FLAG_STARTEQUIP)
        || QUERY_FLAG(tmp,FLAG_NO_STEAL)
        || tmp->invisible ) continue;

    /* Okay, try stealing this item. Dependent on dexterity of thief,
     * skill level, see the adj_stealroll fctn for more detail.
     */

    roll=die_roll(2, 100, who, PREFER_LOW)/2; /* weighted 1-100 */

    if((chance=adj_stealchance(who,op,(stats_value+skill->level * 10 - op->level * 3)))==-1)
        return 0;
    else if (roll < chance ) {
        tag_t tmp_count = tmp->count;

        pick_up(who, tmp);
        /* need to see if the player actually stole this item -
         * if it is in the players inv, assume it is.  This prevents
         * abuses where the player can not carry the item, so just
         * keeps stealing it over and over.
         */
        if (was_destroyed(tmp, tmp_count) || tmp->env != op) {
        /* for players, play_sound: steals item */
        success = tmp;
        CLEAR_FLAG(tmp, FLAG_INV_LOCKED);

        /* Don't delete it from target player until we know
         * the thief has picked it up.  can't just look at tmp->count,
         * as it's possible that it got merged when picked up.
         */
        if (op->type == PLAYER)
            esrv_del_item(op->contr, tmp_count);
        }
        break;
    }
    } /* for loop looking for an item */

    if (!tmp) {
    new_draw_info_format(NDI_UNIQUE, 0, who, "%s%s has nothing you can steal!",
                 op->type == PLAYER ? "" : "The ", query_name(op));
    return 0;
    }

    /* If you arent high enough level, you might get something BUT
     * the victim will notice your stealing attempt. Ditto if you
     * attempt to steal something heavy off them, they're bound to notice
     */

    if((roll>=skill->level) || !chance
      ||(tmp && tmp->weight>(250*(random_roll(0, stats_value+skill->level * 10-1, who, PREFER_LOW))))) {

    /* victim figures out where the thief is! */
    if(who->hide) make_visible(who);

    if(op->type != PLAYER) {
        /* The unaggressives look after themselves 8) */
        if(who->type==PLAYER) {
        npc_call_help(op);
        new_draw_info_format(NDI_UNIQUE, 0,who,
          "%s notices your attempted pilfering!",query_name(op));
        }
        CLEAR_FLAG(op, FLAG_UNAGGRESSIVE);
        /* all remaining npc items are guarded now. Set flag NO_STEAL
         * on the victim.
         */
        SET_FLAG(op,FLAG_NO_STEAL);
    } else { /* stealing from another player */
        char buf[MAX_BUF];
        /* Notify the other player */
        if (success && who->stats.Int > random_roll(0, 19, op, PREFER_LOW)) {
        sprintf(buf, "Your %s is missing!", query_name(success));
        } else {
        sprintf(buf, "Your pack feels strangely lighter.");
        }
        new_draw_info(NDI_UNIQUE, 0,op,buf);
        if (!success) {
        if (who->invisible) {
            sprintf(buf, "you feel itchy fingers getting at your pack.");
        } else {
            sprintf(buf, "%s looks very shifty.", query_name(who));
        }
        new_draw_info(NDI_UNIQUE, 0,op,buf);
        }
    } /* else stealing from another player */
    /* play_sound("stop! thief!"); kindofthing */
    } /* if you weren't 100% successful */
    return success? 1:0;
}


int steal(object* op, int dir, object *skill)
{
    object *tmp, *next;
    sint16 x, y;
    mapstruct *m;
    int mflags;

    x = op->x + freearr_x[dir];
    y = op->y + freearr_y[dir];

    if(dir == 0) {
    /* Can't steal from ourself! */
    return 0;
    }

    m = op->map;
    mflags = get_map_flags(m, &m ,x,y, &x, &y);
    /* Out of map - can't do it.  If nothing alive on this space,
     * don't need to look any further.
     */
    if ((mflags & P_OUT_OF_MAP) || !(mflags & P_IS_ALIVE))
    return 0;

    /* If player can't move onto the space, can't steal from it. */
    if (OB_TYPE_MOVE_BLOCK(op, GET_MAP_MOVE_BLOCK(m, x, y)))
    return 0;

    /* Find the topmost object at this spot */
    for(tmp = get_map_ob(m,x,y);
    tmp != NULL && tmp->above != NULL;
        tmp = tmp->above);

    /* For all the stacked objects at this point, attempt a steal */
    for(; tmp != NULL; tmp = next) {
    next = tmp->below;
    /* Minor hack--for multi square beings - make sure we get
     * the 'head' coz 'tail' objects have no inventory! - b.t.
     */
    if (tmp->head) tmp=tmp->head;

    if(tmp->type!=PLAYER && !QUERY_FLAG(tmp, FLAG_MONSTER)) continue;

    /* do not reveal hidden DMs */
    if (tmp->type == PLAYER && QUERY_FLAG(tmp, FLAG_WIZ) && tmp->contr->hidden) continue;
    if (attempt_steal(tmp, op, skill)) {
        if (tmp->type==PLAYER) /* no xp for stealing from another player */
        return 0;

        /* no xp for stealing from pets (of players) */
        if (QUERY_FLAG(tmp, FLAG_FRIENDLY) && tmp->attack_movement == PETMOVE) {
        object *owner = get_owner(tmp);
        if (owner != NULL && owner->type == PLAYER)
            return 0;
        }

        return (calc_skill_exp(op,tmp, skill));
    }
    }
    return 0;
}
EoI
}

_say_skill_singing_code_(){
cat >&1 <<EoI

#define FLAG_MONSTER        14 /* Will attack players */
#define FLAG_FRIENDLY       15 /* Will help players */
#define FLAG_SPLITTING      32 /* Object splits into stats.food other objs */
#define FLAG_HITBACK        33 /* Object will hit back when hit */
#define FLAG_UNDEAD     36 /* Monster is undead */
#define FLAG_SCARED     37 /* Monster is scared (mb player in future)*/
#define FLAG_UNAGGRESSIVE   38 /* Monster doesn't attack players */
#define FLAG_NO_STEAL       96 /* Item can't be stolen */

file : server/server/skills.c
/* Singing() -this skill allows the player to pacify nearby creatures.
 * There are few limitations on who/what kind of
 * non-player creatures that may be pacified. Right now, a player
 * may pacify creatures which have Int == 0. In this routine, once
 * successfully pacified the creature gets Int=1. Thus, a player
 * may only pacify a creature once.
 * BTW, I appologize for the naming of the skill, I couldnt think
 * of anything better! -b.t.
 */

int singing(object *pl, int dir, object *skill) {
    int i,exp = 0,chance, mflags;
    object *tmp;
    mapstruct *m;
    sint16  x, y;

    if(pl->type!=PLAYER) return 0;    /* only players use this skill */

    new_draw_info_format(NDI_UNIQUE,0,pl, "You sing");
    for(i=dir;i<(dir+MIN(skill->level,SIZEOFFREE));i++) {
    x = pl->x+freearr_x[i];
    y = pl->y+freearr_y[i];
    m = pl->map;

    mflags =get_map_flags(m, &m, x,y, &x, &y);
    if (mflags & P_OUT_OF_MAP) continue;
    if (!(mflags & P_IS_ALIVE)) continue;

    for(tmp=get_map_ob(m, x, y); tmp;tmp=tmp->above) {
        if(QUERY_FLAG(tmp,FLAG_MONSTER)) break;
        /* can't affect players */
            if(tmp->type==PLAYER) break;
    }

    /* Whole bunch of checks to see if this is a type of monster that would
     * listen to singing.
     */
    if (tmp && QUERY_FLAG(tmp, FLAG_MONSTER) &&
        !QUERY_FLAG(tmp, FLAG_NO_STEAL) &&      /* Been charmed or abused before */
        !QUERY_FLAG(tmp, FLAG_SPLITTING) &&     /* no ears */
        !QUERY_FLAG(tmp, FLAG_HITBACK) &&       /* was here before */
        (tmp->level <= skill->level) &&
        (!tmp->head) &&
        !QUERY_FLAG(tmp, FLAG_UNDEAD) &&
        !QUERY_FLAG(tmp,FLAG_UNAGGRESSIVE) &&   /* already calm */
        !QUERY_FLAG(tmp,FLAG_FRIENDLY)) {       /* already calm */

        /* stealing isn't really related (although, maybe it should
         * be).  This is mainly to prevent singing to the same monster
         * over and over again and getting exp for it.
         */
        chance=skill->level*2+(pl->stats.Cha-5-tmp->stats.Int)/2;
        if(chance && tmp->level*2<random_roll(0, chance-1, pl, PREFER_HIGH)) {
        SET_FLAG(tmp,FLAG_UNAGGRESSIVE);
        new_draw_info_format(NDI_UNIQUE, 0,pl,
             "You calm down the %s\n",query_name(tmp));
        /* Give exp only if they are not aware */
        if(!QUERY_FLAG(tmp,FLAG_NO_STEAL))
            exp += calc_skill_exp(pl,tmp, skill);
        SET_FLAG(tmp,FLAG_NO_STEAL);
        } else {
                 new_draw_info_format(NDI_UNIQUE, 0,pl,
                    "Too bad the %s isn't listening!\n",query_name(tmp));
        SET_FLAG(tmp,FLAG_NO_STEAL);
        }
    }
    }
    return exp;
}

EoI
}


_check_skill_available_stdalone(){
_msg_stdalone 7 "_check_skill_available_stdalone:$*"
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
  _log_stdalone "_check_skill_available_stdalone:$REPLY"
_msg_stdalone 7 "$REPLY"

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

_set_next_direction_stdalone(){
_msg_stdalone 7 "_set_next_direction_stdalone:$*:$DIRN"
_log_stdalone   "_set_next_direction_stdalone:$*:$DIRN"

DIRN=$((DIRN-1))
test "$DIRN" -le 0 && DIRN=8

_number_to_direction_stdalone $DIRN
_draw_stdalone 2 "Will turn to direction $DIRECTION .."
}

__set_next_direction_stdalone(){
_msg_stdalone 7 "__set_next_direction_stdalone:$*:$DIRN"
_log_stdalone   "__set_next_direction_stdalone:$*:$DIRN"

DIRN=$((DIRN+1))
test "$DIRN" -ge 9 && DIRN=1

_number_to_direction_stdalone $DIRN
_draw_stdalone 2 "Will turn to direction $DIRECTION .."
}

_kill_monster_stdalone(){
_msg_stdalone 7 "_kill_monster_stdalone:$*"
_log_stdalone   "_kill_monster_stdalone:$*"

local lATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

# TODO:
#*'You withhold your attack'*)  _set_next_direction_stdalone; break 1;;
#*'You avoid attacking '*)      _set_next_direction_stdalone; break 1;;

for i in `seq 1 1 ${lATTACKS:-1}`; do
_is_stdalone 1 1 $DIRECTION
done
_empty_message_stream_stdalone
}

_brace_stdalone(){
_msg_stdalone 7 "_brace_stdalone:$*"
_log_stdalone   "_brace_stdalone:$*"

_watch_stdalone $DRAWINFO
while :
do
_is_stdalone 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log_stdalone "_brace_stdalone:$REPLY"
 _msg_stdalone 7 "$REPLY"
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
_msg_stdalone 7 "_unbrace_stdalone:$*"
_log_stdalone   "_unbrace_stdalone:$*"

_watch_stdalone $DRAWINFO
while :
do
_is_stdalone 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log_stdalone "_unbrace_stdalone:$REPLY"
 _msg_stdalone 7 "$REPLY"
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

_calm_down_monster_ready_skill_stdalone(){
_msg_stdalone 7 "_calm_down_monster_ready_skill_stdalone:$*"
_log_stdalone   "_calm_down_monster_ready_skill_stdalone:$*"

# Return Possibilities :
# 0 : success calming down, go on with orate
# 1 : no success calming down
#     -> kill the monster and try next in DIRN
#     -> turn to next monster
# 3 : Monster does not respond
#     -> try again
#     -> it is already calmed, go on with orate
#     -> kill monster and try next in DIRN
#     -> turn to next monster

local lRV=

_watch_stdalone $DRAWINFO
 while :;
 do

  _is_stdalone 1 1 fire_stop
  _is_stdalone 1 1 ready_skill singing
  _empty_message_stream_stdalone

  _is_stdalone 1 1 fire $DIRN
  _is_stdalone 1 1 fire_stop
  SINGING_ATTEMPTS_DONE=$((SINGING_ATTEMPTS_DONE+1))

  while :; do unset REPLY
  read -t $TMOUT
  _log_stdalone "_calm_down_monster_ready_skill_stdalone:$REPLY"
  _msg_stdalone 7 "$REPLY"

  case $REPLY in
  # EMPTY response by !FLAG_MONSTER
  # FLAG_NO_STEAL, FLAG_SPLITTING, FLAG_HITBACK,
  # FLAG_UNDEAD, FLAG_UNAGGRESSIVE, FLAG_FRIENDLY
  '') break 2;; #!=PLAYER
  *'You sing'*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit_stdalone;;
  *) :;;
  esac

  sleep 0.01
  done

  while :; do unset REPLY
  read -t $TMOUT
  _log_stdalone "_calm_down_monster_ready_skill_stdalone:$REPLY"
  _msg_stdalone 7 "$REPLY"

  case $REPLY in
  '') lRV=0; break 2;;
  *'You calm down the '*) CALMS=$((CALMS+1)); lRV=0;;
  *"Too bad the "*"isn't listening!"*) _kill_monster_stdalone; break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit_stdalone;;
  *) :;;
  esac

  sleep 0.01
  done

 sleep 0.1
 done

_unwatch_stdalone $DRAWINFO
_draw_stdalone 5 "With ${SINGING_ATTEMPTS_DONE:-0} singings you calmed down ${CALMS:-0} monsters."
#_sleep_stdalone
_msg_stdalone 7 "lRV=$lRV"
return ${lRV:-1}
}

_steal_from_monster_ready_skill_stdalone(){
_msg_stdalone 7 "_steal_from_monster_ready_skill_stdalone:$*"
_log_stdalone   "_steal_from_monster_ready_skill_stdalone:$*"

local lRV=

 while :;
 do

  _watch_stdalone $DRAWINFO
  _is_stdalone 1 1 fire_stop
  _is_stdalone 1 1 ready_skill stealing
  _empty_message_stream_stdalone   # todo : check if skill available

  _is_stdalone 1 1 fire $DIRN
  _is_stdalone 1 1 fire_stop
  STEALING_ATTEMPTS_DONE=$((STEALING_ATTEMPTS_DONE+1))

  while :; do unset REPLY
  read -t $TMOUT
  _log_stdalone "_steal_from_monster_ready_skill_stdalone:$REPLY"
  _msg_stdalone 7 "$REPLY"

  case $REPLY in
  #PLAYER, more, head, msg
  '') lRV=0; break 2;; # monster does not respond at all, try next
  *'There is nothing to orate to.'*) lRV=0; break 2;; # next monster #!tmp
  *'You orate to the '*) break 1;; #tmp
  *scripttell*break*)    break ${REPLY##*?break};;
  *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit_stdalone;;
  *) :;;
  esac

  sleep 0.01
  done

  while :; do unset REPLY
  read -t $TMOUT
  _log_stdalone "_steal_from_monster_ready_skill_stdalone:$REPLY"
  _msg_stdalone 7 "$REPLY"

  case $REPLY in
  #!FLAG_UNAGGRESSIVE && !FLAG_FRIENDLY
  *'Too bad '*) _debug_stdalone "Catched Too bad oratory"; break 2;; # try again singing the kobold isn't listening!
  #FLAG_FRIENDLY && PETMOVE && get_owner(tmp)==pl
  *'Your follower loves '*)          lRV=0; break 2;; # next creature or exit
  #FLAG_FRIENDLY && PETMOVE && (skill->level > tmp->level)
  *"You convince the "*" to follow you instead!"*)   FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  *'You convince the '*' to become your follower.'*) FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  #/* Charm failed. Creature may be angry now */ skill < random_roll
  *"Your speech angers the "*) _debug_stdalone 3 "Catched Anger oratory";   break 2;;
  #/* can't steal from other player */, /* Charm failed. Creature may not be angry now */
  '') break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit_stdalone;;
  *) :;;
  esac

  sleep 0.01
  done

 sleep 0.1
 done

_unwatch_stdalone $DRAWINFO
_draw_stdalone 5 "With ${ORATORY_ATTEMPTS_DONE:-0} oratings you conceived ${FOLLOWS:-0} followers."
#_sleep_stdalone
_msg_stdalone 7 "lRV=$lRV"
return ${lRV:-1}
}

_sing_and_steal_around_stdalone(){
_msg_stdalone 7 "_sing_and_steal_around_stdalone:$*"
_log_stdalone   "_sing_and_steal_around_stdalone:$*"

while :;
do

one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction_stdalone $DIRECTION_OPT || _set_next_direction_stdalone

_calm_down_monster_ready_skill_stdalone
case $? in
 0) _steal_from_monster_ready_skill_stdalone
  case $? in
  0) :;;
  *) _kill_monster_stdalone;;
  esac
 ;;
 *) :;;
esac

_draw_stdalone 2 "You calmed ${CALMS:-0} and convinced ${FOLLOWS:-0} monsters."

case $NUMBER in $one) break;; esac
case $ORATORY_ATTEMPTS in $ORATORY_ATTEMPTS_DONE) break;; esac
case $SINGING_ATTEMPTS in $SINGING_ATTEMPTS_DONE) break;; esac

if _check_counter_stdalone; then
_check_food_level_stdalone
_check_hp_and_return_home_stdalone $HP
fi

_say_script_time_stdalone

done
}


# MAIN

_main_steal_stdalone(){
_msg_stdalone 7 "_main_steal_stdalone:$*"
_log_stdalone   "_main_steal_stdalone:$*"

_set_global_variables_stdalone $*
_do_parameters_stdalone $*

if test "$ATTACKS_SPOT" -a "$COUNT_CHECK_FOOD"; then
 COUNT_CHECK_FOOD=$((COUNT_CHECK_FOOD/ATTACKS_SPOT))
 test "$COUNT_CHECK_FOOD" -le 0 && COUNT_CHECK_FOOD=1
fi

_say_start_msg_stdalone $*

_get_player_speed_stdalone
test "$PL_SPEED1" && __set_sync_sleep_stdalone ${PL_SPEED1} || _set_sync_sleep_stdalone "$PL_SPEED"


_direction_to_number_stdalone $DIRECTION_OPT
_check_skill_available_stdalone singing  || return 1
_check_skill_available_stdalone stealing || return 1

_brace_stdalone
_sing_and_steal_around_stdalone
_unbrace_stdalone
_say_end_msg_stdalone
}

_main_steal_func(){

_source_library_files(){
. $MY_DIR/cf_funcs_common.sh   || { echo draw 3 "$MY_DIR/cf_funcs_common.sh   failed to load."; exit 4; }
. $MY_DIR/cf_funcs_food.sh     ||       _exit 5 "$MY_DIR/cf_funcs_food.sh     failed to load."
. $MY_DIR/cf_funcs_move.sh     ||       _exit 7 "$MY_DIR/cf_funcs_move.sh     failed to load."
. $MY_DIR/cf_funcs_skills.sh   ||       _exit 9 "$MY_DIR/cf_funcs_skills.sh   failed to load."
. $MY_DIR/cf_funcs_fight.sh    ||      _exit 10 "$MY_DIR/cf_funcs_fight.sh    failed to load."
. $MY_DIR/cf_funcs_oratory.sh  ||      _exit 11 "$MY_DIR/cf_funcs_oratory.sh  failed to load."
. $MY_DIR/cf_funcs_requests.sh ||      _exit 12 "$MY_DIR/cf_funcs_requests.sh failed to load."
}
_source_library_files

_debug "_main_steal_func:$*"
_log   "_main_steal_func:$*"

_set_global_variables $*
_say_start_msg $*
_do_parameters $*

_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"


_direction_to_number $DIRECTION_OPT
_check_skill_available singing  || return 1
_check_skill_available stealing || return 1

_brace
_sing_and_steal_around
_unbrace
_say_end_msg
}

 _main_steal_stdalone "$@"
#_main_steal_func "$@"

###END###
