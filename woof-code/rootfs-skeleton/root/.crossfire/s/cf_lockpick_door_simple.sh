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

LOCKPICK_ATTEMPTS_DEFAULT=9
SEARCH_ATTEMPTS_DEFAULT=9

VERSION=0.0
VERSION=0.1 # code reorderings, smaller bugfixes
VERSION=0.2 # instead using _debug now using a MSGLEVEL

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script

DRAWINFO=drawinfo # client 1.12.svn seems to accept both drawinfo and drawextinfo
# client gtk1 1.12.svn needs drawinfo
#DEBUG=1
LOGGING=1
MSGLEVEL=7 # Message Levels 1-7 to print to the msg pane

. $HOME/cf/s/cf_functions.sh || exit 2

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

exit ${1:-2}
}

_say_version(){
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


_search_traps(){
cnt=${SEARCH_ATTEMPTS:-$SEARCH_ATTEMPTS_DEFAULT}
_draw 5 "Searching traps ..."

while :
do

_draw 5 "Searching traps $cnt times ..."

echo watch $DRAWINFO
__is 0 0 search
_sleep


 while :
 do
 unset REPLY
 read -t $TMOUT
 _log "_search_traps:$REPLY"
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

TRAPS_ALL=${FOUND_TRAP:-$TRAPS_ALL}
unset FOUND_TRAP

echo unwatch $DRAWINFO
_sleep


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
_sleep

 unset REPLY
 while :
 do
 read -t $TMOUT
 _log "_disarm_traps:$REPLY"
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

echo unwatch $DRAWINFO
_sleep

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

_lockpick_door(){
_draw 5 "Attempting to lockpick the door ..."

cnt=${LOCKPICK_ATTEMPTS:-$LOCKPICK_ATTEMPTS_DEFAULT}

while :
do

test "$INFINITE" || _draw 5 "$cnt attempts in lockpicking skill left .."

echo watch $DRAWINFO
#_sleep
__is 1 1 use_skill lockpicking
_sleep

 unset cnt0 REPLY
 while :
 do
 cnt0=$((cnt0+1))
 #unset REPLY
 read -t ${TMOUT:-1}
 _log "_lockpick_door:$REPLY"
 _msg 7 "_lockpick_door:$REPLY"

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

echo unwatch $DRAWINFO

test "$INFINITE" || {
	cnt=$((cnt-1))
	test "$cnt" -gt 0 || break 1
}

_sleep
done

return ${RV:-1}
}

_open_door_with_standard_key(){
# TODO
:
}

_do_parameters(){
# dont forget to pass parameters when invoking this function
test "$*" || return 0

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

_search_traps

_disarm_traps

_lockpick_door || _open_door_with_standard_key

echo unwatch $DRAWINFO

#_say_script_time
_say_end_msg
