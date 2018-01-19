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
#  dropping chests and using a middle value of both
VERSION=0.4 # code cleanup 2018-01-08

VERSION=1.0 # added options to choose between
# use_skill, cast and invoke to disarm traps
VERSION=1.1 # added NUMBER option
# Recognize *help and *version options
VERSION=1.2 # if no DIRECTION then default to invoke
# if cast was given
VERSION=1.3 # handle chest as permanent container: exit.
# handle portal of elementals: exit.
VERSION=1.3.1 # count opened chests
VERSION=2.0 # use sourced functions files
VERSION=2.1 # implement -M option
VERSION=2.1.1 # bugfixes
VERSION=2.2 # more alternative functions

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

#. $HOME/cf/s/cf_functions.sh || exit 2

. $HOME/cf/s/cf_funcs_common.sh || exit 4
. $HOME/cf/s/cf_funcs_food.sh   || exit 5
. $HOME/cf/s/cf_funcs_traps.sh  || exit 6
. $HOME/cf/s/cf_funcs_move.sh   || exit 7
. $HOME/cf/s/cf_funcs_chests.sh || exit 8

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to search for traps,"
_draw 7  "disarming them,"
_draw 7  "and open chest(s)."
_draw 6  "Syntax:"
_draw 7  "$0 <<NUMBER>> <<Options>>"
_draw 8  "Options:"
_draw 10 "Simple number:Just open NUMBER chests."
_draw 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw 10 "-M   :Do not break search when found first trap,"
_draw 10 "      usefull if chests have more than one trap."
_draw 11 "-V   :Print version information."
_draw 12 "-c   :cast spell disarm"
_draw 12 "-i   :invoke spell disarm"
_draw 12 "-u   :use_skill disarm"
_draw 10 "-d   :Print debugging to msgpane."
exit ${1:-2}
}

__say_version(){
_draw 6 "$MY_BASE Version:$VERSION"
exit ${1:-2}
}

___debug(){  ##+++2018-01-06
test "$DEBUG" || return 0
cnt=0
echo "$*" | while read line
do
cnt=$((cnt+1))
    echo draw 3 "___DEBUG:$cnt:$line"
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

__drop_chest(){
local lITEM="$*"
_is 0 0 drop ${lITEM:-chest}
sleep 3
}

__set_pickup(){
# TODO: Seems to pick up only
# one piece of the item, if more than one
# piece of the item, as 4 coins or 23 arrows
# in _open_chests() ..?
#_is 0 0 pickup ${*:-0}
#_is 1 0 pickup ${*:-0}
#_is 0 1 pickup ${*:-0}
 _is 1 1 pickup ${*:-0}
}

__move_back(){  ##+++2018-01-08
test "$DIRB" || return 0
for i in `seq 1 1 ${1:-1}`
do
_is 1 1 $DIRB
_sleep
done
}

__move_forth(){  ##+++2018-01-08
test "$DIRF" || return 0
for i in `seq 1 1 ${1:-1}`
do
_is 1 1 $DIRF
_sleep
done
}

__move_back_and_forth(){  ##+++2018-01-08
STEPS=${1:-1}

#test "$DIRB" -a "$DIRF" || return 0
test "$DIRB" || return 0
for i in `seq 1 1 $STEPS`
do
_is 1 1 $DIRB
_sleep
done

if test "$2"; then shift
 while test "$1";
 do
 #oIFS=$IFS
 #IFS=';'
 COMMANDS=`echo "$1" | tr ';' '\n'`
 test "$COMMANDS" || break 1
  echo "$COMMANDS" | while read line
  do
  $line
  sleep 0.1
  done

 #IFS=$oIFS
 shift
 sleep 0.1
 done
fi

test "$DIRF" || return 0
for i in `seq 1 1 $STEPS`
do
_is 1 1 $DIRF
_sleep
done
}

__check_if_on_item_examine(){
# Using 'examine' directly after dropping
# the item examines the bottommost tile
# as 'That is marble'
_debug "__check_if_on_item_examine:$*"

local DO_LOOP TOPMOST
unset DO_LOOP TOPMOST

while [ "$1" ]; do
case $1 in
-l) DO_LOOP=1;;
-t) TOPMOST=1;;
-lt|-tl) DO_LOOP=1; TOPMOST=1;;
*) break;;
esac
shift
done

local lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

_draw 5 "Checking if standing on $lITEM ..."

_watch $DRAWINFO
_is 0 0 examine
while :; do unset REPLY
read -t $TMOUT
 _log "__check_if_on_item_examine:$REPLY"
 _msg 7 "$REPLY"

 case $REPLY in
  *"That is"*"$lITEM"*|*"Those are"*"$lITEM"*) break 1;;
  *"That is"*|*"Those are"*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1;;
  '') break 1;;
  *) :;;
 esac

 sleep 0.01
done

_unwatch
_empty_message_stream
echo "$REPLY" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es"
}

__check_if_on_chest_request_items_on__(){
_debug "__check_if_on_chest_request_items_on__:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST
#
#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

#_draw 5 "Checking if standing on chests ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "__check_if_on_chest_request_items_on__:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)    _exit 1;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.01s
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

_check_if_on_chest_request_items_on_(){
_debug "_check_if_on_chest_request_items_on_:$*"
local lRV
unset lRV

#_draw 5 "Checking if standing on chests ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "_check_if_on_chest_request_items_on_:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${REPLY##*?break};;
*scripttell*exit*)      _exit 1;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_CHEST=`echo "$UNDER_ME_LIST" | grep 'chest' | wc -l`

test "`echo "$UNDER_ME_LIST" | grep 'chest.*cursed'`" && lRV=5
test "`echo "$UNDER_ME_LIST" | grep -E 'chest$|chests$'`" || lRV=6
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep 'chest.*cursed'`" && lRV=7
test "`echo "$UNDER_ME_LIST" | tail -n1 | grep -E 'chest$|chests$'`" || lRV=8

return ${lRV:-0}
}

__eval_check_if_on_chest_request_items_on(){
_debug "__eval_check_if_on_chest_request_items_on:$*"

  __check_if_on_chest_request_items_on
  local lRV=$?
case $lRV in
5) _draw 3 "You appear to stand upon some cursed chest!";;
6) _draw 3 "You appear not to stand on some chest!";;
7) _draw 3 "Topmost chest appears to be cursed!";;
8) _draw 3 "Chest appears not topmost!";;
0) return 0;;
*) _warn "_eval_check_if_on_chest_request_items_on:Unhandled return value '$lRV'";;
esac
beep -l 1000 -f 700
test "$1" && return 1 || exit 1
}

__check_if_on_chest__(){  ###+++2018-01-19
_debug "__check_if_on_chest__:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST
#
#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

_draw 5 "Checking if standing on chests ..."

#__check_if_on_item_examine $1 chest    && return 0
#__check_if_on_chest_request_items_on__ && return 0

  _check_if_on_chest_request_items_on_
  local lRV=$?
case $lRV in
5) _draw 3 "You appear to stand upon some cursed chest!";;
6) _draw 3 "You appear not to stand on some chest!";;
7) _draw 3 "Topmost chest appears to be cursed!";;
8) _draw 3 "Chest appears not topmost!";;
0) return 0;;
*) _warn "__check_if_on_chest__:Unhandled return value '$lRV'";;
esac
beep -l 1000 -f 700
test "$1" && return 1 || exit 1
}

__check_if_on_chest(){
_debug "__check_if_on_chest:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST
#
#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

_draw 5 "Checking if standing on chests ..."

#__check_if_on_item_examine__ $1 chest
#__check_if_on_chest_request_items_on__ $1
__eval_check_if_on_chest_request_items_on $1
}


__search_traps(){
_debug "__search_traps:$*"

cnt=${SEARCH_ATTEMPTS:-$SEARCH_ATTEMPTS_DEFAULT}
_draw 5 "Searching traps ..."
test "$cnt" -gt 0 || return 0

TRAPS_ALL_OLD=0
TRAPS_ALL=$TRAPS_ALL_OLD

while :
do

_draw 5 "Searching traps $cnt time(s) ..."

#echo watch ${DRAWINFO}
_watch ${DRAWINFO}
_sleep
_is 0 0 search
_sleep

 unset cnt0 FOUND_TRAP
 while :
 do
 cnt0=$((cnt0+1))
 unset REPLY
 read -t $TMOUT
 _log "__search_traps:$cnt0:$REPLY"
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
 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1;;
 '') break 1;;
 *) :;;
 esac

 sleep 0.1
 done

test "$FOUND_TRAP" && _draw 2 "Found $FOUND_TRAP trap(s)."
TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
_debug "TRAPS_ALL=$TRAPS_ALL"
test "$TRAPS_ALL_OLD" -gt $TRAPS_ALL && TRAPS_ALL=$TRAPS_ALL_OLD
_debug "TRAPS_ALL=$TRAPS_ALL"
TRAPS_ALL_OLD=${TRAPS_ALL:-0}
_debug "FOUND_TRAP=$FOUND_TRAP TRAPS_ALL_OLD=$TRAPS_ALL_OLD"

_unwatch $DRAWINFO
_sleep

test "$MULTIPLE_TRAPS" || {
    test "$TRAPS_ALL" -ge 1 && break 1; }

cnt=$((cnt-1))
test "$cnt" -gt 0 || break 1

done

unset cnt
}

__cast_disarm(){
_debug "__cast_disarm:$*"
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "${TRAPS:-0} trap(s) to disarm ..."

# TODO: checks for enough mana
#echo watch $DRAWINFO
_watch $DRAWINFO
_is 0 0 cast disarm
_sleep
_is 0 0 fire 0
_is 0 0 fire_stop
_sleep

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "__cast_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) break 2;; #_just_exit 1;;
 *'Something blocks your spellcasting.') _exit 1;;
 *scripttell*break*)   break 2;;
 *scripttell*exit*)    _exit 1;;
 *) :;;
 esac

 sleep 0.1
 done

_unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

_unwatch $DRAWINFO
}

__invoke_disarm(){ ## invoking does to a direction
_debug "__invoke_disarm:$*"
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
_draw 5 "${TRAPS:-0} trap(s) to disarm ..."

#echo watch $DRAWINFO
_watch $DRAWINFO
_is 0 0 invoke disarm
_sleep

#There's nothing there!
#You fail to disarm the diseased needle.
#You successfully disarm the diseased needle!
 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "__invoke_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 # Here there could be a trap next to the stack of chests ...
 # so invoking disarm towards the stack of chests would not
 # work to disarm the traps elsewhere on tiles around
 *"There's nothing there!"*) break 2;;
 *'Something blocks your spellcasting.') _exit 1;;
 *scripttell*break*)   break 2;;
 *scripttell*exit*)    _exit 1;;
 *) :;;
 esac
 done

_unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

_unwatch $DRAWINFO
_move_forth 1
}

__use_skill_disarm(){
_debug "__use_skill_disarm:$*"
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "${TRAPS:-0} trap(s) to disarm ..."

#echo watch $DRAWINFO
_watch $DRAWINFO
_is 0 0 use_skill disarm
_sleep

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
 _log "__use_skill_disarm:$cnt0:$REPLY"
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
 *'A portal opens up, and screaming hordes pour'*) _just_exit 1;;
 *'through!'*)     _just_exit 1;;
 *'You are pricked'*) :;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit 1;;
 '') break 1;;
 *) :;;
 esac

 _sleep
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

_move_back_and_forth 2

_unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

__disarm_traps(){
_debug "__disarm_traps:$*"
_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
case "$DISARM" in
invokation) _invoke_disarm;;
cast|spell) #case "$DIRECTION" in '') _invoke_disarm;; *) _cast_disarm;; esac;;
            _cast_disarm;;
skill|'') _use_skill_disarm;;
*) _error "DISARM variable set not to skill, invokation OR cast'";;
esac
}

__open_chests(){
_debug "__open_chests:$*"

_draw 5 "Opening chests ..."

unset one
while :
do
one=$((one+1))

#__check_if_on_item_examine -l chest || break 1
#__check_if_on_chest_request_items_on__ -l || break 1
# _check_if_on_chest_request_items_on_ -l || break 1
__check_if_on_chest -l || break 1

_sleep
_draw 5 "${NUMBER_CHEST:-?} chest(s) to open ..."

_move_back_and_forth 2

_watch
_is 1 1 apply
#_sleep
 unset OPEN_COUNT
 while :; do unset REPLY
 read -t ${TMOUT:-1}
 _log "__open_chests:$REPLY"
 _msg 7 "$REPLY"
 case $REPLY in
 *'You find'*)   OPEN_COUNT=1;;
 *empty*)        OPEN_COUNT=1;;
 *'You open chest.'*) break 2;; # permanent container
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit 1;;
 '') break 1;;
 esac
 sleep 0.01
 done
_unwatch
test "$OPEN_COUNT" && CHEST_COUNT=$((CHEST_COUNT+1))
# TODO : You find*Rune of*
#You find Blades trap in the chest.
#You set off a Blades trap!
#You find silver coins in the chest.
#You find booze in the chest.
#You find Rune of Shocking in the chest.
#You detonate a Rune of Shocking
#The chest was empty.
#11:50 You open chest.
#11:50 You close chest (open) (active).

_move_back_and_forth 2 "_set_pickup 4;_sleep;"

_set_pickup 0
_sleep

case $NUMBER in $one) break 1;; esac

#__drop_chest
_drop chest
_sleep

done
}

_do_parameters(){
_debug "_do_parameters:$*"

# dont forget to pass parameters when invoking this function
test "$*" || return 0

case $1 in [0-9]*) NUMBER=$1; shift;;
*help)    _say_help 0;;
*version) _say_version 0;;
esac

# S # :Search attempts
# u   :use_skill
# c   :cast disarm
# i   :invoke disarm
# d   :debugging output
while getopts S:ciudMVhabdefgjklmnopqrstvwxyzABCDEFGHIJKLNOPQRTUWXYZ oneOPT
do
case $oneOPT in
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;
M) MULTIPLE_TRAPS=$((MULTIPLE_TRAPS+1));;
c) DISARM=cast;;
i) DISARM=invokation;;
u) DISARM=skill;;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}

#MAIN
_set_global_variables $*
_say_start_msg $*
_do_parameters $*

#_check_for_space 2
test "$FUNCTION_CHECK_FOR_SPACE" && $FUNCTION_CHECK_FOR_SPACE 2
_sleep

_get_player_speed
PL_SPEED2=$PL_SPEED1
_sleep

#__drop_chest
_drop chest
_sleep
_set_pickup 0
_move_back_and_forth 2 # this is needed for __check_if_on_item_examine

_get_player_speed
PL_SPEED3=$PL_SPEED1
_sleep
PL_SPEED4=$(( (PL_SPEED2+PL_SPEED3) / 2 ))
#_set_sync_sleep ${PL_SPEED4:-$PL_SPEED}
test "$PL_SPEED4" && __set_sync_sleep ${PL_SPEED4} || _set_sync_sleep "$PL_SPEED"

_main_open_chests(){
_debug "_main_open_chests:$*"
#_sleep
#_set_pickup 0
_sleep

_search_traps
_disarm_traps
_open_chests
}

__main_open_chests(){
_debug "__main_open_chests:$*"
#_sleep
#__set_pickup 0
_sleep

__search_traps
__disarm_traps
__open_chests
}

#__check_if_on_item_examine chest && __main_open_chests
#__check_if_on_item_examine chest &&  _main_open_chests
#__check_if_on_chest_request_items_on && __main_open_chests
# _check_if_on_chest_request_items_on &&  _main_open_chests

#_check_if_on_chest && _main_open_chests
__check_if_on_chest && __main_open_chests

_draw 8 "You opened ${CHEST_COUNT:-0} chest(s)."

_say_end_msg
###END###
