#!/bin/ash


MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
MY_DIR=${MY_SELF%/*}

#test -f "$MY_DIR"/cf_functions.sh   && . "$MY_DIR"/cf_functions.sh
#_set_global_variables "$@"

test -f "$MY_DIR"/cf_funcs_common.sh   && . "$MY_DIR"/cf_funcs_common.sh
_set_global_variables "$@"

test -f "$MY_DIR"/cf_funcs_move.sh    && . "$MY_DIR"/cf_funcs_move.sh
test -f "$MY_DIR"/cf_funcs_food.sh    && . "$MY_DIR"/cf_funcs_food.sh
test -f "$MY_DIR"/cf_funcs_alchemy.sh && . "$MY_DIR"/cf_funcs_alchemy.sh

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "$MY_DIR"/"${MY_BASE}".conf && . "$MY_DIR"/"${MY_BASE}".conf

_usage(){
_draw 5 "$MY_BASE"
_draw 5  "Script to produce water of the wise."
_draw 5  "To be used in the crossfire roleplaying game client."
_draw 7  "Syntax:"
_draw 7  "$0 <-version VERSION> NUMBER"
_draw 5  "Allowed NUMBER will loop for"
_draw 5  "NUMBER times to produce NUMBER of"
_draw 5  "Water of the Wise ."
_draw 2  "Option -version 1.12.0 and lesser"
_draw 2  "turns on some compatibility switches."

        exit 0
}

# *** Here begins program *** #
_say_start_msg "$@"

# *** PARAMETERS *** #
while :;
do
case "$1" in
-version) shift;;
*.*) shift;;
*) break;;
esac
done

until [ "$#" = 0 ];
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"*) _usage;;
-d) DEBUG=$((DEBUG+1));;
-L) LOGGING=$((LOGGING+1));;
-V) _say_version;;
*)
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1
;;
esac

shift
sleep 0.1
done

#} || {
#_draw 3  "Script needs number of alchemy attempts as argument."
#        exit 1
#}
#
#test "$1" || {
#_draw 3  "Need <number> ie: script $0 3 ."
#        exit 1
#}


# *** Actual script to alch the desired water of the wise           *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water --                        *** #
# *** only one inventory line with water(s) allowed !!              *** #
# *** Otherwise a wand or scroll of summon water elemental may be   *** #
# *** put into the cauldron, which would result in failure !!!!     *** #

# *** Now get the number of desired water of                        *** #
# *** seven times the number of the desired water of the wise.      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** $DIRB of the cauldron.                                        *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

# *** instead echo issue all the time make it a function


rm -f "$REPLY_LOG" # empty old log file
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"

# *** Getting Player's Speed *** #
_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"
# *** Check if standing on a cauldron *** #
#_is 1 1 pickup 0  # precaution
_check_if_on_cauldron
# *** Check if there are 4 walkable tiles in $DIRB *** #
#_check_for_space
$FUNCTION_CHECK_FOR_SPACE
# *** Check if cauldron is empty *** #
_check_empty_cauldron

#sleep ${SLEEP}s
#sleep ${SLEEP}s

# *** Unreadying rod of word of recall - just in case *** #
_unapply_rod_of_recall


# *** Now LOOPING *** #

_draw 4 "OK... Might the Might be with You!"

TIMEA=`date +%s`
success=0
for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep 0.5s
#sleep ${SLEEP}s

_drop_in_cauldron 7 water

_close_cauldron
#sleep ${SLEEP}s

_alch_and_get
#sleep ${SLEEP}s

_go_cauldron_drop_alch_yeld
#sleep ${SLEEP}s

if test "$NOTHING" = 0; then
 if test "$SLAG" = 0; then
 _success &
 _is 1 1 use_skill sense curse
 _is 1 1 use_skill sense magic
 _is 1 1 use_skill alchemy

 sleep ${SLEEP}s

 _is 0 1 drop water of the wise    # _is 1 1 drop drops only one water
 _is 0 1 drop waters of the wise

 _is 0 1 drop water "(cursed)"
 _is 0 1 drop waters "(cursed)"

 _is 0 1 drop water "(magic)"
 _is 0 1 drop waters "(magic)"

 _is 0 1 drop water "(cursed) (magic)"
 _is 0 1 drop waters "(cursed) (magic)"

 #_is 0 1 drop water (magic) (cursed)
 #_is 0 1 drop waters (magic) (cursed)
 #_is 0 1 drop water (unidentified)
 #_is 0 1 drop waters (unidentified)
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
