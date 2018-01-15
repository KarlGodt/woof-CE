#!/bin/ash

export PATH=/bin:/usr/bin

# *** PARAMETERS *** #

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_common.sh   && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_move.sh    && . "${MY_SELF%/*}"/cf_funcs_move.sh
test -f "${MY_SELF%/*}"/cf_funcs_food.sh    && . "${MY_SELF%/*}"/cf_funcs_food.sh
test -f "${MY_SELF%/*}"/cf_funcs_alchemy.sh && . "${MY_SELF%/*}"/cf_funcs_alchemy.sh

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

# *** Here begins program *** #
_say_start_msg "$@"

while :;
do
case "$1" in
-version) shift;;
*.*) shift;;
*) break;;
esac
done

[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*)

_draw 5 "Script to produce water of the wise."
_draw 7 "Syntax:"
_draw 7 "$0 [ -version VERSION ] NUMBER"
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Balm of First Aid ."
_draw 2  "Option -version 1.12.0 and lesser"
_draw 2  "turns on some compatibility switches."
        exit 0
;; esac

PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1

} || {
_draw 3 "Script needs number of alchemy attempts as argument."
        exit 1
}

test "$1" || {
_draw 3 "Need <number> ie: script $0 4 ."
        exit 1
}

_draw 7 "OK."

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"


# *** Getting Player's Speed *** #
_get_player_speed
# *** Check if standing on a cauldron *** #
#_is 1 1 pickup 0  # precaution ## now done in _check_empty_cauldron
_check_if_on_cauldron
# *** Check if there are 4 walkable tiles in $DIRB *** #
#_check_for_space
$FUNCTION_CHECK_FOR_SPACE
# *** Check if cauldron is empty *** #
_check_empty_cauldron
# *** Unreadying rod of word of recall - just in case *** #
_unapply_rod_of_recall


# *** Monitoring function *** #
# *** Todo ...            *** #
_monitor_malfunction(){

while :; do
read -t $TMOUT ERRORMSGS

sleep 0.1s
done
}

# *** Actual script to alch the desired balm of first aid *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' and                                      *** #
# *** drop mandrake root   before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water and mandrake root --      *** #
# *** only one inventory line with water(s) and                     *** #
# *** mandrake root are allowed !!                                  *** #
# *** Otherwise a wand or scroll of summon water elemental may be   *** #
# *** put into the cauldron, which would result in failure !!!!     *** #

# *** Now get the number of desired water of the wise and           *** #
# *** same times the number of mandrake root .                      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** $DIRB of the cauldron.                                        *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

TIMEA=`date +%s`
success=0
# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep 0.5
#sleep ${SLEEP}s

_drop_in_cauldron 1 water of the wise

_drop_in_cauldron 1 mandrake root

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

        _is 0 1 drop balm
        success=$((success+1))
        else
        _failure &
        _is 0 1 drop slag
        fi
elif test "$NOTHING" = "-1"; then
      :   # emergency drop to prevent new created items droped in cauldron
else
 _disaster &
fi

_return_to_cauldron
_loop_counter

done  # *** MAINLOOP *** #


# *** Here ends program *** #
_say_end_msg
