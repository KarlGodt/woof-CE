#!/bin/ash

# Who:
# Created by Karl Reimer Godt
# First version 2018-01-06
# Time elapsed for the crossfire client
# while writing the script was 3,5 hours.
# Most time took error fixes after testing the script.
# Bugs are still likely :( !
#
# About:
# Script to open chests in bulk mode
# for the roleplaying game Crossfire.
# Simple script that does not finetune
# trap handling.
# In case of detonating a trap while
# disarming, it does just exit.
#
# Reason:
# I wrote this script because of lazyness,
# since such scripts to open chests already exist
# in my repositories, but I was too lazy to
# search for these similar scripts.
#
# Style:
# This script was written mainly from memeory,
# but used the function _check_if_on_cauldron()
# with modifications for _check_if_on_chest()
# from the cf_functions.sh already available.
# Also used the existing functions
# _is, _draw, _set_global_variables,
# _say_start_msg, _say_end_msg from cf_functions.sh .
# Added __debug() function to cf_functions.sh
# to draw multiple lines given.

#. /etc/DISTRO_SPECS
#. /etc/rc.d/PUPSTATE
#. /etc/rc.d/f4puppy5


. $HOME/cf/s/cf_functions.sh || exit 2

__is(){
_debug "$*"
Z1=$1; shift
Z2=$1; shift
_debug "$*"
echo issue $Z1 $Z2 $*
unset Z1 Z2
sleep 0.2
}

_drop_chest(){
__is 0 0 drop chest
sleep 3
}

_check_if_on_chest(){
_draw 5 "Checking if standing on chests ..."
UNDER_ME='';
UNDER_ME_LIST='';
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "$UNDER_ME"
_debug "$UNDER_ME"

#UNDER_ME_LIST="$UNDER_ME
#$UNDER_ME_LIST"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break;;
*scripttell*break*)     break;;
*scripttell*exit*)    _exit 1;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_CHEST=`echo "$UNDER_ME_LIST" | grep 'chest' | wc -l`

test "`echo "$UNDER_ME_LIST" | grep 'chest.*cursed'`" && {
_draw 3 "You appear to stand upon some cursed chest!"
beep -l 1000 -f 700
test "$1" && return 1 || exit 1
}

test "`echo "$UNDER_ME_LIST" | grep -E 'chest$|chests$'`" || {
_draw 3 "You appear not to stand on some chest!"
beep -l 1000 -f 700
test "$1" && return 1 || exit 1
}

test "`echo "$UNDER_ME_LIST" | tail -n1 | grep 'chest.*cursed'`" && {
_draw 3 "Topmost chest appears to be cursed!"
beep -l 1000 -f 700
test "$1" && return 1 || exit 1
}

test "`echo "$UNDER_ME_LIST" | tail -n1 | grep -E 'chest$|chests$'`" || {
_draw 3 "Chest appears not topmost!"
beep -l 1000 -f 700
test "$1" && return 1 || exit 1
}

return 0
}

_pickup(){
__is 0 0 pickup ${*:-0}
}

_search_traps(){
cnt=9
_draw 5 "Searching traps ..."

while :
do

_draw 5 "Searching traps $cnt times ..."

echo watch $DRAWINFO
__is 0 0 search
sleep 1


 while :
 do
 unset REPLY
 read -t $TMOUT
 _log "$REPLY"
 _debug "$REPLY"

#You spot a Rune of Burning Hands!
#You spot a poison needle!
#You spot a spikes!
#You spot a Rune of Shocking!
#You spot a Rune of Icestorm!
#You search the area.

 case $REPLY in
 *' spot '*) FOUND_TRAP=$((FOUND_TRAP+1));;
 *'You search the area.') break 1;;
 '') break 1;;
 *) :;;
 esac

 sleep 1
 done

TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
unset FOUND_TRAP

echo unwatch $DRAWINFO
sleep 1


cnt=$((cnt-1))
test $cnt -gt 0 || break 1

done

unset cnt
}

_disarm_traps(){
_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "Disarming ${TRAPS:-0} traps ..."

echo watch $DRAWINFO
__is 0 0 use_skill disarm
sleep 1

 unset REPLY
 while :
 do
 read -t $TMOUT
 _log "$REPLY"
 _debug "$REPLY"

#You fail to disarm the Rune of Burning Hands.
#In fact, you set it off!
#You detonate a Rune of Burning Hands!
#You successfully disarm the spikes!
#You fail to disarm the Rune of Icestorm.

 case $REPLY in
 *'You successfully disarm'*)  TRAPS=$((TRAPS-1));;
 *'You fail to disarm'*) :;;
 *'In fact, you set it off!'*) TRAPS=$((TRAPS-1));;
 *'You detonate'*) _just_exit 1;;
 *'You are pricked'*) :;;
 *) :;;
 esac

 sleep 1
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

# when trap is triggered,
# it might be wise to pick up the chests,
# so they do not get burned or icecubed
__is 1 1 $DIRB
sleep 1
__is 1 1 $DIRB
sleep 1

__is 1 1 $DIRF
sleep 1
__is 1 1 $DIRF
sleep 1

echo unwatch $DRAWINFO
sleep 1

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

_open_chests(){
_draw 5 "Opening chests ..."

_check_if_on_chest -l || return 0
sleep 1

while :
do

__is 1 1 apply
sleep 1
# TODO : You find*Rune of*

__is 1 1 $DIRB
sleep 1
__is 1 1 $DIRB
sleep 1

_pickup 4
sleep 1

__is 1 1 $DIRF
sleep 1
__is 1 1 $DIRF
sleep 1

_pickup 0
sleep 1

_drop_chest
sleep 1
_check_if_on_chest -l || break 1
sleep 1
_draw 5 "$NUMBER_CHEST chest(s) to open ..."

__is 1 1 $DIRB
sleep 1
__is 1 1 $DIRB
sleep 1
__is 1 1 $DIRF
sleep 1
__is 1 1 $DIRF

sleep 1
done

}

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main scrip

LOGGING=1
_set_global_variables
LOGGING=1

_say_start_msg

_drop_chest
sleep 1
_check_if_on_chest
sleep 1
_pickup 0
sleep 1

_search_traps

_disarm_traps

_open_chests

_say_end_msg
