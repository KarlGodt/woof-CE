#!/bin/ash

[ "$HAVE_FUNCS_COMMON" ] && return 0

export LC_NUMERIC=de_DE
export LC_ALL=de_DE

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
# Some older clients use both formattings by drawinfo and drawextinfo,
# especially the gtk+-2.0 clients v1.11.0 and earlier.
# So setting the DRAWINFO variable here is of no real use.
# _check_drawinfo() should take care of this now.
DRAWINFO=drawinfo #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
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

SOUND_DIR="$HOME"/.crossfire/cf_sounds

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

_say_version(){
_draw 6 "$MY_BASE Version:${VERSION:-0.0}"
exit ${1:-2}
}

_check_if_already_running_scripts(){
_log   "_check_if_already_running_scripts:$*"
_debug "_check_if_already_running_scripts:$*"

local lRV=0

_is 1 1 scripts
while :; do unset REPLY
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"

case $REPLY in
 *scripts*currently*running:*) :;;
 *${MY_BASE}*) lRV=1;;
 '') break 1;;
 *)  :;;
esac
sleep 0.01
done

return ${lRV:-2}
}

_check_if_already_running_ps(){

local lPROGS=`ps -o pid,ppid,args | grep "$PPID " | grep -v "$$ "`
__debug "$lPROGS"
lPROGS=`echo "$lPROGS" | grep -vE "^$PPID[[:blank:]]+|^[[:blank:]]+$PPID[[:blank:]]+" | grep -vE '<defunct>|grep|cfsndserv'`
__debug "$lPROGS"
test ! "$lPROGS"
}

__watch(){
echo unwatch ${*:-$DRAWINFO}
sleep 0.4
echo   watch ${*:-$DRAWINFO}
}

__unwatch(){
echo unwatch ${*:-$DRAWINFO}
}

___watch(){
case $* in draw*)
echo unwatch drawinfo
echo unwatch drawextinfo
sleep 0.4
echo   watch drawinfo
echo   watch drawextinfo;;
*)
echo unwatch "${@}"
sleep 0.4
echo   watch "${@}";;
esac
}

___unwatch(){
case $* in draw*)
echo unwatch drawinfo
echo unwatch drawextinfo;;
*) echo unwatch "${@}"
esac
}

_watch(){
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

_unwatch(){
case $* in
'') echo unwatch;;
*)
for i in $*; do
 echo unwatch $i
done;;
esac
}


_sleep(){
SLEEP=${SLEEP//,/.}
sleep ${SLEEP:-1}
}

_draw(){
    local lCOLOUR="${1:-$COLOUR}"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    echo draw $lCOLOUR $@ # no double quotes here,
# multiple lines are drawn using __draw below
}

__draw(){
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
test "$2" && { lDUR="$1"; shift; }
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

_beep_std(){
beep -l 1000 -f 700
}

_say_start_msg(){
# *** Here begins program *** #
_draw 2 "$0 has started.."
_draw 2 "PID is $$ - parentPID is $PPID"

_check_if_already_running_ps || _exit 1 "Another $MY_BASE is already running."
_check_drawinfo || _exit 1 "Unable to fetch the DRAWINFO variable. Please try again."

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
TIME_ELAPSED=`ps -o pid,etime,args | grep -w "$$" | grep -vwE "grep|ps|${TMP_DIR:-/tmp}"`
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
test -f "$SOUND_DIR"/su-fanf.raw && aplay $Q "$SOUND_DIR"/su-fanf.raw & aPID=$!

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
local lREPLY
while :;
do
read -t $TMOUT lREPLY
_log "$REPLY_LOG" "_empty_message_stream:$lREPLY"
test "$lREPLY" || break
case $lREPLY in
*scripttell*break*)     break ${lREPLY##*?break};;
*scripttell*exit*)      _exit 1 $lREPLY;;
*'YOU HAVE DIED.'*) _just_exit;;
esac
_msg 7 "_empty_message_stream:$lREPLY"
unset lREPLY
 sleep 0.01
#sleep 0.1
done
}

__check_drawinfo(){  ##+++2018-01-08
_debug "__check_drawinfo:$*"

oDEBUG=$DEBUG;       DEBUG=${DEBUG:-''}
oLOGGING=$LOGGING; LOGGING=${LOGGING:-1}

_draw 2 "Checking drawinfo ..."

echo watch

while :;
do

# I use search here to provoke
# a response from the server
# like You search the area.
# It could be something else,
# but I have no better idea for the moment.
_is 0 0 search
_is 0 0 examine

 unset cnt0 TICKS
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "__check_drawinfo:$cnt0:$REPLY"
    _msg 7 "$cnt0:$REPLY"

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

_sleep
done

echo unwatch
_empty_message_stream
unset cnt0

test "$DRAWINFO0" = "$DRAWINFO" || {
    _msg 5 "Changing internally from $DRAWINFO to $DRAWINFO0"
    DRAWINFO=$DRAWINFO0
}

DEBUG=$oDEBUG
LOGGING=$oLOGGING
_draw 6 "Done."
}

_check_drawinfo(){  ##+++2018-02-19
_debug "_check_drawinfo:$*"

oDEBUG=$DEBUG;       DEBUG=${DEBUG:-''}
oLOGGING=$LOGGING; LOGGING=${LOGGING:-1}

_draw 2 "Checking drawinfo ..."

echo watch

while :;
do

# I use search here to provoke
# a response from the server
_is 1 1 save
_is 1 1 ready_skill xxx

 unset cnt0 TICKS HAVE_DRAWINFO HAVE_DRAWEXTINFO
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "_check_drawinfo:$cnt0:$REPLY"
    _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *drawinfo*)         HAVE_DRAWINFO=drawinfo;;
 *drawextinfo*)   HAVE_DRAWEXTINFO=drawextinfo;;
 *tick*) TICKS=$((TICKS+1)); test "$TICKS" -gt 39 && break 2;; # 5 seconds
 '') break 1;;
 *) :;;
 esac

 sleep 0.001
 done

_sleep
done

echo unwatch
_empty_message_stream
unset cnt0

DRAWINFO="$HAVE_DRAWINFO $HAVE_DRAWEXTINFO"
DRAWINFO=`echo $DRAWINFO`
_msg 5 "Client recognizes $DRAWINFO"

DEBUG=$oDEBUG
LOGGING=$oLOGGING
_draw 6 "Done."
test "$DRAWINFO"
}

# *** EXIT FUNCTIONS *** #
_exit(){
case $1 in
[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) RV=$1; shift;;
esac

_is 1 1 fire_stop

if test "$DIRB" -a "$DIRF"; then
_move_back_and_forth 2 # cf_funcs_move.sh
fi

_sleep

test "$*" && _draw 3 $@
_draw 3 "Exiting $0. PID was $$"

_unwatch ""
_beep_std
test ${RV//[0-9]/} && RV=3
exit ${RV:-0}
}

_just_exit(){
_draw 3 "Exiting $0."
_is 1 1 fire_stop
_unwatch
_beep_std
exit ${1:-0}
}

_emergency_exit(){
RV=${1:-4}; shift
local lRETURN_ITEM=${*:-"$RETURN_ITEM"}

_is 1 1 fire_stop

case $lRETURN_ITEM in
''|*rod*|*staff*|*wand*|*horn*)
_is 1 1 apply -u ${lRETURN_ITEM:-'rod of word of recall'}
_is 1 1 apply -a ${lRETURN_ITEM:-'rod of word of recall'}
_is 1 1 fire center
_is 1 1 fire_stop
;;
*scroll*) _is 1 1 apply ${lRETURN_ITEM};;
*) _is 1 1 invoke "$lRETURN_ITEM";; # assuming spell
esac

_draw 3 "Emergency Exit $0 !"
_unwatch

# apply bed of reality
 sleep 6
_is 1 1 apply

_beep_std
exit ${RV:-0}
}

_exit_no_space(){
_draw 3 "On position $nr $DIRB there is something ($IS_WALL)!"
_draw 3 "Remove that item and try again."
_draw 3 "If this is a wall, try on another place."
_beep_std
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

__direction_to_number(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 254

DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=0; DIRN=0;;
1|north|n)         DIRECTION=1; DIRN=1;;
2|northeast|ne)    DIRECTION=2; DIRN=2;;
3|east|e)          DIRECTION=3; DIRN=3;;
4|southeast|se)    DIRECTION=4; DIRN=4;;
5|south|s)         DIRECTION=5; DIRN=5;;
6|southwest|sw)    DIRECTION=6; DIRN=6;;
7|west|w)          DIRECTION=7; DIRN=7;;
8|northwest|nw)    DIRECTION=8; DIRN=8;;
#*) ERROR=1 _error "Not recognized: '$DIRECTION'";; # bash
*) oERROR="$ERROR"; ERROR=1
_error "Not recognized: '$DIRECTION'"
ERROR="$oERROR"; unset oERROR;;
esac
DIRECTION_NUMBER=$DIRN
return ${DIRN:-255}
}

__number_to_direction(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 254
DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=center;    DIRN=0;;
1|north|n)         DIRECTION=north;     DIRN=1;;
2|northeast|ne)    DIRECTION=northeast; DIRN=2;;
3|east|e)          DIRECTION=east;      DIRN=3;;
4|southeast|se)    DIRECTION=southeast; DIRN=4;;
5|south|s)         DIRECTION=south;     DIRN=5;;
6|southwest|sw)    DIRECTION=southwest; DIRN=6;;
7|west|w)          DIRECTION=west;      DIRN=7;;
8|northwest|nw)    DIRECTION=northwest; DIRN=8;;
#*) ERROR=1 _error "Not recognized: '$DIRECTION'";; # bash
*) oERROR="$ERROR"; ERROR=1
_error "Not recognized: '$DIRECTION'"
ERROR="$oERROR"; unset oERROR;;
esac
DIRECTION_NUMBER=$DIRN
return ${DIRN:-255}
}

_direction_to_number(){ # cf_funcs_move.sh
local lDIRECTION=${1:-$DIRECTION}
test "$lDIRECTION" || return 254

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
#*) ERROR=1 _error "Not recognized: '$lDIRECTION'";; # bash
*) oERROR="$ERROR"; ERROR=1
_error "Not recognized: '$DIRECTION'"
ERROR="$oERROR"; unset oERROR;;
esac
DIRECTION_NUMBER=$DIRN
return ${DIRN:-255}
}

_number_to_direction(){ # cf_funcs_move.sh
local lDIRECTION=${1:-$DIRECTION}
test "$lDIRECTION" || return 254

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
#*) ERROR=1 _error "Not recognized: '$lDIRECTION'";; # bash
*) oERROR="$ERROR"; ERROR=1
_error "Not recognized: '$DIRECTION'"
ERROR="$oERROR"; unset oERROR;;
esac
DIRECTION_NUMBER=$DIRN
return ${DIRN:-255}
}

_round_up_and_down(){  ##+++2018-01-08
[ "$DEBUG" ] && echo "_round_up_and_down:$1" >&2
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

_set_sync_sleep(){
_debug "_set_sync_sleep:$*"

local lPL_SPEED=${1:-$PL_SPEED}
lPL_SPEED=${lPL_SPEED:-50000}

  if test "$lPL_SPEED"  =  "";    then
_draw 3 "WARNING: Could not set player speed. Using defaults."
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
_exit 1 "ERROR while processing player speed."
fi

_info "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

__set_sync_sleep(){
_debug "__set_sync_sleep:$*"

local lPL_SPEED=${1:-$PL_SPEED1}
lPL_SPEED=${lPL_SPEED:-50}

  if test "$lPL_SPEED"  =  ""; then
_draw 3 "WARNING: Could not set player speed. Using defaults."
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
_exit 1 "ERROR while processing player speed."
fi

_info "Setting SLEEP=$SLEEP ,TMOUT=$TMOUT ,DELAY_DRAWINFO=$DELAY_DRAWINFO"
}

_player_speed_to_human_readable(){
_debug "_player_speed_to_human_readable:$*"

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

_msg 7 "Player speed is '$PL_SPEED1'"

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
_msg 7 "Rounded Player speed is '${PL_SPEED_PRE}$PL_SPEED_POST'"
PL_SPEED_POST=${PL_SPEED_POST:0:2}
_msg 7 "Rounded Player speed is '${PL_SPEED_PRE}$PL_SPEED_POST'"

PL_SPEED1="${PL_SPEED_PRE}${PL_SPEED_POST}"
_msg 7 "Rounded Player speed is '$PL_SPEED1'"

PL_SPEED1=`echo "$PL_SPEED1" | sed 's!\.!!g;s!\,!!g;s!^0*!!'`
LC_NUMERIC=$oLC_NUMERIC
}

__player_speed_to_human_readable(){
_debug "__player_speed_to_human_readable:$*"

local lPL_SPEED=${1:-$PL_SPEED}
test "$lPL_SPEED" || return 254
:  #TODO
}

__request(){ # for multi-line replies
test "$*" || return 254

local lANSWER lOLD_ANSWER
lANSWER=
lOLD_ANSWER=
ANSWER=

_empty_message_stream
echo request $*
while :; do
 read -t $TMOUT lANSWER
 _log "$REQUEST_LOG" "__request $*:$lANSWER"
 _msg 7 "$lANSWER"
 #test "$lANSWER" || break
 #test "$lANSWER" = "$lOLD_ANSWER" && break
 case $lANSWER in ''|$lOLD_ANSWER|*request*end) break 1;; esac
 ANSWER="$ANSWER
$lANSWER"
lOLD_ANSWER="$lANSWER"
sleep 0.01
done
#ANSWER="$lANSWER"
ANSWER=`echo "$ANSWER" | sed 'sI^$II'`
test "$ANSWER"
}

_request(){  # for one line replies
test "$*" || return 254

local lANSWER=''

_empty_message_stream
echo request $*
read -t $TMOUT lANSWER
 _log "$REQUEST_LOG" "_request $*:$lANSWER"
 _msg 7 "$lANSWER"

ANSWER="$lANSWER"
test "$ANSWER"
}

_check_counter(){
ckc=$((ckc+1))
test "$ckc" -lt $COUNT_CHECK_FOOD && return $ckc
ckc=0
return $ckc
}

_get_player_speed(){
_debug "_get_player_speed:$*"

if test "$1" = '-l'; then # loop counter
 #spdcnt=$((spdcnt+1))
 #test "$spdcnt" -ge ${COUNT_CHECK_FOOD:-10} || return 1
 #spdcnt=0
 _check_counter || return 1
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
 _log "$REQUEST_LOG" "_get_player_speed:__old_req:$reqANSWER"
 _msg 7 "$reqANSWER"
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
 _log "$REQUEST_LOG" "_get_player_speed:__new_req:$r $s $c $WC $AC $DAM PL_SPPED=$PL_SPEED $WP_SPEED"
 _msg 7 "$r $s $c $WC $AC $DAM PL_SPPED=$PL_SPEED $WP_SPEED"
}

_use_old_funcs(){
_empty_message_stream
echo request stat cmbt # only one line
#__old_req
__new_req
}

_use_new_funcs(){
#__request stat cmbt
 _empty_message_stream
 _request stat cmbt
test "$ANSWER" && PL_SPEED0=`echo "$ANSWER" | awk '{print $7}'`
PL_SPEED=${PL_SPEED0:-$PL_SPEED}
}

_draw 5 "Processing Player's speed..."
#_use_old_funcs
_use_new_funcs

PL_SPEED=${PL_SPEED:-50000} # 0.50

_player_speed_to_human_readable $PL_SPEED
_msg 6 "Using player speed '$PL_SPEED1'"

_draw 6 "Done."
return 0
}

_unapply_rod_of_recall(){
# *** Unreadying rod of word of recall - just in case *** #
_debug "_unapply_rod_of_recall:$*"

local RECALL OLD_REPLY REPLY

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

_empty_message_stream
echo request items actv

while :; do
read -t $TMOUT
_log "$REPLY_LOG" "_unapply_rod_of_recall:request items actv:$REPLY"
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

local currHP currHPMin
currHP=${1:-$HP}
currHPMin=${2:-$HP_MIN_DEF}
currHPMin=${currHPMin:-$((MHP/10))}

_msg 7 "currHP=$currHP currHPMin=$currHPMin"
if test "$currHP" -le ${currHPMin:-20}; then

 __old_recall(){
 _empty_message_stream
 _is 1 1 apply -u ${RETURN_ITEM:-'rod of word of recall'}
 _is 1 1 apply -a ${RETURN_ITEM:-'rod of word of recall'}
 _empty_message_stream

 _is 1 1 fire center ## TODO: check if already applied and in inventory
 _is 1 1 fire_stop

 _empty_message_stream
 _unwatch $DRAWINFO
 exit 5
 }

_emergency_exit
fi

unset HP
}

_check_if_on_item_examine(){
# Using 'examine' directly after dropping
# the item examines the bottommost tile
# as 'That is marble'
_debug "_check_if_on_item_examine:$*"

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

_draw 5 "Checking if standing on $lITEM ..."

_watch $DRAWINFO
#_is 0 0 examine
while :; do unset REPLY
_is 0 0 examine
_sleep
read -t $TMOUT
 _log "_check_if_on_item_examine:$REPLY"
 _msg 7 "$REPLY"

 case $REPLY in
  *"That is"*"$lITEM"*|*"Those are"*"$lITEM"*|*"Those are"*"${lITEM// /?*}"*) break 1;;
  *"That is"*|*"Those are"*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  '') break 1;;
  *) continue;; #:;;
 esac

LIST="$LIST
$REPLY"
# sleep 0.01
#sleep 0.1
done

_unwatch
_empty_message_stream

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

_check_if_on_item(){
_debug "_check_if_on_item:$*"

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

_draw 5 "Checking if standing on $lITEM ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "_check_if_on_item:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)      _exit 1 $REPLY;;
*'YOU HAVE DIED.'*) _just_exit;;
*bed*to*reality*)   _just_exit;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

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

_beep_std
_draw 3 $lMSG
test "$DO_LOOP" && return 1 || _exit 1
}

__check_if_on_item(){
_debug "__check_if_on_item:$*"

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

_draw 5 "Checking if standing on $lITEM ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "__check_if_on_item:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)      _exit 1 $REPLY;;
*'YOU HAVE DIED.'*) _just_exit;;
*bed*to*reality*)   _just_exit;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_ITEM=`echo "$UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}" | wc -l`

if test "$TOPMOST"; then

 TOP_UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | tail -n1`
 if test "`echo "$TOP_UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}" | grep -E 'cursed|damned'`";
  then lMSG="Topmost $lITEM appears to be cursed!"
  false
 elif  test "`echo "$TOP_UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"`";
  then true
 elif test "`echo "$UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"`";
  then lMSG="$lITEM appears not to be topmost!"
  false
 else lMSG="You appear not to stand on some $lITEM!"
  false
 fi
lRV=$?

else

case "$UNDER_ME_LIST" in
*"$lITEM"*cursed*|*"${lITEM}s"*cursed*|*"${lITEM}es"*cursed*|*"${lITEM// /?*}"*cursed*)
   lMSG="${lMSG:-You appear to stand upon some cursed $lITEM!}"
   lRV=1;;
*"$lITEM"*damned*|*"${lITEM}s"*damned*|*"${lITEM}es"*damned*|*"${lITEM// /?*}"*damned*)
   lMSG="${lMSG:-You appear to stand upon some damned $lITEM!}"
   lRV=1;;
*"$lITEM"|*"${lITEM}s"|*"${lITEM}es"|*"${lITEM// /?*}")
   lRV=${lRV:-0};;
*) lMSG="You appear not to stand on some $lITEM!"
   lRV=1;;
esac
fi

test "$lRV" = 0 && return 0

_beep_std
_draw 3 $lMSG
test "$DO_LOOP" && return 1 || _exit 1
}

_check_have_item_in_inventory(){
_debug "_check_have_item_in_inventory:$*"

local oneITEM oldITEM ITEMS ITEMSA lITEM
lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

TIMEB=`date +%s`

unset oneITEM oldITEM ITEMS ITEMSA

_empty_message_stream
echo request items inv
while :;
do
read -t ${TMOUT:-1} oneITEM
 _log "$INV_LOG" "_check_have_item_in_inventory:$oneITEM"
 _debug "$oneITEM"

 case $oneITEM in
 $oldITEM|'') break 1;;
 *"$lITEM"*) _draw 7 "Got that item $lITEM in inventory.";;
 *scripttell*break*)  break ${oneITEM##*?break};;
 *scripttell*exit*)   _exit 1 $oneITEM;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac
 ITEMS="${ITEMS}${oneITEM}\n"
#$oneITEM"
 oldITEM="$oneITEM"
sleep 0.01
done
unset oldITEM oneITEM


TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_debug 4 "Fetching Inventory List: Elapsed $TIME sec."

#_debug "lITEM=$lITEM"
#_debug "head:`echo -e "$ITEMS" | head -n1`"
#_debug "tail:`echo -e "$ITEMS" | tail -n2 | head -n1`"
#HAVEIT=`echo "$ITEMS" | grep -E  " $lITEM| ${lITEM}s| ${lITEM}es"`
#__debug "HAVEIT=$HAVEIT"
echo -e "$ITEMS" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
}

_is(){
# issue <repeat> <must_send> <command> - send
#  <command> to server on behalf of client.
#  <repeat> is the number of times to execute command
#  <must_send> tells whether or not the command must sent at all cost (1 or 0).
#  <repeat> and <must_send> are optional parameters.
    _debug "_is:$*"
    _log   "_is:$*"
    echo issue "$@"
    sleep 0.2
}

_drop(){
 _sound 0 drip &
 #_is 1 1 drop "$@" #01:58 There are only 1 chests.
  _is 0 0 drop "$@"
}

_set_pickup(){
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

#_is 0 0 pickup ${*:-0}
#_is 1 0 pickup ${*:-0}
#_is 0 1 pickup ${*:-0}
 _is 1 1 pickup ${*:-0}
}

###END###
HAVE_FUNCS_COMMON=1
