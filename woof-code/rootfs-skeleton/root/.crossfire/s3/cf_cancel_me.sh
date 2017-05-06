#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

RECHARGE_TIME=1 # rods 4 sec., heavy rods 1 sec.
ITEM_OF_XXX='{rod,staff,wand} of cancellation'

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
_draw 5 "apply $ITEM_OF_XXX"
_draw 5 "and then to fire center on oneself."
_draw 2 "Syntax:"
_draw 2 "script $MY_SELF <NUMBER>"
_draw 2 "where NUMBER is the desired amount of firings"
_draw 5 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 4 "-n  do not check inventory."
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
case "$PARAM_1" in -h|*"help"*|*usage) _usage;;
-d|*debug)      DEBUG=$((DEBUG+1));;
-L|*logging)  LOGGING=$((LOGGING+1));;
-n|*no-check) NOCHECK=$((NOCHECK+1));;
-v|*verbose)  VERBOSE=$((VERBOSE+1));;
[0-9]*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
_draw 3 "Only integer :digit: numbers as optional option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;
*) _draw 3 "Ignoring unhandled parameter '$PARAM_1'";;
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
test "$ITEM" || { _draw 3 "__check_if_item_is_active:ITEM missing"; exit 1; }

test "$HAVE_ITEM_APPLIED" && return 0

#echo watch $DRAWINFO
#_watch
sleep 0.1
echo request items actv
while :; do
read -t 1 tmpR
_log "__check_if_item_is_active:$tmpR"
_debug "__check_if_item_is_active:$tmpR"
case $tmpR in
*"$ITEM"*) HAVE_ITEM_APPLIED=YES; break;;
'') break;;
esac
test "$oR" = "$tmpR" && break
oR="$tmpR"
sleep 0.1
done
#echo unwatch $DRAWINFO
#_unwatch

# read the rest off the pipe
while :; do
 unset tmpR
 sleep 0.1
 read -t 1 tmpR
 case $tmpR in
 ''|'request items actv end') break;;
 esac
done


_debug "__check_if_item_is_active:HAVE_ITEM_APPLIED='$HAVE_ITEM_APPLIED'"

test "$HAVE_ITEM_APPLIED"
}

_check_item_of_xxx(){
[ "$NOCHECK" ] && return 3
_debug "_check_item_of_xxx:$*"

test "$*" || return 4
ITEM_OF="$*"

_debug "ITEM_OF='$ITEM_OF'"

local oneITEM ITEMS TIMEB TIMEE TIME
unset oneITEM ITEMS TIMEB TIMEE TIME

_debug "_check_item_of_xxx:$*"
_draw 4 "Creating inventory list."
_draw 4 "Please wait..."

TIMEB=`date +%s`

echo request items inv
while :;
do
read -t 1 oneITEM
 _log "_check_item_of_xxx:$oneITEM"
 _debug "_check_item_of_xxx:$oneITEM"

 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 #ITEMS="$ITEMS
#$oneITEM"
 ITEMS=`echo -e "$ITEMS\n$oneITEM"`
 oldITEM="$oneITEM"
sleep 0.1
done
unset oldITEM oneITEM

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME sec."

# check item

[ "$DEBUG" ] && echo "$ITMES" > /tmp/items.lst

while read one
do
test "$one" || continue
case $one in '#'*) continue;; esac

_debug "_check_item_of_xxx:$one"
_log "_check_item_of_xxx:$one"

[ "$DEBUG" ] && grep -i "${one} $ITEM_OF" /tmp/items.lst 2>&1 >> /tmp/item_grep.out

echo "$ITEMS" | grep -q -i "${one} $ITEM_OF" && { ITEM_OF_XXX="${one} $ITEM_OF"; break; }
sleep 0.1

done <<EoI
heavy rod
rod
#scroll
staff
wand
EoI

echo "$ITMES" > /tmp/items.lst


unset one
_draw 4 "You have '$ITEM_OF_XXX'"
test "$ITEM_OF_XXX"
}

_check_item_of_cancellation(){
_debug "_check_item_of_cancellation:$*"
_draw 4 "Creating inventory list."
_draw 4 "Please wait..."

local oneITEM ITEMS
unset oneITEM ITEMS

TIMEB=`date +%s`

echo request items inv
while :;
do
read -t 1 oneITEM
 _log "_check_item_of_cancellation:$oneITEM"
 _debug "_check_item_of_cancellation:$oneITEM"

 test "$oldITEM" = "$oneITEM" && break
 test "$oneITEM" || break
 #ITEMS="$ITEMS
#$oneITEM"
 ITEMS=`echo -e "$ITEMS\n$oneITEM"`
 oldITEM="$oneITEM"
sleep 0.1
done
unset oldITEM oneITEM

TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_draw 4 "Elapsed $TIME sec."

# check item
while read one
do
test "$one" || continue
case $one in '#'*) continue;; esac
_debug "_check_item_of_cancellation:$one"
_log "_check_item_of_cancellation:$one"
echo "$ITEMS" | grep -q -i "${one} of cancellation" && { ITEM_OF_XXX="${one} of cancellation"; break; }
sleep 0.1

done <<EoI
heavy rod
rod
#scroll
staff
wand
EoI

unset one
_draw 4 "You have '$ITEM_OF_XXX'"
test "$ITEM_OF_XXX"
}

unset ITEM_OF_XXX
if _check_item_of_xxx "of cancellation" ;then
 __check_if_item_is_active "$ITEM_OF_XXX"
else
 [ "$NOCHECK" ] || _exit 1 "Found no item of cancellation in inventory."
fi


_simple_apply_item_of_xxx(){
_debug "_simple_apply_item_of_xxx:$*"
local RV=1
local item OF_XXX
unset item OF_XXX
test "$*" || { _draw 3 "_simple_apply_item_of_xxx:Missing argument."; return 3; }
OF_XXX="$*"

set - "heavy rod" rod staff wand
for item in "$@"; do
 _is 1 1 apply -u $item $OF_XXX
 sleep 1
 _is 1 1 apply -a $item $OF_XXX
 sleep 1
 __check_if_item_is_active "$item $OF_XXX" && { ITEM_OF_XXX="$item $OF_XXX"; RV=0; break; }
done

return ${RV:-4}
}

_simple_apply_item_of_cancellation(){
_debug "_simple_apply_item_of_cancellation:$*"
local RV=1
if test "$*"; then
 echo "issue 1 1 apply -u $*"
 sleep 1
 echo "issue 1 1 apply -a $*"
 sleep 1
 __check_if_item_is_active "$*" && { ITEM_OF_XXX="$*"; RV=0; }
else
set - "heavy rod" rod staff wand
 for item in "$@"; do
 _is 1 1 apply -u $item of cancellation
 sleep 1
 _is 1 1 apply -a $item of cancellation
 sleep 1
 __check_if_item_is_active "$item of cancellation" && { ITEM_OF_XXX="$item of cancellation"; RV=0; break; }
 done
fi
return ${RV:-3}
}

#test "$HAVE_ITEM_APPLIED" || _simple_apply_item_of_cancellation "$ITEM_OF_XXX"
test "$HAVE_ITEM_APPLIED" || _simple_apply_item_of_xxx "of cancellation"

__check_range_attack(){

_debug "__check_range_attack:$*"
local ITEM="$*" oR tmpR c
test "$ITEM" || { _draw 3 "__check_range_attack:ITEM missing"; return 3; }

while :; do
 unset LEFTOVER; sleep 0.1;
 read -t 1 LEFTOVER
 _debug "LEFTOVER=$LEFTOVER"
 case $LEFTOVER in '') break;;
 esac
done

c=0
#echo watch $DRAWINFO
while :;
do
test $c = 55 && break

sleep 0.1
echo request range
 while :;
 do
 read -t 1 tmpR
 _log "__check_range_attack:$tmpR"
 _debug "__check_range_attack:$tmpR"
 case $tmpR in
 *"$ITEM"*) RANGE_ITEM_APPLIED=YES; break 2;;
 '') break;;
 esac
 test "$oR" = "$tmpR" && break
 oR="$tmpR"

 done
c=$((c+1))
sleep 0.1
test "$RANGE_ITEM_APPLIED" || _is 1 1 rotateshoottype
done

#echo unwatch $DRAWINFO
test "$RANGE_ITEM_APPLIED"
}

__check_range_attack "$ITEM_OF_XXX"
if test $? = 0; then
#if test "$RANGE_ITEM_APPLIED"; then

c=0
while :;
do

_is 1 1 fire center
sleep $RECHARGE_TIME

c=$((c+1))
test "$c" = "$NUMBER" && break
done


else
_draw 3 "'$ITEM_OF_XXX' not applied."
fi

_is 1 1 fire_stop

# *** Here ends program *** #
#echo draw 2 "$0 is finished."
_say_end_msg
