#!/bin/ash

[ "$HAVE_FUNCS_SKILLS" ] && return 0

# depends :
[ "$HAVE_FUNCS_COMMON"   ] || . cf_funcs_common.sh

_check_skill_available(){
_debug "_check_skill_available:$*"
_log   "_check_skill_available:$*"

local lSKILL=${1:-"$SKILL"}
test "$lSKILL" || return 254

local lRV=

_empty_message_stream
_watch $DRAWINFO
case "$lSKILL" in
punch*) _is 1 1 ready_skill ${SKILL_NOT_PUNCHING:-throwing};;
throw*) _is 1 1 ready_skill ${SKILL_NOT_THROWING:-punching};;
*)      _is 1 1 ready_skill ${2:-punching};;  # force response, because when not changing
esac                                          # range attack, no message is printed
_is 1 1 ready_skill "$lSKILL"

while :; do unset REPLY
read -t $TMOUT
  _log "_check_skill_available:$REPLY"
_debug "$REPLY"

 case $REPLY in
 '') break 1;;
 *'Readied skill: '"$lSKILL"*) lRV=0; break 1;;   # if (!(aflags & AP_NOPRINT))
 # server/apply.c:          new_draw_info_format (NDI_UNIQUE, 0, who, "Readied skill: %s.",
 # server/apply.c-                    op->skill? op->skill:op->name);
 *'Unable to find skill '*)    lRV=1; break 1;; # new_draw_info_format(NDI_UNIQUE, 0, op,
 # server/skill_util.c:          "Unable to find skill %s", string);
 # server/skill_util.c- return 0;
 *scripttell*break*)     break ${REPLY##*?break};;
 *scripttell*exit*)    _exit 1 $REPLY;;
 *'YOU HAVE DIED.'*) _just_exit;;
 *) :;;
 esac

sleep 0.01
done

_unwatch $DRAWINFO
_empty_message_stream

return ${lRV:-3}
}

_issue_skills(){

_watch $DRAWINFO
_is 1 1 skills
usleep 10000

while :; do unset REPLY
read -t ${TMOUT:-1}
_log "$REPLY"
_msg 7 "$REPLY"

case $REPLY in '') break 1;;
*worship*)    _debug 3 $REPLY
              GOD=`echo "$REPLY" | awk '{print $NF}' | sed 's/\.$//'` ;;
*item*power*) _debug 3 $REPLY
       ITEM_POWER=`    echo "$REPLY" | awk '{print $9}'`
       ITEM_POWER_MAX=`echo "$REPLY" | awk '{print $NF}' | sed 's/\.$//'`;;
*handle*improvements*) _debug 3 $REPLY
       AVAIL_IMPR=`    echo "$REPLY" | awk '{print $7}'`;;
esac

done

_unwatch $DRAWINFO

_debug $GOD $ITEM_POWER $ITEM_POWER_MAX $AVAIL_IMPR
test "$GOD" = 'none' && unset GOD
test "$GOD" -a "$AVAIL_IMPR" -a "$ITEM_POWER" -a "$ITEM_POWER_MAX"
}


###END###
HAVE_FUNCS_SKILLS=1
