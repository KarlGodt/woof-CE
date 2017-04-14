#!/bin/ash

export PATH=/bin:/usr/bin

_usage(){
_draw 5 "Script to produce water of GEM."
_draw 7 "Syntax:"
_draw 7 "$0 [ -version VERSION ] GEM NUMBER"
_draw 2 "Allowed GEM are diamond, emerald,"
_draw 2 "pearl, ruby, sapphire ."
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Water of GEM ."
_draw 5 "Options:"
_draw 2  "Option -version 1.12.0 and lesser"
_draw 2  "turns on some compatibility switches."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v to say what is being issued to server."
        exit 0
}

# *** Setting defaults *** #
GEM='';  #set empty default
NUMBER=0 #set zero as default

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

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


# *** Here begins program *** #
_say_start_msg "$@"
_debug "$@"

# *** PARAMETERS *** #

# ** client version ** #
while :;
do
case "$1" in
-version) shift;;
*.*) shift;;
*) break;;
esac
sleep 0.1
done

until test "$#" = 0;
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
*)

 case $PARAM_1 in
 diamond|emerald|pearl|ruby|sapphire)
 # *** testing parameters for validity *** #
 PARAM_1test="${PARAM_1//[[:alpha:]]/}"
 test "$PARAM_1test" && {
 _draw 3 "Only :alpha: characters as (TODO:?first?) option allowed."
        exit 1 #exit if other input than letters
        }
GEM="$PARAM_1"
 ;;
*)
 PARAM_1test="${PARAM_1//[[:digit:]]/}"
 test "$PARAM_1test" && {
 _draw 3 "Only :digit: numbers as (TODO:?second?) option allowed."
        exit 1 #exit if other input than numbers
        }
NUMBER=$PARAM_1
 ;;
 esac


fi
;;
esac
shift
sleep 0.1
done

test "$GEM" -a "$NUMBER" || {
_draw 3 "Script needs gem and number of alchemy attempts as arguments."
        exit 1
}

#test "$1" -a "$2" || {
#_draw 3 "Need <gem> and <number> ie: script $0 ruby 3 ."
#        exit 1
#}

if test ! "$GEM"; then #set fallback
GEM=diamond
#GEM=sapphire
#GEM=ruby
#GEM=emerald
#GEM=pearl
fi

if test ! "$NUMBER"; then
_draw 3 "Need a number of items to alch."
exit 1
elif test "$NUMBER" = 0; then
_draw 3 "Number must be not ZERO."
exit 1
elif test "$NUMBER" -lt 0; then
_draw 3 "Number must be greater than ZERO."
exit 1
fi

test "$GEM" = diamond -o "$GEM" = emerald -o "$GEM" = pearl \
  -o "$GEM" = ruby -o "$GEM" = sapphire || {
_draw 3 "'$GEM' : Not a recognized kind of gem."
exit 1
}

# *** Getting Player's Speed *** #
_get_player_speed
# *** Check if standing on a cauldron *** #
#_is 1 1 pickup 0  # precaution
_check_if_on_cauldron
# *** Check if there are 4 walkable tiles in $DIRB *** #
#_check_for_space
$FUNCTION_CHECK_FOR_SPACE
# *** Check if cauldron is empty *** #
_check_empty_cauldron
# *** Unreadying rod of word of recall - just in case *** #
_prepare_rod_of_recall

# *** Actual script to alch the desired water of gem *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #

# *** So do a 'drop water' and 'drop GEM' before beginning to alch. *** #
# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Watch out to drop any GEM of great value or beauty,           *** #
# *** otherwise drop GEM would also drop these GEMS, which          *** #
# *** would result in several type of GEM being inside cauldron,    *** #
# *** thus resulting in failure of an alchemy attempt.              *** #

# *** Now get the number of desired water of the wise and           *** #
# *** three times the number of the desired gem.                    *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** $DIRB of the cauldron.                                        *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"

TIMEA=`date +%s`
success=0
# *** NOW LOOPING *** #
for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep 0.5s
#sleep ${SLEEP}s

_drop_in_cauldron 1 water of the wise

_drop_in_cauldron 3 $GEM

_close_cauldron
#sleep 1s

_alch_and_get
#sleep 1s

_go_cauldron_drop_alch_yeld
#sleep 1s

_debug "get:NOTHING is '$NOTHING'"

if test "$NOTHING" = 0; then
 if test "$SLAG" = 0; then
  _success &
  _is 1 1 use_skill sense curse
  _is 1 1 use_skill sense magic
  _is 1 1 use_skill alchemy
  sleep ${SLEEP}s

 _is 1 1 drop water of $GEM
 _is 1 1 drop water "(cursed)"
 _is 1 1 drop water "(magic)"
 success=$((success+1))
 else
 _failure &
 _is 0 1 drop slag
 fi
else
 _disaster &
fi


_return_to_cauldron
_loop_counter


done

# *** Here ends program *** #
_say_end_msg
