#!/bin/ash

[ "$HAVE_FUNCS_ITEMS" ] && return 0

# depends :
[ "$HAVE_FUNCS_COMMON"   ] || . cf_funcs_common.sh
[ "$HAVE_FUNCS_REQUESTS" ] || . cf_funcs_requests.sh

_check_if_on_item_examine(){
# Using 'examine' directly after dropping
# the item examines the bottommost tile
# as 'That is marble'
_debug "_check_if_on_item_examine:$*"
_log   "_check_if_on_item_examine:$*"

local DO_LOOP TOPMOST LIST
unset DO_LOOP TOPMOST LIST

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

_draw ${NDI_BLUE:-5} "Checking if standing on $lITEM ..."

_watch $DRAWINFO
#_is 0 0 examine
while :; do unset REPLY
_is 0 0 examine
_sleep
read -t $TMOUT
 _log "_check_if_on_item_examine:$REPLY"
 _msg 7 "$REPLY"

 case $REPLY in
  *"That is"*"$lITEM"*|*"Those are"*"$lITEM"*|*"Those are"*"${lITEM// /?*}"*) break 1;;
  *"That is"*|*"Those are"*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  '') break 1;;
  *) continue;; #:;;
 esac

LIST="$LIST
$REPLY"
# sleep 0.01
#sleep 0.1
done

_unwatch
_empty_message_stream

LIST=`echo "$LIST" | sed 'sI^$II'`

if test "$TOPMOST"; then
 echo "${LIST:-$REPLY}"  | tail -n1 | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"
else
 echo "$REPLY"                      | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"
fi
local lRV=$?
test "$lRV" = 0 && return $lRV

if test "$DO_LOOP"; then
 return ${lRV:-3}
else
  _exit ${lRV:-3} "$lITEM not here or not on top of stack."
fi
}

_check_if_on_item(){
_debug "_check_if_on_item:$*"
_log   "_check_if_on_item:$*"

local DO_LOOP TOPMOST lMSG lRV
unset DO_LOOP TOPMOST lMSG lRV

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

_draw ${NDI_BLUE:-5} "Checking if standing on $lITEM ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "_check_if_on_item:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${UNDER_ME##*?break};;
*scripttell*exit*)      _exit 1 $UNDER_ME;;
*'YOU HAVE DIED.'*) _just_exit;;
*bed*to*reality*)   _just_exit;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_ITEM=`echo "$UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}" | wc -l`

unset TOPMOST_MSG
case "$UNDER_ME_LIST" in
*"$lITEM"|*"${lITEM}s"|*"${lITEM}es"|*"${lITEM// /?*}")
 TOPMOST_MSG='some'
;;
esac
test "$TOPMOST" && { UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | tail -n1`; TOPMOST_MSG=${TOPMOST_MSG:-topmost}; }

case "$UNDER_ME_LIST" in
*"$lITEM"|*"${lITEM}s"|*"${lITEM}es"|*"${lITEM// /?*}")
   lRV=0;;
*) lMSG="You appear not to stand on $TOPMOST_MSG $lITEM!"
   lRV=1;;
esac

if test $lRV = 0; then
 case "$UNDER_ME_LIST" in
 *cursed*)
   lMSG="You appear to stand upon $TOPMOST_MSG cursed $lITEM!"
   lRV=1;;
 *damned*)
   lMSG="You appear to stand upon $TOPMOST_MSG damned $lITEM!"
   lRV=1;;
 esac
fi

test "$lRV" = 0 && return 0

_beep_std
_draw ${NDI_RED:-3} $lMSG
test "$DO_LOOP" && return 1 || _exit 1
}

__check_if_on_item(){
_debug "__check_if_on_item:$*"
_log   "__check_if_on_item:$*"

local DO_LOOP TOPMOST lMSG lRV
unset DO_LOOP TOPMOST lMSG lRV

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

_draw ${NDI_BLUE:-5} "Checking if standing on $lITEM ..."
UNDER_ME='';
UNDER_ME_LIST='';

_empty_message_stream
echo request items on

while :; do
read -t $TMOUT UNDER_ME
_log "$ON_LOG" "__check_if_on_item:$UNDER_ME"
_msg 7 "$UNDER_ME"

case $UNDER_ME in
'') continue;;
*request*items*on*end*) break 1;;
*scripttell*break*)     break ${UNDER_ME##*?break};;
*scripttell*exit*)      _exit 1 $UNDER_ME;;
*'YOU HAVE DIED.'*) _just_exit;;
*bed*to*reality*)   _just_exit;;
esac

UNDER_ME_LIST="$UNDER_ME
$UNDER_ME_LIST"

unset UNDER_ME
sleep 0.1s
done

UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | sed 's%^$%%'`

__debug "UNDER_ME_LIST='$UNDER_ME_LIST'"

NUMBER_ITEM=`echo "$UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}" | wc -l`

if test "$TOPMOST"; then

 TOP_UNDER_ME_LIST=`echo "$UNDER_ME_LIST" | tail -n1`
 if test "`echo "$TOP_UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}" | grep -E 'cursed|damned'`";
  then lMSG="Topmost $lITEM appears to be cursed!"
  false
 elif  test "`echo "$TOP_UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"`";
  then true
 elif test "`echo "$UNDER_ME_LIST" | grep -iE " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"`";
  then lMSG="$lITEM appears not to be topmost!"
  false
 else lMSG="You appear not to stand on some $lITEM!"
  false
 fi
lRV=$?

else

case "$UNDER_ME_LIST" in
*"$lITEM"*cursed*|*"${lITEM}s"*cursed*|*"${lITEM}es"*cursed*|*"${lITEM// /?*}"*cursed*)
   lMSG="${lMSG:-You appear to stand upon some cursed $lITEM!}"
   lRV=1;;
*"$lITEM"*damned*|*"${lITEM}s"*damned*|*"${lITEM}es"*damned*|*"${lITEM// /?*}"*damned*)
   lMSG="${lMSG:-You appear to stand upon some damned $lITEM!}"
   lRV=1;;
*"$lITEM"|*"${lITEM}s"|*"${lITEM}es"|*"${lITEM// /?*}")
   lRV=${lRV:-0};;
*) lMSG="You appear not to stand on some $lITEM!"
   lRV=1;;
esac
fi

test "$lRV" = 0 && return 0

_beep_std
_draw ${NDI_RED:-3} $lMSG
test "$DO_LOOP" && return 1 || _exit 1
}

_check_have_item_in_inventory(){
_debug "_check_have_item_in_inventory:$*"
_log   "_check_have_item_in_inventory:$*"

local oneITEM oldITEM ITEMS ITEMSA lITEM
lITEM=${*:-"$ITEM"}
test "$lITEM" || return 254

TIMEB=`date +%s`

unset oneITEM oldITEM ITEMS ITEMSA

_empty_message_stream
echo request items inv
while :;
do
read -t ${TMOUT:-1} oneITEM
 _log "$INV_LOG" "_check_have_item_in_inventory:$oneITEM"
 _debug "$oneITEM"

 case $oneITEM in
 $oldITEM|'') break 1;;
 *"$lITEM"*)
  NrOF=`echo "$oneITEM" | cut -f5 -d' '`; NROF_ITEM=$((NROF_ITEM+NrOF))
  _draw 7 "Got $NrOF of that item $lITEM in inventory.";;
 *scripttell*break*)  break ${oneITEM##*?break};;
 *scripttell*exit*)   _exit 1 $oneITEM;;
 *'YOU HAVE DIED.'*) _just_exit;;
 esac
 ITEMS="${ITEMS}${oneITEM}\n"
#$oneITEM"
 oldITEM="$oneITEM"
sleep 0.01
done
unset oldITEM oneITEM


TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_debug "Fetching Inventory List: Elapsed $TIME sec."

#_debug "lITEM=$lITEM"
#_debug "head:`echo -e "$ITEMS" | head -n1`"
#_debug "tail:`echo -e "$ITEMS" | tail -n2 | head -n1`"
#HAVEIT=`echo "$ITEMS" | grep -E  " $lITEM| ${lITEM}s| ${lITEM}es"`
#__debug "HAVEIT=$HAVEIT"
echo -e "$ITEMS" | grep -q -i -E " $lITEM| ${lITEM}s| ${lITEM}es| ${lITEM// /[s ]+}"
}

_toggle_lock(){
  _log "_toggle_lock:$*"
_debug "_toggle_lock:$*"

lD_NAME=${lD_NAME:-"$D_NAME"}
test "$lD_NAME" || return 254

case $lD_NAME in
 "one "*|"two "*|"three "*|"four "*|"five "*|"six "*|"seven "*|"eight "*|"nine "*)
   _is 1 1 lock ${lD_NAME#* };;
 "ten "*|"eleven "*|"twelve "*|"thirteen "*|*"teen "*|"twenty "*)
   _is 1 1 lock ${lD_NAME#* };;
*) _is 1 1 lock ${lD_NAME};;
esac
unset lD_NAME

}

_lock_all_items(){
_log   "_lock_all_items:$*"
_debug "_lock_all_items:$*"

local lEMPTY_LINE=0

unset INVENTORY_LIST

echo request items inv
usleep 1000

while :; do
unset  req itm inv TAG NROF WEIGHT FLAGS TYPE D_NAME

#flags=it->magical;                      1
#   flags= (flags<<1)|it->cursed;        2
#   flags= (flags<<1)|it->damned;        4
#   flags= (flags<<1)|it->unpaid;        8
#   flags= (flags<<1)|it->locked;       16
#   flags= (flags<<1)|it->applied;      32
#   flags= (flags<<1)|it->open;         64
#   flags= (flags<<1)|it->was_open;    128
#   flags= (flags<<1)|it->inv_updated; 256

# sprintf(buf,"%s%d %d %f %d %d %s\n",
# head,
# it->tag,
# it->nrof,
# it->weight,
# flags,
# it->type,
# it->d_name);
read -t ${TMOUT:-1} req itm inv TAG NROF WEIGHT FLAGS TYPE D_NAME
# 72605606 1 19 17 0 flower
_log "$INV_LIST_FILE" "_lock_all_items:$req $itm $inv $TAG $NROF $WEIGHT $FLAGS $TYPE $D_NAME"
_debug "$req $itm $inv $TAG $NROF $WEIGHT $FLAGS $TYPE $D_NAME"

case $req in
'') lEMPTY_LINE=$((lEMPTY_LINE+1));
    if test $lEMPTY_LINE -ge 5; then
     _log "$INV_LIST_FILE" "WARNING: Inventory has too many items to request them all!"
     _warn "Inventory has too many items to request them all!"
     break 1
    fi
 ;;
esac

case $TAG in end) break 1;; esac

INVENTORY_LIST="$INVENTORY_LIST
$NROF:$D_NAME"

test $FLAGS -lt 16 && _toggle_lock


usleep 1000
done

INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv end//'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv //'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/^$//'`

test "$INVENTORY_LIST"
}

_unlock(){
_log   "_unlock:$*"
_debug "_unlock:$*"

local lITEM=${*:-"$THROW_WEAPON"}
test "$lITEM" || return 254

local lreq litm linv lTAG lNROF lWEIGHT lFLAGS lTYPE lD_NAME
local lEMPTY_LINE=0

echo request items inv
usleep 1000

while :; do
unset lreq litm linv lTAG lNROF lWEIGHT lFLAGS lTYPE lD_NAME
read -t ${TMOUT:-1} lreq litm linv lTAG lNROF lWEIGHT lFLAGS lTYPE lD_NAME
# 72605606 1 19 17 0 flower
_log "$INV_LIST_FILE" "_unlock:$lreq $litm $linv $lTAG $lNROF $lWEIGHT $lFLAGS $lTYPE $lD_NAME"
_debug "$lreq $litm $linv $lTAG $lNROF $lWEIGHT $lFLAGS $lTYPE $lD_NAME"

case $req in
'') lEMPTY_LINE=$((lEMPTY_LINE+1));
    if test $lEMPTY_LINE -ge 5; then
     _log "$INV_LIST_FILE" "WARNING: Inventory has too many items to request them all!"
     _warn "Inventory has too many items to request them all!"
     break 1
    fi
 ;;
esac

case $lTAG in end) break 1;; esac

#case $lITEM in
#*$lD_NAME*)
# _debug "Have '$lITEM' in '$lD_NAME'"
# _log   "_unlock:Have '$lITEM' in '$lD_NAME'"
# test "$lFLAGS" -gt 15 && _toggle_lock;;
#esac

case $lD_NAME in
*$lITEM*|*"$lITEM"*|*"${lITEM// /?*}"*)
 _debug "Have '$lITEM' in '$lD_NAME'"
 _log   "_unlock:Have '$lITEM' in '$lD_NAME'"
 test "$lFLAGS" -gt 15 && _toggle_lock;;
esac

usleep 1000
done
}

_mark_item(){
_debug "_mark_item:$*"
_log   "_mark_item:$*"

local lITEM=${*:-"$MARK_ITEM"}

lITEM=${lITEM:-"$ITEM"}
lITEM=${lITEM:-icecube}

test "$lITEM" || return 254

local lRV=0

_is 1 1 mark "$lITEM"

 while :; do
  unset REPLY
 read -t $TMOUT
  _log "_mark_item:$REPLY"
  _debug "$REPLY"
 case $REPLY in
  *Could*not*find*an*object*that*matches*) lRV=1;break 1;;
  *scripttell*break*) break ${REPLY##*?break};;
  *scripttell*exit*)  _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;
  '') break;;
 esac
 sleep 0.1
 done

return ${lRV:-0}
}

_apply_item_flint_and_steel(){
_debug "_apply_item_flint_and_steel:$*"
_log   "_apply_item_flint_and_steel:$*"

local lITEM=${*:-"$ITEM"}

lITEM=${lITEM:-"flint and steel"}

test "$lITEM" || return 254

local lRV=0

_is 1 1 apply "$lITEM"

 while :; do
  unset REPLY
 read -t $TMOUT
  _log "_apply_item_flint_and_steel:$REPLY"
  _debug "$REPLY"
 case $REPLY in
  *You*light*the*icecube*with*the*flint*and*steel.*) lRV=0; SUCC=$((SUCC+1)); break 1;;
  *fail*used*up*flint*and*steel*)                    lRV=5; break 1;;
  *fail*)                                            lRV=1; FAIL=$((FAIL+1)); break 1;;
  *Could*not*find*any*match*to*the*flint*and*steel*) lRV=6; break 1;;
  *You*need*to*mark*a*lightable*object.*)            lRV=7; break 1;;
  *scripttell*break*) break ${REPLY##*?break};;
  *scripttell*exit*)  _exit 1 $REPLY;;
  *'YOU HAVE DIED.'*) _just_exit;;

  '')     lRV=1; break 1;;
  *) :;;
 esac
 sleep 0.1
 done

return ${lRV:-0}
}


###END###
HAVE_FUNCS_ITEMS=1
###END###
