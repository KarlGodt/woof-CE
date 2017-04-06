#!/bin/bash

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
TIMEA=`date +%s`

# ***VARIABLES *** #
# *** Setting defaults *** #

GEM=diamond
#GEM=sapphire
#GEM=ruby
#GEM=emerald
#GEM=pearl

NUMBER=1  # of alch attempts

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
esac

DELAY_DRAWINFO=2    # sleep seconds to sync msgs from script with msgs from server

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

DEBUG='1'      # set to anything to enable debug output to msg pane
LOGGING='1'    # set to anything to log to LOG_REPLY_FILE
LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

PING_DO=1
URL=crossfire.metalforge.net # localhost if server running on local PC

_ping(){
test "$PING_DO" || return 0

local FOREVER=''

case $1 in
-I|--infinite) FOREVER=1;;
esac

while :; do
ping -c 1 -w10 -W10 "$URL" >/dev/null 2>&1
PRV=$?
 if test "$FOREVER"; then
  case $PRV in 0) :;;
  *) echo draw 3 "WARNING: Client seems disconnected.." >&1;;
  esac
  sleep 2
 else
  case $PRV in 0) return 0;;
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

#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch $DRAW_INFO
beep
_kill_jobs
exit $RV
}

# *** Here begins program *** #
echo draw 2 "$0 is started:"
echo draw 2 "PID $$ -- PPID $PPID"
echo draw 2 "ARGUMENTS:$*"

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to produce water of GEM."
echo draw 7 "Syntax:"
echo draw 7 "$0 GEM NUMBER"
echo draw 2 "Allowed GEM are diamond, emerald,"
echo draw 2 "pearl, ruby, sapphire ."
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of GEM ."
echo draw 6 "Defaults:"
echo draw 4 "GEM is set currently to '$GEM'"
echo draw 4 "NUMBER is set to '$NUMBER'"
echo draw 4 "in script header."

        f_exit 0
        }

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:alpha:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :alpha: characters as first option allowed."
        f_exit 1 #exit if other input than letters
        }

GEM="$PARAM_1"

PARAM_2="$2"
PARAM_2test="${PARAM_2//[[:digit:]]/}"
test "$PARAM_2test" && {
echo draw 3 "Only :digit: numbers as second options allowed."
        f_exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_2
} || {
echo draw 3 "Script needs gem and number of alchemy attempts as arguments."
        f_exit 1
}

test "$1" -a "$2" || {
echo draw 3 "Need <gem> and <number> ie: script $0 ruby 3 ."
        f_exit 1
}

#if test ! "$GEM"; then #set fallback
#GEM=diamond
##GEM=sapphire
##GEM=ruby
##GEM=emerald
##GEM=pearl
#fi

if test ! "$NUMBER"; then
echo draw 3 "Need a number of items to alch."
f_exit 1
elif test "$NUMBER" = 0; then
echo draw 3 "Number must be not ZERO."
f_exit 1
elif test "$NUMBER" -lt 0; then
echo draw 3 "Number must be greater than ZERO."
f_exit 1
fi

test "$GEM" = diamond -o "$GEM" = emerald -o "$GEM" = pearl \
  -o "$GEM" = ruby -o "$GEM" = sapphire || {
echo draw 3 "'$GEM' : Not a recognized kind of gem."
f_exit 1
}


# *** Does our player possess the skill alchemy ? *** #
_check_skill(){

local PARAM="$*"

echo request skills

while :;
do
 unset REPLY
 sleep 0.1
 read -t 1
  [ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
  [ "$DEBUG" ] && echo draw 6 "$REPLY"

 case $REPLY in    '') break;;
 'request skills end') break;;
 esac

 if test "$PARAM"; then
  case $REPLY in *$PARAM) return 0;; esac
 else # print skill
  SKILL=`echo "$REPLY" | cut -f4- -d' '`
  echo draw 5 "'$SKILL'"
 fi

done

test ! "$PARAM" # returns 0 if called without parameter, else 1
}

_check_skill alchemy || f_exit 1 "You do not have the skill alchemy."


# *** Do NOT pickup cauldron *** #
echo "issue 1 1 pickup 0"  # precaution


_check_if_on_cauldron(){
# *** Check if standing on a cauldron *** #
echo draw 5 "Check if on cauldron..."

local UNDER_ME=''
local UNDER_ME_LIST=''

echo request items on

while [ 1 ]; do
read UNDER_ME
sleep 0.1s
[ "$LOGGING" ] && echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"  # code further down does not care
		 # if other msgs go into UNDER_ME_LIST variable
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && f_exit 1
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
f_exit 1
}

echo draw 7 "Done."
return 0
}

_check_if_empty_cauldron(){
# *** Check if cauldron is empty *** #
echo draw 5 "Check if on cauldron..."

local OLD_REPLY="";
local REPLY="";
local NOTHING=0

echo "issue 1 1 apply"   # open cauldron
sleep 0.5

echo watch $DRAW_INFO

echo "issue 1 1 get"     # empty cauldron

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
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

sleep 1s

echo "issue 1 1 $DIRB"  # close cauldron
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s
sleep $DELAY_DRAWINFO

echo draw 7 "Done. Cauldron SEEMS empty."
return 0
}

#_check_if_on_cauldron && _check_if_empty_cauldron && _check_if_on_cauldron || f_exit 1


# *** Actual script to alch the desired water of gem *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** west of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


# *** Now LOOPING *** #

FAIL=0
TIMELB=`date +%s`
echo draw 4 "OK... Might the Might be with You!"

for one in `seq 1 1 $NUMBER`
do

TIMEB=${TIMEE:-`date +%s`}

_check_if_on_cauldron && _check_if_empty_cauldron && _check_if_on_cauldron || break

echo "issue 1 1 apply"  # open cauldron

echo watch $DRAW_INFO

echo "issue 1 1 drop 1 water of the wise"

OLD_REPLY="";
REPLY="";


while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

sleep 1s

echo "issue 1 1 drop 3 $GEM"

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | busybox grep -E '.*Nothing to drop\.|.*There are only.*|.*There is only.*'`" && f_exit 1
#test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
#test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

sleep 1s

echo "issue 1 1 $DIRB"  # close cauldron
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s


_check_if_on_cauldron

echo "issue 1 1 use_skill alchemy"  # alch

echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
#_ping
read -t 1 REPLY
[ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && f_exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

echo "issue 1 1 apply"   # open cauldron

echo watch $DRAW_INFO

echo "issue 1 1 get"     # empty cauldron

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while [ 1 ]; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to take\!'`"   && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

if test "$SLAG" = 1 -o "$NOTHING" = 1;
then
 FAIL=$((FAIL+1))
fi

sleep 1s

echo "issue 1 1 $DIRB"   # drop slag/water four tiles back
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep 1s

[ "$DEBUG" ] && echo draw 2 "NOTHING is '$NOTHING'"

if test "$NOTHING" = 0; then

echo "issue 1 1 use_skill sense curse"  # identify water
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep 1s

echo "issue 1 1 drop water of $GEM"  # drop it

elif test "SLAG" = 1; then
echo "issue 0 1 drop slag"
fi


sleep ${DELAY_DRAWINFO}s

echo "issue 1 1 $DIRF"  # go back onto cauldron
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s

sleep ${DELAY_DRAWINFO}s

TRIES_SILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo draw 4 "Time $TIME sec., still $TRIES_SILL laps to go..."

done  # *** MAINLOOP *** #


# Now count the whole loop time
TIMELE=`date +%s`
TIMEL=$((TIMELE-TIMELB))
TIMELM=$((TIMEL/60))
TIMELS=$(( TIMEL - (TIMELM*60) ))
case $TIMELS in [0-9]) TIMELS="0$TIMELS";; esac
echo draw 5 "Whole  loop  time : $TIMELM:$TIMELS minutes." # light blue

if test "$FAIL" = 0; then
 echo draw 7 "You succeeded $one times of $NUMBER ." # green
else
if test "$((NUMBER/FAIL))" -lt 2;
then
 echo draw 8 "You failed $FAIL times of $NUMBER ."    # light green
 echo draw 7 "You should increase your Int stat."
else
 SUCC=$((NUMBER-FAIL))
 echo draw 7 "You succeeded $SUCC times of $NUMBER ." # green
fi
fi

# Now count the whole script time
TIMEZ=`date +%s`
TIMEY=$((TIMEZ-TIMEA))
TIMEAM=$((TIMEY/60))
TIMEAS=$(( TIMEY - (TIMEAM*60) ))
case $TIMEAS in [0-9]) TIMEAS="0$TIMEAS";; esac
echo draw 6 "Whole script time : $TIMEAM:$TIMEAS minutes." # dark orange


# *** Here ends program *** #
_kill_jobs
echo draw 2 "$0 is finished."
beep -l 500 -f 700
