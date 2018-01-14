#!/bin/ash

# Who:
# Created by Karl Reimer Godt
# First version 2018-01-06
# Time elapsed for the crossfire client
# while writing the script was 5,5 hours;
# which included fixes to cf_open_chests_simple.sh .
# Most time took error fixes after testing the script.
# Bugs are still likely :( !
#
# About:
# Script to open door
# for the roleplaying game Crossfire.
# Simple script that does not finetune
# trap handling.
# In case of detonating a trap while
# disarming, it does just exit.
#
# Reason:
# I wrote this script because of lazyness,
# since such scripts to open a door already exist
# in my repositories, but I was too lazy to
# search for these similar scripts.
#
# Style:
# This script was written mainly from memory,
# using the script cf_open_chests_simple.sh .
# Also used the existing functions
# _is, _draw, _debug, _log, _set_global_variables,
# _say_start_msg, _say_end_msg from cf_functions.sh .

VERSION=0.0
VERSION=0.1 # code reorderings, smaller bugfixes
VERSION=0.2 # instead using _debug now using a MSGLEVEL

VERSION=1.0 # added option to choose between
# use_skill, cast and invoke to disarm traps
VERSION=1.1 # bugfix in _open_door_with_standard_key()
# was missing a '-' in ${1:-$DIRECTION}
VERSION=1.2 # bugfixes in regards to unexpected
# settings of variables
VERSION=1.3 # Recognize *help and *version options
VERSION=2.0 # use sourced functions files

LOCKPICK_ATTEMPTS_DEFAULT=9
SEARCH_ATTEMPTS_DEFAULT=9

#DISARM variable set to skill, invokation OR cast
DISARM=skill

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script

DRAWINFO=drawinfo # client 1.12.svn seems to accept both drawinfo and drawextinfo
# client gtk1 1.12.svn needs drawinfo, but gtk2 1.12.svn needs drawextinfo
DEBUG=1
LOGGING=1
MSGLEVEL=6 # Message Levels 1-7 to print to the msg pane

. $HOME/cf/s/cf_funcs_common.sh || exit 4
. $HOME/cf/s/cf_funcs_traps.sh  || exit 5
. $HOME/cf/s/cf_funcs_move.sh   || exit 6
. $HOME/cf/s/cf_funcs_chests.sh || exit 7

_say_help(){
_draw 6  "$MY_BASE"
_draw 7  "Script to search for traps,"
_draw 7  "disarming them,"
_draw 7  "and lockpick a door."
_draw 8  "Options:"
_draw 9  "-S # :Number of search attempts, default $SEARCH_ATTEMPTS_DEFAULT"
_draw 9  "-L # :Number of lockpick attempts, deflt $LOCKPICK_ATTEMPTS_DEFAULT"
_draw 9  "-D # :Direction [0-8] to go"
_draw 10 "-I   :Do infinte attempts to lockpick door,"
_draw 10 "      use scriptkill command to terminate."
_draw 11 "-V   :Print version information."
_draw 12 "-c   :cast spell disarm"
_draw 12 "-i   :invoke spell disarm"
_draw 12 "-u   :use_skill disarm"
_draw 10 "-d   :Print debugging to msgpane"

exit ${1:-2}
}

__say_version(){
_draw 6 "$MY_BASE Version:$VERSION"
exit ${1:-2}
}

__is(){
_msg 7 "__is:$*"
Z1=$1; shift
Z2=$1; shift
_msg 7 "__is:$*"
echo issue $Z1 $Z2 $*
unset Z1 Z2
sleep 0.2
}


__search_traps(){
cnt=${SEARCH_ATTEMPTS:-$SEARCH_ATTEMPTS_DEFAULT}
_draw 5 "Searching traps ..."

TRAPS_ALL=0
TRAPS_ALL_OLD=$TRAPS_ALL

while :
do

_draw 5 "Searching traps $cnt time(s) ..."

_watch $DRAWINFO
__is 0 0 search
_sleep

 while :
 do
 unset REPLY
 read -t $TMOUT
 _log "__search_traps:$REPLY"
 _msg 7 "$REPLY"

#You spot a Rune of Burning Hands!
#You spot a poison needle!
#You spot a spikes!
#You spot a Rune of Shocking!
#You spot a Rune of Icestorm!
#You search the area.

 case $REPLY in
 *'You spot a Rune of Ball Lightning!'*) _just_exit 0;;
 *' spot '*) FOUND_TRAP=$((FOUND_TRAP+1));;
 *'You search the area.'*) break 1;;
 '') break 1;;
 *) :;;
 esac

 _sleep
 done

test "$FOUND_TRAP" && _draw 2 "Found $FOUND_TRAP trap(s)."
TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
test "$TRAPS_ALL_OLD" -gt $TRAPS_ALL && TRAPS_ALL=$TRAPS_ALL_OLD
TRAPS_ALL_OLD=${TRAPS_ALL:-0}

unset FOUND_TRAP

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
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "${TRAPS:-0} trap(s) to disarm ..."

_watch $DRAWINFO
_turn_direction $DIRECTION cast disarm

# TODO: checks for enough mana
#_watch $DRAWINFO
#__is 0 0 cast disarm
#_sleep
#__is 0 0 fire $DIRECTION
#__is 0 0 fire_stop
#_sleep

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
 *"There's nothing there!"*) _just_exit 1;;
 *) :;;
 esac

 sleep 0.1
 done

_unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done
}

__invoke_disarm(){ ## invoking does to a direction
#_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "${TRAPS:-0} trap(s) to disarm ..."

#_turn_direction $DIRECTION

_watch $DRAWINFO
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
 _log "__invoke_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) _just_exit 1;;
 *) :;;
 esac
 done

_unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

}

__use_skill_disarm(){
_draw 5 "Disarming ${TRAPS_ALL:-0} trap(s) ..."
test "$TRAPS_ALL" || return 0
test "${TRAPS_ALL//[0-9]/}" && return 2
test "$TRAPS_ALL" -gt 0     || return 0

TRAPS=$TRAPS_ALL

while :
do
_draw 5 "Disarming ${TRAPS:-0} trap(s) ..."

_watch $DRAWINFO
__is 0 0 use_skill disarm
_sleep

 unset REPLY
 while :
 do
 read -t $TMOUT
 _log "__use_skill_disarm:$REPLY"
 _msg 7 "$REPLY"

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

 _sleep
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

_unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

__disarm_traps(){
_draw 5 "Disarming ${TRAPS_ALL:-0} trap(s) ..."
case "$DISARM" in
invokation) _invoke_disarm;;
cast|spell) case "$DIRECTION" in '') _invoke_disarm;; *) _cast_disarm;; esac;;
            # _cast_disarm;;
skill|'') _use_skill_disarm;;
*) _error "DISARM variable set not to skill, invokation OR cast'";;
esac
}

__lockpick_door(){
_draw 5 "Attempting to lockpick the door ..."

cnt=${LOCKPICK_ATTEMPTS:-$LOCKPICK_ATTEMPTS_DEFAULT}
test "$cnt" -gt 0 || return 1  # to trigger _open_door_with_standard_key

unset RV cnt1
while :
do

cnt1=$((cnt1+1))
test "$INFINITE" && _draw 5 "${cnt1}. attempt .." || _draw 5 "$cnt attempts in lockpicking skill left .."

_watch $DRAWINFO
#_sleep
__is 1 1 use_skill lockpicking
_sleep

 unset cnt0 REPLY
 while :
 do
 cnt0=$((cnt0+1))
 #unset REPLY
 read -t ${TMOUT:-1}
 _log "__lockpick_door:$REPLY"
 _msg 7 "__lockpick_door:$REPLY"

 case $REPLY in
 *there*is*no*door*) RV=4; break 2;; #return 4;;

 *'There is no lock there.'*) RV=0; break 2;; #return 0;;
 *'You pick the lock.'*)      RV=0; break 2;; #return 0;;
 *'The door has no lock!'*)   RV=0; break 2;; #return 0;;

 *'You fail to pick the lock.'*) break 1;;
 '') break 1;; # :;;
 *)  :;;
 esac

 test "$cnt0" -gt 9 && break 1 # emergency break
 _sleep
 done

_unwatch $DRAWINFO

test "$INFINITE" || {
    cnt=$((cnt-1))
    test "$cnt" -gt 0 || break 1
}

_sleep
done

#DEBUG=1 _debug "RV=$RV"
return ${RV:-1}
}

__open_door_with_standard_key(){
#DEBUG=1 _debug "_open_door_with_standard_key:$*"
DIRECTION=${1:-$DIRECTION}
#DEBUG=1 _debug "DIRECTION=$DIRECTION"
test "$DIRECTION" || return 0
_number_to_direction "$DIRECTION"
#DEBUG=1 _debug "DIRECTION=$DIRECTION"
_is 0 0 $DIRECTION
}

__direction_to_number(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 0

DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=0;;
1|north|n)         DIRECTION=1;;
2|northeast|ne)    DIRECTION=2;;
3|east|e)          DIRECTION=3;;
4|southeast|se)    DIRECTION=4;;
5|south|s)         DIRECTION=5;;
6|southwest|sw)    DIRECTION=6;;
7|west|w)          DIRECTION=7;;
8|northwest|nw)    DIRECTION=8;;
*) ERROR=1 _error "Not recognized: '$DIRECTION'"
esac
}

__number_to_direction(){
DIRECTION=${1:-$DIRECTION}
test "$DIRECTION" || return 0
DIRECTION=`echo "$DIRECTION" | tr '[A-Z]' '[a-z]'`
case $DIRECTION in
0|center|centre|c) DIRECTION=center;;
1|north|n)         DIRECTION=north;;
2|northeast|ne)    DIRECTION=northeast;;
3|east|e)          DIRECTION=east;;
4|southeast|se)    DIRECTION=southeast;;
5|south|s)         DIRECTION=south;;
6|southwest|sw)    DIRECTION=southwest;;
7|west|w)          DIRECTION=west;;
8|northwest|nw)    DIRECTION=northwest;;
*) ERROR=1 _error "Not recognized: '$DIRECTION'"
esac
}

__turn_direction(){
test "$3" && { DIRECTION=${1:-DIRECTION}; shift; }
test "$DIRECTION" || return 0

_direction_to_number $DIRECTION
_is 0 0 ${1:-ready_skill} ${2:-lockpicking}
_is 0 0 fire $DIRECTION
_is 0 0 fire_stop
}

_do_parameters(){
# dont forget to pass parameters when invoking this function
test "$*" || return 0

case $1 in
*help)    _say_help 0;;
*version) _say_version 0;;
esac

# S # :Search attempts
# D # :Direction to open door
# I   :Infinte lockpick attempts
while getopts S:D:L:IVhabcdefgijklmnopqrstuvwxyzABCEFGHJKMNOPQRTUWXYZ oneOPT
do
case $oneOPT in
D) DIRECTION=${OPTARG:-0};;
I) INFINITE=1;;
L) LOCKPICK_ATTEMPTS=${OPTARG:-$LOCKPICK_ATTEMPTS_DEFAULT};;
S) SEARCH_ATTEMPTS=${OPTARG:-$SEARCH_ATTEMPTS_DEFAULT};;

M) MULTIPLE_TRAPS=$((MULTIPLE_TRAPS+1));;

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
_set_sync_sleep

#__turn_direction $DIRECTION cast "show invisible"
  _turn_direction $DIRECTION ready_skill "literacy"

#__search_traps
  _search_traps

#__disarm_traps
  _disarm_traps

#__lockpick_door
  _lockpick_door
RV=$?
#DEBUG=1 _debug "RV=$RV"
case $RV in
0) :;;
*) #__open_door_with_standard_key $DIRECTION;;
     _open_door_with_standard_key $DIRECTION;;
esac

_unwatch $DRAWINFO

_say_end_msg

###END###
