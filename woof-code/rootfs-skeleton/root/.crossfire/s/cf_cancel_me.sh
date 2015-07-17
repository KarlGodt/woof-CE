#!/bin/bash

# *** Here begins program *** #
echo draw 2 "$0 is started.."

ROD='heavy rod of cancellation'

# *** Check for parameters *** #
[ "$*" ] && {
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to "
echo draw 5 "apply $ROD"
echo draw 5 "and then to fire center on oneself."

        exit 0
        }

# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1

} || {
echo draw 3 "Script needs number of cancellation attempts as argument."
        exit 1
}

test "$1" || {
echo draw 3 "Need <number> ie: script $0 50 ."
        exit 1
}


# *** Actual script to cancel multiple times *** #
test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution

echo "issue 1 1 apply $ROD"

for one in `seq 1 1 $NUMBER`
do

echo "issue 1 1 fire center"
sleep 1s

done

echo "issue 1 1 fire_stop"

# *** Here ends program *** #
echo draw 2 "$0 is finished."
