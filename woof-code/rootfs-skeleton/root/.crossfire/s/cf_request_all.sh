#!/bin/ash

ME_PROG=`realpath "$0"`
ME_DIR=${ME_PROG%/*}
cd "$ME_DIR"

VERSION=0.0.1


rm -f /tmp/cf_req_*.reply

while read AST line
do

sleep 0.1
test "$line" || continue

REQUEST=`echo "$line" | sed 's/[[:blank:]]*Return .*//'`

echo draw 4 "$REQUEST"
case $REQUEST in
*'<'*'>'*) continue;;
esac

echo request $REQUEST

 while :; do
 unset REPLY
 sleep 0.1
 read -t 1 <&1   # IMPORTANT to <&1 ( not <&0 ) !! Otherwise reads EoI input further down ... ( in ash + bash )
  echo draw 5 "$REPLY" # DEBUG

  case $REPLY in
  '')          break;;
  $REPLY_OLD)  break;;
  *) echo "$REPLY" >>/tmp/cf_req_"$REQUEST".reply
  esac

 REPLY_OLD="$REPLY"
 done


done <<EoI
         *   player       Return the player's tag and title
         *   range        Return the type and name of the currently selected range attack
         *   stat <type>  Return the specified stats
         *   stat stats   Return Str,Con,Dex,Int,Wis,Pow,Cha
         *   stat cmbt    Return wc,ac,dam,speed,weapon_sp
         *   stat hp      Return hp,maxhp,sp,maxsp,grace,maxgrace,food
         *   stat xp      Return level,xp,skill-1 level,skill-1 xp,...
         *   stat resists Return resistances
         *   stat paths   Return spell paths: attuned, repelled, denied.
         *   weight       Return maxweight, weight
         *   flags        Return flags (fire, run)
         *   items inv    Return a list of items in the inventory, one per line
         *   items actv   Return a list of inventory items that are active, one per line
         *   items on     Return a list of items under the player, one per line
         *   items cont   Return a list of items in the open container, one per line
         *   map pos      Return the players x,y within the current map
         *   map near     Return the 3x3 grid of the map centered on the player
         *   map all      Return all the known map information
         *   map <x> <y>  Return the information about square x,y in the current map
         *   skills       Return a list of all skill names, one per line (see also stat xp)
         *   spells       Return a list of known spells, one per line
EoI

