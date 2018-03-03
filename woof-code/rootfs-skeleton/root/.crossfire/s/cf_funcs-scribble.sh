#!/bin/ash

return 0  # unused

_check_if_already_running_scripts(){
_log   "_check_if_already_running_scripts:$*"
_debug "_check_if_already_running_scripts:$*"

local lRV=0

_is 1 1 scripts
while :; do unset REPLY
read -t $TMOUT
_log "$REPLY"
_debug "$REPLY"

case $REPLY in
 *scripts*currently*running:*) :;;
 *${MY_BASE}*) lRV=1;;
 '') break 1;;
 *)  :;;
esac
sleep 0.01
done

return ${lRV:-2}
}

_check_if_already_running_ps(){

local lPROGS=`ps -o pid,ppid,args | grep -w $PPID | grep -v -w $$`
__debug_stdalone "$lPROGS"
lPROGS=`echo "$lPROGS" | grep -vE "^$PPID[[:blank:]]+|^[[:blank:]]+$PPID[[:blank:]]+" | grep -vE '<defunct>|grep'`
__debug_stdalone "$lPROGS"

test ! "$lPROGS"
}

__check_hp(){
_debug "__check_hp:$*"
_log   "__check_hp:$*"

while :; do
 unset HP MAXHP
 _request_stat_hp
 case $HP in '') :;; *) break 1;; esac
 sleep 0.1
done

  if test $MAXHP -le 20; then return 0
elif test $HP -le 100; then
     test $HP -gt $(( ( MAXHP / 10 ) * 9 ))
else test $HP -gt $(( ( MAXHP / 100 ) * 90 ))
fi
}

_heal(){
_debug "_heal:$*"
_log   "_heal:$*"

local lITEM=${*:-"$HEAL_ITEM"}

case $lITEM in
*rod*|*staff*|*wand*|*horn*|*scroll*) _check_have_item_in_inventory $lITEM || return 1;;
*) :;;
esac

case $lITEM in
*rod*|*staff*|*wand*|*horn*)
 _is 1 1 apply -u $lITEM
 _is 1 1 apply -a $lITEM
 _is 1 1 fire 0
 _is 1 1 fire_stop
 ;;
*scroll*) _is 1 1 apply $lITEM;;
'') :;;
*) _is 1 1 invoke $lITEM;;
esac

}

_check_hp(){
_debug "_check_hp:$*"
_log   "_check_hp:$*"

while :;
do
 __check_hp && return 0
 _heal
 _sleep
done

}
