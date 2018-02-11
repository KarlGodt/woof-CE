#!/bin/bash

# Who:
# Created by Karl Reimer Godt
# First version 2018-01-06
# Time elapsed for the crossfire client
# while writing the script was 3,5 hours.
# Most time took error fixes after testing the script.
# Bugs are still likely :( !
#
# About:
# Script to open chests in bulk mode
# for the roleplaying game Crossfire.
# Simple script that does not finetune
# trap handling.
# In case of detonating a trap while
# disarming, it does just exit.
#
# Reason:
# I wrote this script because of lazyness,
# since such scripts to open chests already exist
# in my repositories, but I was too lazy to
# search for these similar scripts.
#
# Style:
# This script was written mainly from memory,
# but used the function _check_if_on_cauldron()
# with modifications for _check_if_on_chest()
# from the cf_functions.sh already available.
# Also used the existing functions
# _is, _draw, _debug, _log, _set_global_variables,
# _say_start_msg, _say_end_msg from cf_functions.sh .
# Added __debug() function to cf_functions.sh
# to draw multiple lines given.

VERSION=0.0
VERSION=0.1 # added parameter processing
# added help and version message
# added script run time message
# reordered some code lines
# early exit if rare ball lightning
# do not break for 'You search the area' message,
#  since that seems to not be in sync with other messages
VERSION=0.2 # code reorderings, smaller bugfixes
VERSION=0.3 # instead using _debug now using a MSGLEVEL
# using PL_SPEED variable before dropping chests and after
#  dropping chests and using a middle value of both
VERSION=0.4 # code cleanup 2018-01-08

VERSION=1.0 # added options to choose between
# use_skill, cast and invoke to disarm traps
VERSION=1.1 # added NUMBER option
# Recognize *help and *version options
VERSION=1.2 # if no DIRECTION then default to invoke
# if cast was given
VERSION=1.3 # handle chest as permanent container: exit.
# handle portal of elementals: exit.
VERSION=1.3.1 # count opened chests
VERSION=2.0 # use sourced functions files
VERSION=2.1 # implement -M option
VERSION=2.1.1 # bugfixes
VERSION=2.2 # more alternative functions
VERSION=2.2.1 # bugfixes
VERSION=3.0 # made the whole script standalone possible
# functions got *_stdalone post-syllable
VERSION=3.1 # code cleanup
VERSION=3.1.1 # false variable names fixed

SEARCH_ATTEMPTS_DEFAULT=9
#DISARM variable set to skill, invokation OR cast
DISARM=skill
PICKUP_ALL_MODE=5  # set pickup 4 or 5

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script

#DEBUG=1
#LOGGING=1
MSGLEVEL=6 # Message Levels 1-7 to print to the msg pane


. $HOME/cf/s/cf_funcs_common.sh || exit 4
. $HOME/cf/s/cf_funcs_food.sh   || exit 5
. $HOME/cf/s/cf_funcs_traps.sh  || exit 6
. $HOME/cf/s/cf_funcs_move.sh   || exit 7
. $HOME/cf/s/cf_funcs_chests.sh || exit 8

_say_help_stdalone(){
_draw_stdalone 6  "$MY_BASE"
_draw_stdalone 7  "Script to search for traps,"
_draw_stdalone 7  "disarming them,"
_draw_stdalone 7  "and open chest(s)."
_draw_stdalone 2  "To be used in the crossfire roleplaying game client."
_draw_stdalone 6  "Syntax:"
_draw_stdalone 7  "$0 <<NUMBER>> <<Options>>"
_draw_stdalone 8  "Options:"
_draw_stdalone 10 "Simple number as first parameter:Just open NUMBER chests."
_draw_stdalone 10 "-C # :like above, just open NUMBER chests."
_draw_stdalone 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw_stdalone 10 "-M   :Do not break search when found first trap,"
_draw_stdalone 10 "      usefull if chests have more than one trap."
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
_draw 7  "and open chest(s)."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 6  "Syntax:"
_draw 7  "$0 <<NUMBER>> <<Options>>"
_draw 8  "Options:"
_draw 10 "Simple number as first parameter:Just open NUMBER chests."
_draw 10 "-C # :like above, just open NUMBER chests."
_draw 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw 10 "-M   :Do not break search when found first trap,"
_draw 10 "      usefull if chests have more than one trap."
_draw 11 "-V   :Print version information."
_draw 12 "-c   :cast spell disarm"
_draw 12 "-i   :invoke spell disarm"
_draw 12 "-u   :use_skill disarm"
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

# *** EXIT FUNCTIONS *** #
_exit_stdalone(){
case $1 in
[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) RV=$1; shift;;
esac

_move_back_and_forth_stdalone 2
_sleep_stdalone
test "$*" && _draw_stdalone 3 $@
_draw_stdalone 3 "Exiting $0. PID was $$"
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
*scroll*) _is 1 1 apply ${lRETURN_ITEM};;
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

_exit_no_space_stdalone(){
_draw_stdalone 3 "On position $nr $DIRB there is something ($IS_WALL)!"
_draw_stdalone 3 "Remove that item and try again."
_draw_stdalone 3 "If this is a wall, try on another place."
_beep_std_stdalone
exit ${1:-0}
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

# ** In case of an early break out of a read loop
# **  and not setting unwatch, the pipeline of fd/0
# **  may still contain (masses!) of lines from the previous
# **  watch, thus making it hard for the next reads of fd/0
# **  to catch the correct line(s) -- especially for request
# ** This function just reads the input-fd ** #
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

_is_stdalone(){
# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.
    _debug_stdalone "issue $*"
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

_drop_chest_stdalone(){
local lITEM="$*"
_is_stdalone 0 0 drop ${lITEM:-chest}
sleep 3
}

_drop_stdalone(){
 _sound_stdalone 0 drip &
 #_is_stdalone 1 1 drop "$@" #01:58 There are only 1 chests.
  _is_stdalone 0 0 drop "$@"
}

_set_pickup_stdalone(){
# Usage: pickup <0-7> or <value_density> .
# pickup 0:Don't pick up.
# pickup 1:Pick up one item.
# pickup 2:Pick up one item and stop.
# pickup 3:Stop before picking up.
# pickup 4:Pick up all items.
# pickup 5:Pick up all items and stop.
# pickup 6:Pick up all magic items.
# pickup 7:Pick up all coins and gems
#
#TODO: In pickup 4 and 5 mode
# seems to pick up only
# one piece of the topmost item, if more than one
# piece of the item, as 4 coins or 23 arrows
# but all items below the topmost item get
# picked up wholly
# in _open_chests() ..?
#_is_stdalone 0 0 pickup ${*:-0}
#_is_stdalone 1 0 pickup ${*:-0}
#_is_stdalone 0 1 pickup ${*:-0}
 _is_stdalone 1 1 pickup ${*:-0}
}

_move_back_stdalone(){  ##+++2018-01-08
test "$DIRB" || return 0
for i in `seq 1 1 ${1:-1}`
do
_is_stdalone 1 1 $DIRB
_sleep_stdalone
done
}

_move_forth_stdalone(){  ##+++2018-01-08
test "$DIRF" || return 0
for i in `seq 1 1 ${1:-1}`
do
_is_stdalone 1 1 $DIRF
_sleep_stdalone
done
}

_move_back_and_forth_stdalone(){  ##+++2018-01-08
STEPS=${1:-1}

#test "$DIRB" -a "$DIRF" || return 0
test "$DIRB" || return 0
for i in `seq 1 1 $STEPS`
do
_is_stdalone 1 1 $DIRB
_sleep_stdalone
done

if test "$2"; then shift
 while test "$1";
 do
 COMMANDS=`echo "$1" | tr ';' '\n'`
 test "$COMMANDS" || break 1
  echo "$COMMANDS" | while read line
  do
  $line
  sleep 0.1
  done

 shift
 sleep 0.1
 done
fi

test "$DIRF" || return 0
for i in `seq 1 1 $STEPS`
do
_is_stdalone 1 1 $DIRF
_sleep_stdalone
done
}

_check_for_space_stdalone(){
# *** Check for [4] empty space to DIRB *** #
_debug_stdalone "_check_for_space_stdalone:$*"

local REPLY_MAP OLD_REPLY NUMBERT
test "$1" && NUMBERT="$1"
NUMBERT=${NUMBERT:-4}
test "${NUMBERT//[[:digit:]]/}" && _exit_stdalone 2 "_check_for_space_stdalone: Need a digit. Invalid parameter passed:$*"

_draw_stdalone 5 "Checking for space to move..."

_empty_message_stream_stdalone
echo request map pos

# client v.1.70.0 request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0 request map pos 272 225 ##cauldron adventurers guild stoneville

while :; do
read -t $TMOUT REPLY_MAP
#echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
_log_stdalone "$REPLY_LOG" "_check_for_space_stdalone:request map pos:$REPLY_MAP"
_debug_stdalone "$REPLY_MAP"
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'` #request map pos:request map pos 280 231
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
;;
north)
R_X=$PL_POS_X
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

_empty_message_stream_stdalone
echo request map $R_X $R_Y

while :; do
read -t $TMOUT
_log_stdalone "$REPLY_LOG" "_check_for_space_stdalone:request map '$R_X' '$R_Y':$REPLY"
_debug_stdalone "$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`

_log_stdalone "$REPLY_LOG" "IS_WALL=$IS_WALL"
_debug_stdalone "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space_stdalone 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

done

 else
  _exit_stdalone 1 "Received Incorrect X Y parameters from server."
 fi

else
 _exit_stdalone 1 "Could not get X and Y position of player."
fi

_draw_stdalone 7 "OK."
}

_check_for_space_old_client_stdalone(){
# *** Check for 4 empty space to DIRB *** #
_debug_stdalone "_check_for_space_old_client_stdalone:$*"

local REPLY_MAP OLD_REPLY NUMBERT cm
test "$1" && NUMBERT="$1"
NUMBERT=${NUMBERT:-4}
test "${NUMBERT//[[:digit:]]/}" && _exit_stdalone 2 "_check_for_space_old_client_stdalone: Need a digit. Invalid parameter passed:$*"

_draw_stdalone 5 "Checking for space to move..."

_empty_message_stream_stdalone
echo request map near

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville
#                request map near:request map     279 231  0 n n n n smooth 30 0 0 heads 4854 825 0 tails 0 0 0
cm=0
while :; do
cm=$((cm+1))
read -t $TMOUT REPLY_MAP
_log_stdalone "$REPLY_LOG" "_check_for_space_old_client_stdalone:request map near:$REPLY_MAP"
_debug_stdalone "$REPLY_MAP"
test "$cm" = 5 && break
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

_empty_message_stream_stdalone

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $3}'` #request map near:request map 278 230  0 n n n n smooth 30 0 0 heads 4854 0 0 tails 0 0 0
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $4}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

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

_empty_message_stream_stdalone
echo request map $R_X $R_Y

while :; do
read -t $TMOUT
_log_stdalone "$REPLY_LOG" "_check_for_space_old_client_stdalone:request map '$R_X' '$R_Y':$REPLY"
_debug_stdalone "$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`

_log_stdalone "$REPLY_LOG" "IS_WALL=$IS_WALL"
_debug_stdalone "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space_stdalone 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

done

 else
  _exit_stdalone 1 "Received Incorrect X Y parameters from server."
 fi

else
 _exit_stdalone 1 "Could not get X and Y position of player."
fi

_draw_stdalone 7 "OK."
}

_check_if_on_item_stdalone(){
_debug_stdalone "_check_if_on_item_stdalone:$*"

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
test "$DO_LOOP" && return 1 || _exit_stdalone 1
}

_check_if_on_item_examine_stdalone(){
# Using 'examine' directly after dropping
# the item examines the bottommost tile
# as 'That is marble'
_debug_stdalone "_check_if_on_item_examine_stdalone:$*"

local DO_LOOP TOPMOST LIST
unset DO_LOOP TOPMOST LIST

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

_watch_stdalone $DRAWINFO
while :; do unset REPLY
_is_stdalone 0 0 examine
_sleep_stdalone
read -t $TMOUT
 _log_stdalone "_check_if_on_item_examine_stdalone:$REPLY"
 _msg_stdalone 7 "$REPLY"

 case $REPLY in
  *"That is"*"$lITEM"*|*"Those are"*"$lITEM"*|*"Those are"*"${lITEM// /?*}"*) break 1;;
  *"That is"*|*"Those are"*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit_stdalone;;
  '') break 1;;
  *) continue;; #:;;
 esac

LIST="$LIST
$REPLY"
sleep 0.01
done

_unwatch_stdalone
_empty_message_stream_stdalone

LIST=`echo "$LIST" | sed 'sI^$II'`

if test "$TOPMOST"; then
 echo "${LIST:-$REPLY}"  | tail -n1 | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"
else
 echo "$REPLY"                      | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"
fi
local lRV=$?
test "$lRV" = 0 && return $lRV

if test "$DO_LOOP"; then
 return ${lRV:-3}
else
  _exit ${lRV:-3} "$lITEM not here or not on top of stack."
fi
}

__check_if_on_chest_request_items_on_stdalone(){
_debug_stdalone "__check_if_on_chest_request_items_on_stdalone:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST
#
#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

#_draw_stdalone 5 "Checking if standing on chests ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream_stdalone
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log_stdalone "$ON_LOG" "__check_if_on_chest_request_items_on_stdalone:$UNDER_ME"
_msg_stdalone 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)    _exit_stdalone 1 $REPLY;;
*'YOU HAVE DIED.'*) _just_exit_stdalone;;
*) :;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.01s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug_stdalone "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_CHEST=`echo "$UNDER_ME_LIST" | grep 'chest' | wc -l`

test "`echo "$UNDER_ME_LIST" | grep 'chest.*cursed'`" && {
_draw_stdalone 3 "You appear to stand upon some cursed chest!"
_beep_std_stdalone
test "$1" && return 1 || exit 1
}

test "`echo "$UNDER_ME_LIST" | grep -E 'chest$|chests$'`" || {
_draw_stdalone 3 "You appear not to stand on some chest!"
_beep_std_stdalone
test "$1" && return 1 || exit 1
}

test "`echo "$UNDER_ME_LIST" | tail -n1 | grep 'chest.*cursed'`" && {
_draw_stdalone 3 "Topmost chest appears to be cursed!"
_beep_std_stdalone
test "$1" && return 1 || exit 1
}

test "`echo "$UNDER_ME_LIST" | tail -n1 | grep -E 'chest$|chests$'`" || {
_draw_stdalone 3 "Chest appears not topmost!"
_beep_std_stdalone
test "$1" && return 1 || exit 1
}

return 0
}

_check_if_on_chest_request_items_on_stdalone(){
_debug_stdalone "_check_if_on_chest_request_items_on_stdalone:$*"

local DO_LOOP TOPMOST lRV
unset DO_LOOP TOPMOST lRV

while [ "$1" ]; do
case $1 in
-l) DO_LOOP=1;;
-t) TOPMOST=1;;
-lt|-tl) DO_LOOP=1; TOPMOST=1;;
*) break;;
esac
shift
done

#_draw_stdalone 5 "Checking if standing on chests ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream_stdalone
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log_stdalone "$ON_LOG" "_check_if_on_chest_request_items_on_stdalone:$UNDER_ME"
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

NUMBER_CHEST=`echo "$UNDER_ME_LIST" | grep 'chest' | wc -l`

test "`echo "$UNDER_ME_LIST" | grep -E 'chest.*cursed|chest.*damned'`" && lRV=5
test "`echo "$UNDER_ME_LIST" | grep -E 'chest$|chests$'`" || lRV=6

if test "$TOPMOST"; then
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep -E 'chest.*cursed|chest.*damned'`" && lRV=7
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep -E 'chest$|chests$'`" || lRV=${lRV:-8}
fi

return ${lRV:-0}
}

_eval_check_if_on_chest_request_items_on_stdalone(){
_debug_stdalone "_eval_check_if_on_chest_request_items_on_stdalone:$*"

 #__check_if_on_chest_request_items_on_stdalone $1
   _check_if_on_chest_request_items_on_stdalone $1
  local lRV=$?
case $lRV in
5) _draw_stdalone 3 "You appear to stand upon some cursed chest!";;
6) _draw_stdalone 3 "You appear not to stand on some chest!";;
7) _draw_stdalone 3 "Topmost chest appears to be cursed!";;
8) _draw_stdalone 3 "Chest appears not topmost!";;
0) return 0;;
*) _warn "_eval_check_if_on_chest_request_items_on_stdalone:Unhandled return value '$lRV'";;
esac
_beep_std_stdalone
case $1 in -l|-lt|-tl) return 1;; *) _just_exit_stdalone 1;; esac
}

_check_if_on_chest_stdalone(){  ###+++2018-01-19
_debug_stdalone "_check_if_on_chest_stdalone:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST
#
#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

_draw_stdalone 5 "Checking if standing on chests ..."

#_check_if_on_item_examine_stdalone $1 chest       && return 0
#_check_if_on_chest_request_items_on_stdalone $1 && return 0

  _check_if_on_chest_request_items_on_stdalone $1
  local lRV=$?
case $lRV in
5) _draw_stdalone 3 "You appear to stand upon some cursed chest!";;
6) _draw_stdalone 3 "You appear not to stand on some chest!";;
7) _draw_stdalone 3 "Topmost chest appears to be cursed!";;
8) _draw_stdalone 3 "Chest appears not topmost!";;
0) return 0;;
*) _warn "_check_if_on_chest_stdalone:Unhandled return value '$lRV'";;
esac
_beep_std_stdalone
case $1 in -l|-lt|-tl) return 1;; *) _just_exit_stdalone 1;; esac
}

_check_if_on_chest_stdalone(){
_debug_stdalone "_check_if_on_chest_stdalone:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST
#
#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

_draw_stdalone 5 "Checking if standing on chests ..."

#_check_if_on_item_examine_stdalone $1 chest
#_check_if_on_chest_request_items_on_stdalone $1
_eval_check_if_on_chest_request_items_on_stdalone $1
}

_search_traps_stdalone(){
_debug_stdalone "_search_traps_stdalone:$*"

cnt=${*:-$SEARCH_ATTEMPTS}
cnt=${cnt:-$SEARCH_ATTEMPTS_DEFAULT}
test "$cnt" -gt 0 || return 0

_draw_stdalone 5 "Searching traps ..."
TRAPS_ALL_OLD=0
TRAPS_ALL=$TRAPS_ALL_OLD

while :
do

_draw_stdalone 5 "Searching traps $cnt time(s) ..."

_watch_stdalone ${DRAWINFO}
_sleep_stdalone
_is_stdalone 0 0 search
_sleep_stdalone

 unset cnt0 FOUND_TRAP
 while :
 do
 cnt0=$((cnt0+1))
 unset REPLY
 read -t $TMOUT
 _log_stdalone "_search_traps_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

#You spot a Rune of Burning Hands!
#You spot a poison needle!
#You spot a spikes!
#You spot a Rune of Shocking!
#You spot a Rune of Icestorm!
#You search the area.
#You spot a Rune of Ball Lightning!
 case $REPLY in
 *'You spot a Rune of Ball Lightning!'*) _just_exit_stdalone 0;;
 *'You spot a Rune of Create Bomb!'*)    _just_exit_stdalone 0;;
 *' spot '*) FOUND_TRAP=$((FOUND_TRAP+1));;
 *'You search the area.'*) SEARCH_MSG=$((SEARCH_MSG+1));; # break 1;;
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') break 1;;
 *) :;;
 esac

 sleep 0.1
 done

test "$FOUND_TRAP" && _draw_stdalone 2 "Found $FOUND_TRAP trap(s)."
TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
_debug_stdalone "TRAPS_ALL=$TRAPS_ALL"
test "$TRAPS_ALL_OLD" -gt $TRAPS_ALL && TRAPS_ALL=$TRAPS_ALL_OLD
_debug_stdalone "TRAPS_ALL=$TRAPS_ALL"
TRAPS_ALL_OLD=${TRAPS_ALL:-0}
_debug_stdalone "FOUND_TRAP=$FOUND_TRAP TRAPS_ALL_OLD=$TRAPS_ALL_OLD"

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$MULTIPLE_TRAPS" || {
    test "$TRAPS_ALL" -ge 1 && break 1; }

cnt=$((cnt-1))
test "$cnt" -gt 0 || break 1

done

unset cnt
}

_cast_disarm_stdalone(){
_debug_stdalone "_cast_disarm_stdalone:$*"

test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw_stdalone 5 "${TRAPS:-0} trap(s) to disarm ..."

# TODO: checks for enough mana
_watch_stdalone $DRAWINFO
_is_stdalone 0 0 cast disarm
_sleep_stdalone
_is_stdalone 0 0 fire 0
_is_stdalone 0 0 fire_stop
_sleep_stdalone

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log_stdalone "_cast_disarm:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) break 2;;
 *'Something blocks your spellcasting.') _exit_stdalone 1;;
 *scripttell*break*)   break 2;;
 *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac

 sleep 0.1
 done

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$TRAPS" -gt 0 || break 1
done

_unwatch_stdalone $DRAWINFO
}

_invoke_disarm_stdalone(){ ## invoking does to a direction
_debug_stdalone "_invoke_disarm_stdalone:$*"

test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

_move_back_stdalone 2
_move_forth_stdalone 1
_sleep_stdalone

while :
do
_draw_stdalone 5 "${TRAPS:-0} trap(s) to disarm ..."

_watch_stdalone $DRAWINFO
_is_stdalone 0 0 invoke disarm
_sleep_stdalone

#There's nothing there!
#You fail to disarm the diseased needle.
#You successfully disarm the diseased needle!
 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log_stdalone "_invoke_disarm_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 # Here there could be a trap next to the stack of chests ...
 # so invoking disarm towards the stack of chests would not
 # work to disarm the traps elsewhere on tiles around
 *"There's nothing there!"*) break 2;;
 *'Something blocks your spellcasting.') _exit_stdalone 1;;
 *scripttell*break*)   break 2;;
 *scripttell*exit*)    _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 *) :;;
 esac
 done

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$TRAPS" -gt 0 || break 1
done

_unwatch_stdalone $DRAWINFO
_move_forth_stdalone 1
}

_use_skill_disarm_stdalone(){
_debug_stdalone "_use_skill_disarm_stdalone:$*"

test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw_stdalone 5 "${TRAPS:-0} trap(s) to disarm ..."

_watch_stdalone $DRAWINFO
_is_stdalone 0 0 use_skill disarm
_sleep_stdalone

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log_stdalone "_use_skill_disarm_stdalone:$cnt0:$REPLY"
 _msg_stdalone 7 "$cnt0:$REPLY"

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
 *'A portal opens up, and screaming hordes pour'*) _just_exit_stdalone 1;;
 *'through!'*)     _just_exit_stdalone 1;;
 *"RUN!  The timer's ticking!"*) _just_exit_stdalone 1;;
 *'You are pricked'*) :;;
 *'You are stabbed'*) :;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') break 1;;
 *) :;;
 esac

 _sleep_stdalone
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

_move_back_and_forth_stdalone 2

_unwatch_stdalone $DRAWINFO
_sleep_stdalone

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

_disarm_traps_stdalone(){
_debug_stdalone "_disarm_traps_stdalone:$*"
_draw_stdalone 5 "Disarming ${TRAPS_ALL:-0} traps ..."
case "$DISARM" in
invokation) _invoke_disarm_stdalone;;
cast|spell) #case "$DIRECTION" in '') _invoke_disarm_stdalone;; *) _cast_disarm_stdalone;; esac;;
            _cast_disarm_stdalone;;
skill|'') _use_skill_disarm_stdalone;;
*) _error "DISARM variable set not to skill, invokation OR cast'";;
esac
}

_open_chests_stdalone(){
_debug_stdalone "_open_chests_stdalone:$*"

_draw_stdalone 5 "Opening chests ..."

unset one
while :
do
one=$((one+1))

_drop_stdalone chest
_sleep_stdalone
_move_back_and_forth_stdalone 2

_check_if_on_chest_stdalone -lt || break 1
_sleep_stdalone

_draw_stdalone 5 "${NUMBER_CHEST:-?} chest(s) to open ..."

_watch_stdalone
_is_stdalone 1 1 apply

 unset OPEN_COUNT
 while :; do unset REPLY
 read -t ${TMOUT:-1}
 _log_stdalone "_open_chests_stdalone:$REPLY"
 _msg_stdalone 7 "$REPLY"
 case $REPLY in
 *'You find'*)   OPEN_COUNT=1;;
 *empty*)        OPEN_COUNT=1;;
 *'You open chest.'*) break 2;; # permanent container
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit_stdalone 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit_stdalone;;
 '') break 1;;
 esac
 sleep 0.01
 done
_unwatch_stdalone
test "$OPEN_COUNT" && CHEST_COUNT=$((CHEST_COUNT+1))
# TODO : You find*Rune of*
#You find Blades trap in the chest.
#You set off a Blades trap!
#You find silver coins in the chest.
#You find booze in the chest.
#You find Rune of Shocking in the chest.
#You detonate a Rune of Shocking
#The chest was empty.
#11:50 You open chest.
#11:50 You close chest (open) (active).

_move_back_and_forth_stdalone 2 "_set_pickup_stdalone ${PICKUP_ALL_MODE:-4};_sleep_stdalone;"

if _check_counter_stdalone; then
_check_food_level_stdalone
_check_hp_and_return_home_stdalone $HP
fi

_is_stdalone 0 0 get all

_set_pickup_stdalone 0
_sleep_stdalone

case $NUMBER in $one) break 1;; esac

done
}

#** we may get attacked and die **#
_check_hp_and_return_home_stdalone(){
_debug_stdalone "_check_hp_and_return_home_stdalone:$*"

local currHP currHPMin
currHP=${1:-$HP}
currHPMin=${2:-$HP_MIN_DEF}
currHPMin=${currHPMin:-$((MHP/10))}

_msg_stdalone 7 "currHP=$currHP currHPMin=$currHPMin"
if test "$currHP" -le ${currHPMin:-20}; then

 __old_recall(){
 _empty_message_stream_stdalone
 _is_stdalone 1 1 apply -u ${RETURN_ITEM:-'rod of word of recall'}
 _is_stdalone 1 1 apply -a ${RETURN_ITEM:-'rod of word of recall'}
 _empty_message_stream_stdalone

 _is_stdalone 1 1 fire center ## TODO: check if already applied and in inventory
 _is_stdalone 1 1 fire_stop

 _empty_message_stream_stdalone
 _unwatch_stdalone $DRAWINFO
 exit 5
 }

_emergency_exit_stdalone
fi

unset HP
}

_check_food_level_stdalone(){
_debug_stdalone "_check_food_level_stdalone:$*"

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
   _log_stdalone "HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL"
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
   _log_stdalone "HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL"
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

_check_mana_for_create_food_stdalone(){
_debug_stdalone "_check_mana_for_create_food_stdalone:$*"

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
 _debug_stdalone "MANA_NEEDED=$MANA_NEEDED"
 test "$lSP" -ge "$MANA_NEEDED" && return 0 || break 1
 ;;
 *'Something blocks your spellcasting.'*) _exit_stdalone 1;;
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

_cast_create_food_and_eat_stdalone(){
_debug_stdalone "_cast_create_food_and_eat_stdalone:$*"

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

_eat_food_from_inventory_stdalone(){
_debug_stdalone "_eat_food_from_inventory_stdalone:$*"

local lEAT_FOOD="${@:-$EAT_FOOD}"
lEAT_FOOD=${lEAT_FOOD:-"$FOOD_DEF"}
test "$lEAT_FOOD" || return 254

#_check_food_in_inventory_stdalone ## Todo: check if food is in INV
_check_have_item_in_inventory_stdalone $lEAT_FOOD && _is_stdalone 1 1 apply $lEAT_FOOD
#_is_stdalone 1 1 apply $lEAT_FOOD
}

_check_have_item_in_inventory_stdalone(){
_debug_stdalone "_check_have_item_in_inventory_stdalone:$*"

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
 _log_stdalone "_check_have_item_in_inventory_stdalone:$oneITEM"
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

_say_start_msg_stdalone(){
# *** Here begins program *** #
_draw_stdalone 2 "$0 has started.."
_draw_stdalone 2 "PID is $$ - parentPID is $PPID"

_check_drawinfo_stdalone

# *** Check for parameters *** #
_draw_stdalone 5 "Checking the parameters ($*)..."
}

_check_drawinfo_stdalone(){  ##+++2018-01-08
_debug_stdalone "_check_drawinfo_stdalone:$*"

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

_do_parameters_stdalone(){
_debug_stdalone "_do_parameters_stdalone:$*"

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

# S # :Search attempts
# u   :use_skill
# c   :cast disarm
# i   :invoke disarm
# d   :debugging output
while getopts C:S:ciudMVhabdefgjklmnopqrstvwxyzABDEFGHIJKLNOPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;
M) MULTIPLE_TRAPS=$((MULTIPLE_TRAPS+1));;
c) DISARM=cast;;
i) DISARM=invokation;;
u) DISARM=skill;;
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

# S # :Search attempts
# u   :use_skill
# c   :cast disarm
# i   :invoke disarm
# d   :debugging output
while getopts C:S:ciudMVhabdefgjklmnopqrstvwxyzABDEFGHIJKLNOPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;
M) MULTIPLE_TRAPS=$((MULTIPLE_TRAPS+1));;
c) DISARM=cast;;
i) DISARM=invokation;;
u) DISARM=skill;;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

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

_get_player_speed_stdalone(){
_debug_stdalone "_get_player_speed_stdalone:$*"

if test "$1" = '-l'; then # loop counter
 _check_counter_stdalone || return 1
 shift
fi

  __old_req(){
  local reqANSWER OLD_ANSWER PL_SPEED
  reqANSWER=
  OLD_ANSWER=

  while :; do
  read -t $TMOUT reqANSWER
  #read -t $TMOUT r s c WC AC DAM PL_SPEED WP_SPEED
  #reqANSWER="$r $s $c $WC $AC $DAM $PL_SPEED $WP_SPEED"
  _log_stdalone "$REQUEST_LOG" "_get_player_speed:__old_req:$reqANSWER"
  _msg_stdalone 7 "$reqANSWER"
  test "$reqANSWER" || break
  test "$reqANSWER" = "$OLD_ANSWER" && break
  OLD_ANSWER="$reqANSWER"
  sleep 0.1
  done

  #PL_SPEED=`awk '{print $7}' <<<"$reqANSWER"`    # *** bash
  test "$reqANSWER" && PL_SPEED0=`echo "$reqANSWER" | awk '{print $7}'` # *** ash + bash
  PL_SPEED=${PL_SPEED0:-$PL_SPEED}
  }

  __new_req(){
  read -t $TMOUT r s c WC AC DAM PL_SPEED WP_SPEED
  _log_stdalone "$REQUEST_LOG" "_get_player_speed_stdalone:__new_req:$r $s $c $WC $AC $DAM PL_SPPED=$PL_SPEED $WP_SPEED"
  _msg_stdalone 7 "$r $s $c $WC $AC $DAM PL_SPPED=$PL_SPEED $WP_SPEED"
  }

 _use_old_funcs(){
 _empty_message_stream_stdalone
 echo request stat cmbt # only one line
 #__old_req
 __new_req
 }

 _use_new_funcs(){
 #__request_stdalone stat cmbt
  _request_stdalone stat cmbt
 test "$ANSWER" && PL_SPEED0=`echo "$ANSWER" | awk '{print $7}'`
 PL_SPEED=${PL_SPEED0:-$PL_SPEED}
 }

_draw_stdalone 5 "Processing Player's speed..."
#_use_old_funcs
_use_new_funcs

PL_SPEED=${PL_SPEED:-50000} # 0.50

_player_speed_to_human_readable_stdalone $PL_SPEED
_msg_stdalone 6 "Using player speed '$PL_SPEED1'"

_draw_stdalone 6 "Done."
return 0
}

_check_counter_stdalone(){
ckc=$((ckc+1))
test "$ckc" -lt ${COUNT_CHECK_FOOD:-11} && return 1
ckc=0
return 0
}

__request_stdalone(){ # for multi-line replies
test "$*" || return 254

local lANSWER lOLD_ANSWER
lANSWER=
lOLD_ANSWER=

_empty_message_stream_stdalone
echo request $*
while :; do
 read -t $TMOUT lANSWER
 _log_stdalone "$REQUEST_LOG" "__request_stdalone $*:$lANSWER"
 _msg_stdalone 7 "$lANSWER"
 case $lANSWER in ''|$lOLD_ANSWER|*request*end) break 1;; esac
 ANSWER="$ANSWER
$lANSWER"
lOLD_ANSWER="$lANSWER"
sleep 0.01
done
ANSWER=`echo "$ANSWER" | sed 'sI^$II'`
test "$ANSWER"
}

_request_stdalone(){  # for one line replies
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

_player_speed_to_human_readable_stdalone(){
_debug_stdalone "_player_speed_to_human_readable_stdalone:$*"

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
echo "_round_up_and_down_stdalone:$1" >&2
               #123
STELLEN=${#1}  #3
echo "STELLEN=$STELLEN" >&2

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

_set_sync_sleep_stdalone(){
_debug_stdalone "_set_sync_sleep_stdalone:$*"

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

_set_pickup_stdalone(){
# Usage: pickup <0-7> or <value_density> .
# pickup 0:Don't pick up.
# pickup 1:Pick up one item.
# pickup 2:Pick up one item and stop.
# pickup 3:Stop before picking up.
# pickup 4:Pick up all items.
# pickup 5:Pick up all items and stop.
# pickup 6:Pick up all magic items.
# pickup 7:Pick up all coins and gems
#
#TODO: In pickup 4 and 5 mode
# seems to pick up only
# one piece of the topmost item, if more than one
# piece of the item, as 4 coins or 23 arrows
# but all items below the topmost item get
# picked up wholly
# in _open_chests() ..?

#_is_stdalone 0 0 pickup ${*:-0}
#_is_stdalone 1 0 pickup ${*:-0}
#_is_stdalone 0 1 pickup ${*:-0}
 _is_stdalone 1 1 pickup ${*:-0}
}

_drop(){
 _sound_stdalone 0 drip &
 #_is_stdalone 1 1 drop "$@" #01:58 There are only 1 chests.
  _is_stdalone 0 0 drop "$@"
}


#MAIN

_main_open_chests_func(){
_debug "_main_open_chests_func:$*"
_set_global_variables $*
_say_start_msg $*
_do_parameters $*

test "$FUNCTION_CHECK_FOR_SPACE" && $FUNCTION_CHECK_FOR_SPACE 2
_sleep

_get_player_speed
PL_SPEED2=$PL_SPEED1
_sleep

_drop chest
_sleep
_set_pickup 0
_move_back_and_forth 2 # this is needed for _check_if_on_item_examine

_get_player_speed
PL_SPEED3=$PL_SPEED1
_sleep
PL_SPEED4=$(( (PL_SPEED2+PL_SPEED3) / 2 ))
test "$PL_SPEED4" && __set_sync_sleep ${PL_SPEED4} || _set_sync_sleep "$PL_SPEED"

#_check_if_on_item_examine chest || return 1
#_check_if_on_chest_request_items_on || return 1
_check_if_on_chest || return 1

_sleep

_search_traps
_disarm_traps
_open_chests
}

_main_open_chests_stdalone(){
_debug_stdalone "_main_open_chests_stdalone:$*"

_set_global_variables_stdalone $*
_say_start_msg_stdalone $*
_do_parameters_stdalone $*

test "$FUNCTION_CHECK_FOR_SPACE" && $FUNCTION_CHECK_FOR_SPACE 2
_sleep_stdalone

_get_player_speed_stdalone
PL_SPEED2=$PL_SPEED1
_sleep_stdalone

_drop_stdalone chest
_sleep_stdalone
_set_pickup_stdalone 0
_move_back_and_forth_stdalone 2 # this is needed for _check_if_on_item_examine_stdalone

_get_player_speed_stdalone
PL_SPEED3=$PL_SPEED1
_sleep_stdalone
PL_SPEED4=$(( (PL_SPEED2+PL_SPEED3) / 2 ))
test "$PL_SPEED4" && __set_sync_sleep_stdalone ${PL_SPEED4} || _set_sync_sleep_stdalone "$PL_SPEED"

#_check_if_on_item_examine_stdalone chest || return 1
#_check_if_on_chest_request_items_on_stdalone || return 1
 _check_if_on_chest_stdalone -l || return 1

_sleep_stdalone

_search_traps_stdalone
_disarm_traps_stdalone
_open_chests_stdalone
}

#_main_open_chests_func "$@"
 _main_open_chests_stdalone "$@"

_draw_stdalone 8 "You opened ${CHEST_COUNT:-0} chest(s)."

_say_end_msg_stdalone
###END###
