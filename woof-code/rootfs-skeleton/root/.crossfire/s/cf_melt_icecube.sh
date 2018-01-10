#!/bin/ash


export PATH=/bin:/usr/bin
MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
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

echo draw 5 "Script to melt icecube."
echo draw 5 "Syntax:"
echo draw 5 "script $0 [number]"
echo draw 5 "For example: 'script $0 5'"
echo draw 5 "will issue 5 times mark icecube and apply filint and steel."

        exit 0
;;
*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
echo draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input than letters
        }

NUMBER=$PARAM_1
;;
esac

shift
sleep 0.1
done


__just_exit(){
echo draw 3 "Exiting $0."
echo unwatch
#echo unwatch drawinfo
exit $1
}

# *** Getting Player's Speed *** #
_get_player_speed

# *** Actual script to pray multiple times *** #
test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

_debug "NUMBER='$NUMBER'"
_watch

    if test "$NUMBER"; then

for one in `seq 1 1 $NUMBER`
do

REPLY=
OLD_REPLY=

echo "issue 1 1 mark icecube"

 while [ 1 ]; do
 read -t $TMOUT REPLY
 _log "$REPLY"
 case $REPLY in
 *Could*not*find*an*object*that*matches*) _just_exit 1;;
 '') break;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

NO_FAIL=
until [ "$NO_FAIL" ]
do

REPLY=
OLD_REPLY=

echo "issue 1 1 apply flint and steel"

 while [ 1 ]; do
 read -t $TMOUT REPLY
 _log "$REPLY"
 case $REPLY in
 *used*up*flint*and*steel*) _exit 2;;
 *Could*not*find*any*match*to*the*flint*and*steel*) _just_exit 2;;
 *You*need*to*mark*a*lightable*object.*) NO_FAIL=1;break 1;;
 '') break;;
 *fail*) :;;
 *) NO_FAIL=1; break 1;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

done #NO_FAIL

done #NUMBER

    else #PARAM_1

until [ "$NO_ICECUBE" ];
do

REPLY=
OLD_REPLY=

echo "issue 1 1 mark icecube"
while [ 1 ]; do
 read -t $TMOUT
 _log "$REPLY"
 case $REPLY in
 *Could*not*find*an*object*that*matches*) _just_exit 1;;
 '') break;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

NO_FAIL=
until [ "$NO_FAIL" ]
do


REPLY=
OLD_REPLY=

echo "issue 1 1 apply flint and steel"
 while [ 1 ]; do
 read -t $TMOUT
 _log "$REPLY"
 case $REPLY in
 *used*up*flint*and*steel*) _just_exit 2;;
 *Could*not*find*any*match*to*the*flint*and*steel*) _exit 2;;
 *You*need*to*mark*a*lightable*object.*) NO_FAIL=1; break 1;;
 '') break;;
 *fail*) :;;
 *) NO_FAIL=1; break 1;;
 esac
 unset REPLY
 sleep 0.1s
 done

sleep 1s

done #NO_FAIL

done #NO_ICECUBE

    fi #^!PARAM_1


# *** Here ends program *** #
#echo draw 2 "$0 is finished."
_say_end_msg
