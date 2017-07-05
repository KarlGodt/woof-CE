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
#define NDI_MAX_COLOR   12      /**< Last value in. */
#
#define NDI_COLOR_MASK  0xff    /**< Gives lots of room for expansion - we are
#                                 *   using an int anyways, so we have the
#                                 *   space to still do all the flags.
#                                 */
#define NDI_UNIQUE      0x100   /**< Print immediately, don't buffer. */
#define NDI_ALL         0x200   /**< Inform all players of this message. */
#define NDI_ALL_DMS     0x400   /**< Inform all logged in DMs. Used in case of
#                                 *   errors. Overrides NDI_ALL. */



LOG_REPLY_FILE=/tmp/cf_script.rpl

rm -f "$LOG_REPLY_FILE"

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to melt icecube."
echo draw 5 "Syntax:"
echo draw 5 "script $0 [number]"
echo draw 5 "For example: 'script $0 5'"
echo draw 5 "will issue 5 times mark icecube and apply flint and steel."

        exit 0
        }

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

}


f_exit(){
RV=${1:-0}
shift
test "$*" && echo draw 4 "$*"
             echo draw 3 "Exiting $0."
echo unwatch
#echo unwatch drawinfo
beep
exit $RV
}

_mark_icecube(){

local REPLY=
local OLD_REPLY=

echo watch drawinfo

echo "issue 1 1 mark icecube"
sleep 0.5

 while :; do
 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"

 test "`echo "$REPLY" | grep 'Could not find an object that matches'`" && return 3
 test "$REPLY" || break
 test "$REPLY" = "$OLD_REPLY" && break

 OLD_REPLY="$REPLY"
 sleep 0.1s
 unset REPLY
 done

echo unwatch drawinfo
sleep 1
}

_light_icecube(){

local REPLY=
local OLD_REPLY=

echo watch drawinfo

while :;
do

echo "issue 1 1 apply flint and steel"
sleep 0.5

 read -t 1 REPLY
 echo "$REPLY" >>"$LOG_REPLY_FILE"
 case $REPLY in
 *'You light '*) DONE=$((DONE+1)); break;;
 *'You need to mark a lightable object.'*) break;;
 *'You fail '*'used up'*) return 4;;
 *' fail.') FAILS=$((FAILS+1));;
 '') break;;
 esac

 sleep 0.1s
 unset REPLY

done

echo unwatch drawinfo
sleep 1
}

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

_mark_icecube  || break

_light_icecube || break

done #NUMBER

    else #PARAM_1

while :;
do

_mark_icecube  || break

_light_icecube || break

done #true

    fi #^!PARAM_1


# *** Here ends program *** #
echo draw 2 "You failed '$FAILS' times."
echo draw 7 "You melted '$DONE' icubes."
echo draw 2 "$0 is finished."
beep