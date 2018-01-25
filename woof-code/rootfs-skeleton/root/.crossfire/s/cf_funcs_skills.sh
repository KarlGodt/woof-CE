#!/bin/ash

[ "$HAVE_FUNCS_SKILLS" ] && return 0

_check_skill_available(){
_debug "_check_skill_available:$*"

local lSKILL=${*:-"$SKILL"}
test "$lSKILL" || return 254

local lRV=

_empty_message_stream
_watch $DRAWINFO
_is 1 1 ready_skill punching  # force response, because when not changing
_is 1 1 ready_skill "$lSKILL" # range attack, no message is printed

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
 *) :;;
 esac

sleep 0.01
done

_unwatch $DRAWINFO
_empty_message_stream

return ${lRV:-3}
}






###END###
HAVE_FUNCS_SKILLS=1
