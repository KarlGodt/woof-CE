#!/bin/bash

VERSION=0.0
VERSION=1.0 # posted on forum.metalforge.net
VERSION=2.0 # 2018-01-10 code overhaul now using functions, posted on wiki.cross-fire.org
VERSION=2.1 # 2018-02-17 more code overhauling
Version=2.2 # 2018-04-16 code overhaul

MARK_ITEM='icecube'      # item to mark in function   _mark_item()
ITEM='flint and steel'   # item to apply in function  _apply_item()

DEBUG=''   #1   # empty string or anything
MSGLEVEL=6 #7   # 0 - 7
LOGGING='' #1   # empty string or anything

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
MY_DIR=${MY_SELF%/*}

test -f "$MY_DIR"/cf_funcs_common.sh && . "$MY_DIR"/cf_funcs_common.sh
_set_global_variables "$@"

cd "$MY_DIR"

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "$MY_DIR"/"${MY_BASE}".conf && . "$MY_DIR"/"${MY_BASE}".conf

unset DIRB DIRF  # for _exit()

# functions:

_say_help(){
_draw 2 "$MY_BASE"
_draw 2 "Script to melt icecubes in inventory."
_draw 4  "To be used in the crossfire roleplaying game client."
_draw 2 "Syntax:"
_draw 2 "script $MY_SELF <<number>>"
_draw 2 "For example: 'script $MY_SELF 5'"
_draw 2 "will issue mark icecube and apply flint and steel"
_draw 2 " until 5 icecubes have been melt."
        exit 0
}

_mark_item(){
    # returns not 0, if message says
    # no match
_debug "_mark_item:$*"
_log   "_mark_item:$*"

local lITEM=${*:-"$MARK_ITEM"}

lITEM=${lITEM:-"$ITEM"}
lITEM=${lITEM:-icecube}

test "$lITEM" || return 254

local lRV=0

_is 1 1 mark "$lITEM"

 while :; do
  unset REPLY
 read -t $TMOUT
  _log "_mark_item:$REPLY"
  _debug "$REPLY"
 case $REPLY in
  *Could*not*find*an*object*that*matches*) lRV=1;break 1;;
  *scripttell*break*) break ${REPLY##*?break};;
  *scripttell*exit*)  _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  '') break;;
 esac
 sleep 0.1
 done

return ${lRV:-0}
}

_apply_item(){
    # returns 0 on success,
    # -gt 0 otherwise

_debug "_apply_item:$*"
_log   "_apply_item:$*"

local lITEM=${*:-"$ITEM"}

lITEM=${lITEM:-"flint and steel"}

test "$lITEM" || return 254

local lRV=0

_is 1 1 apply "$lITEM"

 while :; do
  unset REPLY
 read -t $TMOUT
  _log "_apply_item:$REPLY"
  _debug "$REPLY"
 case $REPLY in
  *You*light*the*icecube*with*the*flint*and*steel.*) lRV=0; SUCC=$((SUCC+1)); break 1;;
  *fail*used*up*flint*and*steel*)                    lRV=5; break 1;;
  *fail*)                                            lRV=1; FAIL=$((FAIL+1)); break 1;;
  *Could*not*find*any*match*to*the*flint*and*steel*) lRV=6; break 1;;
  *You*need*to*mark*a*lightable*object.*)            lRV=7; break 1;;

  *scripttell*break*) break ${REPLY##*?break};;
  *scripttell*exit*)  _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;

  '')     lRV=1; break 1;;
  *) :;;
 esac
 sleep 0.1
 done

return ${lRV:-0}
}

_say_count(){
case $SUCC in [0-9]*) _draw 7 "You had melt $SUCC icecube(s).";; esac
case $FAIL in [0-9]*) _draw 4 "You tried $FAIL time(s) with failure.";; esac
}

# *** Here begins program *** #

# *** Check for parameters *** #

while [ "$1" ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"*) _say_help;;
-d) DEBUG=$((DEBUG+1));;
-L) LOGGING=$((LOGGING+1));;
-V) _say_version;;
*) # *** testing parameters for validity *** #
   PARAM_1test="${PARAM_1//[[:digit:]]/}"
   test "$PARAM_1test" && _exit 1 "Only :digit: numbers as first option allowed."
   #exit if other input than letters
NUMBER=$PARAM_1
;;
esac

shift
sleep 0.1
done

# Prerequsites: DRAWINFO variable,
# prevent multiple scripts running,
# set sleep values according to player speed
_say_start_msg "$@"

# *** Getting Player's Speed *** #
_get_player_speed
#_set_sync_sleep ${PL_SPEED1:-$PL_SPEED}
test "$PL_SPEED1" && __set_sync_sleep ${PL_SPEED1} || _set_sync_sleep "$PL_SPEED"

test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution
_debug "NUMBER='$NUMBER'"

SUCC=0  # count the successful attempts
FAIL=0  # count the failure attempts
# *** Actual script to melt icecubes multiple times *** #

# MAIN
_watch $DRAWINFO

unset one
while :
do
one=$((one+1))

_mark_item icecube || break 2

_sleep

 while :;
 do

 _apply_item "flint and steel"
 case $? in
 0) break 1;; #success
 1) :;;       #try again
 2) :;;       #unused
 3) :;;       #unused
 4) :;;       #unused
 5)           #used up
    _warn "Your flint and steel is used up.";
    break 2;;
 6) break 2;; #no item
 7) break 1;; #not marked
 8) :;;       #unused
 9) :;;       #unused
 esac

 #_say_count
 _sleep

 done

case $NUMBER in $one) break 1;; esac

_say_count
done #main while loop


# *** Here ends program *** #
_say_count
_say_end_msg
###END###
