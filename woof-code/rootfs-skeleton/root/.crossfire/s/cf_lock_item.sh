#!/bin/bash

# lock

MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
MY_DIR=${MY_SELF%/*}

. $MY_DIR/cf_funcs_common.sh
. $MY_DIR/cf_funcs_requests.sh
. $MY_DIR/cf_funcs_items.sh

_set_global_variables "$@"
_say_start_msg "$*"

DEBUG=1
LOGGING=1

# parameters :
# -A --all
# -U --unlock
# -L --lock
# -N --not
# -I --item


# getting inventory list

# if item unlocked, lock it

INV_LIST_FILE="$TMP_DIR"/"$MY_BASE".$$.inv

_request_items_inv(){
_debug "_request_items_inv:$*"
_log   "_request_items_inv:$*"

unset INVENTORY_LIST

echo request items inv
usleep 1000

while :; do
unset REPLY

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
read -t ${TMOUT:-1}
# 72605606 1 19 17 0 flower
_log "$INV_LIST_FILE" "cf_lock_items:$REPLY"
_debug "$REPLY"

case $REPLY in
'') EMPTY_LINE=$((EMPTY_LINE+1));
    if test $EMPTY_LINE -ge 5; then
     _log "WARNING: Inventory has too many items to request them all!"
     _warn "Inventory has too many items to request them all!"
     break 1
    fi
 ;;
*"request items inv end"*) break 1;;

esac

INVENTORY_LIST="$INVENTORY_LIST
$REPLY"

usleep 1000
done

INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv end//'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv //'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/^$//'`

test "$INVENTORY_LIST"
}
#_request_items_inv

_request_items_inv_and_lock_unlocked(){
_debug "_request_items_inv:$*"
_log   "_request_items_inv:$*"

local lP1="$1"
case $lP1 in *all|*not)
 shift
 local lP2="$*";;
esac

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
_log "$INV_LIST_FILE" "cf_lock_items:$req $itm $inv $TAG $NROF $WEIGHT $FLAGS $TYPE $D_NAME"
_debug "$req $itm $inv $TAG $NROF $WEIGHT $FLAGS $TYPE $D_NAME"

case $req in
'') EMPTY_LINE=$((EMPTY_LINE+1));
    if test $EMPTY_LINE -ge 5; then
     _log "WARNING: Inventory has too many items to request them all!"
     _warn "Inventory has too many items to request them all!"
     break 1
    fi
 ;;
esac

case $TAG in end) break 1;; esac

if test $FLAGS -lt 16; then
case $lP1 in
*all|'') _toggle_lock;;
*not)
 case $D_NAME in
 $lP2) :;;
    *) _toggle_lock;;
 esac;;
*)
 case $D_NAME in
 $lP1) _toggle_lock;;
    *) :;;
  esac;;
esac
fi

#if test $FLAGS -lt 16; then
#case $D_NAME in
# "one "*|"two "*|"three "*|"four "*|"five "*|"six "*|"seven "*|"eight "*|"nine "*)
#   _is 1 1 lock ${D_NAME#* };;
# "ten "*|"eleven "*|"twelve "*|"thirteen "*|*"teen "*|"twenty "*)
#   _is 1 1 lock ${D_NAME#* };;
#*) _is 1 1 lock ${D_NAME};;
#esac
#fi

INVENTORY_LIST="$INVENTORY_LIST
$NROF:$D_NAME"

usleep 1000
done

INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv end//'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv //'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/^$//'`

test "$INVENTORY_LIST"
}
#_request_items_inv_and_lock_unlocked

_request_items_inv_and_unlock_locked(){
_debug "_request_items_inv:$*"
_log   "_request_items_inv:$*"

local lP1="$1"
case $lP1 in *all|*not)
 shift
 local lP2="$*";;
esac


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
_log "$INV_LIST_FILE" "cf_lock_items:$req $itm $inv $TAG $NROF $WEIGHT $FLAGS $TYPE $D_NAME"
_debug "$req $itm $inv $TAG $NROF $WEIGHT $FLAGS $TYPE $D_NAME"

case $req in
'') EMPTY_LINE=$((EMPTY_LINE+1));
    if test $EMPTY_LINE -ge 5; then
     _log "WARNING: Inventory has too many items to request them all!"
     _warn "Inventory has too many items to request them all!"
     break 1
    fi
 ;;
esac

case $TAG in end) break 1;; esac

if test $FLAGS -gt 15; then
case $lP1 in
*all|'') _toggle_lock;;
*not)
 case $D_NAME in
 $lP2) :;;
    *) _toggle_lock;;
 esac;;
*)
 case $D_NAME in
  $lP1) _toggle_lock;;
     *) :;;
  esac;;
esac
fi

INVENTORY_LIST="$INVENTORY_LIST
$NROF:$D_NAME"

usleep 1000
done

INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv end//'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/request items inv //'`
INVENTORY_LIST=`echo "$INVENTORY_LIST" | sed 's/^$//'`

test "$INVENTORY_LIST"
}

_toggle_lock(){
  _log "_toggle_lock:$*"
_debug "_toggle_lock:$*"

case $D_NAME in
 "one "*|"two "*|"three "*|"four "*|"five "*|"six "*|"seven "*|"eight "*|"nine "*)
   _is 1 1 lock ${D_NAME#* };;
 "ten "*|"eleven "*|"twelve "*|"thirteen "*|*"teen "*|"twenty "*)
   _is 1 1 lock ${D_NAME#* };;
*) _is 1 1 lock ${D_NAME};;
esac

}

# parameters :
# -A --all
# -U --unlock
# -L --lock
# -N --not
# -I --item

until [ $# = 0 ]; do
case $1 in
-A|-*all) SFLAGS="$SFLAGS ALL";;
-L|-lock|--lock) SFLAGS="$SFLAGS LOCK";;
-U|-*unlock)     SFLAGS="$SFLAGS UNLOCK";;
-N|-*not)  ITEM_NOT="$ITEM_NOT|$OPTARG";;
-I|-*item) ITEM="$ITEM|$OPTARG";;
esac

shift
usleep 1000
done

    ITEM=`echo "$ITEM"     | sed 's%^|*%%;s%|*$%%' | tr -s '|'`
ITEM_NOT=`echo "$ITEM_NOT" | sed 's%^|*%%;s%|*$%%' | tr -s '|'`

case $SFLAGS in *ALL*) unset ITEM ITEM_NOT; esac

case $SFLAGS in
*ALL*)
 case $SFLAGS in
  LOCK)   _request_items_inv_and_lock_unlocked;;
  UNLOCK) _request_items_inv_and_unlock_locked;;
  *) _request_items_inv;;
 esac
;;

*UNLOCK*)
 if test "$ITEM" ; then
  _request_items_inv_and_unlock_locked "$ITEM"
 fi
 if test "$ITEM_NOT" ; then
  _request_items_inv_and_unlock_locked -not "$ITEM_NOT"
 fi
;;

*LOCK*)
 if test "$ITEM" ; then
  _request_items_inv_and_lock_unlocked "$ITEM"
 fi
 if test "$ITEM_NOT" ; then
  _request_items_inv_and_lock_unlocked -not "$ITEM_NOT"
 fi
;;

*) _error "Need either -A, -L, -U parameter.";;
esac

__draw ${NDI_NAVY:-2} "$INVENTORY_LIST"

_say_end_msg
