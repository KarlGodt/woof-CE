#!/bin/ash
# *** Here begins program *** #
echo draw 2 "$0 is started with pid $$ $PPID"
echo draw 5 " with '$*' parameter."

__print_data_types(){
DATA_TYPES=`cat <<EoI
Data Type   Comment
range   Return the type and name of the currently selected range attack
stat <type>     Return the specified stats
stat stats  Return Str,Con,Dex,Int,Wis,Pow,Cha
stat cmbt   Return wc,ac,dam,speed,weapon_sp
stat hp     Return hp,maxhp,sp,maxsp,grace,maxgrace,food
stat xp     Return level,xp,skill-1 level,skill-1 xp,...
stat resists    Return resistances
weight  Return maxweight, weight
flags   Return flags (fire, run)
items inv   Return a list of items in the inventory, one per line
items actv  Return a list of inventory items that are active, one per line
items on    Return a list of items under the player, one per line
items cont  Return a list of items in the open container, one per line
map pos     Return the players x,y within the current map
map near    Return the 3×3 grid of the map centered on the player
map all     Return all the known map information
map <x> <y>     Return the information about square x,y in the current map (relative to player position)
EoI`

echo draw 5 "$DATA_TYPES"
}

_print_data_types(){
    while read -r aLINE
    do
    echo draw 5 "$aLINE"

    done<<EoI
    File : client/common/script.c

            Data Type       Comment
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
}

_print_resists_table(){
 while read -r aLINE
    do
    echo draw 5 "$aLINE"
    done <<EoI
File: client/common/client.c

const char *const resists_name[NUM_RESISTS] = {
"armor", "magic", "fire",  "elec",
"cold",  "conf",  "acid",  "drain",
"ghit",  "pois",  "slow",  "para",
"t undead", "fear", "depl", "death",
"hword", "blind" };
EoI

}

#_print_data_types

case $1 in
*help) _print_data_types;;
'') echo draw 3 "Need parameter(s) :Use <help> to show them.";;
*)
echo request "$@"
while :; do
read -t 10 REQUEST_ANSWER
echo draw 5 "ANSWER=$REQUEST_ANSWER"
test "$REQUEST_ANSWER" || break
unset REQUEST_ANSWER
sleep 0.1
done
 case $@ in
  *resists*) _print_resists_table;;
 esac
;;
esac

#echo request range
#read -t 1 REQ_RANGE
#echo draw 5 "RANGE=$REQ_RANGE"

#echo watch range
#read -t 1 WAT_RANGE
#echo draw 3 "RANGE=$WAT_RANGE"

echo draw 2 "$0 has ended"

