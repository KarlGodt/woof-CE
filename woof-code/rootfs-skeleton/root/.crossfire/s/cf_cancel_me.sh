#!/bin/ash

exec 2>/tmp/cf_errs.txt

_usage(){
echo draw 5 "Script to"
echo draw 5 "apply rod of cancellation"
echo draw 5 "and run fire center"
echo draw 6 "Syntax:"
echo draw 6 "script $0 <NUMBER>"
echo draw 6 "where NUMBER is the desired amount of cancellations"
        exit 0
}

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
#[ "$*" ] && {
until [ $# = 0 ];
do
sleep 0.1
PARAM_1="$1"
shift

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"|*usage) _usage;;

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

done

#} || {
#echo draw 3 "Script needs number of cancellation attempts as argument."
#        exit 1
#}
#
#test "$1" || {
#echo draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}


# *** Actual script to pray multiple times *** #
test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

echo "issue 1 1 apply -u rod of cancellation"
sleep 1
echo "issue 1 1 apply -a rod of cancellation"

c_loop(){
for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 fire center"
sleep 1s

done
}
c_loop

#echo "issue $NUMBER 1 fire center"

echo "issue 1 1 fire_stop"

# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700
