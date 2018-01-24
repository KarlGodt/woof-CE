#!/bin/bash

# 2018-01-10 : Code overhaul,
# made duplicate code in functions.

export PATH=/bin:/usr/bin

MARK_ITEM='icecube'
ITEM='flint and steel'

DEBUG=1
MSGLEVEL=7

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_common.sh && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables "$@"

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #

while [ "$1" ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*)

_draw 5 "$MY_BASE"
_draw 5 "Script to melt icecubes in inventory."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 5 "Syntax:"
_draw 5 "script $0 <<number>>"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times mark icecube and apply flint and steel."
        exit 0
;;
-d) DEBUG=$((DEBUG+1));;
-V) _say_version;;
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

# functions:
_mark_item(){
_debug "_mark_item:$*"
local lITEM=${*:-"$MARK_ITEM"}
lITEM=${lITEM:-"$ITEM"}
lITEM=${lITEM:-icecube}
test "$lITEM" || return 254

local lRV=0

_is 1 1 mark "$lITEM"

 while [ 1 ]; do
 unset REPLY
 read -t $TMOUT
 _log "_mark_item:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *Could*not*find*an*object*that*matches*) lRV=1;break 1;;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit 1;;
 '') break;;
 esac
 #unset REPLY
 sleep 0.1s
 done

return ${lRV:-0}
}

_apply_item(){
_debug "_apply_item:$*"
local lITEM=${*:-"$ITEM"}
lITEM=${lITEM:-"flint and steel"}
test "$lITEM" || return 254

local lRV=0
_is 1 1 apply "$lITEM"

 while [ 1 ]; do
 unset REPLY
 read -t $TMOUT
 _log "_apply_item:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *used*up*flint*and*steel*) lRV=5; break 1;;
 *Could*not*find*any*match*to*the*flint*and*steel*) lRV=6; break 1;;
 *You*need*to*mark*a*lightable*object.*) NO_FAIL=1; lRV=7; break 1;;
 '')     lRV=1; break 1;;
 *fail*) lRV=1; FAIL=$((FAIL+1)); break 1;;
 *You*light*the*icecube*with*the*flint*and*steel.*) lRV=0; SUCC=$((SUCC+1)); break 1;;
 *scripttell*break*) break ${REPLY##*?break};;
 *scripttell*exit*)  _exit 1;;
 *) :;;
 esac
 #unset REPLY
 sleep 0.1s
 done

return ${lRV:-0}
}

_say_count(){
case $SUCC in [0-9]*) _draw 7 "You had smolten $SUCC icecube(s).";; esac
case $FAIL in [0-9]*) _draw 4 "You tried $FAIL time(s) and failed.";; esac
}

# *** Getting Player's Speed *** #
_get_player_speed
#_set_sync_sleep ${PL_SPEED1:-$PL_SPEED}
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"

# *** Actual script to pray multiple times *** #
# MAIN

SUCC=0  # count the successful attempts
FAIL=0  # count the failure attempts
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

_debug "NUMBER='$NUMBER'"
_watch

unset one
while :
do
one=$((one+1))

_mark_item icecube || break 2

_sleep

 NO_FAIL=
 until [ "$NO_FAIL" ]
 do

 _apply_item "flint and steel"
 case $? in
 0) break 1;; #success
 1) :;;       #try again
 2) :;;       #unused
 3) :;;       #unused
 4) :;;       #unused
 5) break 2;; #used up
 6) break 2;; #no item
 7) break 1;; #not marked
 8) :;;       #unused
 9) :;;       #unused
 esac

 _say_count
 _sleep

 done #NO_FAIL

#test "$NUMBER" && { test "$NUMBER" = "$cnt" && break 1; }
case $NUMBER in $one) break 1;; esac

done #main while loop


# *** Here ends program *** #
_say_count
_say_end_msg
###END###
