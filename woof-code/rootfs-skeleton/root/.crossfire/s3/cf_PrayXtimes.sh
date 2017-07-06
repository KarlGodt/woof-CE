#!/bin/ash

export PATH=/bin:/usr/bin

TIMEA=`date +%s`

# *** Color numbers found in common/shared/newclient.h : *** #
#define NDI_BLACK       0
#define NDI_WHITE       1
#define NDI_NAVY        2
#define NDI_RED         3
#define NDI_ORANGE      4
#define NDI_BLUE        5       /**< Actually, it is Dodger Blue */
#define NDI_DK_ORANGE   6       /**< DarkOrange2 */
#define NDI_GREEN       7       /**< SeaGreen */
#define NDI_LT_GREEN    8       /**< DarkSeaGreen, which is actually paler
#                                 *   than seagreen - also background color. */
#define NDI_GREY        9
#define NDI_BROWN       10      /**< Sienna. */
#define NDI_GOLD        11
#define NDI_TAN         12      /**< Khaki. */



# Global variables

#DEBUG=1

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf
_get_player_name && {
test -f "${MY_SELF%/*}"/"${MY_NAME}".conf && . "${MY_SELF%/*}"/"${MY_NAME}".conf
}

_usage(){
_draw 5 "Script to pray given number times."
_draw 8 "Syntax:"
_draw 7 "script $0 <number>"
_draw 5 "For example: 'script $0 50'"
_draw 5 "will issue 50 times the use_skill praying command."
_draw 6 "Without number given as option, loops forever."
_draw 4 "Use 'scriptkill to abort."
_draw 2 "Options:"
_draw 4 "-F  on fast network connection."
_draw 4 "-S  on slow 2G network connection."
_draw 5 "-d  to turn on debugging."
_draw 6 "-f  do not check msgs received from server."
_draw 5 "-L  to log to $REPLY_LOG ."
_draw 5 "-v to say what is being issued to server."
_draw 6 "-X  do not check for praying skill."

        exit 0
}

CHECK_DO=1
# *** Here begins program *** #
_say_start_msg "$@"

# *** Check for parameters *** #
until test "$#" = 0;
do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in
-h|*help) _usage;;
-d|*debug)     DEBUG=$((DEBUG+1));;
-F|*fast)   SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
-f|*force)     FORCE=$((FORCE+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-S|*slow)   SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
-X|*nocheck*) unset CHECK_DO;;

--*) case $PARAM_1 in
 -h|*help) _usage;;
 -d|*debug)     DEBUG=$((DEBUG+1));;
 -F|*fast)   SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
 -f|*force)     FORCE=$((FORCE+1));;
 -L|*log*)    LOGGING=$((LOGGING+1));;
 -S|*slow)   SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
 -v|*verbose) VERBOSE=$((VERBOSE+1));;
 -X|*nocheck*) unset CHECK_DO;;
 *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
 esac
;;

-*)
 OPTS=`printf '%s' $PARAM_1 | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
     h) _usage;;
     d)     DEBUG=$((DEBUG+1));;
     F)   SLEEP_MOD='/'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
     f)     FORCE=$((FORCE+1));;
     L)    LOGGING=$((LOGGING+1));;
     S)   SLEEP_MOD='*'; SLEEP_MOD_VAL=$((SLEEP_MOD_VAL+1));;
     v) VERBOSE=$((VERBOSE+1));;
     X) unset CHECK_DO;;
     *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
    done
;;

[0-9]*)
# *** testing parameters for validity *** #
#PARAM_1test="${PARAM_1//[[:digit:]]/}" # does not work for ash @ BusyBox v1.21.0 (2014-01-06 20:37:23 EST) multi-call binary.
PARAM_1test="${PARAM_1//[0-9]/}"
test "$PARAM_1test" && {
_draw 3 "Only :digit: numbers as further option allowed."
        exit 1 #exit if other input than letters
        }
NUMBER=$PARAM_1
;;
*) _red "Ignoring unrecognized option '$PARAM_1'";;
esac
shift
sleep 0.1
done


#test "$NUMBER" || {
#_draw 3 "Script needs number of praying attempts as argument."
#        exit 1
#}


_check_skill_praying(){
[ "$CHECK_DO" ] || return 0
_draw 5 "Checking if having praying skill..."
local lYES
echo request skills
while :; do sleep 0.1
unset REPLY
read -t 2 <&0   # <&1 works, <&0 works, in ash
_debug "$REPLY"
_log "_check_skill_praying:$REPLY"
case $REPLY in *' praying') lYES=0;;
'request skills end') break;;
'') break;;
esac
done
return ${lYES:-1}
}

__flush(){
timeout -t 1 cat 1>/dev/null <&0 2>/dev/null
}

__check_skill_praying(){
[ "$CHECK_DO" ] || return 0
_draw 5 "Checking if having praying skill..."

local lSKILLS

#rm -f /tmp/stdin.txt

echo request skills
sleep 1

# these do not work:
#cat >/tmp/stdin.txt </dev/stdin

# these work:
#timeout -t 2 cat >/tmp/stdin.txt <&0 2>/dev/null  # timeout sends Terminated to &2
#grep -q ' praying$' /tmp/stdin.txt

SKILLS=`timeout -t 1 cat >&1 <&0 2>/dev/null`
_log "$lSKILLS"  # debug
echo "$lSKILLS" | grep -q ' praying$'
}

_get_player_speed(){

_draw 5 "Getting player speed ..."

local Req Stat Cmbt WC AC DAM SPEED W_SPEED

echo request stat cmbt
#snprintf(buf, sizeof(buf), "request stat cmbt %d %d %d %d %d\n", cpl.stats.wc, cpl.stats.ac, cpl.stats.dam, cpl.stats.speed, cpl.stats.weapon_sp);
read -t 1 Req Stat Cmbt WC AC DAM SPEED W_SPEED
_debug "wc=$WC:ac=$AC:dam=$DAM:speed=$SPEED:weaponspeed=$W_SPEED"

case $SPEED in
[1-9][0-9][0-9][0-9][0-9][0-9]) USLEEP=600000;; #six
1[0-9][0-9][0-9][0-9]) USLEEP=1500000;;  #five
2[0-9][0-9][0-9][0-9]) USLEEP=1400000;;
3[0-9][0-9][0-9][0-9]) USLEEP=1300000;;
4[0-9][0-9][0-9][0-9]) USLEEP=1200000;;
5[0-9][0-9][0-9][0-9]) USLEEP=1100000;;
6[0-9][0-9][0-9][0-9]) USLEEP=1000000;;
7[0-9][0-9][0-9][0-9]) USLEEP=900000;;
8[0-9][0-9][0-9][0-9]) USLEEP=800000;;
9[0-9][0-9][0-9][0-9]) USLEEP=700000;;
*) USLEEP=2000000;; # four
esac
_debug "USLEEP=$USLEEP:SPEED=$SPEED"

USLEEP=$(( USLEEP - ( (SPEED/10000) * 1000 ) ))

if test "$SLEEP_MOD" -a "$SLEEP_MOD_VAL"; then
USLEEP=$(echo "scale=0; $USLEEP $SLEEP_MOD $SLEEP_MOD_VAL" | bc -l)
_debug "USLEEP='$USLEEP'"
fi
USLEEP=${USLEEP:-1000000}

_debug "Sleeping $USLEEP usleep micro-seconds between praying"
}

_read_reply_praying(){
[ "$FORCE" ] && return 0
sleep 0.5

CAT_IN=`timeout -t 1 cat >&1 <&0 2>/dev/null`
#echo "$CAT_IN" >&2

if test "$DEBUG"; then
while read line
do
echo draw 3 "DEBUG:$line"
done <<EoI
`echo "$CAT_IN"`
EoI
fi
}
#_read_reply_praying

__read_reply_praying(){
[ "$FORCE" ] && return 0
# Checking the parameters (100)...
# without
# Loop of script had run a total of 1:41 minutes.
# with REPLY read loop:
# Loop of script had run a total of 3:30 minutes.

sleep 0.5

 while :; do sleep 0.1
  unset REPLY
  read -t 1 <&0
  _debug "$REPLY"
  _log "$REPLY"

  case $REPLY in
  '') break;;
  $REPLY_OLD) break;;
  # server/skills.c
  *'You pray over the '*) break;;
  *'You pray.'*) break;;
  # server/gods.c

  esac

# TODO: server/gods.c
# Heretic! You are using cloak of Lythander * (worn)!
# Heretic! You are using %s!
# Foul Priest! %s punishes you!
# Foolish heretic! %s is livid!
# Heretic! %s is angered!
# A divine force pushes you off the altar.
# The %s crumble to dust!
# The %s crumbles to dust!
# You lose knowledge of %s.
# Fool! %s detests your kind!
# %s's blessing is withdrawn from you.
# You are bathed in %s's aura.
# You feel like someone is helping you.
# A phosphorescent glow envelops your weapon!
# %s considers your %s is not worthy to be enchanted any more.
# Your %s already belongs to %s !
# The %s is not yours, and is magically protected against such changes !
# Your weapon quivers as if struck!
# Your %s now hungers to slay enemies of your god!
# Your weapon suddenly glows!
# You feel a holy presence!
# Something appears before your eyes.  You catch it before it falls to the ground.
# You are returned to a state of grace.
# A white light surrounds and heals you!
# A blue lightning strikes your head but doesn't hurt you!
# Shimmering light surrounds and restores you!
# You hear a voice from behind you, but you don't dare to
#  turn around:
# %s grants you use of a special prayer!
# You feel rapture.
# %s becomes angry and punishes you!
## This prayer is useless unless you worship an appropriate god
 done
}

_check_skill_praying || {
        echo draw 3 "You do not have the abillity to pray."
        exit 1
}

_get_player_speed

# *** Actual script to pray multiple times *** #
if test "$NUMBER"; then
 test "$NUMBER" -ge 1 || NUMBER=1 #paranoid precaution
else NUMBER=inifinite
fi

TIMEB=`date +%s`

_watch

c=0

_draw 5 "Starting praying..."

#for one in `seq 1 1 $NUMBER`
while :;
do

unset REPLY_OLD

_is 1 1 use_skill praying
one=$((one+1))
#sleep 0.5


__read_reply_praying

usleep $USLEEP

_check_food_level $COUNT_CHECK_FOOD $MIN_FOOD_LEVEL_DEF  # creates HP
_check_hp_and_return_home $COUNT_CHECK_FOOD $HP


c=$((c+1))
test $c -ge $COUNT_CHECK_FOOD && {
c=0
 if test "$NUMBER" = inifinite; then
   _draw 5 "$one prayings done."
   _draw 6 "Use scriptkill to abort."
 else
  _draw 5 "$((NUMBER-one)) prayings left"
 fi
}


test "$one" = "$NUMBER" && break
done

# *** Here ends program *** #
_say_end_msg
