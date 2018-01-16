#!/bin/bash

export PATH=/bin:/usr/bin
export LC_NUMERIC=de_DE
export LC_ALL=de_DE


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
[ "$*" ] && {
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
;; esac

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

} || {
_draw 3 "Script needs number of cancellation attempts as argument."
        exit 1
}

test "$1" || {
_draw 3 "Need <number> ie: script $0 50 ."
        exit 1
}


# *** Actual script to cancel multiple times *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

__say_apply_params(){
cat >&1 <<EoI
 void command_apply(object *op, const char *params) {
    int aflag = 0;
    object *inv = op->inv;
    object *item;

    if (*params == '\0') {
        apply_by_living_below(op);
        return;
    }

    while (*params == ' ')
        params++;
    if (!strncmp(params, "-a ", 3)) {
        aflag = AP_APPLY;
        params += 3;
    }
    if (!strncmp(params, "-u ", 3)) {
        aflag = AP_UNAPPLY;
        params += 3;
    }
    if (!strncmp(params, "-b ", 3)) {
        params += 3;
        if (op->container)
            inv = op->container->inv;
        else {
            inv = op;
            while (inv->above)
                inv = inv->above;
        }
    }
    while (*params == ' ')
        params++;

    item = find_best_apply_object_match(inv, op, params, aflag);
    if (item == NULL)
        item = find_best_apply_object_match(inv, op, params, AP_NULL);
    if (item) {
        apply_by_living(op, item, aflag, 0);
    } else
        draw_ext_info_format(NDI_UNIQUE, 0, op, MSG_TYPE_COMMAND, MSG_TYPE_COMMAND_ERROR,
                             "Could not find any match to the %s.",
                             params);
}
EoI

}

__check_if_item_is_active(){
_debug "__check_if_item_is_active:$*"

local lITEM="$*" oR tmpR lRV=1
#test "$lITEM" || { echo "draw 3 \$lITEM missing"; exit 1; }
test "$lITEM" || _exit 1 "\$lITEM missing."

unset HAVE_ITEM_APPLIED oR tmpR
sleep 0.1
echo request items actv
while :; do
 unset tmpR
 read -t 1 tmpR
 _log "__check_if_item_is_active:$tmpR"
 _msg 7 "__check_if_item_is_active:$tmpR"

 case $tmpR in
 *"$lITEM"*) HAVE_ITEM_APPLIED=YES; lRV=0; break;;
 '')  break;;
 #$oR) break;;
 esac
#test "$oR" = "$tmpR" && break

#oR="$tmpR"
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
#sleep 2
_is 1 1 apply -a "$lITEM"
}

__check_range_attack(){
_debug "__check_range_attack:$*"

local lITEM="${*:-$ITEM}" oR tmpR c lRV=1
#test "$lITEM" || { _draw 3 '$lITEM missing.'; exit 1; }
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
 #$oR) break;;
 esac
 #oR="$tmpR"
 sleep 0.01
 done

c=$((c+1))
sleep 0.1
test "$RANGE_ITEM_APPLIED" || _is 1 1 rotateshoottype
done

return ${lRV:-1}
}

# MAIN:

_get_player_speed
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"

#__check_if_item_is_active "$CANCEL_ITEM"
#test "$HAVE_ITEM_APPLIED" || __force_apply_item "$CANCEL_ITEM"

while :
do
one=$((one+1))

#__check_if_item_is_active "$CANCEL_ITEM"
#test "$HAVE_ITEM_APPLIED" || __force_apply_item "$CANCEL_ITEM"
__check_if_item_is_active "$CANCEL_ITEM" || __force_apply_item "$CANCEL_ITEM"

__check_range_attack "$CANCEL_ITEM"
#if test "$RANGE_ITEM_APPLIED"; then
if test "$?" = 0; then
_is 1 1 fire "center"
_is 1 1 fire_stop
else
 __force_apply_item "$CANCEL_ITEM"
fi

case $NUMBER in $one) break 1;; esac

_check_food_level
_check_hp_and_return_home $HP

ckc=$((ckc+1))
test "$ckc" -ge $COUNT_CHECK_FOOD && {
ckc=0
case $NUMBER in
'') _draw 5 "$one firing attempt(s) done.";;
*)  _draw 5 "$((NUMBER-one)) firings(s) left.";;
esac
}

_sleep
done

_is 1 1 fire_stop

# *** Here ends program *** #
_say_end_msg
###END###
