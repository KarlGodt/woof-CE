#!/bin/bash

# 2018-01-10 : Code overhaul.
# No real changes,
# except to support infinte looping.

export PATH=/bin:/usr/bin
export LC_NUMERIC=de_DE
export LC_ALL=de_DE

VERSION=0.0 # initial version
VERSION=1.0 # set a sleep value between use_skill praying
# to sync the messages 5 times You pray in the msgpane
VERSION=2.0 # refine the setting of sleep values
VERSION=3.0 # add a check for food level and to eat
VERSION=3.1 # recognize -V and -d options

# Global variables

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables $*

test -f "${MY_SELF%/*}"/cf_funcs_common.sh && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables $*

test -f "${MY_SELF%/*}"/cf_funcs_food.sh   && . "${MY_SELF%/*}"/cf_funcs_food.sh

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
-d) DEBUG=$((DEBUG+1));;
-V) _say_version;;
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

# *** functions *** #
_usleep(){
usleep ${USLEEP:-1000000}
}

_get_multiplicator(){
local lPL_SPEED=${1:-$PL_SPEED}
test "$lPL_SPEED" || { MUL=10; return 254; }

   case $lPL_SPEED in
   1[0-4]*) MUL=18;;
   1[5-9]*) MUL=17;;
   2[0-4]*) MUL=16;;
   2[5-9]*) MUL=15;;
   3[0-4]*) MUL=14;;
   3[5-9]*) MUL=13;;
   4[0-4]*) MUL=12;;
   4[5-9]*) MUL=11;;
   5[0-4]*) MUL=10;;
   5[5-9]*) MUL=9;;
   6[0-4]*) MUL=8;;
   6[5-9]*) MUL=7;;
   7[0-4]*) MUL=6;;
   7[5-9]*) MUL=5;;
   8[0-4]*) MUL=4;;
   8[5-9]*) MUL=3;;
   9[0-4]*) MUL=2;;
   9[5-9]*) MUL=1;;
   esac
}

__get_player_speed_and_set_usleep(){

_empty_message_stream

echo request stat cmbt
#read REQ_CMBT
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n",
# cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read -t 1 Req Stat Cmbt WC AC DAM PL_SPEED W_SPEED
_msg 7 "wc=$WC:ac=$AC:dam=$DAM:speed=$PL_SPEED:weaponspeed=$W_SPEED"

case ${#PL_SPEED} in
1) MAL=1000000000;;
2) MAL=100000000;;
3) MAL=10000000;;
4) MAL=1000000;;
5) MAL=100000;;   #0.xx
6) MAL=10000;;    #1.xx
7) MAL=1000;;    #10.xx
8) MAL=100;;    #100.xx
*) :;;
esac

_get_multiplicator ${PL_SPEED:-50000}
USLEEP=$(( MAL * MUL ))
_msg 7 "USLEEP=$USLEEP:PL_SPEED=$PL_SPEED"

USLEEP=$(( USLEEP - ( (PL_SPEED/10000) * 1000 ) ))
_msg 6 "Sleeping $USLEEP usleep micro-seconds between praying"
}

_get_player_speed_and_set_usleep(){

_empty_message_stream

echo request stat cmbt
read -t 1 Req Stat Cmbt WC AC DAM PL_SPEED W_SPEED
_msg 7 "wc=$WC:ac=$AC:dam=$DAM:speed=$PL_SPEED:weaponspeed=$W_SPEED"

#06:29 DEBUG:wc=-33:ac=-16:dam=1:speed=34588:weaponspeed=9526
#06:29 DEBUG:VAL1=0.289118
#06:29 DEBUG:VAL2=0.167178
#06:29 DEBUG:SLEEP=1.44559
#06:29 DEBUG:VAL3=8.64701
#06:29 DEBUG:SLEEP=2.08973:PL_SPEED=34588
#06:29 INFO:Sleeping 2.08973 sleep seconds between praying

#06:31 DEBUG:wc=-33:ac=-16:dam=1:speed=50860:weaponspeed=13723
#06:31 DEBUG:VAL1=0.196618
#06:31 DEBUG:VAL2=0.0773173
#06:31 DEBUG:SLEEP=0.983091
#06:31 DEBUG:VAL3=12.715
#06:31 DEBUG:SLEEP=0.966466:PL_SPEED=50860
#06:31 INFO:Sleeping 0.966466 sleep seconds between praying

#06:33 DEBUG:wc=-33:ac=-16:dam=1:speed=85033:weaponspeed=22003
#06:33 DEBUG:VAL1=0.117601
#06:33 DEBUG:VAL2=0.02766
#06:33 DEBUG:SLEEP=0.588007
#06:33 DEBUG:VAL3=21.2584
#06:33 DEBUG:SLEEP=0.345752:PL_SPEED=85033
#06:33 INFO:Sleeping 0.345752 sleep seconds between praying

#06:34 DEBUG:wc=-33:ac=-16:dam=1:speed=103671:weaponspeed=26240
#06:34 DEBUG:VAL1=0.096459
#06:34 DEBUG:VAL2=0.0186087
#06:34 DEBUG:SLEEP=0.482295
#06:34 DEBUG:VAL3=25.9177
#06:34 DEBUG:SLEEP=0.232608:PL_SPEED=103671
#06:34 INFO:Sleeping 0.232608 sleep seconds between praying

VAL1=`dc 10000 ${PL_SPEED:-50000} \/ p`
_debug "VAL1=$VAL1"
VAL2=`dc $VAL1 $VAL1 \* 2 \* p`
_debug "VAL2=$VAL2"

SLEEP=`dc 50000 ${PL_SPEED:-50000} \/ p`
_debug "SLEEP=$SLEEP"
 VAL3=`dc $SLEEP $VAL2 \/ p`
_debug "VAL3=$VAL3"
SLEEP=`dc $SLEEP $VAL2 \* $VAL3 \* p`

_msg 7 "SLEEP=$SLEEP:PL_SPEED=$PL_SPEED"

#SLEEP_P=`dc $PL_SPEED 100 \* 50000 \/ 100 \/p`

##SLEEP=$(( SLEEP - ( (PL_SPEED/10000) * 1000 ) ))
#SLEEP_T=`dc $SLEEP 10 \/p`
#SLEEP=`dc $SLEEP $SLEEP_T \- p`


USLEEP=`dc $SLEEP 1000000 \* p`
SLEEP=${SLEEP//,/.}  # _check_food_level uses _sleep and sleep does not like 1,2 but 1.2
USLEEP=${USLEEP%.*}  # usleep does not like floats
USLEEP=${USLEEP%,*}
_msg 6 "Sleeping $USLEEP usleep micro-sec. / $SLEEP sec. between praying."
}

_say_progress(){
#ckc=$((ckc+1))
#test "$ckc" -lt $COUNT_CHECK_FOOD && return 0
#ckc=0
case $NUMBER in
'') _draw 5 "$one praying attempt(s) done.";;
*)  _draw 5 "$((NUMBER-one)) praying(s) left.";;
esac
}


#   __get_player_speed_and_set_usleep
     _get_player_speed_and_set_usleep

# *** Actual script to pray multiple times *** #
 test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution
#case $NUMBER in *[0-9]*) test $NUMBER -ge 1 || NUMBER=1;; esac #paranoid precaution
#case $NUMBER in [1-9]*) :;; *) NUMBER=1;; esac

c=0; one=0
while :
do
one=$((one+1))

_is 1 1 "use_skill" "praying"
_usleep

if _check_counter; then
 _check_food_level
 _check_hp_and_return_home $HP
 _say_progress
fi

 case $NUMBER in $one) break 1;; esac
done

# *** Here ends program *** #
_say_end_msg
###END###
