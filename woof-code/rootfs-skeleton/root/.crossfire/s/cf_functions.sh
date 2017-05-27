#!/bin/ash


_use_skill(){

echo watch $DRAW_INFO

local c=0
local NUM=$1:-NUMBER}

while :;
do

echo issue 1 1 use_skill "$*"

test "$NUMBER" && { NUM=$((NUM-1)); test "$NUM" -le 0 && break; } || { c=$((c+1)); test "$c" = "$NUM" && break; }

sleep 1

done

echo unwatch $DRAW_INFO

sleep 1

}


_handle_spell_errors(){
local RV=0
 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item'*)    unset CAST_DEX CAST_PROBE; break 2;;
 '*Something blocks the magic of your scroll'*)  unset CAST_DEX CAST_PROBE; break 2;;
 *'Something blocks your spellcasting'*)         unset CAST_DEX; break 2;;
 *'This ground is unholy'*)                      unset CAST_REST;break 2;;
 *'You lack the skill '*)                        unset CAST_DEX; break 2;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX; break 2;;
 *'That spell path is denied to you'*)           unset CAST_DEX; break 2;;
 *'You recast the spell while in effect'*) INF_THRESH=$((INF_THRESH+1));;
 *'You grow no more agile'*)                     unset CAST_DEX; break 2;;
 *) RV=1;;
esac
return ${RV:-1}
}

_handle_spell_msgs(){
local RV=0
 case $REPLY in
 *'You can no longer use the skill:'*) :;;
 *'You ready talisman '*)              :;;
 *'You ready holy symbol'*)            :;;
 *'You can now use the skill:'*)       :;;
 *'You ready the spell'*)              :;;
 *'You feel more agile'*)              :;;
 *'The effects of your dexterity are draining out'*)    :;;
 *'The effects of your dexterity are about to expire'*) :;;
 *'You feel clumsy'*) :;;
 *) RV=1;;
esac
return ${RV:-1}
}


