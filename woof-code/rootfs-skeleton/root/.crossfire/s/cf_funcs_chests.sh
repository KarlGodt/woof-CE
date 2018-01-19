#!/bin/ash

[ "$HAVE_FUNCS_CHEST" ] && return 0

_open_chests(){
_debug "_open_chests:$*"
_draw 5 "Opening chests ..."

unset one
while :
do
one=$((one+1))

#__check_if_on_item_examine -l chest
#_check_if_on_chest_request_items_on -l || break 1
_check_if_on_chest -l || break 1

_sleep
_draw 5 "${NUMBER_CHEST:-?} chest(s) to open ..."

_move_back_and_forth 2

_watch
_is 1 1 apply
#_sleep
unset OPEN_COUNT
 while :; do unset REPLY
 read -t ${TMOUT:-1}
 _log "_open_chests:$REPLY"
 _msg 7 "$REPLY"
 case $REPLY in
 *'You find'*)   OPEN_COUNT=1;;
 *empty*)        OPEN_COUNT=1;;
 *'You open chest.'*) break 2;;
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

if _check_counter; then
_check_food_level
_check_hp_and_return_home $HP
fi

_set_pickup 0
_sleep

case $NUMBER in $one) break 1;; esac

#_drop_chest
_drop chest
_sleep

done
}

__check_if_on_chest_request_items_on(){
_debug "__check_if_on_chest_request_items_on:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST

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
_log "$ON_LOG" "__check_if_on_chest_request_items_on:$UNDER_ME"
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

_check_if_on_chest_request_items_on(){
_debug "_check_if_on_chest_request_items_on:$*"

#local DO_LOOP TOPMOST
#unset DO_LOOP TOPMOST

#while [ "$1" ]; do
#case $1 in
#-l) DO_LOOP=1;;
#-t) TOPMOST=1;;
#-lt|-tl) DO_LOOP=1; TOPMOST=1;;
#*) break;;
#esac
#shift
#done

local lRV
unset lRV

#_draw 5 "Checking if standing on chests ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "_check_if_on_chest_request_items_on:$UNDER_ME"
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

test "`echo "$UNDER_ME_LIST" | grep 'chest.*cursed'`" && {
#_draw 3 "You appear to stand upon some cursed chest!"
#beep -l 1000 -f 700
#test "$1" && return 1 || exit 1
lRV=5
}

test "`echo "$UNDER_ME_LIST" | grep -E 'chest$|chests$'`" || {
#_draw 3 "You appear not to stand on some chest!"
#beep -l 1000 -f 700
#test "$1" && return 1 || exit 1
lRV=6
}

test "`echo "$UNDER_ME_LIST" | tail -n1 | grep 'chest.*cursed'`" && {
#_draw 3 "Topmost chest appears to be cursed!"
#beep -l 1000 -f 700
#test "$1" && return 1 || exit 1
lRV=7
}

test "`echo "$UNDER_ME_LIST" | tail -n1 | grep -E 'chest$|chests$'`" || {
#_draw 3 "Chest appears not topmost!"
#beep -l 1000 -f 700
#test "$1" && return 1 || exit 1
lRV=8
}

return ${lRV:-0}
}

_eval_check_if_on_chest_request_items_on(){
_debug "_eval_check_if_on_chest_request_items_on:$*"

  _check_if_on_chest_request_items_on
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

_check_if_on_chest(){
_debug "_check_if_on_chest:$*"

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

#__check_if_on_item_examine $1 chest
__check_if_on_chest_request_items_on $1
#_eval_check_if_on_chest_request_items_on $1
}

_lockpick_door(){
_debug "_lockpick_door:$*"
_draw 5 "Attempting to lockpick the door ..."

one=${LOCKPICK_ATTEMPTS:-$LOCKPICK_ATTEMPTS_DEFAULT}
test "$one" -gt 0 || return 1  # to trigger _open_door_with_standard_key

unset RV cnt1
while :
do

cnt1=$((cnt1+1))
test "$INFINITE" && _draw 5 "${cnt1}. attempt .." || _draw 5 "$one attempts in lockpicking skill left .."

_watch $DRAWINFO
#_sleep
_is 1 1 use_skill lockpicking
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

 *scripttell*break*)   break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1;;
 '') break 1;; # :;;
 *)  :;;
 esac

 test "$cnt0" -gt 9 && break 1 # emergency break
 _sleep
 done

_unwatch $DRAWINFO

test "$INFINITE" || {
    one=$((one-1))
    test "$one" -gt 0 || break 1
}

if _check_counter; then
_check_food_level
_check_hp_and_return_home $HP
fi

_sleep
done

return ${RV:-1}
}


###END###
HAVE_FUNCS_CHEST=1
