#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables "$@"
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

_usage(){
_draw 5 "Script to produce balm of first aid."
_draw 7 "Syntax:"
_draw 7 "$0 < -version VERSION > <NUMBER>"
_draw 5 "Allowed NUMBER will loop for"
_draw 5 "NUMBER times to produce NUMBER of"
_draw 5 "Balm of First Aid ."
_draw 4 "If no number given, loops as long"
_draw 4 "as ingredients could be dropped."
_draw 2  "Option -version 1.12.0 and lesser"
_draw 2  "turns on some compatibility switches."
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $REPLY_LOG ."
_draw 5 "-v to say what is being issued to server."
        exit 0
}

# *** Here begins program *** #
_say_start_msg "$@"


# *** PARAMETERS *** #

# ** client version ** #
while :;
do
case "$1" in
-version) shift;;
*.*) shift;;
*) break;;
esac
sleep 0.1
done


until test "$#" = 0;
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help|*usage)
_usage
;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-F|*fast)   SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-S|*slow)   SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

--*) case $PARAM_1 in
      --help)   _usage;;
      --deb*)    DEBUG=$((DEBUG+1));;
      --fast)  SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --log*)  LOGGING=$((LOGGING+1));;
      --slow)  SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      --verb*) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;
-*) OPTS=`echo "$PARAM_1" | sed -r 's/^-*//; s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      h)  _usage;;
      d)   DEBUG=$((DEBUG+1));;
      F) SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      L) LOGGING=$((LOGGING+1));;
      S) SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

[0-9]*)
PARAM_1test="${PARAM_1//[[:digit:]]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as option allowed."
        exit 1 #exit if other input than numbers
        }

NUMBER=$PARAM_1
;;
*) _red "Unrecognized option '$PARAM_1'";;
esac
shift
sleep 0.1
done

#test "$NUMBER" || {
#_draw 3 "Script needs number of alchemy attempts as argument."
#        exit 1
#}

#test "$1" || {
#_draw 3 "Need <number> ie: script $0 4 ."
#        exit 1
#}

_draw 7 "OK."

rm -f "$REPLY_LOG"    # empty old log files
rm -f "$REQUEST_LOG"
rm -f "$ON_LOG"


# *** Getting Player's Speed *** #
_get_player_speed
# *** Check if standing on a cauldron *** #
#_is 1 1 pickup 0  # precaution ## now done in _check_empty_cauldron
_check_if_on_cauldron
# *** Check if there are 4 walkable tiles in $DIRB *** #
#_check_for_space
$FUNCTION_CHECK_FOR_SPACE
# *** Check if cauldron is empty *** #
_check_empty_cauldron
# *** Unreadying rod of word of recall - just in case *** #
_prepare_rod_of_recall


# *** Monitoring function *** #
# *** Todo ...            *** #
_monitor_malfunction(){

while :; do
read -t $TMOUT ERRORMSGS

sleep 0.1s
done
}

# *** Actual script to alch the desired balm of first aid *** #
#test $NUMBER -ge 1 || NUMBER=1 #paranoid precaution
test "$NUMBER" && { test "$NUMBER" -ge 1 || NUMBER=1; } #paranoid precaution
NUMBER=${NUMBER:-infinite}

if _test_integer $NUMBER; then
 alias _loop_counter=_loop_counter_number  # alias x=function in ash works, bash 3.2 not
 LOOP_COUNTER=_loop_counter_number
else
 alias _loop_counter=_loop_counter_infinite
 LOOP_COUNTER=_loop_counter_infinite
fi

# *** Lets loop - hope you have the needed amount of ingredients    *** #
# *** in the inventory of the character and unlocked !              *** #
# *** Make sure similar items are not in the inventory --           *** #
# *** eg. staff of summon water elemental and such ...              *** #
# *** So do a 'drop water' and                                      *** #
# *** drop mandrake root   before beginning to alch.                *** #

# *** Then if some items are locked, unlock these and drop again.   *** #
# *** Now get the number of desired water and mandrake root --      *** #
# *** only one inventory line with water(s) and                     *** #
# *** mandrake root are allowed !!                                  *** #
# *** Otherwise a wand or scroll of summon water elemental may be   *** #
# *** put into the cauldron, which would result in failure !!!!     *** #

# *** Now get the number of desired water of the wise and           *** #
# *** same times the number of mandrake root .                      *** #

# *** Now walk onto the cauldron and make sure there are 4 tiles    *** #
# *** $DIRB of the cauldron.                                        *** #
# *** Do not open the cauldron - this script does it.               *** #
# *** HAPPY ALCHING !!!                                             *** #

TIMEB=`date +%s`
success=0
# *** Now LOOPING *** #

#for one in `seq 1 1 $NUMBER`
while :;
do

#TIMEB=`date +%s`
TIMEC=${TIMEE:-$TIMEB}

_is 1 1 apply
sleep 0.5
#_sleep

_drop_in_cauldron 1 water of the wise; ## sleeps in the middle and at the end of _check_drop_or_exit

_drop_in_cauldron 1 mandrake root;     ## sleeps in the middle and at the end of _check_drop_or_exit

_close_cauldron; #_sleep ## _close_cauldron sleeps two times

_alch_and_get;   #_sleep ## _alch_and_get sleeps at the end

_go_cauldron_drop_alch_yeld; #_sleep   ## sleeps at the end

if test "$NOTHING" = 0; then
        if test "$SLAG" = 0; then
        _success &
        _is 1 1 use_skill sense curse
        _is 1 1 use_skill sense magic
        _is 1 1 use_skill alchemy
        _sleep

        _is 0 1 drop balm
        success=$((success+1))
        else
        _failure &
        _is 0 1 drop slag
        fi
elif test "$NOTHING" = "-1"; then
      :   # emergency drop to prevent new created items droped in cauldron
else
 _disaster &
fi

one=$((one+1))
_loop_counter        # ash   ## 3G Quality 0,60 speed SLEEP=0.5: 20s, -S 26s,
#$LOOP_COUNTER       # bash
_return_to_cauldron  # calls _go_drop_alch_yeld_cauldron, _check_food_level, _get_player_speed -l, _check_if_on_cauldron
#_loop_counter
#$LOOP_COUNTER

test "$one" = "$NUMBER" && break
done  # *** MAINLOOP *** #


# *** Here ends program *** #
_say_end_msg
