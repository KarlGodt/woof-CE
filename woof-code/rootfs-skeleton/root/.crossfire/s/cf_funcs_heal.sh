#!/bin/ash

[ "$HAVE_FUNCS_HEAL" ] && return 0

# depends :
[ "$HAVE_FUNCS_COMMON"   ] || . cf_funcs_common.sh
[ "$HAVE_FUNCS_REQUESTS" ] || . cf_funcs_requests.sh

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
*rod*|*staff*|*wand*|*horn*|*scroll*)
 if _check_have_item_in_inventory $lITEM; then
      unset NROF_ITEM
 else unset NROF_ITEM
      return 1
 fi
 ;;
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


HAVE_FUNCS_HEAL=1
###END###
