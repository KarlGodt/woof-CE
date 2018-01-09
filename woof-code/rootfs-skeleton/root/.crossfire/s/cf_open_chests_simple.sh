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
# This script was written mainly from memory,
# but used the function _check_if_on_cauldron()
# with modifications for _check_if_on_chest()
# from the cf_functions.sh already available.
# Also used the existing functions
# _is, _draw, _debug, _log, _set_global_variables,
# _say_start_msg, _say_end_msg from cf_functions.sh .
# Added __debug() function to cf_functions.sh
# to draw multiple lines given.

VERSION=0.0
VERSION=0.1 # added parameter processing
# added help and version message
# added script run time message
# reordered some code lines
# early exit if rare ball lightning
# do not break for 'You search the area' message,
#  since that seems to not be in sync with other messages
VERSION=0.2 # code reorderings, smaller bugfixes
VERSION=0.3 # instead using _debug now using a MSGLEVEL
# using PL_SPEED variable before dropping chests and after
# dropping chests and using a middle value of both
VERSION=0.4 # code cleanup 2018-01-08
VERSION=1.0 # added options to choose between
# use_skill, cast and invoke to disarm traps

SEARCH_ATTEMPTS_DEFAULT=9
#DISARM variable set to skill, invokation OR cast
DISARM=skill

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script

#DEBUG=1
#LOGGING=1
MSGLEVEL=6 # Message Levels 1-7 to print to the msg pane

#DRAWINFO=drawextinfo # client gtk2 1.12.svn

. $HOME/cf/s/cf_functions.sh || exit 2

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to search for traps,"
_draw 7  "disarming them,"
_draw 7  "and open chest(s)."
_draw 8  "Options:"
_draw 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw 11 "-V   :Print version information."
_draw 12 "-c   :cast spell disarm"
_draw 12 "-i   :invoke spell disarm"
_draw 12 "-u   :use_skill disarm"
_draw 10 "-d   :Print debugging to msgpane"
exit ${1:-2}
}

_say_version(){
_draw 6 "$MY_BASE Version:$VERSION"
exit ${1:-2}
}

___debug(){  ##+++2018-01-06
test "$DEBUG" || return 0
cnt=0
echo "$*" | while read line
do
cnt=$((cnt+1))
    echo draw 3 "__DEBUG:$cnt:$line"
done
unset cnt line
}

__is(){
_msg 7 "$*"
Z1=$1; shift
Z2=$1; shift
_msg 7 "$*"
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
_log "$ON_LOG" "_check_if_on_chest:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break 1;;
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
# TODO: Seems to pick up only
# one piece of the item, if more than one
# piece of the item, as 4 coins or 23 arrows
# in _open_chests() ..?
__is 0 0 pickup ${*:-0}
}

_search_traps(){
cnt=${SEARCH_ATTEMPTS:-$SEARCH_ATTEMPTS_DEFAULT}
_draw 5 "Searching traps ..."
test "$cnt" -gt 0 || return 0

TRAPS_ALL_OLD=0
while :
do

_draw 5 "Searching traps $cnt times ..."

echo watch ${DRAWINFO}
_sleep
__is 0 0 search
_sleep

 unset cnt0
 while :
 do
 cnt0=$((cnt0+1))
 unset REPLY
 read -t $TMOUT
 _log "_search_traps:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

#You spot a Rune of Burning Hands!
#You spot a poison needle!
#You spot a spikes!
#You spot a Rune of Shocking!
#You spot a Rune of Icestorm!
#You search the area.
#You spot a Rune of Ball Lightning!
 case $REPLY in
 *'You spot a Rune of Ball Lightning!'*) _just_exit 0;;
 *' spot '*) FOUND_TRAP=$((FOUND_TRAP+1));;
 *'You search the area.'*) SEARCH_MSG=$((SEARCH_MSG+1));; # break 1;;
 '') break 1;;
 *) :;;
 esac

 _sleep
 done

TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
_debug "TRAPS_ALL=$TRAPS_ALL"
test "$TRAPS_ALL_OLD" -gt $TRAPS_ALL && TRAPS_ALL=$TRAPS_ALL_OLD
_debug "TRAPS_ALL=$TRAPS_ALL"
TRAPS_ALL_OLD=${TRAPS_ALL:-0}
_debug "FOUND_TRAP=$FOUND_TRAP TRAPS_ALL_OLD=$TRAPS_ALL_OLD"

unset FOUND_TRAP

echo unwatch $DRAWINFO
_sleep


cnt=$((cnt-1))
test $cnt -gt 0 || break 1

done

unset cnt
}

_cast_disarm(){
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "${TRAPS:-0} traps to disarm ..."

# TODO: checks for enough mana
echo watch $DRAWINFO
__is 0 0 cast disarm
_sleep
__is 0 0 fire 0
__is 0 0 fire_stop
_sleep

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "_cast_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) break 2;; #_just_exit 1;;
 *) :;;
 esac

 sleep 0.1
 done

echo unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

echo unwatch $DRAWINFO
}

_invoke_disarm(){ ## invoking does to a direction
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

_move_back 2
_move_forth 1
_sleep

while :
do
_draw 5 "${TRAPS:-0} traps to disarm ..."

echo watch $DRAWINFO
__is 0 0 invoke disarm
_sleep

#There's nothing there!
#You fail to disarm the diseased needle.
#You successfully disarm the diseased needle!
 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "_invoke_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 # Here there could be a trap next to the stack of chests ...
 # so invoking disarm towards the stack of chests would not
 # work to disarm the traps elsewhere on tiles around
 *"There's nothing there!"*) break 2;; #_just_exit 1;;
 *) :;;
 esac
 done

echo unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

echo unwatch $DRAWINFO
_move_forth 1
}

_use_skill_disarm(){
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "${TRAPS:-0} traps to disarm ..."

echo watch $DRAWINFO
__is 0 0 use_skill disarm
_sleep

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "_use_skill_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

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
 '') break 1;;
 *) :;;
 esac

 _sleep
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

_move_back_and_forth 2

echo unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

_disarm_traps(){
_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
case "$DISARM" in
invokation) _invoke_disarm;;
cast|spell) _cast_disarm;;
skill|'') _use_skill_disarm;;
*) _error "DISARM variable set not to skill, invokation OR cast'";;
esac
}

_open_chests(){
_draw 5 "Opening chests ..."

while :
do

_check_if_on_chest -l || break 1
_sleep
_draw 5 "$NUMBER_CHEST chest(s) to open ..."

_move_back_and_forth 2

__is 1 1 apply
_sleep
# TODO : You find*Rune of*
#You find Blades trap in the chest.
#You set off a Blades trap!
#You find silver coins in the chest.
#You find booze in the chest.
#You find Rune of Shocking in the chest.
#You detonate a Rune of Shocking
#The chest was empty.

_move_back_and_forth 2 "_pickup 4;_sleep;"

_pickup 0
_sleep

_drop_chest
_sleep

#_sleep
done

}

_do_parameters(){
# dont forget to pass parameters when invoking this function
test "$*" || return 0

# S # :Search attempts
# u   :use_skill
# c   :cast disarm
# i   :invoke disarm
# d   :debugging output
while getopts S:ciudVhabdefgjklmnopqrstvwxyzABCDEFGHIJKLMNOPQRTUWXYZ oneOPT
do
case $oneOPT in
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;
c) DISARM=cast;;
i) DISARM=invokation;;
u) DISARM=skill;;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' ."
esac

sleep 0.1
done

}

#MAIN
_set_global_variables $*
_say_start_msg $*
_do_parameters $*

_get_player_speed
PL_SPEED2=$PL_SPEED1
_sleep
_drop_chest
_sleep
_get_player_speed
PL_SPEED3=$PL_SPEED1
_sleep
PL_SPEED4=$(( (PL_SPEED2+PL_SPEED3) / 2 ))
_set_sync_sleep

_check_if_on_chest
_sleep
_pickup 0
_sleep

_search_traps

_disarm_traps

_open_chests

_say_end_msg

###END###
