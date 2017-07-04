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

# *** Here begins program *** #
echo draw 2 "$0 is started with '$*' as arg and as pid $$ from ppid $PPID"

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

_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$*"
    echo draw $COLOUR "$MSG"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"${lFILE:-/tmp/cf_script.log}"
}

_debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$*"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_is(){
    _verbose "$*"
    echo issue "$*"
    sleep 0.2
}

# *** Check for parameters *** #

test "$*" || {
echo draw 3 "Need <number> ie: script $0 50 ."
        exit 1
}

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help")

echo draw 5 "Script to pray given number times."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <number>"
echo draw 5 "For example: 'script $0 50'"
echo draw 5 "will issue 50 times the use_skill praying command."
echo draw 5 "Options:"
echo draw 5 "-d  to turn on debugging."
echo draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*) LOGGING=$((LOGGING+1));;
'') :;;

*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;
esac
shift
sleep 0.1
done

#} || {
#echo draw 3 "Script needs number of praying attempts as argument."
#        exit 1
#}


# *** Player's Speed *** #
echo request stat cmbt
#read REQ_CMBT
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n", cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read Req Stat Cmbt WC AC DAM SPEED W_SPEED
echo draw 11 "$WC:$AC:$DAM:$SPEED:$W_SPEED"  # DEBUG
case $SPEED in
[1-9][0-9][0-9][0-9][0-9][0-9]) USLEEP=600000;; #six
1[0-9][0-9][0-9][0-9]) USLEEP=1500000;; #five
2[0-9][0-9][0-9][0-9]) USLEEP=1400000;;
3[0-9][0-9][0-9][0-9]) USLEEP=1300000;;
4[0-9][0-9][0-9][0-9]) USLEEP=1200000;;
5[0-9][0-9][0-9][0-9]) USLEEP=1100000;;
6[0-9][0-9][0-9][0-9]) USLEEP=1000000;;
7[0-9][0-9][0-9][0-9]) USLEEP=900000;;
8[0-9][0-9][0-9][0-9]) USLEEP=800000;;
9[0-9][0-9][0-9][0-9]) USLEEP=700000;;
*) USLEEP=600000;;
esac
echo draw 10 "$USLEEP:$SPEED"  # DEBUG

USLEEP=$((USLEEP-SPEED))
echo draw 11 "Sleeping $USLEEP usleep micro-seconds between praying"


# *** Actual script to pray multiple times *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 use_skill praying"
#sleep 1s
usleep $USLEEP
done

# *** Here ends program *** #
echo draw 2 "$0 is finished."
_beep
