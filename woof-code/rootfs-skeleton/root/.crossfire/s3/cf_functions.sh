#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5


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
case $DIRB in
west)  DIRF=east;;  # direction forward
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

SOUND_DIR=${SOUND_DIR:-"$HOME"/.crossfire/sounds}

# Log file path in /tmp
#MY_SELF=`realpath "$0"` ## needs to be in main script
#MY_BASE=${MY_SELF##*/}  ## needs to be in main scrip

TMP_DIR=${TMP_DIR:-/tmp/crossfire_client}
mkdir -p "$TMP_DIR"

LOGFILE=${LOGFILE:-"$TMP_DIR"/"$MY_BASE".$$.log}
REPLY_LOG=${REPLY_LOG:-"$TMP_DIR"/"$MY_BASE".$$.rpl}    # log only replys
REQUEST_LOG=${REQUEST_LOG:-"$TMP_DIR"/"$MY_BASE".$$.req}  # log only replys for requests
ON_LOG=${ON_LOG:-"$TMP_DIR"/"$MY_BASE".$$.ion}       # log only replys for request items on

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

# beeping
BEEP_DO=${BEEP_DO:-1}
BEEP_LENGTH=500
BEEP_FREQ=700

# ** ping if bad connection ** #
PING_DO=${PING_DO:-}
URL=crossfire.metalforge.net

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err
}

_ping(){
test "$PING_DO" || return 0
while :;
do
ping -c1 -w10 -W10 "$URL" && break
sleep 1
done >/dev/null
}

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "$*"
}

_watch(){
_unwatch
_debug "watch $DRAWINFO"
echo watch $DRAWINFO
sleep 0.2
}

_unwatch(){
_debug "unwatch $DRAWINFO"
echo unwatch $DRAWINFO
sleep 0.2
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}

__draw(){
    local COLOUR="$1"
    test "$COLOUR" || COLOUR=1 #set default
    shift
    local MSG="$@"
    echo $DRAWINFO $COLOUR "$MSG"
}

_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_black()  { _draw 0  "$*"; }
_bold()   { _draw 1  "$*"; }
_blue()   { _draw 5  "$*"; }
_navy()   { _draw 2  "$*"; }
_lgreen() { _draw 8  "$*"; }
_green()  { _draw 7  "$*"; }
_red()    { _draw 3  "$*"; }
_dorange(){ _draw 6  "$*"; }
_orange() { _draw 4  "$*"; }
_gold()   { _draw 11 "$*"; }
_tan()    { _draw 12 "$*"; }
_brown()  { _draw 10 "$*"; }
_gray()   { _draw 9  "$*"; }
alias _grey=_gray

__debug(){
test "$DEBUG" || return 0
    _draw 3 "DEBUG:$@"
}

_debug(){
test "$DEBUG" || return 0
while read -r line
do
test "$line" || continue
_draw 3 "DEBUG:$line"
done <<EoI
`echo "$*"`
EoI
}

_debugx(){
test "$DEBUGX" || return 0
while read -r line
do
test "$line" || continue
_draw 3 "DEBUG:$line"
done <<EoI
`echo "$*"`
EoI
}

__log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOGFILE"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOGFILE"
   echo "$*" >>"$lFILE"
}

_sound(){
    local DUR
test "$2" && { DUR="$1"; shift; }
test "$DUR" || DUR=0
test -e "$SOUND_DIR"/${1}.raw && \
           aplay $Q $VERB -d $DUR "$SOUND_DIR"/${1}.raw
}

___get_player_name(){
# this does not work correctly since case insensitive
local ANSWER

_watch

for player_name in karl Karl KARL Karl_ Trollo Aelfdoerf kalle kalli
do
sleep 0.1
_is 1 1 hug $player_name #case insensitive!
sleep 0.1
read -t $TMOUT ANSWER
_debug "ANSWER=$ANSWER"
_log "$ANSWER"
case $ANSWER in *You*hug*yourself*) MY_NAME="$player_name"; break 1;; esac
sleep 0.1
unset ANSWER
done

if test "$MY_NAME"; then
 _draw 2 "Your name found out to be $MY_NAME"
 test -f "${MY_SELF%/*}"/"${MY_NAME}".conf || echo '#' "${MY_NAME}'s config file" >"${MY_SELF%/*}"/"${MY_NAME}".conf
 true
else
 _draw 3 "Error finding your player name."
 false
fi

_unwatch
}

__get_player_name(){
unset MY_NAME
#test -s "${MY_SELF%/*}"/player_name.$PPID && read -r MY_NAME <"${MY_SELF%/*}"/player_name.$PPID
test -s "${TMP_DIR}"/player_name.$PPID && read -r MY_NAME <"${TMP_DIR}"/player_name.$PPID
test "$MY_NAME"
}

_get_player_name(){

local c=0
local r p N P

echo request player
while :;
do
read -t $TMOUT
_log "REQUEST PLAYER:'$REPLY'"
_debug "REQUEST PLAYER:'$REPLY'"

c=$((c+1))
test "$c" = 9 && break
test "$REPLY" || break

MY_NAME_ALL="$REPLY"
unset REPLY
sleep 0.1
done

read r p N P MY_NAME_W_TITLE <<EoI
`echo "$MY_NAME_ALL"`
EoI

#MY_NAME=`echo "$MY_NAME_W_TITLE" | sed 's% the .*%%'`  #MIKE the Mechanic
MY_NAME=`echo "$MY_NAME_W_TITLE" | awk '{print $1}'`    #Nico a wonderful terrible
_debug "Player:'$MY_NAME'"

if test "$MY_NAME"; then
 _draw 2 "Your name found out to be $MY_NAME"
 test -f "${MY_SELF%/*}"/"${MY_NAME}".conf || echo '#' "${MY_NAME}'s config file" >"${MY_SELF%/*}"/"${MY_NAME}".conf
 true
else
 _draw 3 "Error finding your player name."
 false
fi

#test "$MY_NAME"
}


_say_start_msg(){
# *** Here begins program *** #
if test "$MY_SELF"; then
_draw 2 "$0 ->"
_draw 2 "$MY_SELF"
_draw 2 "has started.."
else
_draw 2 "$0 has started.."
fi
_draw 2 "PID is $$ - parentPID is $PPID"

# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."
}

_say_end_msg(){
# *** Here ends program *** #
_is 1 1 fire_stop
if test -f "$HOME"/.crossfire/sounds/su-fanf.raw; then
aplay $Q "$HOME"/.crossfire/sounds/su-fanf.raw & aPID=$!
else
(
beep -l 300 -f 700
beep -l 300 -f 750
beep -l 300 -f 800
beep -l 300 -f 1000
) & aPID=$!
fi

if test "$TIMEA" -o "$TIMEB"; then
 TIMEE=`date +%s`
 #if test "$TIMEB"; then
 # TIMEC=$TIMEB
 #else
 # TIMEC=$TIMEA
 #fi
 if test "$TIMEA"; then
  TIMEC=$TIMEA
 else
  TIMEC=$TIMEB
 fi
 TIMEX=$((TIMEE-TIMEC))
 TIMEM=$((TIMEX/60))
 TIMES=$(( TIMEX - (TIMEM*60) ))
 case $TIMES in [0-9]) TIMES="0$TIMES";; esac

 #_draw 4 "Loop of script had run a total of $TIMEM minutes and $TIMES seconds."
 _draw 4 "Loop of script had run a total of $TIMEM:$TIMES minutes."
fi

#+++2017-03-20 Remove *.err file if empty
if test -s "$TMP_DIR"/"$MY_BASE".$$.err; then
_draw 3 "WARNING:Content reported in $TMP_DIR/$MY_BASE.$$.err ."
else
_draw 7 "No content reported in $TMP_DIR/$MY_BASE.$$.err ."
[ "$DEBUG" ] || rm -f "$TMP_DIR"/"$MY_BASE".$$.err
fi

test "$aPID" && wait $aPID
_draw 2  "$0 has finished."
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

echo draw 5 "$* $TIMEm:$TIMEs minutes."
}

_say_success_fail(){
test "$NUMBER" -a "$FAIL" || return 3
test "${NUMBER//[0-9]/}"  && return 4
test "${FAIL//[0-9]/}"    && return 5

if test "$FAIL" -le 0; then
 SUCC=$((NUMBER-FAIL))
 echo draw 7 "You succeeded '$SUCC' times of '$NUMBER' ." # green
elif test "$((NUMBER/FAIL))" -lt 2;
then
 echo draw 8 "You failed '$FAIL' times of '$NUMBER' ."    # light green
 echo draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((NUMBER-FAIL))
 echo draw 7 "You succeeded '$SUCC' times of '$NUMBER' ." # green
fi
}

_say_statistics_end(){
# Now count the whole loop time
TIMELE=`date +%s`
_say_minutes_seconds "$TIMELB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"
}

# *** EXIT FUNCTIONS *** #
_exit(){
_debug "_exit:$*"
RV=${1:-0}
shift

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep ${SLEEP}s

test "$*" && echo draw 5 "$*"
_draw 3 "Exiting $0. $@"
echo unwatch
#echo unwatch $DRAWINFO
_unwatch
_beep

NUMBER=$((one-1))
_say_statistics_end

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

NUMBER=$((one-1))
_say_statistics_end

test "$*" && echo draw 5 "$*"
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
exit $RV
}


_get_player_speed(){

if test "$1" = '-l'; then
 spc=$((spc+1))
 test "$spc" -ge $COUNT_CHECK_FOOD || return 1
 spc=0
fi

_draw 5 "Processing Player's speed..."

local ANSWER OLD_ANSWER PL_SPEED
ANSWER=
OLD_ANSWER=

echo request stat cmbt

#echo watch request

while :; do
read -t $TMOUT ANSWER

_log "$REQUEST_LOG" "request stat cmbt:$ANSWER"
_debug "$ANSWER"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#echo unwatch request

test ! "$ANSWER" -a "$OLD_ANSWER" && ANSWER="$OLD_ANSWER"  #+++2017-03-20

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash

PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_debug "Player speed is '$PL_SPEED'"

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_verbose "Using player speed '$PL_SPEED'"

  if test "$PL_SPEED" = "";   then
    _draw 3 "WARNING: Could not set player speed. Using defaults."

elif test "$PL_SPEED" -gt 80; then
SLEEP=0.1; DELAY_DRAWINFO=0.6; TMOUT=1
elif test "$PL_SPEED" -gt 75; then
SLEEP=0.1; DELAY_DRAWINFO=0.7; TMOUT=1
elif test "$PL_SPEED" -gt 70; then
SLEEP=0.2; DELAY_DRAWINFO=0.8; TMOUT=1
elif test "$PL_SPEED" -gt 65; then
SLEEP=0.3; DELAY_DRAWINFO=0.9; TMOUT=1
elif test "$PL_SPEED" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$PL_SPEED" -gt 55; then
SLEEP=0.5; DELAY_DRAWINFO=1.1; TMOUT=1
elif test "$PL_SPEED" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$PL_SPEED" -gt 45; then
SLEEP=0.7; DELAY_DRAWINFO=1.4; TMOUT=1
elif test "$PL_SPEED" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$PL_SPEED" -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0; TMOUT=2
elif test "$PL_SPEED" -gt 30; then
SLEEP=1.5; DELAY_DRAWINFO=3.0; TMOUT=2
elif test "$PL_SPEED" -gt 25; then
SlEEP=2.0; DELAY_DRAWINFO=4.0; TMOUT=2
elif test "$PL_SPEED" -gt 20; then
SlEEP=2.5; DELAY_DRAWINFO=5.0; TMOUT=2
elif test "$PL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0; TMOUT=2
elif test "$PL_SPEED" -gt 10; then
SLEEP=4.0; DELAY_DRAWINFO=8.0; TMOUT=2
elif test "$PL_SPEED" -ge 0;  then
SLEEP=5.0; DELAY_DRAWINFO=10.0; TMOUT=2
else
_exit 1 "ERROR while processing player speed."
fi

_debug "SLEEP='$SLEEP' DELAY_DRAWINFO='$DELAY_DRAWINFO' TMOUT='$TMOUT'"

if test "$SLEEP_MOD" -a "$SLEEP_MOD_VAL"; then
SLEEP=$(echo "$SLEEP $SLEEP_MOD $SLEEP_MOD_VAL" | bc -l)
_debug "SLEEP='$SLEEP'"
fi

SLEEP=${SLEEP:-1}
_verbose "Finally set SLEEP='$SLEEP'"

_draw 6 "Done."
return 0
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

### ALCHEMY

_drop_in_cauldron(){

if test "$DRAWINFO" = drawextinfo; then
echo watch drawinfo
#echo watch $DRAWINFO
_watch
else
#echo watch $DRAWINFO
_watch
fi

_drop "$@"

#echo sync
sleep ${SLEEP}s

_check_drop_or_exit "$@"

if test "$DRAWINFO" = drawextinfo; then
echo unwatch drawinfo
#echo unwatch $DRAWINFO
_unwatch
else
#echo unwatch $DRAWINFO
_unwatch
fi
}

_drop(){
 _sound 0 drip &
 echo issue 1 1 drop "$@"
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


# *** Check if standing on a cauldron *** #
_check_if_on_cauldron(){
_draw 5 "Checking if on a cauldron..."

local UNDER_ME='';
local UNDER_ME_LIST='';
_debugx A
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

echo request items on

while :; do
read -t $TMOUT UNDER_ME
_debugx C
_debugx "UNDER_ME='$UNDER_ME'"
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

_log "$ON_LOG" "$UNDER_ME"

_debugx L
_debugx "UNDER_ME='$UNDER_ME'"
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

_debugx X
 UNDER_ME_LIST="${UNDER_ME}
${UNDER_ME_LIST}"
#UNDER_ME_LIST=`echo -e "${UNDER_ME}"\\n"${UNDER_ME_LIST}"`
#UNDER_ME_LIST=`echo -e "${UNDER_ME}\\n${UNDER_ME_LIST}"`
_debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

case $UNDER_ME in
*request*items*on*end*) break;;
*scripttell*break*)     break;;
*scripttell*exit*)    _exit 1 "$UNDER_ME";;
esac

unset UNDER_ME
sleep 0.1s
done

_debugx B
UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | grep -v 'malfunction'`
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"

_debugx C
UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed '/^$/d'`
_debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

test "`echo "$UNDER_ME_LIST" | grep 'cauldron.*cursed'`" && {
_draw 3 "You stand upon a cursed cauldron!"
_beep
exit 1
}

_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"
test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
_draw 3 "Need to stand upon cauldron!"
_beep
exit 1
}

#+++2017-03-20 make sure cauldron is on top
_debugx "UNDER_ME_LIST='$UNDER_ME_LIST'"
#test "`echo "$UNDER_ME_LIST" | head -n1 | grep 'cauldron$'`" || {
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep 'cauldron$'`" || {
_draw 3 "Cauldron is not topmost!"
_beep
exit 1
}

_draw 7 "OK."
return 0
}

_check_if_on_item(){  ##2017-03-20
local ITEM="$*"
_draw 5 "Checking if on a '$ITEM' ..."

test "$ITEM" || {
 _draw 3 "_check_if_on_item:Need <ITEM> as parameter."
 exit 1
 }

UNDER_ME='';
UNDER_ME_LIST='';
echo request items on

while :; do
read -t $TMOUT UNDER_ME
#echo "$UNDER_ME" >>"$ON_LOG"
_log "$ON_LOG" "$UNDER_ME"

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
exit 1
}

test "`echo "$UNDER_ME_LIST" | grep " ${ITEM}$"`" || {
_draw 3 "Need to stand upon ${ITEM}!"
_beep
exit 1
}

_draw 7 "OK."
return 0
}

_check_if_on_item_topmost(){  ##2017-03-20
local ITEM="$*"
_draw 5 "Checking if on a topmost '$ITEM' ..."

test "$ITEM" || {
 _draw 3 "_check_if_on_item_topmost:Need <ITEM> as parameter."
 exit 1
 }

UNDER_ME='';
UNDER_ME_LIST='';
echo request items on

while :; do
read -t $TMOUT UNDER_ME
#echo "$UNDER_ME" >>"$ON_LOG"
_log "$ON_LOG" "$UNDER_ME"
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
exit 1
}

test "`echo "$UNDER_ME_LIST" | grep " ${ITEM}$"`" || {
_draw 3 "Need to stand upon ${ITEM}!"
_beep
exit 1
}

#test "`echo "$UNDER_ME_LIST" | head -n1 | grep " ${ITEM}$"`" || {
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep " ${ITEM}$"`" || {
_draw 3 "${ITEM} is not topmost!"
_beep
exit 1
}

_draw 7 "OK."
return 0
}

_check_for_space(){
# *** Check for 4 empty space to DIRB ***#

local REPLY_MAP OLD_REPLY NUMBERT
test "$1" && NUMBERT="$1"
test "$NUMBERT" || NUMBERT=4
#test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space: Need a digit. Invalid parameter passed:$*"
test "${NUMBERT//[0-9]/}" && _exit 2 "_check_for_space: Need a digit. Invalid parameter passed:$*"
_draw 5 "Checking for space to move..."


#         if ( strncmp(c,"pos",3)==0 ) { // v.1.10.0
#            char buf[1024];
#
#            sprintf(buf,"request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if ( strncmp(c,"pos",3)==0 ) { // v.1.12.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if (strncmp(c, "pos", 3) == 0) { // v.1.70.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n", pl_pos.x+use_config[CONFIG_MAPWIDTH]/2, pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2);
#            write(scripts[i].out_fd, buf, strlen(buf));

#        if ( strncmp(c,"near",4)==0 ) { // v.1.10.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#         }

#        if ( strncmp(c,"near",4)==0 ) { // v.1.12.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#        }


#         if (strncmp(c, "near", 4) == 0) { // v.1.70.0
#                for (y = 0; y < 3; ++y)
#                    for (x = 0; x < 3; ++x)
#                        send_map(i,
#                            x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                            y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                        );
#         }

echo request map pos

#echo watch request

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville

while :; do
read -t $TMOUT REPLY_MAP
#echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
_log "$REPLY_LOG" "_check_for_space:$REPLY_MAP"
_debug "REPLY_MAP='$REPLY_MAP'"
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

#echo unwatch request

test ! "$REPLY_MAP" -a "$OLD_REPLY" && REPLY_MAP="$OLD_REPLY" #+++2017-03-20

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'` #request map pos:request map pos 280 231
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`
_debug PL_POS_X=$PL_POS_X
_debug PL_POS_Y=$PL_POS_Y

if test "$PL_POS_X" -a "$PL_POS_Y"; then

#if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then
if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

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
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
esac

    _say_map_pos_1_10_0(){
    cat >&2 <<EoI
    // client v.1.10.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
        sprintf(buf,"request map %d %d unknown\n",x,y);
        write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    sprintf(buf,"request map %d %d  %d %c %c %c %c"
            " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
            x,y,the_map.cells[x][y].darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_update,
            'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
            'n'+('y'-'n')*the_map.cells[x][y].cleared,
            the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
            the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
            the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
        );
        write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_12_0(){
    cat >&2 <<EoI
    // client v.1.12.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
      snprintf(buf, sizeof(buf), "request map %d %d unknown\n",x,y);
      write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
           " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
           x,y,the_map.cells[x][y].darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_update,
           'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
           'n'+('y'-'n')*the_map.cells[x][y].cleared,
           the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
           the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
           the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
      );
      write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_70_0(){
    cat >&2 <<EoI
    // client v.1.70.0 common/script.c
    static void send_map(int i, int x, int y) {
    char buf[1024];

    if (x < 0 || y < 0 || the_map.x <= x || the_map.y <= y) {
        snprintf(buf, sizeof(buf), "request map %d %d unknown\n", x, y);
        write(scripts[i].out_fd, buf, strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
        " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
        x, y, the_map.cells[x][y].darkness,
        the_map.cells[x][y].need_update ? 'y' : 'n',
        the_map.cells[x][y].have_darkness ? 'y' : 'n',
        the_map.cells[x][y].need_resmooth ? 'y' : 'n',
        the_map.cells[x][y].cleared ? 'y' : 'n',
        the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
        the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
        the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
    );
    write(scripts[i].out_fd, buf, strlen(buf));
    }
EoI
    }


echo request map $R_X $R_Y

#echo watch request

while :; do
read -t $TMOUT
#echo "request map '$R_X' '$R_Y':$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request map '$R_X' '$R_Y':$REPLY"
_debug  "$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`
#echo "IS_WALL=$IS_WALL" >>"$REPLY_LOG"
_log "$REPLY_LOG" "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

#echo unwatch request

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

_check_for_space_old_client(){
# *** Check for 4 empty space to DIRB ***#

local REPLY_MAP OLD_REPLY NUMBERT cm
test "$1" && NUMBERT="$1"
test "$NUMBERT" || NUMBERT=4
#test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space_old_client: Need a digit. Invalid parameter passed:$*"
test "${NUMBERT//[0-9]/}" && _exit 2 "_check_for_space_old_client: Need a digit. Invalid parameter passed:$*"

_draw 5 "Checking for space to move..."


#         if ( strncmp(c,"pos",3)==0 ) { // v.1.10.0
#            char buf[1024];
#
#            sprintf(buf,"request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if ( strncmp(c,"pos",3)==0 ) { // v.1.12.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n",pl_pos.x,pl_pos.y);
#            write(scripts[i].out_fd,buf,strlen(buf));
#         }

#         if (strncmp(c, "pos", 3) == 0) { // v.1.70.0
#            char buf[1024];
#
#            snprintf(buf, sizeof(buf), "request map pos %d %d\n", pl_pos.x+use_config[CONFIG_MAPWIDTH]/2, pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2);
#            write(scripts[i].out_fd, buf, strlen(buf));

#        if ( strncmp(c,"near",4)==0 ) { // v.1.10.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#         }

#        if ( strncmp(c,"near",4)==0 ) { // v.1.12.0
#            for(y=0;y<3;++y)
#               for(x=0;x<3;++x)
#                  send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                     );
#        }


#         if (strncmp(c, "near", 4) == 0) { // v.1.70.0
#                for (y = 0; y < 3; ++y)
#                    for (x = 0; x < 3; ++x)
#                        send_map(i,
#                            x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                            y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                        );
#         }

#echo watch request

sleep 0.5

echo request map near

#echo watch request

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville
#                request map near:request map     279 231  0 n n n n smooth 30 0 0 heads 4854 825 0 tails 0 0 0
cm=0
while :; do
cm=$((cm+1))
read -t $TMOUT REPLY_MAP
#echo "request map pos:$REPLY_MAP" >>"$REPLY_LOG"
_log "$REPLY_LOG" "_check_for_space_old_client:$REPLY_MAP"
_debug "$REPLY_MAP"
test "$cm" = 5 && break
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

#echo unwatch request

_empty_message_stream

test ! "$REPLY_MAP" -a "$OLD_REPLY" && REPLY_MAP="$OLD_REPLY" #+++2017-03-20

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $3}'` #request map near:request map 278 230  0 n n n n smooth 30 0 0 heads 4854 0 0 tails 0 0 0
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $4}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

#if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then
if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

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
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
esac

    _say_map_pos_1_10_0(){
    cat >&2 <<EoI
    // client v.1.10.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
        sprintf(buf,"request map %d %d unknown\n",x,y);
        write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    sprintf(buf,"request map %d %d  %d %c %c %c %c"
            " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
            x,y,the_map.cells[x][y].darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_update,
            'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
            'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
            'n'+('y'-'n')*the_map.cells[x][y].cleared,
            the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
            the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
            the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
        );
        write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_12_0(){
    cat >&2 <<EoI
    // client v.1.12.0 common/script.c
    static void send_map(int i,int x,int y)
    {
    char buf[1024];

    if (x<0 || y<0 || the_map.x<=x || the_map.y<=y)
    {
      snprintf(buf, sizeof(buf), "request map %d %d unknown\n",x,y);
      write(scripts[i].out_fd,buf,strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
           " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
           x,y,the_map.cells[x][y].darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_update,
           'n'+('y'-'n')*the_map.cells[x][y].have_darkness,
           'n'+('y'-'n')*the_map.cells[x][y].need_resmooth,
           'n'+('y'-'n')*the_map.cells[x][y].cleared,
           the_map.cells[x][y].smooth[0],the_map.cells[x][y].smooth[1],the_map.cells[x][y].smooth[2],
           the_map.cells[x][y].heads[0].face,the_map.cells[x][y].heads[1].face,the_map.cells[x][y].heads[2].face,
           the_map.cells[x][y].tails[0].face,the_map.cells[x][y].tails[1].face,the_map.cells[x][y].tails[2].face
      );
      write(scripts[i].out_fd,buf,strlen(buf));
    }
EoI
    }

    _say_map_pos_1_70_0(){
    cat >&2 <<EoI
    // client v.1.70.0 common/script.c
    static void send_map(int i, int x, int y) {
    char buf[1024];

    if (x < 0 || y < 0 || the_map.x <= x || the_map.y <= y) {
        snprintf(buf, sizeof(buf), "request map %d %d unknown\n", x, y);
        write(scripts[i].out_fd, buf, strlen(buf));
    }
    /*** FIXME *** send more relevant data ***/
    snprintf(buf, sizeof(buf), "request map %d %d  %d %c %c %c %c"
        " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
        x, y, the_map.cells[x][y].darkness,
        the_map.cells[x][y].need_update ? 'y' : 'n',
        the_map.cells[x][y].have_darkness ? 'y' : 'n',
        the_map.cells[x][y].need_resmooth ? 'y' : 'n',
        the_map.cells[x][y].cleared ? 'y' : 'n',
        the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
        the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
        the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
    );
    write(scripts[i].out_fd, buf, strlen(buf));
    }
EoI
    }


echo request map $R_X $R_Y

#echo watch request

while :; do
read -t $TMOUT
#echo "request map '$R_X' '$R_Y':$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request map '$R_X' '$R_Y':$REPLY"
_debug "$REPLY"
test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`
#echo "IS_WALL=$IS_WALL" >>"$REPLY_LOG"
_log "$REPLY_LOG" "IS_WALL=$IS_WALL"
test "$IS_WALL" = 0 || _exit_no_space 1

test "$REPLY" || break
unset REPLY
sleep 0.1s
done

#echo unwatch request

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

_prepare_rod_of_recall(){
# *** Unreadying rod of word of recall - just in case *** #

local RECALL OLD_REPLY REPLY

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

#echo watch request

while :; do
read -t $TMOUT
#echo "request items actv:$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "request items actv:$REPLY"
_debug "$REPLY"
case $REPLY in
*rod*of*word*of*recall*) RECALL=1;;
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , _emergency_exit applies again
_is 1 1 apply rod of word of recall
fi

#echo unwatch request

_draw 6 "Done."

}


_check_empty_cauldron(){
# *** Check if cauldron is empty *** #

local REPLY OLD_REPLY REPLY_ALL

_is 1 1 pickup 0  # precaution otherwise might pick up cauldron
sleep 0.5
sleep ${SLEEP}s

_draw 5 "Checking for empty cauldron..."

_is 1 1 apply
sleep 0.5
sleep ${SLEEP}s

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

_watch
#sleep 0.5

#issue <repeat> <must_send> <command>
#- send <command> to server on behalf of client.
#<repeat> is the number of times to execute command
#<must_send> tells whether or not the command must sent at all cost (1 or 0).
#<repeat> and <must_send> are optional parameters.
#See The Issue Command for more details.
#issue 1 0 get nugget (works as 'get 1 nugget')
#issue 2 0 get nugget (works as 'get 2 nugget')
#issue 1 1 get nugget (works as 'get 1 nugget')
#issue 2 1 get nugget (works as 'get 2 nugget')
#issue 0 0 get nugget (works as 'get nugget')

#_is 1 1 get  ##gets 1 of topmost item
#_is 0 1 take
#_is 0 1 get all
#_is 0 1 get
_is 99 1 get

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water

#cr=0
while :; do
#cr=$((cr+1))
read -t $TMOUT
#echo "take:$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "take:$cr:$REPLY"
_debug "$REPLY"
#REPLY_ALL="$REPLY
#$REPLY_ALL"
#REPLY_ALL=`echo -e "$REPLY"\\n"$REPLY_ALL"`
REPLY_ALL=`echo -e "$REPLY\\n$REPLY_ALL"`

#if test "$cr" -ge 50; then
test "$REPLY" || break
#break
#fi
unset REPLY
sleep 0.1s
done

case $REPLY_ALL in
*You*pick*up*the*cauldron*) _exit 1 "pickup 0 seems not to work in script..?";;
*Nothing*to*take*) :;;
*) _exit 1 "Cauldron NOT empty !!";;
esac
#test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
#_draw 3 "Cauldron NOT empty !!"
#_draw 3 "Please empty the cauldron and try again."
#_exit 1
#}

#echo unwatch $DRAWINFO
_unwatch

sleep ${SLEEP}s

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF

sleep ${SLEEP}s

_draw 7 "OK ! Cauldron SEEMS empty."
}

_alch_and_get(){

_check_if_on_cauldron

local REPLY OLD_REPLY
local HAVE_CAULDRON=1
_unknown &

if test "$DRAWINFO" = drawextinfo; then
echo watch drawinfo
#echo watch $DRAWINFO
_watch
else
#echo watch $DRAWINFO
_watch
fi

sleep 0.5
_is 1 1 use_skill alchemy

# *** TODO: The cauldron burps and then pours forth monsters!
OLD_REPLY="";
REPLY="";
while :; do
read -t $TMOUT
#echo "$REPLY" >>"$REPLY_LOG"
_log "$REPLY_LOG" "alchemy:$REPLY"
_debug "$REPLY"
case $REPLY in
                                                       #(level < 25)  /* INGREDIENTS USED/SLAGGED */
                                                       #(level < 40)  /* MAKE TAINTED ITEM */
                                                       #(level == 40) /* MAKE RANDOM RECIPE */ if 0
                                                       #(level < 45)  /* INFURIATE NPC's */
*The*cauldron*creates*a*bomb*) _emergency_exit 1;;     #(level < 50)  /* MINOR EXPLOSION/FIREBALL */
                                                       #(level < 60)  /* CREATE MONSTER */
*The*cauldron*erupts*in*flame*)     HAVE_CAULDRON=0;;  #(level < 80)  /* MAJOR FIRE */
*The*burning*item*erupts*in*flame*) HAVE_CAULDRON=0;;  #(level < 80)  /* MAJOR FIRE */
*turns*darker*then*makes*a*gulping*sound*) _exit 1 "Cauldron probably got cursed";;  #(level < 100) /* WHAMMY the CAULDRON */
*Your*cauldron*becomes*darker*) _exit 1 "Cauldron probably got cursed";;  #(level < 100) /* WHAMMY the CAULDRON */
*pours*forth*monsters*) _emergency_exit 1;;            #(level < 110) /* SUMMON EVIL MONSTERS */
                                                       #(level < 150) /* COMBO EFFECT */
                                                       #(level == 151) /* CREATE RANDOM ARTIFACT */
*You*unwisely*release*potent*forces*) _emergency_exit 1;;  #else /* MANA STORM - watch out!! */
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$HAVE_CAULDRON" = 0; then
 _check_if_on_cauldron && HAVE_CAULDRON=1
 test "$HAVE_CAULDRON" = 0 && _exit 1 "Destroyed cauldron." # :D
fi

_is 1 1 apply

#issue <repeat> <must_send> <command>
#- send <command> to server on behalf of client.
#<repeat> is the number of times to execute command
#<must_send> tells whether or not the command must sent at all cost (1 or 0).
#<repeat> and <must_send> are optional parameters.
#See The Issue Command for more details.

#_is  1 1 get  # [AMOUNT] [ITEM]
#_is 99 1 take # [ITEM] ## take gets <repeat> of ITEM -> 99 should be enough to empty the cauldron

#issue 1 0 get nugget (works as 'get 1 nugget')
#issue 2 0 get nugget (works as 'get 2 nugget')
#issue 1 1 get nugget (works as 'get 1 nugget')
#issue 2 1 get nugget (works as 'get 2 nugget')
#issue 0 0 get nugget (works as 'get nugget')
#_is 0 1 take
#_is 0 1 get all
#_is 0 1 get
_is 99 1 get

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
read -t $TMOUT
#echo "take:$REPLY" >>"$REPLY_LOG"
_log "$get:REPLY_LOG" "take:$REPLY"
_debug "$REPLY"
case $REPLY in
*Nothing*to*take*)   NOTHING=1;;
*You*pick*up*the*slag*) SLAG=1;;
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$DRAWINFO" = drawextinfo; then
echo unwatch drawinfo
#echo unwatch $DRAWINFO
_unwatch
else
echo unwatch $DRAWINFO
_unwatch
fi

sleep ${SLEEP}s
}

_check_drop_or_exit(){
local HAVE_PUT=0
local OLD_REPLY="";
local REPLY="";
while :; do
read -t $TMOUT
_log "$REPLY_LOG" "_check_drop_or_exit:$REPLY"
_debug "_check_drop_or_exit:'$REPLY'"
case $REPLY in
*Nothing*to*drop*)                _exit 1 "Missing '$@' in inventory";;
*There*are*only*|*There*is*only*) _exit 1 "Not enough '$@' to drop." ;;
*You*put*in*cauldron*) HAVE_PUT=$((HAVE_PUT+1));;
'') break;;
esac

unset REPLY
sleep 0.1s
done

case "$HAVE_PUT" in
0)   _exit 1 "Could not put.";;
1)   :;;
'')  _exit 2 "_check_drop_or_exit:ERROR:Got no content.";;
*[[:alpha:][:punct:]]*) _exit 2 "_check_drop_or_exit:ERROR:Got no number.";;
[2-9]*|1[0-9]*) _exit 1 "More than one stack of '$@' put.";;
esac
sleep ${SLEEP}s
}

_close_cauldron(){

_is 1 1 $DIRB
_is 1 1 $DIRB
sleep ${SLEEP}s

_is 1 1 $DIRF
_is 1 1 $DIRF
sleep ${SLEEP}s
}

_go_cauldron_drop_alch_yeld(){
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB

sleep ${SLEEP}s
}

_go_drop_alch_yeld_cauldron(){
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF

sleep ${SLEEP}s
#sleep ${DELAY_DRAWINFO}s
}

_check_cauldron_cursed(){
#_is 1 1 sense curse
_is 1 1 cast detect curse
_is 1 1 fire 0 # 0 is center
_is 1 1 fire_stop
}

_return_to_cauldron(){

_go_drop_alch_yeld_cauldron

_check_food_level

_get_player_speed -l || sleep ${DELAY_DRAWINFO}s

_check_if_on_cauldron

}

### ALCHEMY

#** the messages in the msgpane may pollute **#
#** need to catch msg to discard them into an unused variable **#
_empty_message_stream(){
local REPLY
while :;
do
read -t $TMOUT
_log "$REPLY_LOG" "_empty_message_stream:$REPLY"
#_debug "$REPLY"
test "$REPLY" || break
_debug "_empty_message_stream:$REPLY"
unset REPLY
sleep 0.1
done
}

#** we may get attacked and die **#
_check_hp_and_return_home(){

hpc=$((hpc+1))
test "$hpc" -lt $COUNT_CHECK_FOOD && return
hpc=0

local REPLY

test "$1" && local currHP=$1
test "$2" && local currHPMin=$2

test "$currHP"     || local currHP=$HP
test "$HP_MIN_DEF" && local currHPMin=$HP_MIN_DEF
test "$currHPMin"  || local currHPMin=$((MHP/10))

_debug currHP=$currHP currHPMin=$currHPMin
if test "$currHP" -le $currHPMin; then

_empty_message_stream
_is 1 1 apply -a rod of word of recall
_empty_message_stream

_is 1 1 fire center ## Todo check if already applied and in inventory
_is 1 1 fire_stop
_empty_message_stream

#echo unwatch $DRAWINFO
_unwatch
exit
fi

unset HP
}

#Food

_check_mana_for_create_food(){

local REPLY
_is 1 0 cast create

while :;
do

read -t $TMOUT
_log "$REPLY"
_debug "_check_mana_for_create_food:$REPLY"
case $REPLY in
*ready*the*spell*create*food*) return 0;;
*create*food*)
MANA_NEEDED=`echo "$REPLY" | awk '{print $NF}'`
test "$SP" -ge "$MANA_NEEDED" && return 0
;;
'') break;;
*) sleep 0.1; continue;;
esac

sleep 0.1
unset REPLY
done

return 1
}

_cast_create_food_and_eat(){

local lEAT_FOOD REPLY1 REPLY2 REPLY3 REPLY4 BUNGLE

test "$EAT_FOOD" && lEAT_FOOD="$EAT_FOOD"
test "$*" && lEAT_FOOD="$@"
test "$lEAT_FOOD" || lEAT_FOOD=$FOOD_DEF
test "$lEAT_FOOD" || lEAT_FOOD=food

#while :;
#do
#_check_mana_for_create_food && break || { sleep 10; continue; }
#done

_is 1 1 pickup 0
_empty_message_stream

# TODO : Check MANA
_is 1 1 cast create food $lEAT_FOOD
_empty_message_stream

_is 1 1 fire_stop
#sleep 0.1

while :;
do
#_is 1 1 fire_stop
#sleep 0.1

while :;
do
_check_mana_for_create_food && break || { sleep 10; continue; }
done

sleep 0.1
_is 1 1 fire center ## Todo handle bungling the spell AND low mana

unset BUNGLE
sleep 0.1
read -t $TMOUT BUNGLE
test "`echo "$BUNGLE" | grep -E -i 'bungle|fumble|not enough'`" || break
_is 1 1 fire_stop
sleep 10
done

_is 1 1 fire_stop
sleep 1
_empty_message_stream


_is 1 1 apply ## Todo check if food is there on tile
_empty_message_stream

#+++2017-03-20 pickup any leftovers
#_is 1 1 get  ##gets 1 of topmost item
_is 0 1 take $lEAT_FOOD
#_is 0 1 get all
#_is 0 1 get
#_is 99 1 get  ## TODO: would get cauldron if only one $lEAT_FOOD

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water
_empty_message_stream

}

_apply_horn_of_plenty_and_eat(){
local REPLY

read -t $TMOUT
unset REPLY
_is 1 1 apply -a Horn of Plenty
#+++2017-03-20 handle failure applying
while :;
do
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"
case $REPLY in
*apply*) break;;
*) _exit 1;;
esac
unset REPLY
sleep 1
done

sleep 1
unset REPLY
read -t $TMOUT

#+++2017-03-20 check if available
# check if topmost item has changed afterwards

while :; #+++2017-03-20 handle bungle AND time to charge
do
_is 1 1 fire center ## Todo handle bungling AND time to charge

unset BUNGLE
sleep 0.1
read -t $TMOUT BUNGLE
_log "$BUNGLE"
_debug "$BUNGLE"
test "`echo "$BUNGLE" | grep -E -i 'bungle|fumble|needs more time to charge'`" || break
sleep 0.1
unset BUNGLE
sleep 1
done

_is 1 1 fire_stop
sleep 1
unset REPLY
read -t $TMOUT

#+++2017-03-20 check if available
# check if topmost item has changed afterwards

# check known food items
echo request items on

while :;
do
unset REPLY
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"
case $REPLY in
*cursed*|*poisoned*) exit 1;;
*apple*|*food*|*haggis*|*waybread*) :;;
*) exit 1;;
esac
break

done

_is 1 1 apply ## Todo check if food is there on tile AND if not poisoned/cursed
unset REPLY
read -t $TMOUT

#+++2017-03-20 pickup any leftovers
#_is 1 1 get  ##gets 1 of topmost item
#_is 0 1 take
#_is 0 1 get all
#_is 0 1 get
#_is 99 1 get

# Note : the commandline of the client handles take and get differently:
# 'get  4 water' would get 4 water of every item containing water
# 'take 4 water' ignores the number and would get all water from the topmost item containing water
#_empty_message_stream

}


_eat_food(){

local REPLY

test "$*" && EAT_FOOD="$@"
test "$EAT_FOOD" || EAT_FOOD=waybread

#_check_food_inventory ## Todo: check if food is in INV

read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"
_is 1 1 apply $EAT_FOOD
unset REPLY
read -t $TMOUT
}

_check_food_level(){

fc=$((fc+1))
test "$fc" -lt $COUNT_CHECK_FOOD && return
fc=0

test "$*" && MIN_FOOD_LEVEL="$@"
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-$MIN_FOOD_LEVEL_DEF}
MIN_FOOD_LEVEL=${MIN_FOOD_LEVEL:-200}

local FOOD_LVL=''
local REPLY

read -t $TMOUT  # empty the stream of messages

_watch
sleep 1
echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
while :;
do
unset FOOD_LVL
read -t1 Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
test "$Re" = request || continue

test "$FOOD_LVL" || break
#test "${FOOD_LVL//[[:digit:]]/}" && break
test "${FOOD_LVL//[0-9]/}" && break

_debug HP=$HP $MHP $SP $MSP $GR $MGR FOOD_LVL=$FOOD_LVL #DEBUG

if test "$FOOD_LVL" -lt $MIN_FOOD_LEVEL; then
 #_eat_food
 _cast_create_food_and_eat $EAT_FOOD

 sleep 1
 _empty_message_stream
 sleep 1
 echo request stat hp   #hp,maxhp,sp,maxsp,grace,maxgrace,food
 #sleep 0.1
 sleep 1
 read -t1 Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2 FOOD_LVL
 _debug HP=$HP2 $MHP2 $SP2 $MSP2 $GR2 $MGR2 FOOD_LVL=$FOOD_LVL #DEBUG

 #return $?
 break
fi

#test "${FOOD_LVL//[[:digit:]]/}" || break
test "${FOOD_LVL//[0-9]/}" || break
test "$FOOD_LVL" && break
test "$oF" = "$FOOD_LVL" && break

oF="$FOOD_LVL"
sleep 0.1
done

#echo unwatch $DRAWINFO
_unwatch
}

#Food

__loop_counter(){
test "$TIMEA" -a "$TIMEB" -a "$NUMBER" -a "$one" || return 0
TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
TIMEZ=$((TIMEE-TIMEA))
TIMEAV=$((TIMEZ/one))
TIMEEST=$(( (TRIES_STILL*TIMEAV) / 60 ))
_draw 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_STILL ($TIMEEST m) to go..."
}

_loop_counter(){
test "$TIMEA" -a "$TIMEB" -a "$NUMBER" -a "$one" || return 0
TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIMEX=$((TIMEE-TIMEB))
TIMEZ=$((TIMEE-TIMEA))
TIMEAV=$((TIMEZ/one))
TIMEESTM=$(( (TRIES_STILL*TIMEAV) / 60 ))
TIMEESTS=$(( (TRIES_STILL*TIMEAV) - (TIMEESTM*60) ))
case $TIMEESTS in [0-9]) TIMEESTS="0$TIMEESTS";; esac
_draw 4 "Elapsed '$TIMEX' s, '$success' of '$one' successfull."
_draw 4 "Still '$TRIES_STILL' ($TIMEESTM:$TIMEESTS m) to go..."
}
