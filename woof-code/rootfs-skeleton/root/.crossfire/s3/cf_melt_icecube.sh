#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

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


MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

_usage(){
_blue "Script to melt icecube."
_blue "Syntax:"
_blue "script $0 <<number>>"
_blue "For example: 'script $0 5'"
_blue "will issue 5 times mark icecube and apply filint and steel."
_navy "Without number breaks infinite loop"
_navy "until no icecube could be marked anymore."
_draw 5 "Options:"
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v to say what is being issued to server."
        exit 0
}

#DRAW_INFO=drawinfo # drawextinfo (older clients)

LOGFILE=${LOGFILE:-/tmp/cf_script.rpl}


# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*help|*usage) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-F|*fast)   SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-S|*slow)   SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
[0-9]*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
 _red "Only :digit: numbers as attempt option allowed."
        exit 1 #exit if other input than letters
       }
NUMBER=$PARAM_1
;;
*) _red "Unrecognized option '$PARAM_1'";;

esac

shift
sleep 0.1
done



# *** Getting Player's Speed *** #
_get_player_speed

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution

_debug "NUMBER='$NUMBER'"
_log ""

_watch

TIMEB=`date +%s`

while :;
do

REPLY=
OLD_REPLY=

_is 1 1 mark icecube

while :; do
 read -t 1 REPLY
 _log "$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in
 *Could*not*find*an*object*that*matches*) break 2;;
 '') break;;
 esac
 unset REPLY
 sleep 0.1s
 done

_sleep

while :;
do


REPLY=
OLD_REPLY=

_is 1 1 apply flint and steel

 while :; do
 read -t 1 REPLY
 _log "$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in
 *used*up*flint*and*steel*) break 3;;
 *fail*) FAIL=$((FAIL+1));;  # ORDER of fail STRINGS IMPORTANT !!!
 *Could*not*find*any*match*to*the*flint*and*steel*) break 3;;
 *You*light*the*icecube*) SUCC=$((SUCC+1)); break 2;; #You light the icecube with the flint and steel.
 *You*need*to*mark*a*lightable*object.*)    break 2;;
 '') break;;
 #*) NO_FAIL=1;;
 #*) break;;
 esac
 unset REPLY
 sleep 0.1s
 done

_sleep

done

one=$((one+1))
test "$one" = "$NUMBER" && break

done #true


# *** Here ends program *** #
#echo draw 2 "$0 is finished."
#test "$FAIL" && _draw 8 "You failed    '$FAIL' times."
#test "$SUCC" && _draw 7 "You succeeded '$SUCC' times."
success=$SUCC
NUMBER=$one
_say_end_msg
