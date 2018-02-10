#!/bin/ash

VERSION=0.0 # Initial version, that did not process much messages
VERSION=1.0 # first "reliable" version 2018-01-23
VERSION=1.1 # cleanups and add missing calls to
# _get_player_speed and *_set_sync_sleep
VERSION=2.0 # made it standalone
VERSION=2.1 # bugfixes and request enhancements 2018-02-09
VERSION=2.1.1 # bugfix if -D option used, exit if "YOU HAVE DIED." msg

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
LOGGING=1

# ATTACK_ATTEMPTS_DEFAULT=1
#ORATORY_ATTEMPTS_DEFAULT=1
#SINGING_ATTEMPTS_DEFAULT=1

. $HOME/cf/s/cf_funcs_common.sh || exit 4
. $HOME/cf/s/cf_funcs_food.sh   || exit 5
. $HOME/cf/s/cf_funcs_move.sh   || exit 7

. $HOME/cf/s/cf_funcs_skills.sh || exit 9
. $HOME/cf/s/cf_funcs_fight.sh  || exit 10
. $HOME/cf/s/cf_funcs_oratory.sh || exit 11
. $HOME/cf/s/cf_funcs_requests.sh || exit 12

_say_help_stdalone(){
_draw_stdalone 6  "$MY_BASE"
_draw_stdalone 7  "Script to calm down monsters"
_draw_stdalone 7  "by skill singing and then"
_draw_stdalone 7  "making them pets by skill oratory."
_draw_stdalone 2  "To be used in the crossfire roleplaying game client."
_draw_stdalone 6  "Syntax:"
_draw_stdalone 7  "$0 <<NUMBER>> <<Options>>"
_draw_stdalone 8  "Options:"
_draw_stdalone 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw_stdalone 10 "-C # :like above, just make NUMBER loop rounds."
_draw_stdalone 9  "-O # :Number of oratory attempts." #, default $ORATORY_ATTEMPTS_DEFAULT"
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
_draw 7  "making them pets by skill oratory."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 6  "Syntax:"
_draw 7  "$0 <<NUMBER>> <<Options>>"
_draw 8  "Options:"
_draw 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw 10 "-C # :like above, just make NUMBER loop rounds."
_draw 9  "-O # :Number of oratory attempts." #, default $ORATORY_ATTEMPTS_DEFAULT"
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
echo draw 3 "Exiting $0."
_unwatch_stdalone
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
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)      _exit_stdalone 1 $REPLY;;
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

_check_counter_stdalone(){
ckc=$((ckc+1))
test "$ckc" -lt ${COUNT_CHECK_FOOD:-11} && return 1
ckc=0
return 0
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
test "$DO_LOOP" && return 1 || _exit_stdalone 1 $lMSG
}

#** we may get attacked and die **#
_check_hp_and_return_home_stdalone(){
_debug_stdalone "_check_hp_and_return_home_stdalone:$*"

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
_debug_stdalone "__check_food_level_stdalone:$*"

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
_debug_stdalone "_check_food_level_stdalone:$*"

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
  *scripttell*break*) break ${REPLY##*?break};;
  *scripttell*exit*)  _exit_stdalone 1 $REPLY;;
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
_debug_stdalone "__get_player_speed_stdalone:$*"

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

# C # :Count loop rounds
# O # :Oratory attempts
# S # :Singing attempts
# d   :debugging output
while getopts C:O:S:D:dVhabdefgijklmnopqrstuvwxyzABEFGHIJKLMNPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
O) ORATORY_ATTEMPTS=${OPTARG:-$ORATORY_ATTEMPTS_DEFAULT};;
S) SINGING_ATTEMPTS=${OPTARG:-$SINGING_ATTEMPTS_DEFAULT};;
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
# O # :Oratory attempts
# S # :Singing attempts
# d   :debugging output
while getopts C:O:S:D:dVhabdefgijklmnopqrstuvwxyzABEFGHIJKLMNPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
O) ORATORY_ATTEMPTS=${OPTARG:-$ORATORY_ATTEMPTS_DEFAULT};;
S) SINGING_ATTEMPTS=${OPTARG:-$SINGING_ATTEMPTS_DEFAULT};;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}
_say_skill_oratory_code_(){
cat >&1 <<EoI
file : server/server/skills.c
/* players using this skill can 'charm' a monster --
 * into working for them. It can only be used on
 * non-special (see below) 'neutral' creatures.
 * -b.t. (thomas@astro.psu.edu)
 */

int use_oratory(object *pl, int dir, object *skill) {
    sint16 x=pl->x+freearr_x[dir],y=pl->y+freearr_y[dir];
    int mflags,chance;
    object *tmp;
    mapstruct *m;

    if(pl->type!=PLAYER) return 0;  /* only players use this skill */
    m = pl->map;
    mflags =get_map_flags(m, &m, x,y, &x, &y);
    if (mflags & P_OUT_OF_MAP) return 0;

    /* Save some processing - we have the flag already anyways
     */
    if (!(mflags & P_IS_ALIVE)) {
    new_draw_info(NDI_UNIQUE, 0, pl, "There is nothing to orate to.");
    return 0;
    }

    for(tmp=get_map_ob(m,x,y);tmp;tmp=tmp->above) {
        /* can't persuade players - return because there is nothing else
     * on that space to charm.  Same for multi space monsters and
     * special monsters - we don't allow them to be charmed, and there
     * is no reason to do further processing since they should be the
     * only monster on the space.
     */
        if(tmp->type==PLAYER) return 0;
        if(tmp->more || tmp->head) return 0;
    if(tmp->msg) return 0;

    if(QUERY_FLAG(tmp,FLAG_MONSTER)) break;
    }

    if (!tmp) {
    new_draw_info(NDI_UNIQUE, 0, pl, "There is nothing to orate to.");
    return 0;
    }

    new_draw_info_format(NDI_UNIQUE,
     0,pl, "You orate to the %s.",query_name(tmp));

    /* the following conditions limit who may be 'charmed' */

    /* it's hostile! */
    if(!QUERY_FLAG(tmp,FLAG_UNAGGRESSIVE) && !QUERY_FLAG(tmp, FLAG_FRIENDLY)) {
    new_draw_info_format(NDI_UNIQUE, 0,pl,
       "Too bad the %s isn't listening!\n",query_name(tmp));
    return 0;
    }

    /* it's already allied! */
    if(QUERY_FLAG(tmp,FLAG_FRIENDLY)&&(tmp->attack_movement==PETMOVE)){
    if(get_owner(tmp)==pl) {
        new_draw_info(NDI_UNIQUE, 0,pl,
              "Your follower loves your speech.\n");
        return 0;
    } else if (skill->level > tmp->level) {
        /* you steal the follower.  Perhaps we should really look at the
         * level of the owner above?
         */
        set_owner(tmp,pl);
        new_draw_info_format(NDI_UNIQUE, 0,pl,
         "You convince the %s to follow you instead!\n",
         query_name(tmp));
        /* Abuse fix - don't give exp since this can otherwise
         * be used by a couple players to gets lots of exp.
         */
        return 0;
    } else {
        /* In this case, you can't steal it from the other player */
        return 0;
    }
    } /* Creature was already a pet of someone */

    chance=skill->level*2+(pl->stats.Cha-2*tmp->stats.Int)/2;

    /* Ok, got a 'sucker' lets try to make them a follower */
    if(chance>0 && tmp->level<(random_roll(0, chance-1, pl, PREFER_HIGH)-1)) {
    new_draw_info_format(NDI_UNIQUE, 0,pl,
         "You convince the %s to become your follower.\n",
         query_name(tmp));

    set_owner(tmp,pl);
    tmp->stats.exp = 0;
    add_friendly_object(tmp);
    SET_FLAG(tmp,FLAG_FRIENDLY);
    tmp->attack_movement = PETMOVE;
    return calc_skill_exp(pl,tmp, skill);
    }
    /* Charm failed.  Creature may be angry now */
    else if((skill->level+((pl->stats.Cha-10)/2)) < random_roll(1, 2*tmp->level, pl, PREFER_LOW)) {
    new_draw_info_format(NDI_UNIQUE, 0,pl,
          "Your speech angers the %s!\n",query_name(tmp));
    if(QUERY_FLAG(tmp,FLAG_FRIENDLY)) {
        CLEAR_FLAG(tmp,FLAG_FRIENDLY);
        remove_friendly_object(tmp);
        tmp->attack_movement = 0;   /* needed? */
    }
    CLEAR_FLAG(tmp,FLAG_UNAGGRESSIVE);
    }
    return 0;   /* Fall through - if we get here, we didn't charm anything */
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
_debug_stdalone "_check_skill_available_stdalone:$*"

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

_set_next_direction_stdalone(){
_debug_stdalone "_set_next_direction_stdalone:$*:$DIRN"

DIRN=$((DIRN-1))
test "$DIRN" -le 0 && DIRN=8

_number_to_direction_stdalone $DIRN
_draw_stdalone 2 "Will turn to direction $DIRECTION .."
}

__set_next_direction_stdalone(){
_debug_stdalone "__set_next_direction_stdalone:$*:$DIRN"

DIRN=$((DIRN+1))
test "$DIRN" -ge 9 && DIRN=1

_number_to_direction_stdalone $DIRN
_draw_stdalone 2 "Will turn to direction $DIRECTION .."
}

_kill_monster_stdalone(){
_debug_stdalone "_kill_monster_stdalone:$*"

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
_debug_stdalone "_brace_stdalone:$*"

_watch_stdalone $DRAWINFO
while :
do
_is_stdalone 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log_stdalone "_brace_stdalone:$REPLY"
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

_watch_stdalone $DRAWINFO
while :
do
_is_stdalone 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log_stdalone "_unbrace_stdalone:$REPLY"
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

_calm_down_monster_ready_skill_stdalone(){
_debug_stdalone "_calm_down_monster_ready_skill_stdalone:$*"

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
  _debug_stdalone "$REPLY"

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
  _debug_stdalone "$REPLY"

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
_debug_stdalone 3 "lRV=$lRV"
return ${lRV:-1}
}

_orate_to_monster_ready_skill_stdalone(){
_debug_stdalone "_orate_to_monster_ready_skill_stdalone:$*"

local lRV=

 while :;
 do

  _watch_stdalone $DRAWINFO
  _is_stdalone 1 1 fire_stop
  _is_stdalone 1 1 ready_skill oratory
  _empty_message_stream_stdalone   # todo : check if skill available

  _is_stdalone 1 1 fire $DIRN
  _is_stdalone 1 1 fire_stop
  ORATORY_ATTEMPTS_DONE=$((ORATORY_ATTEMPTS_DONE+1))

  while :; do unset REPLY
  read -t $TMOUT
  _log_stdalone "_orate_to_monster_ready_skill_stdalone:$REPLY"
  _debug_stdalone "$REPLY"

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
  _log_stdalone "_orate_to_monster_ready_skill_stdalone:$REPLY"
  _debug_stdalone "$REPLY"

  case $REPLY in
  #!FLAG_UNAGGRESSIVE && !FLAG_FRIENDLY
  *'Too bad '*) _draw_stdalone 3 "Catched Too bad oratory"; break 2;; # try again singing the kobold isn't listening!
  #FLAG_FRIENDLY && PETMOVE && get_owner(tmp)==pl
  *'Your follower loves '*)          lRV=0; break 2;; # next creature or exit
  #FLAG_FRIENDLY && PETMOVE && (skill->level > tmp->level)
  *"You convince the "*" to follow you instead!"*)   FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  *'You convince the '*' to become your follower.'*) FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  #/* Charm failed. Creature may be angry now */ skill < random_roll
  *"Your speech angers the "*) _draw_stdalone 3 "Catched Anger oratory";   break 2;;
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
_debug_stdalone 3 "lRV=$lRV"
return ${lRV:-1}
}

_sing_and_orate_around_stdalone(){
_debug_stdalone "_sing_and_orate_around_stdalone:$*"

while :;
do

#_sleep
one=$((one+1))

[ "$DIRECTION_OPT" ] && _number_to_direction_stdalone $DIRECTION_OPT || _set_next_direction_stdalone

_calm_down_monster_ready_skill_stdalone
case $? in
 0) _orate_to_monster_ready_skill_stdalone
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
#_sleep_stdalone
#_set_next_direction_stdalone_stdalone

done
}




# MAIN

_main_orate_stdalone(){
_set_global_variables_stdalone $*
_say_start_msg_stdalone $*
_do_parameters_stdalone $*

_get_player_speed_stdalone
test "$PL_SPEED1" && __set_sync_sleep_stdalone ${PL_SPEED1} || _set_sync_sleep_stdalone "$PL_SPEED"


_direction_to_number_stdalone $DIRECTION_OPT
_check_skill_available_stdalone singing || return 1
_check_skill_available_stdalone oratory || return 1

_brace_stdalone
_sing_and_orate_around_stdalone
_unbrace_stdalone
_say_end_msg_stdalone
}

_main_orate_func(){
_set_global_variables $*
_say_start_msg $*
_do_parameters $*

_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"


_direction_to_number $DIRECTION_OPT
_check_skill_available singing || return 1
_check_skill_available oratory || return 1

_brace
_sing_and_orate_around
_unbrace
_say_end_msg
}

 _main_orate_stdalone "$@"
#_main_orate_func "$@"

###END###
