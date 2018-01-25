#!/bin/ash

[ "$HAVE_FUNCS_FIGHT" ] && return 0

_kill_monster(){
_debug "_kill_monster:$*"

local lATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

# TODO:
#*'You withhold your attack'*)  _set_next_direction; break 1;;
#*'You avoid attacking '*)      _set_next_direction; break 1;;

for i in `seq 1 1 ${lATTACKS:-1}`; do
_is 1 1 $DIRECTION
done
_empty_message_stream
}


_brace(){
_debug "_brace:$*"

_watch $DRAWINFO
while :
do
_is 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log "_brace:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 2;;
 *'Not braced.'*)     break 1;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch $DRAWINFO
_empty_message_stream
}

_unbrace(){
_debug "_unbrace:$*"

_watch $DRAWINFO
while :
do
_is 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log "_unbrace:$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 1;;
 *'Not braced.'*)     break 2;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch $DRAWINFO
_empty_message_stream
}


###END###
HAVE_FUNCS_FIGHT=1
