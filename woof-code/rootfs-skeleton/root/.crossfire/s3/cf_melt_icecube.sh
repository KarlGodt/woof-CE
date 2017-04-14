#!/bin/ash

export PATH=/bin:/usr/bin

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
_blue "script $0 [number]"
_blue "For example: 'script $0 5'"
_blue "will issue 5 times mark icecube and apply filint and steel."
_navy "Without number breaks infinite loop"
_navy "if no icecube could be marked anymore."
_draw 5 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v to say what is being issued to server."
        exit 0
}


DEBUG=1   # unset to disable, set to anything to enable
LOGGING=1 # unset to disable, set to anything to enable

DRAW_INFO=drawinfo # drawextinfo (older clients)

LOGFILE=${LOGFILE:-/tmp/cf_script.rpl}

_log_(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOGFILE"
}

__black()  { echo draw 0  "$*"; }
__bold()   { echo draw 1  "$*"; }
__blue()   { echo draw 5  "$*"; }
__navy()   { echo draw 2  "$*"; }
__lgreen() { echo draw 8  "$*"; }
__green()  { echo draw 7  "$*"; }
__red()    { echo draw 3  "$*"; }
__dorange(){ echo draw 6  "$*"; }
__orange() { echo draw 4  "$*"; }
__gold()   { echo draw 11 "$*"; }
__tan()    { echo draw 12 "$*"; }
__brown()  { echo draw 10 "$*"; }
__gray()   { echo draw 9  "$*"; }
alias __grey=__gray


# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"*) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
 _red "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
       }
NUMBER=$PARAM_1
;;
esac

shift
sleep 0.1
done


_watch(){
echo watch $DRAW_INFO
}

_unwatch(){
echo unwatch $DRAW_INFO
}

__just_exit(){
_red "Exiting $0."
_unwatch
#echo unwatch drawinfo
exit $1
}

# *** Getting Player's Speed *** #
_get_player_speed

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

_debug "NUMBER='$NUMBER'"
_log ""

_watch

TIMEB=`date +%s`

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

REPLY=
OLD_REPLY=

echo "issue 1 1 mark icecube"

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

sleep 1s

while :;
do

REPLY=
OLD_REPLY=

echo "issue 1 1 apply flint and steel"

 while :; do
 read -t 1 REPLY
 _log "$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in
 *used*up*flint*and*steel*) break 3;;
 *fail*) FAIL=$((FAIL+1));;  # ORDER of fail STRINGS IMPORTANT !!!
 *Could*not*find*any*match*to*the*flint*and*steel*) break 3;;
 *You*light*the*icecube*) SUCC=$((SUCC+1)); break 2;;
 *You*need*to*mark*a*lightable*object.*)    break 2;;
 '') break;;
 #*) NO_FAIL=1;;
 #*) break;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

done

done #NUMBER

    else #PARAM_1

while :;
do

REPLY=
OLD_REPLY=

echo "issue 1 1 mark icecube"

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

sleep 1s

while :;
do


REPLY=
OLD_REPLY=

echo "issue 1 1 apply flint and steel"

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

sleep 1s

done

done #true

    fi #^!PARAM_1

__get_time_end(){
test "$TIMEB" || return 0
TIMEE=`date +%s`
TIMEX=$((TIMEE-TIMEB))
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))
case $TIMES in [0-9]) TIMES="0$TIMES";; esac

_green "Script loop took $TIMEM:$TIMES minutes."
}

# *** Here ends program *** #
#echo draw 2 "$0 is finished."
test "$FAIL" && _draw 8 "You failed    '$FAIL' times."
test "$SUCC" && _draw 7 "You succeeded '$SUCC' times."
_say_end_msg
