#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`/bin/date +%s`

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
_draw 2 "script $MY_SELF <<NUMBER>>"
_draw 2 "where NUMBER is the desired amount of firings"
_draw 2 "Whithout NUMBER loops forever, scriptkill to abort."
_draw 5 "Options:"
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."
#_draw 4 "-n  do not check inventory."
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
case "$PARAM_1" in
-h|*"help"*|*usage) _usage;;
-d|*debug)      DEBUG=$((DEBUG+1));;
-L|*logging)  LOGGING=$((LOGGING+1));;
#-n|*no-check) NOCHECK=$((NOCHECK+1));;
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

#test "$NUMBER" || {
#_draw 3 "Script needs number of cancellation attempts as argument."
#        exit 1
#}


# *** Actual script to cancel multiple times *** #
#test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution



__check_if_item_is_active(){

local ITEM="$*" oR tmpR
test "$ITEM" || { _draw 3 "__check_if_item_is_active:ITEM missing"; exit 1; }

test "$HAVE_ITEM_APPLIED" && return 0


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

__check_range_attack(){

_debug "__check_range_attack:$*"
local oR tmpR c
local ITEM="$*"
test "$ITEM" || { _draw 3 "__check_range_attack:ITEM missing"; return 3; }

while :; do
 unset LEFTOVER; sleep 0.1;
 read -t 1 LEFTOVER
 _debug "LEFTOVER=$LEFTOVER"
 case $LEFTOVER in '') break;;
 esac
done

c=0

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

test "$RANGE_ITEM_APPLIED"
}

unset ITEM_OF_XXX
test "$HAVE_ITEM_APPLIED" || _simple_apply_item_of_xxx "of cancellation"

__check_range_attack "$ITEM_OF_XXX"
if test $? = 0; then

TIMEB=`/bin/date +%s`

c=0
while :;
do

_is 1 1 fire center
sleep $RECHARGE_TIME

c=$((c+1))
 if test "$NUMBER"; then
  test "$c" = "$NUMBER" && break
 else
  test "$c" = 9 && {
  _draw 3 "Infinite loop - Use scriptkill to abort."
  _draw 3 "Do not forget to type fire_stop !!!"
  c=0; }
 fi

done


else
_draw 3 "'$ITEM_OF_XXX' not applied."
fi

_is 1 1 fire_stop

# *** Here ends program *** #
#echo draw 2 "$0 is finished."
_say_end_msg
