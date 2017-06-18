#!/bin/ash

# *** diff marker 1
# ***
# ***

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
#                                *   than seagreen - also background color. */
#define NDI_GREY        9
#define NDI_BROWN       10      /**< Sienna. */
#define NDI_GOLD        11
#define NDI_TAN         12      /**< Khaki. */

TIMEA=`/bin/date +%s`

#DEBUG=1   # unset to disable, set to anything to enable
#LOGGING=1 # unset to disable, set to anything to enable

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO


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

#logging

TMP_DIR=/tmp/crossfire_client
LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
#LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
mkdir -p "$TMP_DIR"

_draw(){
test "$*" || return
local COLOUR=${1:-0}
shift
while read -r line
do
test "$line" || continue
echo draw $COLOUR "$line"
sleep 0.1
done <<EoI
`echo "$@"`
EoI
}

_verbose(){
[ "$VERBOSE" ] || return 0
_draw ${COL_VERB:-12} "$*"
}

_debug(){
[ "$DEBUG" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOG_REPLY_FILE"
}

_usage(){
echo draw $COL_BLUE "Script to melt icecube."
echo draw $COL_BLUE "Syntax:"
echo draw $COL_BLUE "script $0 {number}"
echo draw $COL_BLUE "For example: 'script $0 5'"
echo draw $COL_BLUE "will issue 5 times mark icecube and apply flint and steel."
_draw 4 "Options:"
_draw 5 "-d set debug"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 5 "-v set verbosity"
        exit 0
}


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


# *** Here begins program *** #
echo draw $COL_NAVY "$0 is started.."

#test "$DEBUG" && echo draw 5 "LOG_REPLY_FILE='$LOG_REPLY_FILE'" #debug

# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*help|*usage) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
echo draw $COL_RED "Only :digit: numbers as optional option allowed."
        exit 1 #exit if other input than letters
        }
 NUMBER=$PARAM_1
;;
esac
shift
sleep 0.1
done


f_exit(){ # unused
RV="$1"
RV=${RV:-0}
shift
test "$*" && echo draw 4 "$*"
echo draw $COL_RED "Exiting $0."
echo unwatch
beep -l 500 -f 700
#echo unwatch $DRAW_INFO
exit $RV
}

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution

TIMEB=`/bin/date +%s`

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

REPLY=
OLD_REPLY=

echo watch $DRAW_INFO
echo "issue 1 1 mark icecube"

 while :; do
 read -t 1 REPLY
 _log "mark icecube:$REPLY"
 _debug "$REPLY"

 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && break 2
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

echo unwatch $DRAW_INFO
sleep 1s

NO_FAIL=
until [ "$NO_FAIL" ]
do

REPLY=
OLD_REPLY=

echo watch $DRAW_INFO
echo "issue 1 1 apply flint and steel"

 while :; do
 read -t 1 REPLY
 _log "apply flint and steel:$REPLY"
 _debug "$REPLY"

 case $REPLY in
 *fail.) :;;
 *You*fail*used*up*) break 3;;
 *"Could not find any match to the flint and steel."*) break 3;;
 *"You need to mark a lightable object."*) break 2;;
 *Your*) :;;    # X times Your monster hits monster
 '') break;;
 *) NO_FAIL=1
# [ "$DEBUG" ] && echo draw $COL_GREEN "REPLY='$REPLY'" #debug
 ;; # assuming success
 # Problem here is while lots of msgs are printed by fighting monsters,
 #  the code would assume each msg a success and the one level upper
 #  until loop would mark icecube again, though not neccessary.
 # The good thing here is that the msgs would get emptied in other scripts
 #  to allow more correct msg handling in other watch drawinfo loops ..
 esac

 unset REPLY
 sleep 0.1s
 done

echo unwatch $DRAW_INFO
sleep 1s

done #NO_FAIL

echo unwatch $DRAW_INFO

done #NUMBER


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


    else #PARAM_1

until [ "$NO_ICECUBE" ];
do

REPLY=
OLD_REPLY=

echo watch $DRAW_INFO
echo "issue 1 1 mark icecube"
while :; do
 read -t 1 REPLY
 _log "mark icecube:$REPLY"
 _debug "$REPLY"

 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break
 #test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && break 2
  test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && { NO_ICECUBE=1; break; }
 OLD_REPLY="$REPLY"
 sleep 0.1s
done

echo unwatch $DRAW_INFO
sleep 1s
[ "$NO_ICECUBE" ] && continue

NO_FAIL=
until [ "$NO_FAIL" ]
do


REPLY=
OLD_REPLY=

echo watch $DRAW_INFO
echo "issue 1 1 apply flint and steel"
 while :; do
 read -t 1 REPLY
 _log "apply flint and steel:$REPLY"
 _debug "$REPLY"

 #test "$REPLY" = "$OLD_REPLY" && break

 case $REPLY in
 *fail.) :;; #You attempt to light the icecube with the flint and steel and fail.
 *You*fail*used*up*) break 3;;
 *Could*not*find*any*match*to*the*flint*and*steel.*) break 3;;
 *You*need*to*mark*a*lightable*object.*) break 2;;
 *Your*) :;;     # X times Your monster hits monster
 '') break;;
 *) NO_FAIL=1
# [ "$DEBUG" ] && echo draw $COL_GREEN "REPLY='$REPLY'" #debug
 ;;  # assuming success
 # Problem here is while lots of msgs are printed by fighting monsters,
 #  the code would assume each msg a success and the one level upper
 #  until loop would mark icecube again, though not neccessary.
 # The good thing here is that the msgs would get emptied in other scripts
 #  to allow more correct msg handling in other watch drawinfo loops ..
 esac

 unset REPLY
 sleep 0.1s
 done

echo unwatch $DRAW_INFO
sleep 1s

done #NO_FAIL

echo unwatch $DRAW_INFO

done #NO_ICECUBE

    fi #^!PARAM_1


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


TIMEE=`/bin/date +%s`
TIMEX=$((TIMEE-TIMEB))
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))
case $TIMES in [0-9]) TIMES="0$TIMES";; esac

echo draw $COL_LGREEN "Script loop took $TIMEM:$TIMES minutes."

# *** Here ends program *** #
echo draw $COL_NAVY "$0 is finished."
beep -l 500 -f 700


# ***
# ***
# *** diff marker 8
