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



# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to pray given number times."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <number>"
echo draw 5 "For example: 'script $0 50'"
echo draw 5 "will issue 50 times the use_skill praying command."

        exit 0
        }

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


# *** Actual script to pray multiple times *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 use_skill praying"
sleep 1s

done

# *** Here ends program *** #
echo draw 2 "$0 is finished."
