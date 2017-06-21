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

# Now count the whole script time
TIMEA=`/bin/date +%s`

# ***VARIABLES *** #
# *** Setting defaults *** #

# When putting ingredients into cauldron, player needs to leave cauldron
# to close it. Also needs to pickup and drop the result(s) to not
# increase carried weight. This version does not adjust player speed after
# several weight losses.

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

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

DELAY_DRAWINFO=2    # sleep seconds to sync msgs from script with msgs from server

ITEM_RECALL='rod of word of recall' # f_emergency_exit uses this ( staff, scroll, rod of word of recall )

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

PING_DO=
URL=crossfire.metalforge.net # localhost if server running on local PC

_usage(){
# *** implementing 'help' option *** #
echo draw 5 "Script to produce water of GEM."
echo draw 7 "Syntax:"
echo draw 7 "$0 GEM < NUMBER >"
echo draw 2 "Mandatory GEM are diamond, emerald,"
echo draw 2 "pearl, ruby, sapphire ."
echo draw 5 "Optional NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of GEM ."
echo draw 4 "If no number given, loops as long"
echo draw 4 "as ingredients could be dropped."
#echo draw 6 "Defaults:"
#echo draw 4 "GEM is set currently to '$GEM'"
#echo draw 4 "NUMBER is set to '$NUMBER'"
#echo draw 4 "in script header."
echo draw 2 "Options:"
echo draw 5 "-d  to turn on debugging."
echo draw 5 "-L  to log to $LOG_REPLY_FILE ."
echo draw 5 "-v  to be more talkaktive."
echo draw 7 "-F each --fast sleeps 0.2 s less"
echo draw 8 "-S each --slow sleeps 0.2 s more"
echo draw 3 "-X --nocheck do not check cauldron (faster)"
        exit 0
}

# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***

_ping(){
test "$PING_DO" || return 0

local lFOREVER=''
local lPRV

case $1 in
-I|--infinite) lFOREVER=1;;
esac

while :; do
ping -c 1 -w10 -W10 "$URL" >/dev/null 2>&1
lPRV=$?
 if test "$lFOREVER"; then
  case $lPRV in 0) :;;
  *) echo draw 3 "WARNING: Client seems disconnected.." >&1;;
  esac
  sleep 2
 else
  case $lPRV in 0) return 0;;
  *) :;;
  esac
 fi

 sleep 1
done
}

#_ping -I &  # when cut off by wonky mobile connection,
         # the whole script waits, even forked functions.
         # would need an external script, that shows a xmessage ..

_kill_jobs(){
for p in `jobs -p`; do kill -9 $p; done
}

# *** Common functions *** #

# *** EXIT FUNCTIONS *** #
f_exit(){
RV=${1:-0}
shift

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s

test "$*" && echo draw 5 "$*"
echo draw 3 "Exiting $0."

echo unwatch
echo unwatch $DRAW_INFO
beep -l 500 -f 700
_kill_jobs
exit $RV
}

f_exit_no_space(){
RV=${1:-0}
shift

echo draw 3 "On position $nr $DIRB there is Something ($IS_WALL)!"
echo draw 3 "Remove that Item and try again."
echo draw 3 "If this is a Wall, try another place."

test "$*" && echo draw 5 "$*"
beep -l 500 -f 700
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

echo "issue 1 1 apply -u $ITEM_RECALL"
echo "issue 1 1 apply -a $ITEM_RECALL"
echo "issue 1 1 fire center"
echo draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
echo "issue 1 1 fire_stop"

test "$*" && echo draw 5 "$*"
beep -l 500 -f 700
exit $RV
}

_debug(){
[ "$DEBUG" ]       || return 0
echo "$*" | while read line; do echo draw 3 "$line"; done
}

_debug_two(){
[ "$DEBUG" ]       || return 3
[ "$DEBUG" -ge 2 ] || return 4
}


CHECK_DO=1
# *** Here begins program *** #
echo draw 2 "$0 is started:"
echo draw 2 "PID $$ -- PPID $PPID"
echo draw 2 "ARGUMENTS:$*"

# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***

# *** Check for parameters *** #

until [ "$#" = 0 ]
do

PARAM_1="$1"

case "$PARAM_1" in

-h|*help|*usage) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
-F|*fast)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \- p`;;
-S|*slow)    SLEEP_ADJ=`dc ${SLEEP_ADJ:-0} 0.2 \+ p`;;
-X|*nocheck) unset CHECK_DO;;

diamond|emerald|pearl|ruby|sapphire)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:alpha:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :alpha: characters as first option allowed."
        f_exit 1 #exit if other input than letters
        }

GEM="$PARAM_1"
;;
[0-9]*)
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as second option allowed."
        f_exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1
;;
*) echo draw 3 "Ignoring unhandled option '$PARAM_1'";;
esac
sleep 0.1
shift
done


test "$GEM" = diamond -o "$GEM" = emerald -o "$GEM" = pearl \
  -o "$GEM" = ruby -o "$GEM" = sapphire || {
echo draw 3 "'$GEM' : Not a recognized kind of gem."
f_exit 1
}

# *** Do NOT pickup cauldron *** #
echo "issue 1 1 pickup 0"  # precaution

# *** PREREQUISITES *** #
# 1.) _check_skill
# 2.) _check_if_on_cauldron    # first use inside loop
# 3.) _check_free_move
# 4.) _check_if_empty_cauldron # first use inside loop

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
  [ "$LOGGING" ] && echo "_check_skill:$REPLY" >>"$LOG_REPLY_FILE"
  [ "$DEBUG" ] && echo draw 6 "$REPLY"

 case $REPLY in    '') break;;
 'request skills end') break;;
 esac

 if test "$lPARAM"; then
  case $REPLY in *$lPARAM) return 0;; esac
 else # print skill
  lSKILL=`echo "$REPLY" | cut -f4- -d' '`
  echo draw 5 "'$lSKILL'"
 fi

done

test ! "$lPARAM" # returns 0 if called without parameter, else 1
}

# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***

_check_if_on_cauldron(){
# *** Check if standing on a cauldron *** #
[ "$CHECK_DO" ] || return 0

echo draw 5 "Check if on cauldron..."

local UNDER_ME=''
local UNDER_ME_LIST=''

echo request items on

while [ 1 ]; do
#read UNDER_ME
read -t 2 UNDER_ME
sleep 0.1s
[ "$LOGGING" ] && echo "_check_if_on_cauldron:$UNDER_ME" >>/tmp/cf_script.ion
[ "$DEBUG" ] && echo draw 6 "$UNDER_ME"

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"  # code further down does not care
         # if other msgs go into UNDER_ME_LIST variable

test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && f_exit 1
done

_debug "$UNDER_ME_LIST"
 test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
  echo draw 3 "Need to stand upon cauldron!"
  f_exit 1
 }

echo draw 7 "Done."
return 0
}

_check_free_move(){
# *** Check for 4 empty space to DIRB *** #
[ "$CHECK_DO" ] || return 0

echo draw 5 "Checking for space to move..."

echo request map pos

while [ 1 ]; do
read -t 2 REPLY
[ "$LOGGING" ] && echo "_check_free_move:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break

OLD_REPLY="$REPLY"
sleep 0.1s
done


PL_POS_X=`echo "$REPLY" | awk '{print $4}'`
PL_POS_Y=`echo "$REPLY" | awk '{print $5}'`
[ "$DEBUG" ] && echo draw 3 "PL_POS_X='$PL_POS_X' PL_POS_Y='$PL_POS_Y'"

if test "$PL_POS_X" -a "$PL_POS_Y"; then

if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then

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

[ "$DEBUG" ] && echo draw 3 "R_X='$R_X' R_Y='$R_Y'"
echo request map $R_X $R_Y

while [ 1 ]; do
read -t 2 REPLY
[ "$LOGGING" ] && echo "_check_free_move:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break

IS_WALL=`echo "$REPLY" | awk '{print $16}'`
[ "$LOGGING" ] && echo "IS_WALL='$IS_WALL'" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "IS_WALL='$IS_WALL'"
test "$IS_WALL" = 0 || f_exit_no_space 1

OLD_REPLY="$REPLY"
sleep 0.1s
done

done

else

echo draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

echo draw 3 "Could not get X and Y position of player."
exit 1

fi

echo draw 7 "OK."
}

# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***

_check_if_empty_cauldron(){
# *** Check if cauldron is empty *** #
[ "$CHECK_DO" ] || return 0

echo draw 5 "Check if on cauldron..."

local OLD_REPLY="";
local REPLY="";
local NOTHING=0

echo watch $DRAW_INFO

echo "issue 1 1 apply"   # open cauldron
sleep ${SLEEP:-1}s  # 0.5

#echo watch $DRAW_INFO

echo "issue 1 1 get"     # empty cauldron

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "_check_if_empty_cauldron:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break

test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1

OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

if test "$NOTHING" = 0;
then
 f_exit 1 "Cauldron NOT empty."
fi

sleep ${SLEEP:-1}s

echo "issue 1 1 $DIRB"  # close cauldron
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP:-1}s
#sleep ${DELAY_DRAWINFO:-1}

echo draw 7 "Done. Cauldron SEEMS empty."
return 0
}

_get_player_speed(){
# *** Getting Player's Speed *** #

echo draw 5 "Processing Player's speed..."

ANSWER=
OLD_ANSWER=

echo request stat cmbt

while [ 1 ]; do
read -t 2 ANSWER
[ "$LOGGING" ] && echo "_get_player_speed:$ANSWER" >>/tmp/cf_request.log
[ "$DEBUG" ] && echo draw 6 "$ANSWER"

test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break

OLD_ANSWER="$ANSWER"
sleep 0.1
done


#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash
#PL_SPEED="0.${PL_SPEED:0:2}"
PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
[ "$DEBUG" ] && echo draw 7 "Player speed is $PL_SPEED"

#PL_SPEED="${PL_SPEED:2:2}"
PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
[ "$DEBUG" ] && echo draw 7 "Player speed set to $PL_SPEED"

if test ! "$PL_SPEED"; then
 echo draw 3 "Unable to receive player speed. Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
 elif test "$PL_SPEED" -gt 65; then
SLEEP=0.6; DELAY_DRAWINFO=1.2
elif test "$PL_SPEED" -gt 55; then
SLEEP=0.8; DELAY_DRAWINFO=1.3
elif test "$PL_SPEED" -gt 45; then
SLEEP=1.0; DELAY_DRAWINFO=1.5
elif test "$PL_SPEED" -gt 35; then
SLEEP=1.5; DELAY_DRAWINFO=2.0
elif test "$PL_SPEED" -gt 25; then
SLEEP=2.0; DELAY_DRAWINFO=4.0
elif test "$PL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0
elif test "$PL_SPEED" -ge  0; then
SLEEP=4.0; DELAY_DRAWINFO=9.0
else
 echo draw 3 "PL_SPEED not a number ? Using defaults '$SLEEP' and '$DELAY_DRAWINFO'"
fi

SLEEP=${SLEEP:-1}

_debug "SLEEP='$SLEEP'"
test "$SLEEP_ADJ" && { SLEEP=`dc $SLEEP $SLEEP_ADJ \+ p`
 case $SLEEP in -[0-9]*) SLEEP=0.1;; esac
 _debug "SLEEP now set to '$SLEEP'" ; }

SLEEP=${SLEEP:-1}

echo draw 6 "Done."
}

# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***

_prepare_recall(){
# *** Readying $ITEM_RECALL - just in case *** #
[ "$CHECK_DO" ]    || return 0
[ "$ITEM_RECALL" ] || return 3

echo draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while [ 1 ]; do
read -t 2 REPLY
[ "$LOGGING" ] && echo "_prepare_recall:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break

test "`echo "$REPLY" | grep ".* $ITEM_RECALL"`" && RECALL=1

OLD_REPLY="$REPLY"
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , f_emergency_exit applies again
echo "issue 1 1 apply $ITEM_RECALL"
fi

echo draw 6 "Done."
}

_get_player_speed
#_check_if_on_cauldron && _check_if_empty_cauldron && _check_if_on_cauldron || f_exit 1
_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."
_check_if_on_cauldron
_check_free_move
_check_if_empty_cauldron
_get_player_speed
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


test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

FAIL=0; one=0

TIMEB=`/bin/date +%s`

echo draw 4 "OK... Might the Might be with You!"

_debug_two && echo monitor; #DEBUG

# ***
# ***
# *** diff marker 12
# *** diff marker 13
# ***
# ***

# *** Now LOOPING *** #
while :;
do

TIMEC=${TIMEE:-$TIMEB}

_check_if_on_cauldron && _check_if_empty_cauldron && _check_if_on_cauldron || break


echo draw 2 "Opening cauldron ..."
echo "issue 1 1 apply"  # open cauldron
sleep ${SLEEP:-1}  #0.5

_debug_two || echo watch $DRAW_INFO

echo draw 4 "Dropping water of the wise ..."
echo "issue 1 1 drop 1 water of the wise"

OLD_REPLY="";
REPLY="";
DW=0
while [ 2 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break

test "`echo "$REPLY" | grep 'Nothing to drop'`" && break 2 # f_exit 1 "Nothing to drop"
test "`echo "$REPLY" | grep 'There are only'`"  && break 2 # f_exit 1 "Not enough water of the wise"
test "`echo "$REPLY" | grep 'There is only'`"   && break 2 # f_exit 1 "Not enough water of the wise"
test "`echo "$REPLY" | grep 'You put the water'`" && { DW=$((DW+1)); unset REPLY; } #s in cauldron (open) (active).

OLD_REPLY="$REPLY"
sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing water of the wise in inventory."
sleep ${SLEEP:-1}s

echo draw 4 "Dropping '$GEM' ..."
echo "issue 1 1 drop 3 $GEM"

OLD_REPLY="";
REPLY="";
DW=0
while [ 2 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break

test "`echo "$REPLY" | busybox grep -E 'Nothing to drop|There are only|There is only'`" && break 2 # f_exit 1 "Not enough $GEM"
test "`echo "$REPLY" | grep ".*You put the $GEM.*"`" && { DW=$((DW+1)); unset REPLY; } #s in cauldron (open) (active).

OLD_REPLY="$REPLY"
sleep 0.1s
done

test "$DW" -ge 2 && f_exit 3 "Too many different stacks containing $GEM in inventory."

_debug_two || echo unwatch $DRAW_INFO
sleep ${SLEEP:-1}s

echo draw 2 "Closing cauldron .."
echo "issue 1 1 $DIRB"  # close cauldron
echo "issue 1 1 $DIRB"
sleep ${SLEEP:-1}s  #0.5
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP:-1}s

sleep ${DELAY_DRAWINFO:-1}s
_check_if_on_cauldron

echo draw 4 "using skill alchemy ..."
echo "issue 1 1 use_skill alchemy"  # alch

_debug_two || echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
[ "$LOGGING" ] && echo "use_skill alchemy:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break

test "`echo "$REPLY" | grep 'pours forth monsters'`"    && f_emergency_exit 1
test "`echo "$REPLY" | grep 'You unwisely release potent forces'`" && break 2 # f_exit 1

OLD_REPLY="$REPLY"
sleep 0.1s
done

_debug_two || echo unwatch $DRAW_INFO

sleep ${SLEEP:-1}s  #0.5
echo draw 2 "Opening cauldron .."
echo "issue 1 1 apply"   # open cauldron
sleep ${SLEEP:-1}s  #0.5

_debug_two || echo watch $DRAW_INFO

echo draw 5 "Getting content .."
echo issue 0 0 "get all"

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while [ 2 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "get:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 6 "$REPLY"

test "$REPLY" || break
test "`echo "$REPLY" | grep 'monitor'`" && continue  # TODO
test "$REPLY" = "$OLD_REPLY" && break

test "`echo "$REPLY" | grep 'Nothing to take'`"   && NOTHING=1
test "`echo "$REPLY" | grep 'You pick up the slag'`" && SLAG=1

OLD_REPLY="$REPLY"
sleep 0.1s
done

_debug_two || echo unwatch $DRAW_INFO
sleep ${SLEEP:-1}s

# ***
# ***
# *** diff marker 14
# *** diff marker 15
# ***
# ***

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

sleep ${SLEEP:-1}s
echo draw 2 "Dropping water of $GEM ...."
echo "issue 1 1 $DIRB"   # drop slag/water four tiles back
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep ${SLEEP:-1}s

[ "$DEBUG" ] && echo draw 3 "NOTHING is '$NOTHING'"

if test "$SLAG" = 1; then
echo "issue 0 1 drop slag"
sleep ${SLEEP:-1}s
elif test "$NOTHING" = 0; then

echo draw 5 "Identifying .."
echo "issue 1 1 use_skill sense curse"  # identify water
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep ${SLEEP:-1}s

echo "issue 1 1 drop water of $GEM"   # drop it
echo "issue 1 1 drop waters of $GEM"  # drop it
sleep ${SLEEP:-1}s
echo "issue 1 1 drop water (magic)"
echo "issue 1 1 drop waters (magic)"
sleep ${SLEEP:-1}s
echo "issue 1 1 drop water (cursed)"
echo "issue 1 1 drop waters (cursed)"
sleep ${SLEEP:-1}s
else sleep ${SLEEP:-1}s
fi


sleep ${DELAY_DRAWINFO:-2}s

echo draw 2 "Returning to cauldron ...."
echo "issue 1 1 $DIRF"  # go back onto cauldron
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep ${SLEEP:-1}s

sleep ${DELAY_DRAWINFO:-1}s


TIMEE=`/bin/date +%s`
TIME=$((TIMEE-TIMEC))

one=$((one+1))
TRIES_STILL=$((NUMBER-one))

case $TRIES_STILL in -*) # negative
TRIES_STILL=${TRIES_STILL#*-}
echo draw 4 "Time $TIME sec., completed ${TRIES_STILL:-$NUMBER} laps.";;
*)
echo draw 4 "Time $TIME sec., still ${TRIES_STILL:-$NUMBER} laps to go...";;
esac


 _debug_two && {
 # log monitor msgs
  while [ 2 ]
  do
  unset REPLY
  read -t 1
  echo "$REPLY" >>"$LOG_REPLY_FILE"
  test "$REPLY" || break
  done

 echo unwatch $DRAW_INFO
 sleep 1
 }

test "$one" = "$NUMBER" && break
done  # *** MAINLOOP *** #

# ***
# ***
# *** diff marker 16
# *** diff marker 17
# ***
# ***

# Now count the whole loop time
TIMELE=`/bin/date +%s`
TIMEL=$((TIMELE-TIMEB))
TIMELM=$((TIMEL/60))
TIMELS=$(( TIMEL - (TIMELM*60) ))
case $TIMELS in [0-9]) TIMELS="0$TIMELS";; esac
echo draw 5 "Whole  loop  time : $TIMELM:$TIMELS minutes." # light blue

if test "$FAIL" = 0; then
 echo draw 7 "You succeeded $one times of $one ." # green
else
if test "$((one/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $one ."    # light green
 echo draw 7 "You should increase your Int stat."
else
 SUCC=$((one-FAIL))
 echo draw 7 "You succeeded $SUCC times of $one ." # green
fi
fi

# Now count the whole script time
TIMEZ=`/bin/date +%s`
TIMEY=$((TIMEZ-TIMEA))
TIMEAM=$((TIMEY/60))
TIMEAS=$(( TIMEY - (TIMEAM*60) ))
case $TIMEAS in [0-9]) TIMEAS="0$TIMEAS";; esac
echo draw 6 "Whole script time : $TIMEAM:$TIMEAS minutes." # dark orange


# *** Here ends program *** #
_kill_jobs
echo draw 2 "$0 is finished."
beep -l 500 -f 700

# ***
# ***
# *** diff marker 18
