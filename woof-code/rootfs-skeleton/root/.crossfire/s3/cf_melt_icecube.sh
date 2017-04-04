#!/bin/bash

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

export PATH=/bin:/usr/bin
MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

DEBUG=1   # unset to disable, set to anything to enable
LOGGING=1 # unset to disable, set to anything to enable

DRAW_INFO=drawinfo # drawextinfo (older clients)

LOGFILE=${LOGFILE:-/tmp/cf_script.rpl}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOGFILE"
}

_black()  { echo draw 0  "$*"; }
_bold()   { echo draw 1  "$*"; }
_blue()   { echo draw 5  "$*"; }
_navy()   { echo draw 2  "$*"; }
_lgreen() { echo draw 8  "$*"; }
_green()  { echo draw 7  "$*"; }
_red()    { echo draw 3  "$*"; }
_dorange(){ echo draw 6  "$*"; }
_orange() { echo draw 4  "$*"; }
_gold()   { echo draw 11 "$*"; }
_tan()    { echo draw 12 "$*"; }
_brown()  { echo draw 10 "$*"; }
_gray()   { echo draw 9  "$*"; }
alias _grey=_gray


# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*)

_blue "Script to melt icecube."
_blue "Syntax:"
_blue "script $0 [number]"
_blue "For example: 'script $0 5'"
_blue "will issue 5 times mark icecube and apply filint and steel."
_navy "Without number breaks infinite loop"
_navy "if no icecube could be marked anymore."
        exit 0
;;
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

NO_FAIL=
until [ "$NO_FAIL" ]
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
 *Could*not*find*any*match*to*the*flint*and*steel*) break 3;;
 '') break;;
 *fail*) :;;
 *) NO_FAIL=1;;
 *You*light*up*the*icecube*) NO_FAIL=1; break;;
 *) break;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

done #NO_FAIL

done #NUMBER

    else #PARAM_1

until [ "$NO_ICECUBE" ];
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

NO_FAIL=
until [ "$NO_FAIL" ]
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
 *Could*not*find*any*match*to*the*flint*and*steel*) break 3;;
 '') break;;
 *fail*) :;;
 *) NO_FAIL=1;;
 *You*light*up*the*icecube*) NO_FAIL=1; break;;
 *) break;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

done #NO_FAIL

done #true

    fi #^!PARAM_1

TIMEE=`date +%s`
TIMEX=$((TIMEE-TIMEB))
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))
case $TIMES in [0-9]) TIMES="0$TIMES";; esac

_green "Script loop took $TIMEM:$TIMES minutes."

# *** Here ends program *** #
#echo draw 2 "$0 is finished."
_say_end_msg
