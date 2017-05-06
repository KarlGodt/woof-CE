#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

MAX_SEARCH=9
MAX_DISARM=9
MAX_LOCKPICK=9

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

_draw 5 "Script to lockpick doors."
_draw 2 "Syntax:"
_draw 2 "script $0 {number} <direction>"
_draw 5 "For example: 'script $0 5 west'"
_draw 5 "will issue 5 times search, disarm and"
_draw 5 "ready_skill lockpicking in west."
_draw 4 "Options:"
#_draw 4 "-c cast detect curse to turn to DIR"
#_draw 4 "-C cast constitution"
#_draw 4 "-t cast disarm"
#_draw 4 "-D cast dexterity"
#_draw 4 "-e cast detect evil"
#_draw 4 "-f cast faery fire"
#_draw 4 "-i cast show invisible"
#_draw 4 "-m cast detect magic"
#_draw 4 "-M cast detect monster"
#_draw 4 "-p cast probe"
_draw 5 "-d set debug"
_draw 5 "-L log to $LOGFILE"
_draw 5 "-v set verbosity"

        exit 0
}


_say_start_msg "$*"

# *** Check for parameters *** #

# If there is only one parameter and it is a number
# assume it means direction
if test $# = 1; then

PARAM_1="$1"
_word_to_number "$PARAM_1"

case $PARAM_1 in [0-8])
 _number_to_direction "$PARAM_1"
 shift;;
esac

fi


until test $# = 0;
do

PARAM_1="$1"
_debug "PARAM_1=$PARAM_1 #=$#"
sleep 0.1
shift

case $PARAM_1 in
[0-9]*)

  __direction_first__(){
  # Check if more numbers to come and if so,
  # assume direction
  unset p FOUND_DIR
  for p in "$@"; do
   case $p in [0-9]*)
    _number_to_direction $PARAM_1 && FOUND_DIR=1;;
   esac
  done

  if test "$FOUND_DIR"; then :
  elif test "$DIR"; then
        NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
           _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
        readonly NUMBER
  fi
  }

  # Check if more numbers to come and if so,
  # assume find traps, since the direction towards
  # doors changes more often
  if test "$NUMBER" -a "$DIR"; then
   _draw 3 "NUMBER and DIR are set, ignoring '$PARAM_1'"
  elif test "$NUMBER"; then
   _number_to_direction $PARAM_1 # 00_cf_*.sh, generates global readonly DIR DIRN
  else
   NUMBER=$PARAM_1
   test "${NUMBER//[0-9]/}" && {
    _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
    readonly NUMBER
  fi

;;

 1|n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
2|ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 3|e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
4|se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 5|s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
6|sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 7|w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
8|nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;

-h|*help|*usage)  _usage;;

--*) case $PARAM_1 in

#-c|*curse)   TURN_SPELL="detect curse";;
#-C|*const*)  TURN_SPELL="constitution";;
#-t|*disarm)  TURN_SPELL="disarm";;
#-D|*dex*)    TURN_SPELL="dexterity";;
#-e|*evil)    TURN_SPELL="detect evil";;
#-f|*faery)   TURN_SPELL="faery fire";;
#-i|*invis*)  TURN_SPELL="show invisible";;
#-m|*magic)   TURN_SPELL="detect magic";;
#-M|*monster) TURN_SPELL="detect monster";;
#-p|*probe)   TURN_SPELL="probe";;
-h|*help|*usage)       _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
*)  _draw 3 "Ignoring unhandled option '$PARAM_1'";;
esac
;;

-*) OPTS=`printf '%s' $PARAM_1 | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
     #c)  TURN_SPELL="detect curse";;
     #C)  TURN_SPELL="constitution";;
     #t)  TURN_SPELL="disarm";;
     #D)  TURN_SPELL="dexterity";;
     #e)  TURN_SPELL="detect evil";;
     #f)  TURN_SPELL="faery fire";;
     #i)  TURN_SPELL="show invisible";;
     #m)  TURN_SPELL="detect magic";;
     #M)  TURN_SPELL="detect monster";;
     #p)  TURN_SPELL="probe";;
     h)  _usage;;
     d)  DEBUG=$((DEBUG+1));;
     L)  LOGGING=$((LOGGING+1));;
     v)  VERBOSE=$((VERBOSE+1));;
     *)  _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

'')     :;;
*)      _draw 3 "Ignoring incorrect parameter '$PARAM_1' .";;
esac

done

_debug "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'"

# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 _draw 3 "Need direction as parameter."
 exit 1
fi



#_turn_direction_using_spell
#$CAST_DEX

# *** MAIN *** #
TIMEB=`date +%s`

_find_traps_bulk_ready_skill
_disarm_traps_bulk_ready_skill
_lockpick_door_ready_skill


# *** Here ends program *** #
_say_end_msg
