#!/bin/ash

# we could add parameters to cast what spell:
# should be low level with few mana/grace point need
# non-attack to avoid triggering traps
# and with some in fantasy/theory usable value
# faery fire and disarm show something at least
# detect magic          - sorcery       1 1  -m
# probe                 - sorcery       1 3  -p
# detect monster        - evocation     2 2  -M
# detect evil           - prayer        3 3  -e
# dexterity             - sorcery       3 9  -D
# disarm                - sorcery       4 7  -t ## for traps, -d is debug
# constitution          - sorcery       4 12 -C
# faery fire            - pyromancy     4 13 -f
# detect curse          - prayer        5 10 -c
# show invisible        - prayer        7 10 -i

# Handle errors like spellpath or not learned
# set VARIABLES <- functions, to unset them if found not allowed/available
# $CAST_SPELL instead _cast_spell
CAST_DEX=_cast_dexterity

_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

echo watch $DRAW_INFO

_draw 5 "casting dexterity.."

_is 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5

_is 1 1 fire ${DIRN:-0}
sleep 0.5

_is 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_cast_dexterity:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX;;
 *'This ground is unholy!'*)                     unset CAST_REST;;
 *'You grow no more agile.'*)                    unset CAST_DEX;;
 *'You lack the skill '*)                        unset CAST_DEX;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX;;
 *'That spell path is denied to you.'*)          unset CAST_DEX;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 '') break;;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}



_turn_direction_all(){

local REPLY c spell

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

# using a bunch of spells to increase availability
# downside if many doors - much drain of mana/grace
for spell in "probe" "detect monster" "detect evil"
do

_draw 2 "Casting $spell to turn to $DIR .."

_is 1 1 cast $spell
sleep 0.5

_is 1 1 fire ${DIRN:-0}
sleep 0.5

_is 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_turn_direction_all:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE; break 2;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE; break 2;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX; break 2;;
 *'This ground is unholy!'*)                     unset CAST_REST;break 2;;
 *'You grow no more agile.'*)                    unset CAST_DEX; break 2;;
 *'You lack the skill '*)                        unset CAST_DEX; break 2;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX; break 2;;
 *'That spell path is denied to you.'*)          unset CAST_DEX; break 2;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 '') break;;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done


done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_turn_direction(){
test "$*" || return 3
local REPLY c spell

spell="$*"

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_draw 2 "Casting $spell to turn to $DIR .."

_is 1 1 cast $spell
sleep 0.5

_is 1 1 fire ${DIRN:-0}
sleep 0.5

_is 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_turn_direction:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_DEX CAST_PROBE; break 2;;
 '*Something blocks the magic of your scroll.'*) unset CAST_DEX CAST_PROBE; break 2;;
 *'Something blocks your spellcasting.'*)        unset CAST_DEX; break 2;;
 *'This ground is unholy!'*)                     unset CAST_REST;break 2;;
 *'You grow no more agile.'*)                    unset CAST_DEX; break 2;;
 *'You lack the skill '*)                        unset CAST_DEX; break 2;;
 *'You lack the proper attunement to cast '*)    unset CAST_DEX; break 2;;
 *'That spell path is denied to you.'*)          unset CAST_DEX; break 2;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 '') break;;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_turn_direction_using_spell(){
if test "$TURN_SPELL"; then
 _turn_direction $TURN_SPELL
else
 _turn_direction_all
fi
}


_check_have_needed_spell_in_inventory(){  # cast by _do_program
# *** check if spell is applyable - takes some time ( 16 seconds )
[ "$CHECK_NO" ] && return 0

_debug "_check_have_needed_spell_in_inventory:$*"

local lSPELL=${*:-"$SPELL"}
local oneSPELL oldSPELL SPELLS r s ATTYPE LVL rest

_draw 5 "Checking if have '$SPELL' ..."
_draw 5 "Please wait...."

TIMEB=`date +%s`

echo request spells
while :;
do
read -t 1 oneSPELL
 _log "_check_have_needed_spell_in_inventory:$oneSPELL"
 _debug "$oneSPELL"

 test "$oldSPELL" = "$oneSPELL" && break
 test "$oneSPELL" || break

 SPELLS="$SPELLS
$oneSPELL"
 oldSPELL="$oneSPELL"
sleep 0.1
done


TIMEE=`date +%s`
TIME=$((TIMEE-TIMEB))
_debug "_check_have_needed_spell_in_inventory:Elapsed '$TIME' s."

read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$SPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i "$lSPELL"
}

_apply_needed_spell(){  # cast by _do_program AND _do_loop; has no params
# *** apply the spell that was given as parameter
# *   does not cast - actual casting is done by 'fire'

#TODO : Something blocks your magic.

_is 1 1 cast $SPELL $SPELL_PARAM
}

# *** stub to switch wizard-cleric spells in future
_watch_wizard_spellpoints(){  # cast by _watch_food
# ***

_debug "_watch_wizard_spellpoints:$*:SP=$SP SP_MAX=$SP_MAX"

SP_NEEDED=${SP_NEEDED:-$SP_MAX}
SP_NEEDED=${SP_NEEDED:-10}
SP_MAX=${SP_MAX:-20}

if [ "$SP" -le 0 ]; then
   return 6
 elif [ "$SP" -lt $SP_NEEDED ]; then
   return 6
 elif [ "$SP" -lt $SP_MAX ]; then
   return 4
 elif [ "$SP" -eq $SP_MAX ]; then
   return 0
fi

test "$SP" -ge $((SP_MAX/2)) || return 3
}

# *** stub to switch wizard-cleric spells in future
_watch_cleric_gracepoints(){  # cast by _watch_food
# ***

_debug "_watch_cleric_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"

GR_NEEDED=${GR_NEEDED:-$SP_NEEDED}
GR_NEEDED=${GR_NEEDED:-$GR_MAX}
GR_NEEDED=${GR_NEEDED:-10}
GR_MAX=${GR_MAX:-20}

if [ "$GR" -le 0 ]; then
   return 6
 elif [ "$GR" -lt $GR_NEEDED ]; then
   return 6
 elif [ "$GR" -lt $GR_MAX ]; then
   return 4
 elif [ "$GR" -eq $GR_MAX ]; then
   return 0
fi

test "$GR" -ge $((GR_MAX/2)) || return 3

}

# *** stub to issue use_skill praying
_pray_up_gracepoints(){
# ***

_debug "_pray_up_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"
PRAYS=$((GR_MAX-GR))
local c=0
while :;
do
c=$((c+1))
   _is 1 1 use_skill praying
sleep 1
test $c = $PRAYS && break
done

}

_regenerate_spell_points(){  # cast by _do_loop if _watch_food returns 6
                             # by _watch_cleric_gracepoints/_watch_wizard_spellpoints
# ***

_draw 4 "Regenerating spell points.."
while :;
do

sleep 20s
_watch_food && break
_verbose "Still regenerating to spellpoints $SP -> $((SP_MAX/2)) .."
done

}
