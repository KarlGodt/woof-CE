#!/bin/bash

export PATH=/bin:/usr/bin

# *** PARAMETERS *** #

# *** Setting defaults *** #
GEM='';  #set empty default
NUMBER=0 #set zero as default

__set_global_variables(){
TMOUT=1    # read -t timeout

DIRB=west  # direction back to go

case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
esac

# Log file path in /tmp
#MY_SELF=`realpath "$0"`
#MY_BASE=${MY_SELF##*/}
TMP_DIR=/tmp/crossfire
mkdir -p "$TMP_DIR"
REPLY_LOG="$TMP_DIR"/"$MY_BASE".$$.rpl
REQUEST_LOG="$TMP_DIR"/"$MY_BASE".$$.req
ON_LOG="$TMP_DIR"/"$MY_BASE".$$.ion

exec 2>>"$TMP_DIR"/"$MY_BASE".$$.err
}

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh

_set_global_variables

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
case "$PARAM_1" in *"help"*)

echo draw 5 "Script to produce water of GEM."
echo draw 7 "Syntax:"
echo draw 7 "$0 GEM NUMBER"
echo draw 2 "Allowed GEM are diamond, emerald,"
echo draw 2 "pearl, ruby, sapphire ."
echo draw 5 "Allowed NUMBER will loop for"
echo draw 5 "NUMBER times to produce NUMBER of"
echo draw 5 "Water of GEM ."

        exit 0
;; esac

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
__check_if_on_cauldron(){
UNDER_ME='';
echo request items on

while :; do
read -t 1 UNDER_ME
sleep 0.1s
#echo "$UNDER_ME" >>"$ON_LOG"
UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"
test "$UNDER_ME" = "request items on end" && break
test "$UNDER_ME" = "scripttell break" && break
test "$UNDER_ME" = "scripttell exit" && exit 1
unset UNDER_ME
sleep 0.1
done

test "`echo "$UNDER_ME_LIST" | grep 'cauldron$'`" || {
echo draw 3 "Need to stand upon cauldron!"
exit 1
}

}

_check_if_on_cauldron
_check_for_space
_check_empty_cauldron

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF

_get_player_speed
_prepare_rod_of_recall

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


_is 1 1 pickup 0  # precaution

__f_exit(){
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep 1s
echo draw 3 "Exiting $0."
#echo unmonitor
#echo unwatch monitor
#echo unwatch monitor issue
echo unwatch
echo unwatch drawinfo
exit $1
}

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"

success=0
# *** NOW LOOPING *** #
for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply

echo watch drawinfo

_is 1 1 drop 1 water of the wise

OLD_REPLY="";
REPLY="";


while :; do
read -t 1 REPLY
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && _exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

sleep 1s

_is 1 1 drop 3 $GEM

OLD_REPLY="";
REPLY="";

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | busybox grep -E '.*Nothing to drop\.|.*There are only.*|.*There is only.*'`" && _exit 1
#test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
#test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo

sleep 1s

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep 1s

_is 1 1 use_skill alchemy
_is 1 1 apply

echo watch drawinfo

_is 1 1 get

OLD_REPLY="";
REPLY="";
NOTHING=0
SLAG=0

while :; do
read -t 1 REPLY
echo "$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to take\!'`" && NOTHING=1
test "`echo "$REPLY" | grep '.*You pick up the slag\.'`" && SLAG=1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo

sleep 1s

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
sleep 1s

[ "$DEBUG" ] && echo draw 2 "NOTHING is '$NOTHING'"

if test "$NOTHING" = 0; then
 if test "$SLAG" = 0; then
  _is 1 1 use_skill sense curse
  _is 1 1 use_skill sense magic
  _is 1 1 use_skill alchemy
  sleep 1s

 _is 1 1 drop water of $GEM
 _is 1 1 drop water "(cursed)"
 _is 1 1 drop water "(magic)"
 success=$((success+1))
 else
 _is 0 1 drop slag
 fi
fi

#DELAY_DRAWINFO=2
sleep ${DELAY_DRAWINFO}s

_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
sleep 1s

_check_if_on_cauldron

TRIES_SILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
echo drawinfo 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_SILL to go..."

done

# *** Here ends program *** #
test -f /root/.crossfire/sounds/su-fanf.raw && aplay /root/.crossfire/sounds/su-fanf.raw
echo draw 2 "$0 is finished."
