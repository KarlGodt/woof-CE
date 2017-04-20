#!/bin/ash
#. /etc/DISTRO_SPECS
#. /etc/rc.d/PUPSTATE
#. /etc/rc.d/f4puppy5


_set_global_variables(){
LOGGING=${LOGGING:-''}  #set to ANYTHING ie "1" to enable, empty to disable
DEBUG=${DEBUG:-''}      #set to ANYTHING ie "1" to enable, empty to disable
TMOUT=${TMOUT:-1}       # read -t timeout
SLEEP=${SLEEP:-1}       #default sleep value, refined in _get_player_speed()
SLEEP_MOD=${SLEEP_MOD:-'*'}       # add -F --fast (/) and -S --slow (*) options
SLEEP_MOD_VAL=${SLEEP_MOD_VAL:-1} # "

DELAY_DRAWINFO=${DELAY_DRAWINFO:-2}  #default seconds pause to sync, refined in _get_player_speed()
DRAWINFO=${DRAWINFO:-drawinfo}   #older clients <= 1.12.0 use drawextinfo , newer clients drawinfo
DRAW_INFO=${DRAW_INFO:-drawinfo}

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
FOOD_DEF="$EAT_FOOD"     # default
MIN_FOOD_LEVEL_DEF=${MIN_FOOD_LEVEL_DEF:-300} # default minimum. 200 starts to beep. waybread has foodvalue of 500 .
                         # 999 is max foodlevel

HP_MIN_DEF=${HP_MIN_DEF:-20}  # minimum HP to return home. Lowlevel characters probably need this set.

DIRB=${DIRB:-west}  # direction back to go while alching on a cauldron. depends on the location.
case $DIRB in       # should have four tiles free to move to DIRB
1|n)   DIRB=north;;
2|ne)  DIRB=northeast;;
3|e)   DIRB=east;;
4|se)  DIRB=southeast;;
5|s)   DIRB=south;;
6|sw)  DIRB=southwest;;
7|w)   DIRB=west;;
8|nw)  DIRB=northwest;;
*)     :;;
esac

case $DIRB in
west)      DIRF=east;;  # direction forward to return to cauldron
east)      DIRF=west;;
northeast) DIRF=southwest;;
north)     DIRF=south;;
northwest) DIRF=southeast;;
southwest) DIRF=northeast;;
south)     DIRF=north;;
southeast) DIRF=northest;;
*)    _exit 2 "Incorrect move direction '$DIRB' .";;
esac

SOUND_DIR=${SOUND_DIR:-"$HOME"/.crossfire/sounds}

# Log file path in /tmp
#MY_SELF=`realpath "$0"` ## needs to be in main script otherwise does not
#MY_BASE=${MY_SELF##*/}  ## find this library file located in same dir as script

TMP_DIR=${TMP_DIR:-/tmp/crossfire_client}
mkdir -p "$TMP_DIR"

LOGFILE=${LOGFILE:-"$TMP_DIR"/"$MY_BASE".$$.log}
REPLY_LOG=${REPLY_LOG:-"$TMP_DIR"/"$MY_BASE".$$.rpl}      # log replys
REQUEST_LOG=${REQUEST_LOG:-"$TMP_DIR"/"$MY_BASE".$$.req}  # log replys for requests
ON_LOG=${ON_LOG:-"$TMP_DIR"/"$MY_BASE".$$.ion}            # log replys for request items on

# colours
COL_BLACK=0
COL_WHITE=1
COL_NAVY=2
COL_RED=3
COL_ORANGE=4
COL_BLUE=5
COL_DORANGE=6  # dark
COL_GREEN=7
COL_LGREEN=8   # light
COL_GRAY=9
COL_BROWN=10
COL_GOLD=11
COL_TAN=12
COL_VERB=$COL_DORANGE  # verbose
COL_DEB=$COL_ORANGE    # debug

# beeping
BEEP_DO=${BEEP_DO:-1}
BEEP_LENGTH=500
BEEP_FREQ=700

# ** ping if bad connection ** #
PING_DO=${PING_DO:-}
URL=crossfire.metalforge.net

oldPWD="$PWD"
cd "${MY_SELF%/*}"

for ff in [0-9][0-9]_*.fun*; do
test -r "$ff" || continue
. "$ff"
sleep 0.1
done
cd "$oldPWD"

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err  # direct errs to file, otherwise appear in msg pane
}

_sleep(){
sleep ${SLEEP}s
}

_unwatch(){
_debug "unwatch $DRAWINFO"
echo unwatch $DRAWINFO
sleep 0.2
}

_watch(){
_unwatch
_debug "watch $DRAWINFO"
echo watch $DRAWINFO
sleep 0.2
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}

_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}

# *** EXIT FUNCTIONS *** #
_exit(){
_debug "_exit:$*"  # had error message exit:invalid value 'Try'
RV=${1:-0}
shift

#_is 2 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
#_is 2 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_sleep

test "$*" && _draw 5 "$*"
_draw 3 "Exiting $0. $@"
echo unwatch
#echo unwatch $DRAWINFO
_unwatch
_beep

#NUMBER=$((one-1))
NUMBER=$one
_say_statistics_end
_remove_err_log

exit $RV
}

_just_exit(){
_debug "_just_exit:$*"
_draw 3 "Exiting $0."
echo unwatch
#echo unwatch $DRAWINFO
exit $1
}

_emergency_exit(){
_debug "_emergency_exit:$*"
RV=${1:-0}
shift

_is 1 1 apply rod of word of recall
_is 1 1 fire center
_draw 3 "Emergency Exit $0 !"
#echo unwatch $DRAWINFO
_unwatch
_is 1 1 fire_stop
_beep
_beep

#NUMBER=$((one-1))  # old: for one in $NUMBER
NUMBER=$one         # new: count one at end of loop
_say_statistics_end
_remove_err_log

test "$*" && _draw 5 "$*"
exit $RV
}

_exit_no_space(){
_debug "_exit_no_space:$*"
RV=${1:-0}
shift
_draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
_draw 3 "Remove that Item and try again."
_draw 3 "If this is a Wall, try another place."
_beep
_remove_err_log
exit $RV
}


_word_to_number(){

case ${1:-PARAM_1} in

one)      	PARAM_1=1;;
two)      	PARAM_1=2;;
three)    	PARAM_1=3;;
four)		PARAM_1=4;;
five)		PARAM_1=5;;
six)		PARAM_1=6;;
seven)		PARAM_1=7;;
eight)		PARAM_1=8;;
nine)		PARAM_1=9;;
ten)		PARAM_1=10;;
eleven)		PARAM_1=11;;
twelve)		PARAM_1=12;;
thirteen)	PARAM_1=13;;
fourteen)	PARAM_1=14;;
fifteen)	PARAM_1=15;;
sixteen)	PARAM_1=16;;
seventeen)	PARAM_1=17;;
eighteen)	PARAM_1=18;;
nineteen)	PARAM_1=19;;
twenty)		PARAM_1=20;;

esac

}

_number_to_direction(){

case $1 in
[0-8]) DIRN=$1;;
*)    return 1;;
esac

case $1 in

0) DIR=center;;
1) DIR=north;;
2) DIR=northeast;;
3) DIR=east;;
4) DIR=southeast;;
5) DIR=south;;
6) DIR=southwest;;
7) DIR=west;;
8) DIR=northwest;;
*) return 1;;

esac

readonly DIR DIRN;
return $?
}


_check_if_on_item(){  #+++2017-03-20
local ITEM="$*"
_draw 5 "Checking if on a '$ITEM' ..."

test "$ITEM" || {
 _draw 3 "_check_if_on_item:Need <ITEM> as parameter."
 exit 1
 }

local UNDER_ME='';
local UNDER_ME_LIST='';

echo request items on

while :; do
read -t $TMOUT UNDER_ME

_log "$ON_LOG" "_check_if_on_item:$UNDER_ME"
_debug "$UNDER_ME"

#UNDER_ME_LIST="$UNDER_ME
#$UNDER_ME_LIST"
#UNDER_ME_LIST=`echo -e "$UNDER_ME"\\n"$UNDER_ME_LIST"`
UNDER_ME_LIST=`echo -e "$UNDER_ME\\n$UNDER_ME_LIST"`

case $UNDER_ME in
*request*items*on*end*) break;;
*scripttell*break*)     break;;
*scripttell*exit*)    _exit 1;;
esac

unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep " ${ITEM} .*cursed"`" && {
_draw 3 "You stand upon a cursed ${ITEM}!"
_beep
_exit 1
}

test "`echo "$UNDER_ME_LIST" | grep " ${ITEM}$"`" || {
_draw 3 "Need to stand upon ${ITEM}!"
_beep
_exit 1
}

_draw 7 "OK."
return 0
}

_check_if_on_item_topmost(){  #+++2017-03-20
local ITEM="$*"
_draw 5 "Checking if on a topmost '$ITEM' ..."

test "$ITEM" || {
 _draw 3 "_check_if_on_item_topmost:Need <ITEM> as parameter."
 exit 1
 }

local UNDER_ME='';
local UNDER_ME_LIST='';

echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "_check_if_on_item_topmost:$UNDER_ME"
_debug "$UNDER_ME"

#UNDER_ME_LIST="$UNDER_ME
#$UNDER_ME_LIST"
#UNDER_ME_LIST=`echo -e "$UNDER_ME"\\n"$UNDER_ME_LIST"`
UNDER_ME_LIST=`echo -e "$UNDER_ME\\n$UNDER_ME_LIST"`

case $UNDER_ME in
*request*items*on*end*) break;;
*scripttell*break*)     break;;
*scripttell*exit*)    _exit 1;;
esac

unset UNDER_ME
sleep 0.1s
done

test "`echo "$UNDER_ME_LIST" | grep " ${ITEM} .*cursed"`" && {
_draw 3 "You stand upon a cursed ${ITEM}!"
_beep
_exit 1
}

test "`echo "$UNDER_ME_LIST" | grep " ${ITEM}$"`" || {
_draw 3 "Need to stand upon ${ITEM}!"
_beep
_exit 1
}

#test "`echo "$UNDER_ME_LIST" | head -n1 | grep " ${ITEM}$"`" || {
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep " ${ITEM}$"`" || {
_draw 3 "${ITEM} is not topmost!"
_beep
_exit 1
}

_draw 7 "OK."
return 0
}

