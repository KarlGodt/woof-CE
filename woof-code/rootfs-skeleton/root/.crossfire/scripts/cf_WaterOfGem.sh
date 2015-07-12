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
echo draw 2 "$0 is started - pid $$ ppid $PPID"

# *** Setting defaults *** #
GEM='';  #set empty default
NUMBER=0 #set zero as default

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to produce water of GEM."
echo draw 7 "Syntax:"
echo draw 7 "$0 GEM NUMBER"
echo draw 2 "Allowed GEM are diamond, emerald,"
echo draw 2 "pearl, ruby, sapphire ."
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of GEM ."

        exit 0
        }

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:alpha:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :alpha: characters as first option allowed."
        exit 1 #exit if other input than letters
        }

GEM="$PARAM_1"

PARAM_2="$2"
PARAM_2test="${PARAM_2//[[:digit:]]/}"
test "$PARAM_2test" && {
echo draw 3 "Only :digit: numbers as second options allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_2
} || {
echo draw 3 "Script needs gem and number of alchemy attempts as arguments."
        exit 1
}

test "$1" -a "$2" || {
echo draw 3 "Need <gem> and <number> ie: script $0 ruby 3 ."
        exit 1
}

if test ! "$GEM"; then #set fallback
GEM=diamond
#GEM=sapphire
#GEM=ruby
#GEM=emerald
#GEM=pearl
fi

if test ! "$NUMBER"; then
echo draw 3 "Need a number of items to alch."
exit 1
elif test "$NUMBER" = 0; then
echo draw 3 "Number must be notg ZERO."
exit 1
elif test "$NUMBER" -lt 0; then
echo draw 3 "Number must be greater than ZERO."
exit 1
fi

test "$GEM" != diamond -a "$GEM" != emerald -a "$GEM" != pearl \
  -a "$GEM" != ruby -a "$GEM" != sapphire && {
echo draw 3 "'$GEM' : Not a recognized kind of gem."
exit 1
}

# *** Check if standing on a cauldron *** #
UNDER_ME='';
echo request items on

while [ 1 ]; do
read UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>/tmp/cf_script.ion
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
exit 1
}

# *** Actual script to alch the desired water of gem *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** west of the cauldron.                                         *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #


echo "issue 1 1 pickup 0"  # precaution

f_exit(){
echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep 1s
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawinfo
exit $1
}

rm -f /tmp/cf_script.rpl

for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 apply"

echo watch drawinfo

echo "issue 1 1 drop 1 water of the wise"

OLD_REPLY="";
REPLY="";


while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && f_exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

sleep 1s

echo "issue 1 1 drop 3 $GEM"

OLD_REPLY="";
REPLY="";

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | busybox grep -E '.*Nothing to drop\.|.*There are only.*|.*There is only.*'`" && f_exit 1
#test "`echo "$REPLY" | grep '.*There are only.*'`"  && f_exit 1
#test "`echo "$REPLY" | grep '.*There is only.*'`"   && f_exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo

sleep 1s

echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep 1s

echo "issue 1 1 use_skill alchemy"
echo "issue 1 1 apply"

echo watch drawinfo

echo "issue 1 1 get"

OLD_REPLY="";
REPLY="";
NOTHING=0

while [ 1 ]; do
read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_script.rpl
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
sleep 0.1s
done

echo unwatch drawinfo

sleep 1s

echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 west"
echo "issue 1 1 west"
sleep 1s

echo draw 2 "NOTHING is '$NOTHING'"

if test $NOTHING = 0; then

echo "issue 1 1 use_skill sense curse"
echo "issue 1 1 use_skill sense magic"
echo "issue 1 1 use_skill alchemy"
sleep 1s

echo "issue 1 1 drop water of $GEM"
echo "issue 0 1 drop slags"

fi

DELAY_DRAWINFO=2
sleep ${DELAY_DRAWINFO}s

echo "issue 1 1 east"
echo "issue 1 1 east"
echo "issue 1 1 east"
echo "issue 1 1 east"
sleep 1s

done

# *** Here ends program *** #
echo draw 2 "$0 is finished."
