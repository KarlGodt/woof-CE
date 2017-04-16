#!/bin/ash

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

# Now count the whole script time
TIMEA=`date +%s`

# *** Here begins program *** #
echo draw 2 "$0 is started:"
echo draw 2 "PID $$ PPID $PPID"
echo draw 2 "ARGUMENTS:$*"

# *** Setting defaults *** #

DEBUG=

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

GEM='';  #set empty default
NUMBER=0 #set zero as default

DRAW_INFO=drawinfo  # drawextinfo (old clients) # used for catching msgs watch/unwatch $DRAW_INFO

DELAY_DRAWINFO=2    # additional sleep value in seconds

#logging
LOGGING=1
TMP_DIR=/tmp/crossfire_client
LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
mkdir -p "$TMP_DIR"

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

# *** Check for parameters *** #

#test "$1" -a "$2" || {
test "$*" || {
echo draw 3 "Need <gem> and <number> ie: script $0 ruby 3 ."
        exit 1
}

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help")

echo draw 5 "Script to produce water of GEM."
echo draw 7 "Syntax:"
echo draw 7 "$0 GEM NUMBER"
echo draw 2 "Allowed GEM are diamond, emerald,"
echo draw 2 "pearl, ruby, sapphire ."
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of GEM ."
echo draw 5 "Options:"
echo draw 5 "-d  to turn on debugging."
echo draw 5 "-L  to log to $LOG_REPLY_FILE ."
        exit 0
;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
'') :;;

*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:alpha:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :alpha: characters as first option allowed."
        exit 1 #exit if other input than letters
        }

GEM="$PARAM_1"

PARAM_2="$2"
PARAM_2test="${PARAM_2//[[:digit:]]/}"
test "$PARAM_2test" && {
echo draw 3 "Only :digit: numbers as second options allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_2
;;
esac
shift
sleep 0.1
done

#} || {
#echo draw 3 "Script needs gem and number of alchemy attempts as arguments."
#        exit 1
#}


if test ! "$NUMBER"; then
echo draw 3 "Need a number of items to alch."
exit 1
elif test "$NUMBER" = 0; then
echo draw 3 "Number must be not ZERO."
exit 1
elif test "$NUMBER" -lt 0; then
echo draw 3 "Number must be greater than ZERO."
exit 1
fi

test "$GEM" = diamond -o "$GEM" = emerald -o "$GEM" = pearl \
  -o "$GEM" = ruby -o "$GEM" = sapphire || {
echo draw 3 "'$GEM' : Not a recognized kind of gem."
exit 1
}

__check_on_cauldron(){
# *** Check if standing on a cauldron *** #
#echo draw 4 "Checking if on cauldron..."

UNDER_ME='';
echo request items on

while :; do
read -t 1 UNDER_ME
sleep 0.1s
[ "$LOGGING" ] && echo "request items on:$UNDER_ME" >>"$LOG_ISON_FILE"
[ "$DEBUG" ] && echo draw 3 "'$UNDER_ME'"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in
"request items on end") break;;
"scripttell break") break;;
"scripttell exit") exit 1;;
esac
done


test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
_beep
exit 1
 }
}

# *** Check if standing on a cauldron *** #

f_check_on_cauldron(){

echo draw 4 "Checking if on cauldron..."

UNDER_ME='';
echo request items on

while :; do
read -t 1 UNDER_ME
sleep 0.1s
[ "$LOGGING" ] && echo "request items on:$UNDER_ME" >>"$LOG_ISON_FILE"
[ "$DEBUG" ] && echo draw 3 "'$UNDER_ME'"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
case "$UNDER_ME" in
"request items on end") break;;
"scripttell break") break;;
"scripttell exit") exit 1;;
esac
done


test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
_beep
exit 1
        }

echo draw 7 "Done."
}
f_check_on_cauldron

#echo draw 7 "Done."

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


echo "issue 1 1 pickup 0"  # precaution

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
_beep
exit $RV
}

f_emergency_exit(){
RV=${1:-0}
shift

echo "issue 1 1 apply rod of word of recall"
echo "issue 1 1 fire center"
echo draw 3 "Emergency Exit $0 !"
echo unwatch $DRAW_INFO
echo "issue 1 1 fire_stop"

NUMBER=$((one-1))
_say_statistics_end
test "$*" && echo draw 5 "$*"
_beep
_beep
exit $RV
}


rm -f "$LOG_REPLY_FILE"

# *** Now LOOPING *** #

TIMEB=`date +%s`

for one in `seq 1 1 $NUMBER`
do

TIMEC=${TIMEE:-$TIMEB}


# *** open the cauldron *** #
echo "issue 1 1 apply"

echo watch $DRAW_INFO

# *** drop ingredients *** #
echo "issue 1 1 drop 1 water of the wise"

OLD_REPLY="";
REPLY="";

 while :; do
 read -t 1 REPLY
 [ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
 [ "$DEBUG" ] && echo draw 3 "REPLY='$REPLY'"

 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.") f_exit 1;;
 *"There are only"*)  f_exit 1;;
 *"There is only"*)   f_exit 1;;
 '') break;;
 esac
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done


sleep 1s

# *** drop ingredients *** #
echo "issue 1 1 drop 3 $GEM"

OLD_REPLY="";
REPLY="";

while :; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "drop:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "REPLY='$REPLY'"
#test "`echo "$REPLY" | busybox grep -E '.*Nothing to drop\.|.*There are only.*|.*There is only.*'`" && f_exit 1
#test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
#test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 case "$REPLY" in
 $OLD_REPLY) break;;
 *"Nothing to drop.") f_exit 1;;
 *"There are only"*)  f_exit 1;;
 *"There is only"*)   f_exit 1;;
 '') break;;
 esac
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

sleep 1s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s

f_check_on_cauldron

echo "issue 1 1 use_skill alchemy"

#TOTO monsters
echo watch $DRAW_INFO

OLD_REPLY="";
REPLY="";

while :; do
_ping
read -t 1 REPLY
[ "$LOGGING" ] && echo "alchemy:$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "REPLY='$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*pours forth monsters\!'`" && f_emergency_exit 1
test "`echo "$REPLY" | grep '.*You unwisely release potent forces\!'`" && exit 1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

echo "issue 1 1 apply"

echo watch $DRAW_INFO

echo "issue 1 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while :; do
read -t 1 REPLY
[ "$LOGGING" ] && echo "get:$REPLY" >>"$LOG_REPLY_FILE"
  [ "$DEBUG" ] && echo draw 3 "REPLY='$REPLY'"
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch $DRAW_INFO

sleep 1s

echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
echo "issue 1 1 $DIRB"
sleep 1s

[ "$DEBUG" ] && echo draw 2 "NOTHING is '$NOTHING'" #DEBUG

if test "$NOTHING" = 0; then

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep 1s

echo "issue 1 1 drop water of $GEM"
echo "issue 0 1 drop slag"

fi

sleep ${DELAY_DRAWINFO}s

echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
echo "issue 1 1 $DIRF"
sleep 1s

f_check_on_cauldron

TRIES_STILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEC))
echo draw 4 "Time $TIME sec., still $TRIES_STILL laps to go..."

done

# *** Here ends program *** #
echo draw 2 "$0 is finished."
_beep
