#!/bin/ash

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

ITEM_CANCEL="rod of cancellation"
LOG_REPLY_FILE=/tmp/cf_cancel_me.rpl #unused

# beeping
BEEP_DO=1
BEEP_LENGTH=500
BEEP_FREQ=700

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}

_draw(){
    local COLOUR="$1"
    COLOUR=${COLOUR:-1} #set default
    shift
    local MSG="$@"
    echo draw $COLOUR "$MSG"
}

_log(){ #unused
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_REPLY_FILE"
   echo "$*" >>"$lFILE"
}

_debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$@"
}

_is(){
    _verbose "$*"
    echo issue "$@"
    sleep 0.2
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_usage(){
_draw 5 "Script to"
_draw 5 "apply ITEM_CANCEL"
_draw 5 "and run fire center"
_draw 5 "ITEM_CANCEL set to '$ITEM_CANCEL'"
_draw 6 "Syntax:"
_draw 6 "script $0 <<NUMBER>>"
_draw 6 "where NUMBER is the desired amount of cancellings."
_draw 2 "Whithout NUMBER loops forever, scriptkill to abort."
_draw 4 "Options:"
_draw 4 "-H to use heavy rod of cancellation"
_draw 5 "-d  to turn on debugging."
#_draw 5 "-L  to log to $LOG_REPLY_FILE ."
_draw 5 "-v to say what is being issued to server."
        exit 0
}

# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #
#test "$*" || {
#_draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"|*usage) _usage;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-H|*heavy)   ITEM_CANCEL="heavy rod of cancellation";;
#-L|*log*)   LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

'') :;;

[0-9]*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
_draw 3 "Only integer :digit: numbers as number option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;

*) _draw 3 "Ignoring unhandled parameter '$PARAM_1'";;

esac
shift
sleep 0.1
done

#} || {
#_draw 3 "Script needs number of cancellation attempts as argument."
#        exit 1
#}


# TODO : Check if +items applied and or in inventory.


# *** Actual script to pray multiple times *** #
#test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

_apply_item_cancellation(){
test "$ITEM_CANCEL" || { _draw 3 "ERROR: ITEM_CANCEL not set."; return 3; }

_is " 1 1 apply -u $ITEM_CANCEL"
sleep 1
_is " 1 1 apply -a $ITEM_CANCEL"
}

_cancellation_loop(){
TIMEB=`/bin/date +%s`
while :
do

_is " 1 1 fire center"
sleep 0.1s
_is " 1 1 fire_stop"
sleep 1s

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
}

#TIMEB=`/bin/date +%s`
_apply_item_cancellation && _cancellation_loop

_is " 1 1 fire_stop"

# *** Here ends program *** #
_draw 2 "$0 is finished."
_beep
