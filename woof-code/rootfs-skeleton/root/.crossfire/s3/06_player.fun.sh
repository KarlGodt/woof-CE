#!/bin/ash


___get_player_name(){
# this does not work correctly since case insensitive
local ANSWER

_watch

for player_name in karl Karl KARL Karl_ Trollo Aelfdoerf kalle kalli
do
sleep 0.1
_is 1 1 hug $player_name #case insensitive!
sleep 0.1
read -t $TMOUT ANSWER
_debug "ANSWER=$ANSWER"
_log "___get_player_name:$ANSWER"
case $ANSWER in *You*hug*yourself*) MY_NAME="$player_name"; break 1;; esac
sleep 0.1
unset ANSWER
done

if test "$MY_NAME"; then
 _draw 2 "Your name found out to be $MY_NAME"
 test -f "${MY_SELF%/*}"/"${MY_NAME}".conf || echo '#' "${MY_NAME}'s config file" >"${MY_SELF%/*}"/"${MY_NAME}".conf
 true
else
 _draw 3 "Error finding your player name."
 false
fi

_unwatch
}

__get_player_name(){ # reads file "${TMP_DIR}"/player_name.$PPID
unset MY_NAME        # created by cf_set_player_name.sh
                     # not needed since request player possible
#test -s "${MY_SELF%/*}"/player_name.$PPID && read -r MY_NAME <"${MY_SELF%/*}"/player_name.$PPID
test -s "${TMP_DIR}"/player_name.$PPID && read -r MY_NAME <"${TMP_DIR}"/player_name.$PPID
test "$MY_NAME"
}

_get_player_name(){

local c=0
local r p N P

echo request player
while :;
do
read -t $TMOUT
_log "_get_player_name:'$REPLY'"
_debug "REQUEST PLAYER:'$REPLY'"

c=$((c+1))
test "$c" = 9 && break
test "$REPLY" || break

MY_NAME_ALL="$REPLY"
unset REPLY
sleep 0.1
done

read r p N P MY_NAME_W_TITLE <<EoI
`echo "$MY_NAME_ALL"`
EoI

#MY_NAME=`echo "$MY_NAME_W_TITLE" | sed 's% the .*%%'`  #MIKE the Mechanic
MY_NAME=`echo "$MY_NAME_W_TITLE" | awk '{print $1}'`    #Nico a wonderful terrible
_debug "Player:'$MY_NAME'"

if test "$MY_NAME"; then
 _draw 2 "Your name found out to be $MY_NAME"
 test -f "${MY_SELF%/*}"/"${MY_NAME}".conf || echo '#' "${MY_NAME}'s config file" >"${MY_SELF%/*}"/"${MY_NAME}".conf
 true
else
 _draw 3 "Error finding your player name."
 false
fi

#test "$MY_NAME"
}


_get_player_speed(){

if test "$1" = '-l'; then # -l for loop
 spc=$((spc+1))
 test "$spc" -ge $COUNT_CHECK_FOOD || return 1
 spc=0
fi

_draw 5 "Processing Player's speed..."

local ANSWER OLD_ANSWER PL_SPEED
ANSWER=
OLD_ANSWER=

echo request stat cmbt

while :; do
read -t $TMOUT ANSWER

_log "$REQUEST_LOG" "request stat cmbt:$ANSWER"
_debug "$ANSWER"
test "$ANSWER" || break
test "$ANSWER" = "$OLD_ANSWER" && break
OLD_ANSWER="$ANSWER"
sleep 0.1
done

test ! "$ANSWER" -a "$OLD_ANSWER" && ANSWER="$OLD_ANSWER"  #+++2017-03-20

#PL_SPEED=`awk '{print $7}' <<<"$ANSWER"`    # *** bash
PL_SPEED=`echo "$ANSWER" | awk '{print $7}'` # *** ash + bash

PL_SPEED=`echo "scale=2;$PL_SPEED / 100000" | bc -l`
_debug "Player speed is '$PL_SPEED'"

PL_SPEED=`echo "$PL_SPEED" | sed 's!\.!!g;s!^0*!!'`
_verbose "Using player speed '$PL_SPEED'"

  if test "$PL_SPEED" = "";   then
    _draw 3 "WARNING: Could not set player speed. Using defaults."

elif test "$PL_SPEED" -gt 80; then
SLEEP=0.1; DELAY_DRAWINFO=0.6; TMOUT=1
elif test "$PL_SPEED" -gt 75; then
SLEEP=0.1; DELAY_DRAWINFO=0.7; TMOUT=1
elif test "$PL_SPEED" -gt 70; then
SLEEP=0.2; DELAY_DRAWINFO=0.8; TMOUT=1
elif test "$PL_SPEED" -gt 65; then
SLEEP=0.3; DELAY_DRAWINFO=0.9; TMOUT=1
elif test "$PL_SPEED" -gt 60; then
SLEEP=0.4; DELAY_DRAWINFO=1.0; TMOUT=1
elif test "$PL_SPEED" -gt 55; then
SLEEP=0.5; DELAY_DRAWINFO=1.1; TMOUT=1
elif test "$PL_SPEED" -gt 50; then
SLEEP=0.6; DELAY_DRAWINFO=1.2; TMOUT=1
elif test "$PL_SPEED" -gt 45; then
SLEEP=0.7; DELAY_DRAWINFO=1.4; TMOUT=1
elif test "$PL_SPEED" -gt 40; then
SLEEP=0.8; DELAY_DRAWINFO=1.6; TMOUT=1
elif test "$PL_SPEED" -gt 35; then
SLEEP=1.0; DELAY_DRAWINFO=2.0; TMOUT=2
elif test "$PL_SPEED" -gt 30; then
SLEEP=1.5; DELAY_DRAWINFO=3.0; TMOUT=2
elif test "$PL_SPEED" -gt 25; then
SlEEP=2.0; DELAY_DRAWINFO=4.0; TMOUT=2
elif test "$PL_SPEED" -gt 20; then
SlEEP=2.5; DELAY_DRAWINFO=5.0; TMOUT=2
elif test "$PL_SPEED" -gt 15; then
SLEEP=3.0; DELAY_DRAWINFO=6.0; TMOUT=2
elif test "$PL_SPEED" -gt 10; then
SLEEP=4.0; DELAY_DRAWINFO=8.0; TMOUT=2
elif test "$PL_SPEED" -ge 0;  then
SLEEP=5.0; DELAY_DRAWINFO=10.0; TMOUT=2
else
_exit 1 "ERROR while processing player speed."
fi

_debug "SLEEP='$SLEEP' DELAY_DRAWINFO='$DELAY_DRAWINFO' TMOUT='$TMOUT'"

if test "$SLEEP_MOD" -a "$SLEEP_MOD_VAL"; then
SLEEP=$(echo "$SLEEP $SLEEP_MOD $SLEEP_MOD_VAL" | bc -l)
case $SLEEP in .*) SLEEP="0$SLEEP";; esac
_debug "SLEEP='$SLEEP'"
fi

SLEEP=${SLEEP:-1}
_verbose "Finally set SLEEP='$SLEEP'"

_draw 6 "Done."
return 0
}

_check_for_space(){
# *** Check for 4 empty space to DIRB *** #

local REPLY_MAP OLD_REPLY NUMBERT

test "$1" && NUMBERT="$1"
test "$NUMBERT" || NUMBERT=4
#test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space: Need a digit. Invalid parameter passed:$*"
test "${NUMBERT//[0-9]/}" && _exit 2 "_check_for_space: Need a digit. Invalid parameter passed:$*"
_draw 5 "Checking for space to move 4 tiles '$DIRB' ..."


echo request map pos

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville

while :; do
read -t $TMOUT REPLY_MAP
_log "$REPLY_LOG" "_check_for_space:$REPLY_MAP"
_debug "REPLY_MAP='$REPLY_MAP'"

test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break

OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

test ! "$REPLY_MAP" -a "$OLD_REPLY" && REPLY_MAP="$OLD_REPLY" #+++2017-03-20

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $4}'` #request map pos:request map pos 280 231
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $5}'`
_debug PL_POS_X=$PL_POS_X
_debug PL_POS_Y=$PL_POS_Y

if test "$PL_POS_X" -a "$PL_POS_Y"; then

#if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then
if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
;;
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
southwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y+nr))
;;
southeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y+nr))
;;
esac


echo request map $R_X $R_Y

 while :; do
 read -t $TMOUT

 _log "$REPLY_LOG" "request map '$R_X' '$R_Y':$REPLY"
 _debug  "$REPLY"

 test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`

 _log "$REPLY_LOG" "IS_WALL=$IS_WALL"
 test "$IS_WALL" = 0 || _exit_no_space 1

 test "$REPLY" || break
 unset REPLY
 sleep 0.1s
 done

done

else

_draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

_draw 3 "Could not get X and Y position of player."
exit 1

fi

_draw 7 "OK."
}

_check_for_space_old_client(){
# *** Check for 4 empty space to DIRB ***#

local REPLY_MAP OLD_REPLY NUMBERT cm

test "$1" && NUMBERT="$1"
test "$NUMBERT" || NUMBERT=4
#test "${NUMBERT//[[:digit:]]/}" && _exit 2 "_check_for_space_old_client: Need a digit. Invalid parameter passed:$*"
test "${NUMBERT//[0-9]/}" && _exit 2 "_check_for_space_old_client: Need a digit. Invalid parameter passed:$*"

_draw 5 "Checking for space to move 4 tiles '$DIRB' ..."

sleep 0.5

echo request map near

# client v.1.70.0 request map pos:request map pos 280 231 ##cauldron adventurers guild stoneville
# client v.1.10.0                 request map pos 272 225 ##cauldron adventurers guild stoneville
#                request map near:request map     279 231  0 n n n n smooth 30 0 0 heads 4854 825 0 tails 0 0 0

cm=0
while :; do
cm=$((cm+1))
read -t $TMOUT REPLY_MAP
_log "$REPLY_LOG" "_check_for_space_old_client:$REPLY_MAP"
_debug "$REPLY_MAP"

test "$cm" = 5 && break
test "$REPLY_MAP" || break
test "$REPLY_MAP" = "$OLD_REPLY" && break

OLD_REPLY="$REPLY_MAP"
sleep 0.1s
done

_empty_message_stream

test ! "$REPLY_MAP" -a "$OLD_REPLY" && REPLY_MAP="$OLD_REPLY" #+++2017-03-20

PL_POS_X=`echo "$REPLY_MAP" | awk '{print $3}'` #request map near:request map 278 230  0 n n n n smooth 30 0 0 heads 4854 0 0 tails 0 0 0
PL_POS_Y=`echo "$REPLY_MAP" | awk '{print $4}'`

if test "$PL_POS_X" -a "$PL_POS_Y"; then

#if test ! "${PL_POS_X//[[:digit:]]/}" -a ! "${PL_POS_Y//[[:digit:]]/}"; then
if test ! "${PL_POS_X//[0-9]/}" -a ! "${PL_POS_Y//[0-9]/}"; then

for nr in `seq 1 1 $NUMBERT`; do

case $DIRB in
west)
R_X=$((PL_POS_X-nr))
R_Y=$PL_POS_Y
;;
east)
R_X=$((PL_POS_X+nr))
R_Y=$PL_POS_Y
;;
north)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y-nr))
;;
south)
R_X=$PL_POS_X
R_Y=$((PL_POS_Y+nr))
;;
northeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y-nr))
;;
northwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y-nr))
;;
southwest)
R_X=$((PL_POS_X-nr))
R_Y=$((PL_POS_Y+nr))
;;
southeast)
R_X=$((PL_POS_X+nr))
R_Y=$((PL_POS_Y+nr))
;;
esac


echo request map $R_X $R_Y

 while :; do
 read -t $TMOUT
 _log "$REPLY_LOG" "request map '$R_X' '$R_Y':$REPLY"
 _debug "$REPLY"

 test "$REPLY" && IS_WALL=`echo "$REPLY" | awk '{print $16}'`

 _log "$REPLY_LOG" "IS_WALL=$IS_WALL"
 test "$IS_WALL" = 0 || _exit_no_space 1

 test "$REPLY" || break
 unset REPLY
 sleep 0.1s
 done

done

else

_draw 3 "Received Incorrect X Y parameters from server"
exit 1

fi

else

_draw 3 "Could not get X and Y position of player."
exit 1

fi

_draw 7 "OK."
}


_prepare_rod_of_recall(){
# *** Unreadying rod of word of recall - just in case *** #

local RECALL OLD_REPLY REPLY

_draw 5 "Preparing for recall if monsters come forth..."

RECALL=0
OLD_REPLY="";
REPLY="";

echo request items actv

while :; do
read -t $TMOUT
_log "$REPLY_LOG" "request items actv:$REPLY"
_debug "$REPLY"

case $REPLY in
*rod*of*word*of*recall*) RECALL=1;;
'') break;;
esac

unset REPLY
sleep 0.1s
done

if test "$RECALL" = 1; then # unapply it now , _emergency_exit applies again
_is 1 1 apply rod of word of recall
fi

_draw 6 "Done."

}


# *** we may get attacked and die *** #
_check_hp_and_return_home(){

hpc=$((hpc+1))
test "$hpc" -lt $COUNT_CHECK_FOOD && return
hpc=0

local REPLY=''

test "$1" && local currHP=$1
test "$2" && local currHPMin=$2

test "$currHP"     || local currHP=$HP
test "$HP_MIN_DEF" && local currHPMin=$HP_MIN_DEF
test "$currHPMin"  || local currHPMin=$((MHP/10))

_debug currHP=$currHP currHPMin=$currHPMin
if test "$currHP" -le $currHPMin; then

_empty_message_stream
_is 1 1 apply -a rod of word of recall
_empty_message_stream

_is 1 1 fire center ## Todo check if already applied and in inventory
_is 1 1 fire_stop
_empty_message_stream

_unwatch
exit
fi

unset HP
}

_turn_direction_brace(){
# use brace and DIR -- attacks in to DIR; so
# either would use key to unlock door
# or punches against it and trigger traps

local lDIR=${1:-"$DIR"}

_draw 5 "Bracing .."
_is 1 1 brace on
sleep 1

_draw 4 "Turning $DIR .."
_is 1 1 $lDIR
sleep 1

}

_rotate_range_attack(){  # cast by _do_program
_debug "_rotate_range_attack:$*"

local lSPELL REPLY_RANGE oldREPLY_RANGE

lSPELL=${SPELL:-"$*"}
lSPELL=${lSPELL:-"$SPELL_DEFAULT"}

test "$lSPELL" || return 3

_draw 5 "Checking if have '$lSPELL' ready..."
_draw 5 "Please wait...."

while :;
do

echo request range
sleep 1
read -t 1 REPLY_RANGE
 _log "_rotate_range_attack:REPLY_RANGE=$REPLY_RANGE"
 _debug "$REPLY_RANGE"

 test "`echo "$REPLY_RANGE" | grep -i "$lSPELL"`" && break
 test "$oldREPLY_RANGE" = "$REPLY_RANGE" && break
 test "$REPLY_RANGE" || break

    _is 1 1 rotateshoottype
 oldREPLY_RANGE="$REPLY_RANGE"
sleep 2.1
done

}

_do_emergency_recall(){  # cast by _watch_food
# *** apply rod of word of recall if hit-points are below HP_MAX /5
# *   fire and fire_stop it
# *   alternatively one could apply rod of heal, scroll of restoration
# *   and ommit exit ( comment 'exit 5' line by setting a '#' before it)
# *   - something like that

#TODO : Something blocks your magic.

  _is 1 1 apply "rod of word of recall"
  _is 1 1 fire 0
  _is 1 1 fire_stop

## apply bed of reality
# sleep 10
# echo issue 1 1 apply

exit 5
}

_probe_enemy(){  # cast by _do_loop
# ***
_debug "_probe_enemy:$*"

local lDIRECTION_NUMBER lPROBE_ITEM

lDIRECTION_NUMBER=${DIRECTION_NUMBER:-$1}
lDIRECTION_NUMBER=${lDIRECTION_NUMBER:-$DIRECTION_NUMBER_DEFAULT}
shift
lPROBE_ITEM=${PROBE_ITEM:-"$*"}
lPROBE_ITEM=${lPROBE_ITEM:-"$PROBE_ITEM_DEFAULT"}

test "$lPROBE_ITEM" -a "$lDIRECTION_NUMBER" || return 3

   _is 1 1 apply -u $lPROBE_ITEM
    sleep 0.2
   _is 1 1 apply -a $lPROBE_ITEM  # 'rod of probe' should also apply heavy rod
   # TODO: read drawinfo if successfull ..

#TODO : Something blocks your magic.

_is 1 1 fire $lDIRECTION_NUMBER
_is 1 1 fire_stop

}
