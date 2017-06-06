#!/bin/ash
#exec 2>/tmp/cf_icecube.err  # DEBUG
# *** Color numbers found in common/shared/newclient.h : *** #
#define NDI_BLACK       0
#define NDI_WHITE       1    # black bold
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

TIMEA=`date +%s`

DRAW_INFO=drawinfo # drawextinfo (older clients)

#logging
TMP_DIR=/tmp/crossfire_client
LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
#LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
mkdir -p "$TMP_DIR"

# colours
COL_BLACK=0
COL_WHITE=1
COL_NAVY=2
COL_RED=3
COL_ORANGE=4
COL_BLUE=5
COL_DORANGE=6
COL_GREEN=7
COL_LGREEN=8
COL_GRAY=9
COL_BROWN=10
COL_GOLD=11
COL_TAN=12

COL_VERB=$COL_TAN
COL_DBG=$COL_GOLD

_draw(){
test "$*" || return

case $1 in [0-9]|1[0-2])
COLOUR=${1:-0}
shift
;;
esac
local lCOLOUR=${COLOUR:-0}

while read -r line
do
test "$line" || continue
echo draw $lCOLOUR "$line"
sleep 0.1
done <<EoI
`echo "$*"`
EoI
}

_verbose(){
[ "$VERBOSE" ] || return 0
_draw ${COL_VERB:-12} "$*"
}

#DEBUG=
__debug(){
[ "$DEBUG" ] || return 0
[ "$*" ] || return 0
while read -r line
do
test "$line" || continue
_draw 3 "Debug:$line"
done<<EoI
`echo "$@"`
EoI
}

_debug(){
[ "$DEBUG" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"${LOG_REPLY_FILE:-/tmp/cf_script.log}"
}

_is(){
_verbose "$*"
echo issue "$@"
sleep 0.2
}

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

_usage(){
_draw 5 "Script to melt icecube."
_draw 2 "Syntax:"
_draw 5 "script $0 [number]"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times mark icecube and apply flint and steel."
_draw 5 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v  set verbosity"

        exit 0
}

# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #

until test $# = 0;
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help|*usage) _usage;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

'') :;;

*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;
esac
shift
sleep 0.1
done


# ** functions ** #
_count_time(){

test "$*" || return 3

TIMEE=`date +%s`

TIMEX=$((TIMEE - $*)) || return 4
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

_say_end_msg(){
# *** Here ends program *** #
_draw 2 "$0 is finished."
_draw 1 "You failed    '$FAIL_ALL' times."
_draw 7 "You succeeded '$SUCCESS' times."
_count_time $TIMEB && _draw ${COL_LGREEN:-8} "Loop   took $TIMEM:$TIMES minutes."
_count_time $TIMEA && _draw ${COL_LGREEN:-8} "Script took $TIMEM:$TIMES minutes."
_beep
}

# *** Actual script to  melt icecube multiple times *** #
test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution


_mark_item(){

local ITEM=${*:-icecube}
local REPLY=

echo unwatch $DRAW_INFO
sleep 0.5
echo watch $DRAW_INFO
_is "1 1 mark $ITEM"

 while :; do
 read -t 1
 _log "$REPLY"
 _debug "mark:'$REPLY'"

 case "$REPLY" in
 *'Could not find an object that matches'*) return 2;;
 '') break;;
 esac

 unset REPLY
 sleep 0.1s
 done

}

_apply_flint_and_steel(){

local REPLY

while :;
do

REPLY=

echo unwatch $DRAW_INFO
sleep 0.5
echo watch $DRAW_INFO
_is "1 1 apply flint and steel"

 while :; do
 read -t 1
 _log "$REPLY"
 _debug "apply:'$REPLY'"

 case $REPLY in
 *"Could not find any match to the flint and steel."*) return 3;;
 *You*need*to*mark*a*lightable*object.) break 2;;
 *fail.) FAIL_ALL=$((FAIL_ALL+1));;
 *You*fail*used*up*) return 3;;
 *You*light*icecube*) SUCCESS=$((SUCCESS+1)); break 2;;
 *Your*) :;;
 '') break;;
 *)  :;;
 esac

 unset REPLY
 sleep 0.1s
 done

sleep 0.5s
done

return 0
}

_melt_icecube_main(){
# *** main *** #

TIMEB=`date +%s`

FAIL_ALL=0; SUCCESS=0

while :;
do

sleep 0.5
_mark_item icecube || break
sleep 0.5s
_apply_flint_and_steel || break

one=$((one+1))
test "$one" = "$NUMBER" && break

done
}

__count_time(){
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
_compute_minutes_seconds $TIMEZ $TIMEB && \
 _draw 5 "Whole loop took $TIMEXM:$TIMEXS minutes."
fi

if test "$TIMEZ" -a "$TIMEA"; then
_compute_minutes_seconds $TIMEZ $TIMEA && \
 _draw 4 "Whole script took $TIMEXM:$TIMEXS minutes."
fi
}


_melt_icecube_main

# *** END *** #
_say_end_msg
