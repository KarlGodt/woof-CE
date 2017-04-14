#!/bin/ash

export PATH=/bin:/usr/bin


ROD='heavy rod of cancellation' # may set to scroll or staff or just rod

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

_usage(){
_draw 5 "Script to "
_draw 5 "apply $ROD"
_draw 5 "and then to fire center on oneself."
_draw 5 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v to say what is being issued to server."
        exit 0
}

# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #
until test "$#" = 0;
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as first option allowed."
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

local ITEM="$*" oR tmpR
test "$ITEM" || { echo "draw 3  $ITEM missing"; exit 1; }

echo watch $DRAWINFO
sleep 0.1
echo request items actv
while :; do
read -t 1 tmpR
case $tmpR in
*"$ITEM"*) HAVE_ITEM_APPLIED=YES; break;;
'') break;;
esac
test "$oR" = "$tmpR" && break
oR="$tmpR"
sleep 0.1
done
echo unwatch $DRAWINFO

}

_check_item(){
#test "$*" || return 0
#ITEM="$*"

# get item list
#_check_have_needed_item_in_inventory(){
_debug "_check_have_needed_item_in_inventory:$*"
TIMEB=`date +%s`
echo watch request
echo request items inv
while :;
do
read -t1 oneITEM
 _log "$oneITEM"
 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 #ITEMS="$ITEMS
#$oneITEM"
 ITEMS=`echo -e "$ITEMS\n$oneITEM"`
 oldITEM="$oneITEM"
sleep 0.1
done
unset oldITEM oneITEM
echo unwatch request

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME s"

#echo "$ITEMS" | grep -q -i "$ITEM"
#}

# check item
while read one
do
test "$one" || continue
case $one in '#'*) continue;; esac

echo "$ITEMS" | grep -i "${one} of cancellation" && { ROD="${one} of cancellation"; break; }
sleep 0.1

done <<EoI
heavy rod
rod
staff
#scroll
EoI

unset one
}

_check_item
__check_if_item_is_active "$ROD"

test "$HAVE_ITEM_APPLIED" || { echo "issue 1 1 apply -a $ROD"; sleep 1s; }


_simple_apply_item(){
echo "issue 1 1 apply -u $ROD"
sleep 2
echo "issue 1 1 apply -a $ROD"
}


__check_range_attack(){

local ITEM="$*" oR tmpR c
test "$ITEM" || { echo "draw 3  $ITEM missing"; exit 1; }


c=0
echo watch $DRAWINFO
while :;
do
test $c = 5 && break

sleep 0.1
echo request range
 while :;
 do
 read -t 1 tmpR
 case $tmpR in
 *"$ITEM"*) RANGE_ITEM_APPLIED=YES; break 2;;
 '') break;;
 esac
 test "$oR" = "$tmpR" && break
 oR="$tmpR"

 done
c=$((c+1))
sleep 0.1
test "$RANGE_ITEM_APPLIED" || echo issue 1 1 rotateshoottype
done

echo unwatch $DRAWINFO
}

__check_range_attack "$ROD"

if test "$RANGE_ITEM_APPLIED"; then

for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 fire center"
sleep 1s

done

else
_draw 3 "$ROD not applied."
fi

echo "issue 1 1 fire_stop"

# *** Here ends program *** #
#echo draw 2 "$0 is finished."
_say_end_msg
