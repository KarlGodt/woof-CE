#!/bin/ash

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

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
echo draw 2 "$0 is started with '$*' as arg"
echo draw 4 "and as pid $$ from ppid $PPID"

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

#test "$*" || {
#echo draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"|*usage)

echo draw 5 "Script to pray optional given number times."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <<number>>"
echo draw 5 "For example: 'script $0 50'"
echo draw 5 "will issue 50 times the use_skill praying command."
echo draw 4 "Without number option, loops forever."
echo draw 4 "Use 'scriptkill' to terminate."
echo draw 5 "Options:"
echo draw 5 "-d  to turn on debugging."
#echo draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
;;

-d|*debug)     DEBUG=$((DEBUG+1));;
#-L|*logging) LOGGING=$((LOGGING+1));;
'') :;;

[0-9]*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as optional option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;
*) echo draw 3 "Ignoring parameter '$PARAM_1' .";;
esac
shift
sleep 0.1
done


# *** Player's Speed *** #
echo request stat cmbt
#read REQ_CMBT
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n", cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read Req Stat Cmbt WC AC DAM SPEED W_SPEED
[ "$DEBUG" ] && echo draw 11 "$WC:$AC:$DAM:$SPEED:$W_SPEED"  # DEBUG
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
[ "$DEBUG" ] && echo draw 10 "$USLEEP:$SPEED"  # DEBUG

USLEEP=$((USLEEP-SPEED))
echo draw 11 "Sleeping $USLEEP usleep micro-seconds between praying"


# *** Actual script to pray multiple times *** #
#test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

TIMEB=`/bin/date +%s`

#for one in `seq 1 1 $NUMBER`
while :;
do

echo "issue 1 1 use_skill praying"
#sleep 1s
usleep $USLEEP

c=$((c+1))
test "$c" = "$NUMBER" && break

case $c in [1-9]0|[1-9][0-9]0) echo draw 8 "You prayed $c times"
[ "$NUMBER" ] || echo draw 3 "Use 'scriptkill' to abort."
;; esac

done

TIMEZ=`/bin/date +%s`


_compute_minutes_seconds(){
unset TIMEXM TIMEXS
test "$1" -a "$2" || return 3

local lTIMEX=$(( $1 - $2 ))

case $lTIMEX in -*) lTIMEX=$(( $2 - $1 ));; esac
case $lTIMEX in -*) return 4;; esac

TIMEXM=$((lTIMEX/60))
TIMEXS=$(( lTIMEX - (TIMEXM*60) ))
case $TIMEXS in [0-9]) TIMEXS="0$TIMEXS";; esac
}

if test "$TIMEZ" -a "$TIMEB"; then
# TIME_L=$((TIMEZ-TIMEB))
# TIME_LM=$((TIME_L/60))
# TIME_LS=$(( TIME_L - (TIME_LM*60) ))
# case $TIME_LS in [0-9]) TIME_LS="0$TIME_LS";; esac

_compute_minutes_seconds $TIMEZ $TIMEB && \
 echo draw 5 "Whole loop took $TIMEXM:$TIMEXS minutes."
fi

if test "$TIMEZ" -a "$TIMEA"; then
# TIME_S=$((TIMEZ-TIMEA))
# TIME_SM=$((TIME_S/60))
# TIME_SS=$(( TIME_S - (TIME_SM*60) ))
# case $TIME_SS in [0-9]) TIME_SS="0$TIME_SS";; esac

_compute_minutes_seconds $TIMEZ $TIMEA && \
 echo draw 4 "Whole script took $TIMEXM:$TIMEXS minutes."
fi

# *** Here ends program *** #
echo draw 2 "$0 is finished."
_beep
