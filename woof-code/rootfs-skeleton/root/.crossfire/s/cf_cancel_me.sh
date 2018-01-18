#!/bin/bash

#export PATH=/bin:/usr/bin
#export LC_NUMERIC=de_DE
#export LC_ALL=de_DE

VERSION=0.0 # initial version
VERSION=2.0 # add a check for food level and to eat
VERSION=2.1 # recognize -V and -d options

CANCEL_ITEM='rod of cancellation' # may set to scroll,
# staff, heavy rod or just rod of cancellation

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_common.sh && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_food.sh   && . "${MY_SELF%/*}"/cf_funcs_food.sh

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf  && . "${MY_SELF%/*}"/"${MY_BASE}".conf


# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #
until [ "$#" = 0 ];
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*)

_draw 5 "Script to "
_draw 5 "apply $CANCEL_ITEM"
_draw 5 "and then to fire center on oneself."
_draw 2 "Syntax:"
_draw 2 "$0 NUMBER"
_draw 7 "$0 5 would fire center 5 times."

        exit 0
;;
-d) DEBUG=$((DEBUG+1));;
-V) _say_version;;
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
sleep 0.1
done

test "$NUMBER" || {
_draw 3 "Script needs number of cancellation attempts as argument."
        exit 1
}

#test "$1" || {
#_draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}


# *** Actual script to cancel multiple times *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

__check_if_item_is_active(){
_debug "__check_if_item_is_active:$*"

local lITEM="$*" oR tmpR lRV=1
test "$lITEM" || _exit 1 "\$lITEM missing."

unset HAVE_ITEM_APPLIED oR tmpR
#sleep 0.1

echo request items actv
while :; do
 unset tmpR
 read -t 1 tmpR
   _log "__check_if_item_is_active:$tmpR"
 _msg 7 "__check_if_item_is_active:$tmpR"

 case $tmpR in
 *"$lITEM"*) HAVE_ITEM_APPLIED=YES; lRV=0; break;;
 '')  break;;
 esac

sleep 0.01
done

return ${lRV:-1}
}

__force_apply_item(){
_debug "__force_apply_item:$*"

local lITEM=${*:-"$CANCEL_ITEM"}
test "$lITEM" || return 254

_draw 4 "Forcing applying of '$lITEM' ..."
_draw 3 'If that fails, use scriptkill to abort!'
_is 1 1 apply -u "$lITEM"
_is 1 1 apply -a "$lITEM"
}

__check_range_attack(){
_debug "__check_range_attack:$*"

local lITEM="${*:-$ITEM}" oR tmpR c lRV=1
test "$lITEM" || _exit 1 '$lITEM missing.'

unset RANGE_ITEM_APPLIED oR tmpR c
c=0
while :;
do
test "$c" = 5 && break

sleep 0.1
echo request range
 while :;
 do
 unset tmpR
 read -t 1 tmpR
   _log "__check_range_attack:$tmpR"
 _msg 7 "__check_range_attack:$tmpR"

 case $tmpR in
 *"$lITEM"*) RANGE_ITEM_APPLIED=YES; lRV=0; break 2;;
 '')  break;;
 esac

 sleep 0.01
 done

c=$((c+1))
sleep 0.1
test "$RANGE_ITEM_APPLIED" || _is 1 1 rotateshoottype
done

return ${lRV:-1}
}

_say_progress(){
#ckc=$((ckc+1))
#test "$ckc" -ge $COUNT_CHECK_FOOD || return 1
#ckc=0
case $NUMBER in
'') _draw 5 "$one firing attempt(s) done.";;
*)  _draw 5 "$((NUMBER-one)) firings(s) left.";;
esac
}

# MAIN:

_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"

while :
do
one=$((one+1))

__check_if_item_is_active "$CANCEL_ITEM" || __force_apply_item "$CANCEL_ITEM"

__check_range_attack "$CANCEL_ITEM"
if test "$?" = 0; then
 _is 1 1 fire "center"
 _is 1 1 fire_stop
else
 __force_apply_item "$CANCEL_ITEM"
fi

case $NUMBER in $one) break 1;; esac

if _check_counter; then
_check_food_level
_check_hp_and_return_home $HP
_say_progress
fi

_sleep
done

_is 1 1 fire_stop

# *** Here ends program *** #
_say_end_msg
###END###
