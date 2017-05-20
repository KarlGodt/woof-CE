#!/bin/ash

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #
#[ "$*" ] && {

until [ $# = 0 ]; do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1"
in -h|*"help"|*usage)

echo draw 5 "Script to"
echo draw 5 "apply rod of cancellation"
echo draw 5 "and run fire center."
echo draw 4 "Syntax:"
echo draw 7 "$0 <<NUMBER>>"
echo draw 4 "where optional NUMBER would be"
echo draw 4 "the count of firings."
echo draw 2 "Without <NUMBER> loops forever."
echo draw 2 "Use scriptkill"
echo draw 2 "Use fire_stop"
echo draw 5 "to stop script."

        exit 0
;;

[0-9]*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as optional option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;

*) echo draw 3 "Ignoring unhandled option '$PARAM_1'";;

esac
sleep 0.1
shift
done

#} || {
#echo draw 3 "Script needs number of cancellation attempts as argument."
#        exit 1
#}

#test "$1" || {
#echo draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}


# *** Actual script to pray multiple times *** #
#test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution

echo "issue 1 1 apply -u rod of cancellation"

echo "issue 1 1 apply -a rod of cancellation"

c_loop(){
#for c in `seq 1 1 $NUMBER`
local c=0
while :;
do

echo "issue 1 1 fire center"
sleep 1s

c=$((c+1))
test "$c" = "$NUMBER" && break
done
}
c_loop

#echo "issue $NUMBER 1 fire center"

echo "issue 1 1 fire_stop"

# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700
