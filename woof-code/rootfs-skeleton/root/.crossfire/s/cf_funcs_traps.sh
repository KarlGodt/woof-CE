#!/bin/ash

[ "$HAVE_FUNCS_TRAPS" ] && return 0

_disarm_traps(){
_draw 5 "Disarming ${TRAPS_ALL:-0} traps ..."
case "$DISARM" in
invokation) _invoke_disarm;;
cast|spell) #case "$DIRECTION" in '') _invoke_disarm;; *) _cast_disarm;; esac;;
            _cast_disarm;;
skill|'') _use_skill_disarm;;
*) _error "DISARM variable set not to skill, invokation OR cast'";;
esac
}

_use_skill_skill(){
_debug "_use_skill_skill:$*"

local lSKILL=${*:-$SKILL}
test "$lSKILL" || return 254

local cnt0
while :
do
_draw 5 "Using skill $lSKILL ..."

#echo watch $DRAWINFO
_watch $DRAWINFO
_is 0 0 use_skill $lSKILL
_sleep

 unset REPLY OLD_REPLY cnt0
 while :
 do
 cnt0=$((cnt0+1))
 read -t $TMOUT
   _log "_use_skill_skill:$cnt0:$REPLY"
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
 *"RUN!  The timer's ticking!"*) _just_exit 1;;
 *'You are pricked'*) :;;
 *'You are stabbed'*) :;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit 1;;
 '') break 1;;
 *) :;;
 esac

 _sleep
 test "$OLD_REPLY" = "$REPLY" && break 1
 OLD_REPLY=$REPLY
 done

_unwatch $DRAWINFO

_move_back_and_forth 2
_sleep

done

unset OLD_REPLY
}

_use_skill_disarm(){
_debug "_use_skill_disarm:$*"

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

 local cnt0
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

_unwatch $DRAWINFO

_move_back_and_forth 2
_sleep

test "$TRAPS" -gt 0 || break 1
done

unset OLD_REPLY
}

_invoke_disarm(){ ## invoking does to a direction
_debug "_invoke_disarm:$*"

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
   _log "_invoke_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 # Here there could be a trap next to the stack of chests ...
 # so invoking disarm towards the stack of chests would not
 # work to disarm the traps elsewhere on tiles around
 *"There's nothing there!"*) break 2;;
 *'A portal opens up, and screaming hordes pour'*) _just_exit 1;;
 *'through!'*)     _just_exit 1;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit 1;;
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

_cast_disarm(){
_debug "_cast_disarm:$*"

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
   _log "_cast_disarm:$cnt0:$REPLY"
 _msg 7 "$cnt0:$REPLY"

 case $REPLY in
 *'You successfully disarm'*) TRAPS=$((TRAPS-1)); break 1;;
 *'You fail to disarm'*) break 1;;
 *"There's nothing there!"*) break 2;;
 *'A portal opens up, and screaming hordes pour'*) _just_exit 1;;
 *'through!'*)     _just_exit 1;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit 1;;
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

_search_traps(){
_debug "_search_traps:$*"
cnt=${SEARCH_ATTEMPTS:-$SEARCH_ATTEMPTS_DEFAULT}
#_draw 5 "Searching traps ..."
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
#_sleep

 unset cnt0 FOUND_TRAP
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
 *'You spot a Rune of Create Bomb!'*)    _just_exit 0;;
 *' spot '*) FOUND_TRAP=$((FOUND_TRAP+1));;
 *'You search the area.'*) SEARCH_MSG=$((SEARCH_MSG+1));; # break 1;;
 *scripttell*break*)  break ${REPLY##*?break};;
 *scripttell*exit*)   _exit 1;;
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

###END###
HAVE_FUNCS_TRAPS=1
