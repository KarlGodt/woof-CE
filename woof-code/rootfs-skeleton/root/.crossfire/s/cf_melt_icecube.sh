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
#                                *   than seagreen - also background color. */
#define NDI_GREY        9
#define NDI_BROWN       10      /**< Sienna. */
#define NDI_GOLD        11
#define NDI_TAN         12      /**< Khaki. */

TIMEA=`date +%s`

DEBUG=1   # unset to disable, set to anything to enable
LOGGING=1 # unset to disable, set to anything to enable

DRAW_INFO=drawinfo # drawextinfo (older clients)

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
LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
mkdir -p "$TMP_DIR"


# *** Here begins program *** #
echo draw $COL_NAVY "$0 is started.."

test "$DEBUG" && echo draw 5 "LOG_REPLY_FILE='$LOG_REPLY_FILE'" #debug

# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help)

echo draw $COL_BLUE "Script to melt icecube."
echo draw $COL_BLUE "Syntax:"
echo draw $COL_BLUE "script $0 [number]"
echo draw $COL_BLUE "For example: 'script $0 5'"
echo draw $COL_BLUE "will issue 5 times mark icecube and apply flint and steel."

        exit 0
;;

*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw $COL_RED "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }
;;
esac
shift
sleep 0.1
done

NUMBER=$PARAM_1


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

TIMEB=`date +%s`

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

REPLY=
OLD_REPLY=

echo watch $DRAW_INFO
echo "issue 1 1 mark icecube"

 while :; do
 read -t 1 REPLY
 [ "$LOGGING" ] && echo "mark icecube:$REPLY" >>"$LOG_REPLY_FILE"
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
 [ "$LOGGING" ] && echo "apply flint and steel:$REPLY" >>"$LOG_REPLY_FILE"

 case $REPLY in
 *fail.) :;;
 *You*fail*used*up*) break 3;;
 *"Could not find any match to the flint and steel."*) break 3;;
 *Your*) :;;    # X times Your monster hits monster
 '') break;;
 *) NO_FAIL=1
 [ "$DEBUG" ] && echo draw $COL_GREEN "REPLY='$REPLY'" #debug
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

done #NUMBER

    else #PARAM_1

until [ "$NO_ICECUBE" ];
do

REPLY=
OLD_REPLY=

echo watch $DRAW_INFO
echo "issue 1 1 mark icecube"
while :; do
 read -t 1 REPLY
 [ "$LOGGING" ] && echo "mark icecube:$REPLY" >>"$LOG_REPLY_FILE"
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
 [ "$LOGGING" ] && echo "apply flint and steel:$REPLY" >>"$LOG_REPLY_FILE"
 test "$REPLY" = "$OLD_REPLY" && break

 case $REPLY in
 *fail.) :;; #You attempt to light the icecube with the flint and steel and fail.
 *You*fail*used*up*) break 3;;
 *"Could not find any match to the flint and steel."*) break 3;;
 *Your*) :;;     # X times Your monster hits monster
 '') break;;
 *) NO_FAIL=1
 [ "$DEBUG" ] && echo draw $COL_GREEN "REPLY='$REPLY'" #debug
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

done #true

    fi #^!PARAM_1

TIMEE=`date +%s`
TIMEX=$((TIMEE-TIMEB))
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))
case $TIMES in [0-9]) TIMES="0$TIMES";; esac

echo draw $COL_LGREEN "Script loop took $TIMEM:$TIMES minutes."

# *** Here ends program *** #
echo draw $COL_NAVY "$0 is finished."
beep -l 500 -f 700
