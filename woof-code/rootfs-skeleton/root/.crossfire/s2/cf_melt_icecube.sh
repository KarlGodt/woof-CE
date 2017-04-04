#!/bin/ash

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

#logging
TMP_DIR=/tmp/crossfire_client
LOG_REPLY_FILE="$TMP_DIR"/cf_script.$$.rpl
LOG_ISON_FILE="$TMP_DIR"/cf_script.$$.ion
mkdir -p "$TMP_DIR"

DEBUG=1
_debug(){
[ "DEBUG" ] || return 0
[ "$*" ] || return 0
while read -r line
do
test "$line" || continue
echo draw 3 "Debug:$line"
done<<EoI
`echo "$@"`
EoI
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

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #

until test $# = 0;
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help)

echo draw 5 "Script to melt icecube."
echo draw 5 "Syntax:"
echo draw 5 "script $0 [number]"
echo draw 5 "For example: 'script $0 5'"
echo draw 5 "will issue 5 times mark icecube and apply flint and steel."

        exit 0
;;
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
done

_say_end_msg(){
# *** Here ends program *** #
echo draw 2 "$0 is finished."
echo draw 1 "You failed    '$FAIL_ALL' times."
echo draw 7 "You succeeded '$SUCCESS' times."
_beep
}

f_exit(){ # unused
echo draw 3 "Forcing exiting $0."
_say_end_msg
echo unwatch
#echo unwatch drawinfo
_beep
exit $1
}

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

REPLY=
OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 mark icecube"

 while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && break 2 #f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

echo unwatch drawinfo
sleep 1s

NO_FAIL=
until [ "$NO_FAIL" ]
do

REPLY=
#OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 apply flint and steel"

 while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 #test "$REPLY" = "$OLD_REPLY" && break
 #test "`echo "$REPLY" | grep 'fail'`" || NO_FAIL=1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 case $REPLY in
 *You*fail*used*up*) break 3;;
 *fail.) FAIL_ALL=$((FAIL_ALL+1));NO_FAIL='';;
 *"Could not find any match to the flint and steel."*) break 3;;
 *You*light*icecube*) SUCCESS=$((SUCCESS+1)); NO_FAIL='1'; break 1;;
 *You*need*to*mark*a*lightable*object.) break 2;;
 *Your*) :;;
 '') break;;
 *) NO_FAIL='';;
 esac
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 unset REPLY
 sleep 0.1s
 done

echo unwatch drawinfo
sleep 1s

done #NO_FAIL

done #NUMBER

    else #PARAM_1

until [ "$NO_ICECUBE" ];
do

REPLY=
OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 mark icecube"
while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 test "$REPLY" = "$OLD_REPLY" && break
 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && break 2 #f_exit 1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 OLD_REPLY="$REPLY"
 sleep 0.1s
 done

echo unwatch drawinfo
sleep 1s

NO_FAIL=
until [ "$NO_FAIL" ]
do


REPLY=
#OLD_REPLY=

echo watch drawinfo
echo "issue 1 1 apply flint and steel"
 while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 #test "$REPLY" = "$OLD_REPLY" && break
 #test "`echo "$REPLY" | grep 'fail'`" || NO_FAIL=1
 #test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
 #test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
 case $REPLY in
 *You*fail*used*up*) break 3;;
 *fail.) FAIL_ALL=$((FAIL_ALL+1)); NO_FAIL='';;
 *You*light*icecube*) SUCCESS=$((SUCCESS+1)); NO_FAIL='1'; break 1;;
 *"Could not find any match to the flint and steel."*) break 3;;
 *You*need*to*mark*a*lightable*object.) break 2;;
 *Your*) :;;
 '') break;;
 *) NO_FAIL='';;
 esac
 #test "$REPLY" || break
 #test "$REPLY" = "$OLD_REPLY" && break
 #OLD_REPLY="$REPLY"
 unset REPLY
 sleep 0.1s
 done

echo unwatch drawinfo
sleep 1s

done #NO_FAIL

done #true

    fi #^!PARAM_1

__count_time(){

test "$TIMEB" || return 1

TIMEE=`date +%s`

TIMEX=$((TIMEE-TIMEB))
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

__say_end_msg(){
# *** Here ends program *** #
echo draw 2 "$0 is finished."
echo draw 1 "You failed    '$FAIL_ALL' times."
echo draw 7 "You succeeded '$SUCCESS' times."
__count_time && echo draw ${COL_LGREEN:-8} "Script loop took $TIMEM:$TIMES minutes."

}
_say_end_msg
