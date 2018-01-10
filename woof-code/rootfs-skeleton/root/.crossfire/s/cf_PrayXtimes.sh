#!/bin/ash

# 2018-01-10 : Code overhaul.
# No real changes,
# except to support infinte looping.

export PATH=/bin:/usr/bin


# Global variables

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables $*
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #
#test "$1" || {
#_draw 3 "Script needs number of praying attempts as argument."
#        exit 1
#_draw 3 "Need <number> ie: script $0 50 ."
#        exit 1
#}

while [ "$1" ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help"*)

_draw 5 "Script to pray given number times."
_draw 2 "Syntax:"
_draw 2 "script $0 <number>"
_draw 5 "For example: 'script $0 50'"
_draw 5 "will issue 50 times the use_skill praying command."
_draw 2 "Without <number> will loop forever,"
_draw 2 "use scriptkill to terminate."
        exit 0;;
*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1;;

esac

shift
sleep 0.1
done

__get_player_speed(){

_empty_message_stream

echo request stat cmbt
#read REQ_CMBT
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n", cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read -t 1 Req Stat Cmbt WC AC DAM SPEED W_SPEED
_msg 7 "wc=$WC:ac=$AC:dam=$DAM:speed=$SPEED:weaponspeed=$W_SPEED"
case $SPEED in
1[0-9][0-9][0-9][0-9]) USLEEP=1500000;;
2[0-9][0-9][0-9][0-9]) USLEEP=1400000;;
3[0-9][0-9][0-9][0-9]) USLEEP=1300000;;
4[0-9][0-9][0-9][0-9]) USLEEP=1200000;;
5[0-9][0-9][0-9][0-9]) USLEEP=1100000;;
6[0-9][0-9][0-9][0-9]) USLEEP=1000000;;
7[0-9][0-9][0-9][0-9]) USLEEP=900000;;
8[0-9][0-9][0-9][0-9]) USLEEP=800000;;
9[0-9][0-9][0-9][0-9]) USLEEP=700000;;
*) USLEEP=600000;;
esac
_msg 7 "USLEEP=$USLEEP:SPEED=$SPEED"

USLEEP=$(( USLEEP - ( (SPEED/10000) * 1000 ) ))
_msg 6 "Sleeping $USLEEP usleep micro-seconds between praying"
}
__get_player_speed


# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

c=0; one=0
while :
do
one=$((one+1))

_is 1 1 "use_skill" "praying"
usleep $USLEEP

_check_food_level
_check_hp_and_return_home $HP

c=$((c+1))
test $c -ge $COUNT_CHECK_FOOD && {
c=0
case $NUMBER in
'') _draw 5 "$one praying attempts done.";;
*)  _draw 5 "$((NUMBER-one)) prayings left.";;
esac
}

#test "$NUMBER" && { test "$NUMBER" = "$one" && break 1; }
 case $NUMBER in $one) break 1;; esac
done

# *** Here ends program *** #
_say_end_msg
###END###
