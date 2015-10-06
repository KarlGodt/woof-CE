#!/bin/ash

export PATH=/bin:/usr/bin

# *** PARAMETERS *** #

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh

_set_global_variables

# *** Here begins program *** #
_draw 2 "$0 is started.."
_draw 2 "PID is $$ - parentPID is $PPID"

# *** Check for parameters *** #
_draw 5 "Checking the parameters ($*)..."

[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in *"help"*)

_draw 5 "Script to produce water of the wise."
_draw 7 "Syntax:"
_draw 7 "$0 NUMBER"
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Balm of First Aid ."

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


#test -f "${MY_SELF%/*}"/cf_functions.sh && . "${MY_SELF%/*}"/cf_functions.sh

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"


# *** Getting Player's Speed *** #
_get_player_speed
# *** Check if standing on a cauldron *** #
#_is 1 1 pickup 0  # precaution ## now done in _check_empty_cauldron
_check_if_on_cauldron
# *** Check if there are 4 walkable tiles in $DIRB *** #
_check_for_space
# *** Check if cauldron is empty *** #
_check_empty_cauldron

#_is 1 1 $DIRB
#_is 1 1 $DIRB
#_is 1 1 $DIRF
#_is 1 1 $DIRF

# *** Unreadying rod of word of recall - just in case *** #
_prepare_rod_of_recall


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

success=0
# *** Now LOOPING *** #

for one in `seq 1 1 $NUMBER`
do

TIMEB=`date +%s`

_is 1 1 apply
sleep ${SLEEP}s

echo watch drawinfo

#_is 1 1 drop 1 water of the wise
_drop 1 water of the wise

#echo watch drawinfo

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "Water of the Wise:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && _exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

sleep ${SLEEP}s

#_is 1 1 drop 1 mandrake root
_drop 1 mandrake root

OLD_REPLY="";
REPLY="";

while :; do
#unset REPLY
read -t $TMOUT REPLY
echo "mandrake root:$REPLY" >>"$REPLY_LOG"
test "`echo "$REPLY" | grep '.*Nothing to drop\.'`" && _exit 1
test "`echo "$REPLY" | grep '.*There are only.*'`"  && _exit 1
test "`echo "$REPLY" | grep '.*There is only.*'`"   && _exit 1
test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"
unset REPLY
sleep 0.1s
done

echo unwatch drawinfo

sleep ${SLEEP}s

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRF
_is 1 1 $DIRF

sleep ${SLEEP}s

_alch_and_get

sleep ${SLEEP}s

_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB
_is 1 1 $DIRB

sleep ${SLEEP}s

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
        _success &
        _is 1 1 use_skill sense curse
        _is 1 1 use_skill sense magic
        _is 1 1 use_skill alchemy
        sleep ${SLEEP}s

        _is 0 1 drop balm
        #_success &
        success=$((success+1))
        else
        _failure &
        _is 0 1 drop slag
        #_failure &
        fi
elif test "$NOTHING" = "-1"; then
      :   # emergency drop to prevent new created items droped in cauldron
else
 _disaster &
fi

_check_food_level

sleep ${DELAY_DRAWINFO}s

_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF
_is 1 1 $DIRF

sleep ${SLEEP}s

_check_if_on_cauldron

TRIES_SILL=$((NUMBER-one))
TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s, $success of $one successfull, still $TRIES_SILL to go..."

done  # *** MAINLOOP *** #


# *** Here ends program *** #
test -f /root/.crossfire/sounds/su-fanf.raw && aplay $Q /root/.crossfire/sounds/su-fanf.raw
_draw 2 "$0 is finished."
