#!/bin/bash

# 2018-01-10 : Code overhaul.
# No real changes,
# except to support infinite looping.

export LC_NUMERIC=de_DE
export LC_ALL=de_DE

VERSION=0.0 # initial version
VERSION=1.0 # set a sleep value between use_skill praying
# to sync the messages 5 times You pray in the msgpane
VERSION=2.0 # refine the setting of sleep values
VERSION=3.0 # add a check for food level and to eat
VERSION=3.1 # recognize -V and -d options
VERSION=3.2 # use cf_funcs_requests.sh
VERSION=3.3 # check if praying skill is available

# Global variables

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
MY_DIR=${MY_SELF%/*}

cd "$MY_DIR"

#test -f "$MY_DIR"/cf_functions.sh   && . "$MY_DIR"/cf_functions.sh
#_set_global_variables $*

test -f "$MY_DIR"/cf_funcs_common.sh   && . "$MY_DIR"/cf_funcs_common.sh
_set_global_variables $*

test -f "$MY_DIR"/cf_funcs_food.sh     && . "$MY_DIR"/cf_funcs_food.sh
test -f "$MY_DIR"/cf_funcs_requests.sh && . "$MY_DIR"/cf_funcs_requests.sh
test -f "$MY_DIR"/cf_funcs_skills.sh   && . "$MY_DIR"/cf_funcs_skills.sh


# *** Override any VARIABLES in cf_functions.sh *** #
test -f "$MY_DIR"/"${MY_BASE}".conf && . "$MY_DIR"/"${MY_BASE}".conf

unset DIRB DIRF

_usage(){
_draw 5 "$MY_BASE"
_draw 5 "Script to pray given number times."
_draw 5  "To be used in the crossfire roleplaying game client."
_draw 2 "Syntax:"
_draw 2 "script $0 <number>"
_draw 5 "For example: 'script $0 50'"
_draw 5 "will issue 50 times the use_skill praying command."
_draw 2 "Without <number> will loop forever,"
_draw 2 "use scriptkill to terminate."

        exit 0
}

# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #

while [ "$1" ]
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*"help"*) _usage;;
-d) DEBUG=$((DEBUG+1));;
-L) LOGGING=$((LOGGING+1));;
-V) _say_version;;
*)
# *** testing parameters for validity *** #
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as first option allowed."
        exit 1 #exit if other input like letters, puncts
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

_request_stat_cmbt

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
SLEEP=`dc $USLEEP 1000000 \/ p`
_msg 6 "Sleeping $USLEEP usleep micro-sec. / $SLEEP sec. between praying."
}

_get_player_speed_and_set_usleep(){

_empty_message_stream

_request_stat_cmbt

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

USLEEP=`dc $SLEEP 1000000 \* p`
SLEEP=${SLEEP//,/.}  # _check_food_level uses _sleep and sleep does not like 1,2 but 1.2
USLEEP=${USLEEP%.*}  # usleep does not like floats
USLEEP=${USLEEP%,*}
_msg 6 "Sleeping $USLEEP usleep micro-sec. / $SLEEP sec. between praying."
}

_say_progress(){
case $NUMBER in
'') _draw 5 "$one praying attempt(s) done.";;
*)  _draw 5 "$((NUMBER-one)) praying(s) left.";;
esac
}

 _check_skill_available "praying" #+++2018-04-19

#   __get_player_speed_and_set_usleep
     _get_player_speed_and_set_usleep

__issue_skills(){

_watch $DRAWINFO
_is 1 1 skills
usleep 10000

while :; do unset REPLY
read -t ${TMOUT:-1}
_log "$REPLY"
_msg 7 "$REPLY"

case $REPLY in '') break 1;;
*worship*)    _debug 3 $REPLY
              GOD=`echo "$REPLY" | awk '{print $NF}' | sed 's/\.$//'` ;;
*item*power*) _debug 3 $REPLY
       ITEM_POWER=`    echo "$REPLY" | awk '{print $9}'`
       ITEM_POWER_MAX=`echo "$REPLY" | awk '{print $NF}' | sed 's/\.$//'`;;
*handle*improvements*) _debug 3 $REPLY
       AVAIL_IMPR=`    echo "$REPLY" | awk '{print $7}'`;;
esac

done

_unwatch $DRAWINFO

_debug $GOD $ITEM_POWER $ITEM_POWER_MAX $AVAIL_IMPR
test "$GOD" = 'none' && unset GOD
test "$GOD" -a "$AVAIL_IMPR" -a "$ITEM_POWER" -a "$ITEM_POWER_MAX"
}

_issue_skills
_request_items_on
case $ANSWER in
*"Altar of"*)
if test "$GOD"; then
 case $ANSWER in *$GOD*) :;; *) _exit 1 "Altar of wrong god.";; esac
fi;;
esac


# *** Actual script to pray multiple times *** #
 test "$NUMBER" && { test $NUMBER -ge 1 || NUMBER=1; } #paranoid precaution

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