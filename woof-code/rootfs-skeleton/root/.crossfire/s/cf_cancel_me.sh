#!/bin/bash

export PATH=/bin:/usr/bin

# *** Here begins program *** #
echo draw 2 "$0 is started.."

ROD='heavy rod of cancellation'

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to "
echo draw 5 "apply $ROD"
echo draw 5 "and then to fire center on oneself."

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
echo draw 3 "Script needs number of cancellation attempts as argument."
        exit 1
}

test "$1" || {
echo draw 3 "Need <number> ie: script $0 50 ."
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

local ITEM="$*" oR tmpR
test "$ITEM" || { echo "draw 3  $ITEM missing"; exit 1; }

echo watch drawinfo
sleep 0.1
echo request items actv
while :; do
read -t 1 tmpR
case $tmpR in
*"$ITEM"*) HAVE_ITEM_APPLIED=YES; break;;
'') break;;
esac
test "$oR" = "$tmpR" && break
oR=$tmpR
sleep 0.1
done
echo unwatch drawinfo

}

__check_if_item_is_active "$ROD"

test "$HAVE_ITEM_APPLIED" || echo "issue 1 1 apply -a $ROD"

_simple_apply_item(){
echo "issue 1 1 apply -u $ROD"
sleep 2
echo "issue 1 1 apply -a $ROD"
}


for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 fire center"
sleep 1s

done

echo "issue 1 1 fire_stop"

# *** Here ends program *** #
echo draw 2 "$0 is finished."
