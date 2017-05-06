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

_cast_dexterity(){  # uses global DIRN, otherwise 0
# ** cast DEXTERITY ** #

local REPLY='' c=0

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


_turn_direction_all(){  # uses global DIRN, otherwise 0

local REPLY c spell
unset REPLY c spell

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

# using a bunch of spells to increase availability
# downside if many doors - much drain of mana/grace
for spell in "probe" "detect monster" "detect evil"
do

_draw 2 "Casting '$spell' to turn to '$DIRN' .."

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

_turn_direction(){  # uses global DIRN, otherwise 0
test "$*" || return 3

local REPLY c spell
unset REPLY c spell

spell="$*"
test "$spell" || return 3

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_draw 2 "Casting '$spell' to turn to '$DIRN' .."

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

local spell=''

if test "$*"; then

 for spell in "$@"; do
  _turn_direction $spell
 done

elif test "$TURN_SPELL"; then
 _turn_direction $TURN_SPELL
else
 _turn_direction_all
fi
}


_check_have_needed_spell_in_inventory(){  # cast by _do_program
# *** check if spell is applyable - takes some time ( 16 seconds )
[ "$CHECK_NO" ] && return 0

_debug "_check_have_needed_spell_in_inventory:$*"

local lSPELL oneSPELL oldSPELL SPELLS r s ATTYPE LVL rest TIMEB TIMEE TIME
unset lSPELL oneSPELL oldSPELL SPELLS r s ATTYPE LVL rest TIMEB TIMEE TIME

lSPELL=${*:-"$SPELL"}
lSPELL=${lSPELL:-"$SPELL_DEFAULT"}

_draw 5 "Checking if have '$lSPELL' ..."
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
_debug "_check_have_needed_spell_in_inventory:Elapsed '$TIME' sec."

# TODO: Several matches
read r s ATTYPE LVL SP_NEEDED rest <<EoI
`echo "$SPELLS" | grep -i "$lSPELL"`
EoI
_debug "_check_have_needed_spell_in_inventory:SP_NEEDED=$SP_NEEDED"

echo "$SPELLS" | grep -q -i "$lSPELL"
}

_apply_needed_spell(){  # cast by _do_program AND _do_loop; has no params
# *** apply the spell that was given as parameter
# *   does not cast - actual casting is done by 'fire'

local lSPELL='' lSPELL_PARAM=''

until [ "$#" = 0 ]; do
sleep 0.1
case $1 in
--) shift; lSPELL_PARAM="$*"; break;;
*) lSPELL="${lSPELL}$1 ";;
esac
shift
done

lSPELL=`echo -n $lSPELL`

lSPELL=${lSPELL:-"$SPELL"}
lSPELL=${lSPELL:-"$SPELL_DEFAULT"}

lSPELL_PARAM=${lSPELL_PARAM:-"$SPELL_PARAM"}
lSPELL_PARAM=${lSPELL_PARAM:-"$SPELL_PARAM_DEFAULT"}

#TODO : Something blocks your magic.

_is 1 1 cast $lSPELL $lSPELL_PARAM
}

# *** stub to switch wizard-cleric spells in future
_watch_wizard_spellpoints(){  # cast by _watch_food
# ***

_debug "_watch_wizard_spellpoints:$*:SP=$SP SP_MAX=$SP_MAX"

local lSP='' lSP_NEEDED='' lSP_MAX=''

lSP=${1:-$SP}
lSP_NEEDED=${SP_NEEDED:-$SP_MAX}
lSP_NEEDED=${lSP_NEEDED:-10}
lSP_MAX=${SP_MAX:-20}

if [ "$lSP" -le 0 ]; then
   return 7
 elif [ "$lSP" -lt $lSP_NEEDED ]; then
   return 6
 elif [ "$lSP" -lt $lSP_MAX ]; then
   return 4
 elif [ "$lSP" -eq $lSP_MAX ]; then
   return 0
fi

# unreached:
test "$lSP" -ge $((lSP_MAX/2)) || return 3
}

# *** stub to switch wizard-cleric spells in future
_watch_cleric_gracepoints(){  # cast by _watch_food
# ***

_debug "_watch_cleric_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"

local lGR='' lGR_NEEDED='' lGR_MAX=''

lGR=${1:-$GR}
lGR_NEEDED=${GR_NEEDED:-$SP_NEEDED}
lGR_NEEDED=${lGR_NEEDED:-$GR_MAX}
lGR_NEEDED=${lGR_NEEDED:-10}
lGR_MAX=${GR_MAX:-20}

if [ "$lGR" -lt 0 ]; then
   return 8  # god grants prayer, though unworthy
 elif [ "$lGR" -eq 0 ]; then
   return 7
 elif [ "$lGR" -lt $lGR_NEEDED ]; then
   return 6
 elif [ "$lGR" -lt $lGR_MAX ]; then
   return 4
 elif [ "$lGR" -eq $lGR_MAX ]; then
   return 0
 elif [ "$lGR" -eq $((lGR_MAX*2)) ]; then
   return 0  # altar
 elif [ "$lGR" -gt $lGR_MAX ]; then
   return 0  # altar
fi

# unreached:
test "$lGR" -ge $((lGR_MAX/2)) || return 3
}

# *** stub to issue use_skill praying
_pray_up_gracepoints(){
# ***

_debug "_pray_up_gracepoints:$*:GR=$GR GR_MAX=$GR_MAX"

local lGR='' lGR_MAX='' PRAYS=1 local c=0

lGR=${1:-$GR}
lGR=${lGR:-10}

lGR_MAX=${2:-$GR_MAX}
lGR_MAX=${lGR_MAX:-15}

PRAYS=$((lGR_MAX-lGR))

while :;
do
c=$((c+1))
   _is 1 1 use_skill praying
sleep 1
test $c = $PRAYS && break
done

return 0
}

_regenerate_spell_points(){  # cast by _do_loop if _watch_food returns 6
                             # by _watch_cleric_gracepoints/_watch_wizard_spellpoints
# ***

_draw 5 "Regenerating spell points.."
_draw 5 "Please wait ..."
while :;
do

sleep 20s # TODO: could pray instead

_watch_food $FOOD_STAT_MIN $FOOD && break

#_verbose "Still regenerating to spellpoints $SP -> $((SP_MAX/2)) .."
_verbose "Still regenerating to spellpoints $SP -> $SP_MAX .."
done

return 0
}
