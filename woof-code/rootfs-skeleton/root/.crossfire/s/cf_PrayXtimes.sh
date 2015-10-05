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


# Global variables
PAUSE_CHECK_FOOD=10 # number between praying attemts to check foodlevel.
                    #  1 would mean check every pray, which is too much
EAT_FOOD=waybread   # set to desired food to eat ie food, mushroom, booze, .. etc.
FOOD_DEF=$EAT_FOOD     # default
MIN_FOOD_LEVEL_DEF=200 # default minimum. 200 starts to beep. waybread has foodvalue of 500 .
                       # 999 is max foodlevel

HP_MIN_DEF=20          # minimum HP to return home. Lowlevel charakters probably need this set.

DEBUG=1; #set to ANYTHING ie "1" to enable, empty to disable


# Log file path in /tmp
MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err


# *** Here begins program *** #
echo draw 2 "$0 has started.."
echo draw 2 "PARAM:$* PID:$$ PPID :$PPID"

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

echo draw 5 "Script to pray given number times."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <number>"
echo draw 5 "For example: 'script $0 50'"
echo draw 5 "will issue 50 times the use_skill praying command."

        exit 0
;; esac

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

} || {
echo draw 3 "Script needs number of praying attempts as argument."
        exit 1
}

test "$1" || {
echo draw 3 "Need <number> ie: script $0 50 ."
        exit 1
}

test -f "${MY_SELF%/*}"/cf_functions.sh && . "${MY_SELF%/*}"/cf_functions.sh

echo request stat cmbt
#read REQ_CMBT
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n", cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read Req Stat Cmbt WC AC DAM SPEED W_SPEED
[ "$DEBUG" ] && echo draw 7 "wc=$WC:ac=$AC:dam=$DAM:speed=$SPEED:weaponspeed=$W_SPEED"
case $SPEED in
1[0-9][0-9][0-9][0-9]) USLEEP=1500000;;
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
[ "$DEBUG" ] && echo draw 10 "USLEEP=$USLEEP:SPEED=$SPEED"

USLEEP=$(( USLEEP- ((SPEED/10000)*1000) ))
[ "$DEBUG" ] && echo draw 7 "Sleeping $USLEEP usleep micro-seconds between praying"



# *** Actual script to pray multiple times *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

c=0
for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 use_skill praying"
#sleep 1s
usleep $USLEEP

c=$((c+1))
test $c -ge $PAUSE_CHECK_FOOD && {
c=0
_check_food_level
#_check_hp_and_return_home $HP $HP_MIN_DEF
_check_hp_and_return_home $HP
unset Re Stat Hp HP MHP SP MSP GR MGR FOOD_LVL
unset Re2 Stat2 Hp2 HP2 MHP2 SP2 MSP2 GR2 MGR2
echo draw 5 "$((NUMBER-one)) prayings left"
}

done

# *** Here ends program *** #
test -f /root/.crossfire/sounds/su-fanf.raw && aplay /root/.crossfire/sounds/su-fanf.raw
echo draw 2 "$0 is finished."
