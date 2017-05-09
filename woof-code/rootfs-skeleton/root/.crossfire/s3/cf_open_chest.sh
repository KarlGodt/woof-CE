#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`/bin/date +%s`

MAX_SEARCH=9  # needs to set, to prevent infinite search for traps if no NUMBER given

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to open chests."
_draw 5 "Syntax:"
_draw 5 "script $0 [number]"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times search, disarm, apply and get."
_draw 4 "Options:"
_draw 4 "-f force running even if bad traps triggered."
_draw 5 "-d set debug"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 5 "-v set verbosity"

        exit 0
}


_say_start_msg "$*"

# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
           _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
           readonly NUMBER
           _debug "NUMBER=$NUMBER"
           ;;
*help|*usage)  _usage;;

--*) case $PARAM_1 in
     *debug) DEBUG=$((DEBUG+1));;
     *force) FORCE=$((FORCE+1));;
     *help)  _usage;;
     *logging) LOGGING=$((LOGGING+1));;
     *verbose) VERBOSE=$((VERBOSE+1));;
     *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
;;

-*) OPTS=`printf '%s' $PARAM_1 | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      d) DEBUG=$((DEBUG+1));;
      f) FORCE=$((FORCE+1));;
      h) _usage;;
      L) LOGGING=$((LOGGING+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
   done
;;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

sleep 1
shift
done

# TODO : check if available space to walk in DIRB

# ** set pickup  0 and drop chests


_is 0 0 pickup 0
sleep 1

_is 0 0 drop chest
sleep 1

_is 1 1 $DIRB
sleep 1

_is 1 1 $DIRF
sleep 1

# TODO : check if on chest


# *** MAIN *** #
TIMEB=`/bin/date +%s`

_find_traps_single $NUMBER
case $? in 112) :;;
*)    _open_chest;;
esac


# *** Here ends program *** #
_say_end_msg
