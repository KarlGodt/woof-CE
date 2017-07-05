#!/bin/ash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

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
#
#define NDI_COLOR_MASK  0xff    /**< Gives lots of room for expansion - we are
#                                 *   using an int anyways, so we have the
#                                 *   space to still do all the flags.
#                                 */
#define NDI_UNIQUE      0x100   /**< Print immediately, don't buffer. */
#define NDI_ALL         0x200   /**< Inform all players of this message. */
#define NDI_ALL_DMS     0x400   /**< Inform all logged in DMs. Used in case of
#                                 *   errors. Overrides NDI_ALL. */

# Now count the whole script time
TIMEA=`/bin/date +%s`

# *** Setting defaults *** #

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
northwest) DIRF=southeast;;
northeast) DIRF=southwest;;
southwest) DIRF=northeast;;
southeast) DIRF=northwest;;
esac

ITEM_RECALL='rod of word of recall' # f_emergency_exit uses this ( staff, scroll, rod of word of recall )

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

DELAY_DRAWINFO=2    # additional sleep value in seconds

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
sleep $(( (RANDOM%7) + 1 ))
done >/dev/null
}

_usage(){
_draw 5 "Script to produce water of GEM."
_draw 7 "Syntax:"
_draw 7 "$0 GEM < NUMBER >"
_draw 2 "Allowed GEM are diamond, emerald,"
_draw 2 "pearl, ruby, sapphire ."
_draw 5 "Optional NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Water of GEM ."
_draw 4 "If no number given, loops as long"
_draw 4 "as ingredients could be dropped."
_draw 2 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v  to be more talkaktive."
_draw 7 "-F each --fast sleeps 0.2 s less"
_draw 8 "-S each --slow sleeps 0.2 s more"
_draw 3 "-X --nocheck do not check cauldron (faster)"
        exit 0
}

# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***

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
test "$one" -a "$FAIL" || return 3

if test "$FAIL" -le 0; then
 SUCC=$((one-FAIL))
 _draw 7 "You succeeded $SUCC times of $one ." # green
elif test "$((one/FAIL))" -lt 2;
then
 _draw 8 "You failed $FAIL times of $one ."    # light green
 _draw 7 "PLEASE increase your INTELLIGENCE !!"
else
 SUCC=$((one-FAIL))
 _draw 7 "You succeeded $SUCC times of $one ." # green
fi
}

_remove_err_log(){
local lFILE="$1"
lFILE=${lFILE:-/tmp/cf_script.err}

if  test -e "$lFILE"; then
 if test -s "$lFILE"; then
  _draw 3 "Content in '$lFILE'"
 else
  _draw 7 "No content in '$lFILE'"
  [ "$DEBUG" ] || rm -f "$lFILE"
 fi
else
 _draw 5 "Does not exist: '$lFILE'"
fi
}

_say_statistics_end(){
# Now count the whole loop time
TIMELE=`/bin/date +%s`
_say_minutes_seconds "$TIMEB" "$TIMELE" "Whole  loop  time :"

_say_success_fail

# Now count the whole script time
TIMEZ=`/bin/date +%s`
_say_minutes_seconds "$TIMEA" "$TIMEZ" "Whole script time :"

_remove_err_log
}

_sleepSLEEP(){
[ "$FAST" ] && return 0
sleep ${SLEEP:-1}s
}

_draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local lMSG="$*"
    echo draw $lCOLOUR "$lMSG"
}

__draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local lMSG="$*"
while read -r line
do
   _draw $lCOLOUR "$line"
    done <<EoI
`echo "$lMSG"`
EoI
}

# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"$lFILE"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_debug(){
test "$DEBUG" || return 0
_draw ${COL_DEB:-3} "DEBUG:$*"
#__draw ${COL_DEB:-3} "DEBUG:$*"
}

__debug(){
test "$DEBUG" || return 0
#_draw ${COL_DEB:-3} "DEBUG:$*"
__draw ${COL_DEB:-3} "DEBUG:$*"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}


CHECK_DO=1
# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
test "$*" || {
_draw 3 "Need <gem> and optinally <number> ie: script $0 ruby 3 ."
_draw 3 "See -h or --help parameter for more info."
        exit 1
}

#[ "$*" ] && {
until test "$#" = 0
do
PARAM_1="$1"

case "$PARAM_1" in
-h|*help|*usage) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
-F|*fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
-S|*slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
-X|*nocheck) unset CHECK_DO;;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)      DEBUG=$((DEBUG+1));;
      --log*)    LOGGING=$((LOGGING+1));;
      --verbose) VERBOSE=$((VERBOSE+1));;
      --fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
      --slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
      --nocheck) unset CHECK_DO;;
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
      F) SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
      S) SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
      X) unset CHECK_DO;;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

'') :;;

diamond|emerald|pearl|ruby|sapphire)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:alpha:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :alpha: characters as first option allowed."
        exit 1 #exit if other input than letters
        }

GEM="$PARAM_1"
;;
[0-9]*)
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as second option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1
;;
*) _draw 3 "Ignoring unhandled option '$PARAM_1'"; GEM="$PARAM_1";;
esac
shift
sleep 0.1
done

# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***

#} || {
#echo draw 3 "Script needs gem and number of alchemy attempts as arguments."
#        exit 1
#}
#
#test "$1" -a "$2" || {
#echo draw 3 "Need <gem> and <number> ie: script $0 ruby 3 ."
#        exit 1
#}

#if test ! "$GEM"; then #set fallback
#GEM=diamond
##GEM=sapphire
##GEM=ruby
##GEM=emerald
##GEM=pearl
#fi

#if test ! "$NUMBER"; then
#echo draw 3 "Need a number of items to alch."
#exit 1
#elif test "$NUMBER" = 0; then
#echo draw 3 "Number must be notg ZERO."
#exit 1
#elif test "$NUMBER" -lt 0; then
#echo draw 3 "Number must be greater than ZERO."
#exit 1
#fi

#test "$GEM" != diamond -a "$GEM" != emerald -a "$GEM" != pearl \
#  -a "$GEM" != ruby -a "$GEM" != sapphire && {
#echo draw 3 "'$GEM' : Not a recognized kind of gem."
#exit 1
#}

test "$GEM" || {
_draw 3 "Need GEM set as parameter."
_usage
}

test "$GEM" = diamond -o "$GEM" = emerald -o "$GEM" = pearl \
  -o "$GEM" = ruby -o "$GEM" = sapphire || {
_draw 3 "'$GEM' : Not a recognized kind of gem."
exit 1
}

# *** EXIT FUNCTIONS *** #
f_exit(){
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawinfo
exit $1
}

f_emergency_exit(){
RV=${1:-0}
shift

_is "1 1 apply -u $ITEM_RECALL"
_is "1 1 apply -a $ITEM_RECALL"
_is "1 1 fire center"
_draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
_is "1 1 fire_stop"

NUMBER=$((one-1))
_say_statistics_end
test "$*" && _draw 5 "$*"
_beep
_beep
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

# *** PREREQUISITES *** #
# 1.) _get_player_speed
# 2.) _check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
# 3.) #__check_on_cauldron
# 3.) f_check_on_cauldron
# 4.) _check_free_move
# 5.) _check_empty_cauldron
# 6.) _prepare_recall

# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***

_check_skill(){
# *** Does our player possess the skill alchemy ? *** #
[ "$CHECK_DO" ] || return 0

local lPARAM="$*"
local lSKILL

echo request skills

while :;
do
 unset REPLY
 sleep 0.1
 read -t 2
  _log "$LOG_REPLY_FILE" "_check_skill:$REPLY"
  _debug "$REPLY"

 case $REPLY in    '') break;;
 'request skills end') break;;
 esac

 if test "$lPARAM"; then
  case $REPLY in *$lPARAM) return 0;; esac
 else # print skill
  lSKILL=`echo "$REPLY" | cut -f4- -d' '`
  _draw 5 "'$lSKILL'"
 fi

done

test ! "$lPARAM" # returns 0 if called without parameter, else 1
}

f_check_on_cauldron(){
# *** Check if standing on a cauldron *** #
UNDER_ME='';
echo request items on

while [ 1 ]; do
read UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done

 test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
 echo draw 3 "Need to stand upon cauldron!"
 exit 1
 }
}

_check_free_move(){
# *** Check for 4 empty space to DIRB *** #

[ "$CHECK_DO" ] || return 0

_draw 5 "Checking for space to move..."

local REPLY
unset REPLY

echo request map pos

while :; do
_ping
read -t 2 REPLY
 _log "$LOG_REPLY_FILE" "request map pos:$REPLY"
 _debug "map pos:'$REPLY'"

 case $REPLY in
 '')         break;;
 $OLD_REPLY) break;;
 *"request map pos end"*) break;;
 esac
OLD_REPLY="$REPLY"
sleep 0.1s
done

PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`
_debug "PL_POS_X='$PL_POS_X' PL_POS_Y='$PL_POS_Y'"

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

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
esac

_debug "R_X='$R_X' R_Y='$R_Y'"
echo request map $R_X $R_Y

while :; do
_ping
read -t 2 REPLY
_log "$LOG_REPLY_FILE" "request map '$R_X' '$R_Y':$REPLY"
_debug "REPLY='$REPLY'"

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
_log "$LOG_REPLY_FILE" "IS_WALL='$IS_WALL'"
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

# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***

_prepare_recall(){
# *** Readying $ITEM_RECALL - just in case *** #

[ "$CHECK_DO" ] || return 0

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
_ping
read -t 2 REPLY
_log "$LOG_REPLY_FILE" "request items actv:$REPLY"
_debug "REPLY='$REPLY'"

case $REPLY in
'')         break;;
$OLD_REPLY) break;;
*$ITEM_RECALL*) RECALL=1;;
esac

OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
_is "1 1 apply $ITEM_RECALL"
fi

_draw 6 "Done."
}

_check_empty_cauldron(){
# *** Check if cauldron is empty *** #
[ "$CHECK_DO" ] || return 0

_is "0 1 pickup 0"  # precaution otherwise might pick up cauldron
_sleepSLEEP

_draw 5 "Checking for empty cauldron..."

_is "1 1 apply"
_sleepSLEEP

OLD_REPLY="";
REPLY_ALL='';
REPLY="";

echo watch $DRAW_INFO

_is "1 1 get"

#echo watch $DRAW_INFO

while :; do
_ping
read -t 2 REPLY
_log "$LOG_REPLY_FILE" "get:$REPLY"
_debug "REPLY='$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
REPLY_ALL="$REPLY
$REPLY_ALL"

OLD_REPLY="$REPLY"
sleep 0.1s
done

 test "`echo "$REPLY_ALL" | grep '.*Nothing to take!'`" || {
 _draw 3 "Cauldron probably NOT empty !!"
 _draw 3 "Please check/empty the cauldron and try again."
 exit 1
 }

echo unwatch $DRAW_INFO

_draw 7 "OK ! Cauldron SEEMS empty."

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
}

# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***

_get_player_speed(){
# *** Getting Player's Speed *** #

_draw 5 "Processing Player's speed..."


ANSWER=
OLD_ANSWER=

echo request stat cmbt

while :; do
_ping
read -t 2 ANSWER
_log "$LOG_REQUEST_FILE" "request stat cmbt:$ANSWER"
_debug "$ANSWER"

test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_debug "Player speed is $PL_SPEED"

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_debug "Player speed set to $PL_SPEED"

if test ! "$PL_SPEED"; then
 _draw 3 "Unable to receive player speed. Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"

elif test "$PL_SPEED" -gt 95; then
SLEEP=0.6; DELAY_DRAWINFO=0.9
elif test "$PL_SPEED" -gt 85; then
SLEEP=0.7; DELAY_DRAWINFO=1.0
elif test "$PL_SPEED" -gt 75; then
SLEEP=0.8; DELAY_DRAWINFO=1.1
elif test "$PL_SPEED" -gt 65; then
SLEEP=0.9; DELAY_DRAWINFO=1.3
elif test "$PL_SPEED" -gt 55; then
SLEEP=1.1; DELAY_DRAWINFO=1.5
elif test "$PL_SPEED" -gt 45; then
SLEEP=1.3; DELAY_DRAWINFO=1.7
elif test "$PL_SPEED" -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test "$PL_SPEED" -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test "$PL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
elif test "$PL_SPEED" -ge  0; then
SLEEP=4.0; DELAY_DRAWINFO=9.0
else
 _draw 3 "PL_SPEED not a number ? Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
fi

_debug "SLEEP='$SLEEP'"
test "$SLEEP_ADJ" && { SLEEP=`dc $SLEEP ${SLEEP_ADJ} \+ p`
 _debug "SLEEP now set to '$SLEEP'" ; }

_draw 6 "Done."
}


_get_player_speed
_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
f_check_on_cauldron
_check_free_move
_check_empty_cauldron
_prepare_recall

# *** Actual script to alch the desired water of gem                *** #

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** DIRB of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


_is "1 1 pickup 0"  # precaution

test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}


#rm -f /tmp/cf_script.rpl

FAIL=0; one=0

TIMEB=`/bin/date +%s`

#for one in `seq 1 1 $NUMBER`
while :;
do

TIMEC=${TIMEE:-$TIMEB}

_is "1 1 apply"

echo watch drawinfo

_is "1 1 drop 1 water of the wise"

OLD_REPLY="";
REPLY="";


while [ 2 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

_sleepSLEEP

_is "1 1 drop 3 $GEM"

OLD_REPLY="";
REPLY="";

while [ 2 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | busybox grep -E '.*Nothing to drop\.|.*There are only.*|.*There is only.*'`" && f_exit 1
#test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
#test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo

_sleepSLEEP

_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP

_is "1 1 use_skill alchemy"
one=$((one+1))

_is "1 1 apply"

echo watch drawinfo

_is "1 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while [ 2 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

_sleepSLEEP
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_is "1 1 $DIRB"
_sleepSLEEP

echo draw 2 "NOTHING is '$NOTHING'"

if test $NOTHING = 0; then

_is "1 1 use_skill sense curse"
_is "1 1 use_skill sense magic"
_is "1 1 use_skill alchemy"
_sleepSLEEP

_is "1 1 drop water of $GEM"
_is "0 1 drop slags"

fi

#DELAY_DRAWINFO=2
sleep ${DELAY_DRAWINFO}s

_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_is "1 1 $DIRF"
_sleepSLEEP


f_check_on_cauldron

one=$((one+1))

TIMEE=`/bin/date +%s`
TIMER=$((TIMEE-TIMEC))
_draw 4 "Time $TIMER seconds"

if _test_integer $NUMBER; then
 TRIES_STILL=$((NUMBER-one))
 _draw 5 "Still '$TRIES_STILL' attempts to go .."

 TIME_STILL=$((TRIES_STILL*TIMER))
 TIME_STILL=$((TIME_STILL/60))
 _draw 5 "Still '$TIME_STILL' minutes to go..."
else
 TRIES_STILL=$one
 _draw 5 "Completed '$TRIES_STILL' attempts .."

 TIME_STILL=$((TRIES_STILL*TIMER))
 TIME_STILL=$((TIME_STILL/60))
 _draw 5 "Completed '$TIME_STILL' minutes. ..."
fi

test "$one" = "$NUMBER" && break
done  # *** Main Loop *** #

# *** Here ends program *** #
_say_statistics_end
echo draw 2 "$0 is finished."
_beep


# ***
# ***
# *** diff marker 22
