#!/bin/ash

TIMEA=`date +%s`

_usage(){
echo draw 5 "Script to"
echo draw 5 "apply rod of cancellation"
echo draw 5 "and run fire center"
echo draw 6 "Syntax:"
echo draw 6 "script $0 <NUMBER>"
echo draw 6 "where NUMBER is the desired amount of cancellings"
echo draw 4 "Options:"
echo draw 4 "-H to use heavy rod of cancellation"
#echo draw 5 "-d  to turn on debugging."
#echo draw 5 "-L  to log to $LOG_REPLY_FILE ."
#echo draw 5 "-v to say what is being issued to server."
        exit 0
}

# *** Here begins program *** #
echo draw 2 "$0 is started.."

ITEM_CANCEL="rod of cancellation"
#LOG_REPLY_FILE=/tmp/cf_cancel_me.rpl

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

# *** Check for parameters *** #
test "$*" || {
echo draw 3 "Need <number> ie: script $0 50 ."
        exit 1
}

until test "$#" = 0
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"|*usage) _usage;;

#-d|*debug)     DEBUG=$((DEBUG+1));;
-H|*heavy)   ITEM_CANCEL="heavy rod of cancellation";;
#-L|*logging) LOGGING=$((LOGGING+1));;
#-v|*verbose) VERBOSE=$((VERBOSE+1));;

'') :;;

[0-9]*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
echo draw 3 "Only integer :digit: numbers as number option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;

*) echo draw 3 "Ignoring unhandled parameter '$PARAM_1'";;

esac
shift
sleep 0.1
done

#} || {
#echo draw 3 "Script needs number of cancellation attempts as argument."
#        exit 1
#}


# TODO : Check if +items applied and or in inventory.


# *** Actual script to pray multiple times *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

echo "issue 1 1 apply -u rod of cancellation"
sleep 1
echo "issue 1 1 apply -a $ITEM_CANCEL"

c_loop(){
for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 fire center"
sleep 0.1s
echo "issue 1 1 fire_stop"
sleep 1s

done
}
c_loop

#echo "issue $NUMBER 1 fire center"

echo "issue 1 1 fire_stop"

# *** Here ends program *** #
echo draw 2 "$0 is finished."
_beep
