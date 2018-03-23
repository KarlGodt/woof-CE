#!/bin/ash

[ "$HAVE_FUNCS_REQUESTS" ] && return 0

# depends :
[ "$HAVE_FUNCS_COMMON"   ] || . cf_funcs_common.sh

_request_stub(){

test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request "$@"
read -t ${TMOUT:-1} ANSWER
#Script %d %s malfunction; unimplemented request:",i+1,scripts[i].name)
 _log "$REQUEST_LOG" "_request_stub $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

__request_stub(){ # for multi-line replies

test "$*" || return 254

local lANSWER lOLD_ANSWER
unset lANSWER lOLD_ANSWER ANSWER

_empty_message_stream
echo request $*
while :; do
 read -t $TMOUT lANSWER
 _log "$REQUEST_LOG" "__request_stub $*:$lANSWER"
 _msg 7 "$lANSWER"
 case $lANSWER in ''|$lOLD_ANSWER|*request*end) break 1;; esac
 ANSWER="$ANSWER
$lANSWER"
lOLD_ANSWER="$lANSWER"
sleep 0.01
done
ANSWER=`echo "$ANSWER" | sed 'sI^$II'`
test "$ANSWER"
}

_request_player_(){
#Return the player's tag and title

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request player
read -t ${TMOUT:-1} ANSWER
#request player %d %s\n", cpl.ob->tag, cpl.title
 _log "$REQUEST_LOG" "_request_player_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_player(){
#Return the player's tag and title

#test "$*" || return 254

_empty_message_stream

unset TAG TITLE REST
echo request player
read -t ${TMOUT:-1} r pl TAG TITLE REST
#request player %d %s\n", cpl.ob->tag, cpl.title
 _log "$REQUEST_LOG" "_request_player $*: '$TAG' '$TITLE' '$REST'"
 _msg 7 "$TAG $TITLE $REST"

test "$TAG" -a "$TITLE"
}

_request_range_(){
#Return the type and name of the currently selected range attack

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request range
read -t ${TMOUT:-1} ANSWER
#request range %s\n",cpl.range
 _log "$REQUEST_LOG" "_request_range_:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_range(){
#Return the type and name of the currently selected range attack

#test "$*" || return 254

_empty_message_stream

unset RANGE REST
echo request range
read -t ${TMOUT:-1} r ra RANGE REST
#request range %s\n",cpl.range
 _log "$REQUEST_LOG" "_request_range: '$RANGE' '$REST'"
 _msg 7 "$RANGE"

test "$RANGE"
}

_request_stat_stats_(){
#Return Str,Con,Dex,Int,Wis,Pow,Cha

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request stat stats
read -t ${TMOUT:-1} ANSWER
#request stat stats %d %d %d %d %d %d %d\n",
#cpl.stats.Str,cpl.stats.Con,cpl.stats.Dex,cpl.stats.Int,cpl.stats.Wis,cpl.stats.Pow,cpl.stats.Cha
 _log "$REQUEST_LOG" "_request_stat_stats_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_stat_stats(){
#Return Str,Con,Dex,Int,Wis,Pow,Cha

#test "$*" || return 254

_empty_message_stream

unset STR CON DEX INT WIS POW CHA
echo request stat stats
read -t ${TMOUT:-1} r s st STR CON DEX INT WIS POW CHA
#request stat stats %d %d %d %d %d %d %d\n",
#cpl.stats.Str,cpl.stats.Con,cpl.stats.Dex,cpl.stats.Int,cpl.stats.Wis,cpl.stats.Pow,cpl.stats.Cha
 _log "$REQUEST_LOG" "_request_stat_stats $*:$STR $CON $DEX $INT $WIS $POW $CHA"
 _msg 7 "$STR $CON $DEX $INT $WIS $POW $CHA"

test "$STR" -a "$CON" -a "$DEX" -a "$INT" -a "$WIS" -a "$POW" -a "$CHA"
}

_request_stat_cmbt_(){
#Return wc,ac,dam,speed,weapon_sp

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request stat cmbt
read -t ${TMOUT:-1} ANSWER
#request stat cmbt %d %d %d %d %d\n",
#cpl.stats.wc,cpl.stats.ac,cpl.stats.dam,cpl.stats.speed,cpl.stats.weapon_sp)
 _log "$REQUEST_LOG" "_request_stat_cmbt_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_stat_cmbt(){
#Return wc,ac,dam,speed,weapon_sp

#test "$*" || return 254

_empty_message_stream

unset WC AC DAM SPEED WP_SPEED REST
echo request stat cmbt
read -t ${TMOUT:-1} r s c WC AC DAM SPEED WP_SPEED REST
#request stat cmbt %d %d %d %d %d\n",
#cpl.stats.wc,cpl.stats.ac,cpl.stats.dam,cpl.stats.speed,cpl.stats.weapon_sp)
 _log "$REQUEST_LOG" "_request_stat_cmbt $*:$WC $AC $DAM $SPEED $WP_SPEED $REST"
 _msg 7 "$WC $AC $DAM $SPEED $WP_SPEED $REST"

PL_SPEED=$SPEED
test "$WC" -a "$AC" && test "$DAM" -a "$SPEED" -a "$WP_SPEED"
}

_request_stat_hp_(){
#Return hp,maxhp,sp,maxsp,grace,maxgrace,food

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request stat hp
read -t ${TMOUT:-1} ANSWER
#request stat hp %d %d %d %d %d %d %d\n",
#cpl.stats.hp,cpl.stats.maxhp,cpl.stats.sp,cpl.stats.maxsp,cpl.stats.grace,cpl.stats.maxgrace,cpl.stats.food)
 _log "$REQUEST_LOG" "_request_stat_hp_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_stat_hp(){
#Return hp,maxhp,sp,maxsp,grace,maxgrace,food

#test "$*" || return 254

_empty_message_stream

unset HP MHP SP MSP GR MGR FOOD_LVL REST
echo request stat hp
read -t ${TMOUT:-1} r s hp HP MHP SP MSP GR MGR FOOD_LVL REST
#request stat hp %d %d %d %d %d %d %d\n",
#cpl.stats.hp,cpl.stats.maxhp,cpl.stats.sp,cpl.stats.maxsp,cpl.stats.grace,cpl.stats.maxgrace,cpl.stats.food)
 _log "$REQUEST_LOG" "_request_stat_hp $*:$HP $MHP $SP $MSP $GR $MGR $FOOD_LVL $REST"
 _msg 7 "$HP $MHP $SP $MSP $GR $MGR $FOOD_LVL $REST"

MAXHP=$MHP
MAXSP=$MSP
MAXGR=$MGR
test "$HP" -a "$MHP" -a "$SP" -a "$MSP" -a "$GR" -a "$MGR" -a "$FOOD_LVL"
}

_request_stat_xp_(){
#Return level,xp,skill-1 level,skill-1 xp,...

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request stat xp
read -t ${TMOUT:-1} ANSWER
#request stat xp %d %" FMT64 ,cpl.stats.level,cpl.stats.exp)
#for(s=0;s<MAX_SKILL;++s) {
#sprintf(buf," %d %" FMT64 ,cpl.stats.skill_level[s],cpl.stats.skill_exp[s])
 _log "$REQUEST_LOG" "_request_stat_xp_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_stat_xp(){
#Return level,xp,skill-1 level,skill-1 xp,...

#test "$*" || return 254

_empty_message_stream

unset LEVEL EXPERIENCE REST
echo request stat xp
read -t ${TMOUT:-1} r s xp LEVEL EXPERIENCE REST
#request stat xp %d %" FMT64 ,cpl.stats.level,cpl.stats.exp)
#for(s=0;s<MAX_SKILL;++s) {
#sprintf(buf," %d %" FMT64 ,cpl.stats.skill_level[s],cpl.stats.skill_exp[s])
 _log "$REQUEST_LOG" "_request_stat_xp $*:$LEVEL $EXPERIENCE $REST"
 _msg 7 "$LEVEL $EXPERIENCE $REST"

test "$LEVEL" -a "$EXPERIENCE"
}

_request_stat_resists_(){
#Return resistances

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request stat resists
read -t ${TMOUT:-1} ANSWER
#request stat resists"
#for(s=0;s<30;++s) {
#sprintf(buf," %d",cpl.stats.resists[s])
 _log "$REQUEST_LOG" "_request_stat_resists_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_stat_resists(){
#Return resistances

#test "$*" || return 254

_empty_message_stream

unset R0  R1  R2  R3  R4  R5  R6  R7  R8  R9
unset R10 R11 R12 R13 R14 R15 R16 R17 R18 R19
unset R20 R21 R22 R23 R24 R25 R26 R27 R28 R29
unset REST

echo request stat resists
read -t ${TMOUT:-1} r s res R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 \
 R10 R11 R12 R13 R14 R15 R16 R17 R18 R19 \
 R20 R21 R22 R23 R24 R25 R26 R27 R28 R29 REST
#request stat resists"
#for(s=0;s<30;++s) {
#sprintf(buf," %d",cpl.stats.resists[s])
 _log "$REQUEST_LOG" "_request_stat_resists $*:$R0 $R1 $R2 $R3 $R4 $R5 $R6 $R7 $R8 $R9"
 _log "$REQUEST_LOG" "_request_stat_resists $*:$R10 $R11 $R12 $R13 $R14 $R15 $R16 $R17 $R18 $R19"
 _log "$REQUEST_LOG" "_request_stat_resists $*:$R20 $R21 $R22 $R23 $R24 $R25 $R26 $R27 $R28 $R29 $REST"
 _msg 7 "$ANSWER"

test "$R0" -o "$R1" -o "$R2" -o "$R3" -o "$R4" -o "$R5" -o "$R6" -o "$R7" -o "$R8" -o "$R9" && return 0
test "$R10" -o "$R11" -o "$R12" -o "$R13" -o "$R14" -o "$R15" -o "$R16" -o "$R17" -o "$R18" -o "$R19" && return 0
test "$R20" -o "$R21" -o "$R22" -o "$R23" -o "$R24" -o "$R25" -o "$R26" -o "$R27" -o "$R28" -o "$R29"
}

_request_stat_paths_(){
#Return spell paths: attuned, repelled, denied.

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request stat paths
read -t ${TMOUT:-1} ANSWER
#request stat paths %d %d %d\n", cpl.stats.attuned, cpl.stats.repelled, cpl.stats.denied)
 _log "$REQUEST_LOG" "_request_stat_paths_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_stat_paths(){
#Return spell paths: attuned, repelled, denied.

#test "$*" || return 254

_empty_message_stream

unset ATTUNED REPELLED DENIED REST
echo request stat paths
read -t ${TMOUT:-1} r s pa ATTUNED REPELLED DENIED REST
#request stat paths %d %d %d\n", cpl.stats.attuned, cpl.stats.repelled, cpl.stats.denied)
 _log "$REQUEST_LOG" "_request_stat_paths $*:$ATTUNED $REPELLED $DENIED $REST"
 _msg 7 "$ATTUNED $REPELLED $DENIED $REST"

test "$ATTUNED" -o "$REPELLED" -o "$DENIED" || true
}

_request_weight_(){
#Return maxweight, weight

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request weight
read -t ${TMOUT:-1} ANSWER
#request weight %d %d\n",cpl.stats.weight_limit,(int)(cpl.ob->weight*1000)
 _log "$REQUEST_LOG" "_request_weight_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_weight(){
#Return maxweight, weight

#test "$*" || return 254

_empty_message_stream

unset MAXWEIGHT OBJWEIGHT REST
echo request weight
read -t ${TMOUT:-1} r w MAXWEIGHT OBJWEIGHT REST
#request weight %d %d\n",cpl.stats.weight_limit,(int)(cpl.ob->weight*1000)
 _log "$REQUEST_LOG" "_request_weight $*:$MAXWEIGHT $OBJWEIGHT $REST"
 _msg 7 "$MAXWEIGHT $OBJWEIGHT $REST"

test "$MAXWEIGHT" -a "$OBJWEIGHT"
}

_request_flags_(){
#Return flags (fire, run)

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request flags
read -t ${TMOUT:-1} ANSWER
#request flags %d %d %d %d\n",cpl.stats.flags,cpl.fire_on,cpl.run_on,cpl.no_echo)
 _log "$REQUEST_LOG" "_request_flags_ $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_flags(){
#Return flags (fire, run)

#test "$*" || return 254

_empty_message_stream

unset FL_FLAGS FL_FIRE_ON FL_RUN_ON FL_NO_ECHO REST
echo request flags
read -t ${TMOUT:-1} r fl FL_FLAGS FL_FIRE_ON FL_RUN_ON FL_NO_ECHO REST
#request flags %d %d %d %d\n",cpl.stats.flags,cpl.fire_on,cpl.run_on,cpl.no_echo)
 _log "$REQUEST_LOG" "_request_flags $*:$FL_FLAGS FL_FIRE_ON FL_RUN_ON FL_NO_ECHO REST"
 _msg 7 "$FL_FLAGS $FL_FIRE_ON $FL_RUN_ON $FL_NO_ECHO $REST"

#test ##TODO: UNKNOWN
}

__request_items_inv(){
#Return a list of items in the inventory, one per line

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request items inv
read -t ${TMOUT:-1} ANSWER
#* flags are a bitmask:
#*   magic, cursed, damned, unpaid, locked, applied, open, was_open, inv_updated
#*    256     128     64      32       16      8       4      2         1
#flags = it->magical;
#   flags = (flags<<1)|it->cursed;
#   flags = (flags<<1)|it->damned;
#   flags = (flags<<1)|it->unpaid;
#   flags = (flags<<1)|it->locked;
#   flags = (flags<<1)|it->applied;
#   flags = (flags<<1)|it->open;
#   flags = (flags<<1)|it->was_open;
#   flags = (flags<<1)|it->inv_updated;
#   snprintf(buf, sizeof(buf), "%s%d %d %d %d %d %s\n",
#    head, it->tag, it->nrof, (int)(it->weight*1000+0.5), flags, it->type, it->d_name)
#while (it) {
# script_send_item(i,"request items inv ",it)
#request items inv end\n
 _log "$REQUEST_LOG" "_request_items_inv $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}


_request_items_inv(){
_debug "_request_items_inv:$*"
_log   "_request_items_inv:$*"

INV_LIST_FILE=${INV_LIST_FILE:-"$TMP_DIR"/"$MY_BASE".$$.inv}

local lEMPTY_LINE=0

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
_log "$INV_LIST_FILE" "_request_items_inv:$REPLY"
_debug "$REPLY"

case $REPLY in
'') lEMPTY_LINE=$((lEMPTY_LINE+1));
    if test $lEMPTY_LINE -ge 5; then
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

ANSWER="$INVENTORY_LIST"
test "$ANSWER"
#test "$INVENTORY_LIST"
}


_request_items_actv(){
#Return a list of inventory items that are active, one per line

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request items actv
read -t ${TMOUT:-1} ANSWER
#while (it) {
# if (it->applied) script_send_item(i,"request items actv ",it)
#request items actv end\n
 _log "$REQUEST_LOG" "_request_items_actv $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_items_on(){
#Return a list of items under the player, one per line

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request items on
read -t ${TMOUT:-1} ANSWER
#while (it) {
# script_send_item(i,"request items on ",it)
#request items on end\n
 _log "$REQUEST_LOG" "_request_items_on $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_items_cont(){
#Return a list of items in the open container, one per line

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request items cont
read -t ${TMOUT:-1} ANSWER
#while (it) {
# script_send_item(i,"request items cont ",it)
#request items cont end\n
 _log "$REQUEST_LOG" "_request_items_cont $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_map_pos(){
#Return the players x,y within the current map

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request map pos
read -t ${TMOUT:-1} ANSWER
#request map pos %d %d\n",pl_pos.x,pl_pos.y)
 _log "$REQUEST_LOG" "_request_map_pos $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_map_near(){
#Return the 3x3 grid of the map centered on the player

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request map near
read -t ${TMOUT:-1} ANSWER
#request map %d %d unknown\n", x, y)
#request map %d %d  %d %c %c %c %c"
#       " smooth %d %d %d heads %d %d %d tails %d %d %d\n",
#       x, y, the_map.cells[x][y].darkness,
#       the_map.cells[x][y].need_update ? 'y' : 'n',
#       the_map.cells[x][y].have_darkness ? 'y' : 'n',
#       the_map.cells[x][y].need_resmooth ? 'y' : 'n',
#       the_map.cells[x][y].cleared ? 'y' : 'n',
#       the_map.cells[x][y].smooth[0], the_map.cells[x][y].smooth[1], the_map.cells[x][y].smooth[2],
#       the_map.cells[x][y].heads[0].face, the_map.cells[x][y].heads[1].face, the_map.cells[x][y].heads[2].face,
#       the_map.cells[x][y].tails[0].face, the_map.cells[x][y].tails[1].face, the_map.cells[x][y].tails[2].face
#   )
#send_map(i,
#                           x+pl_pos.x+use_config[CONFIG_MAPWIDTH]/2-1,
#                           y+pl_pos.y+use_config[CONFIG_MAPHEIGHT]/2-1
#                       )
 _log "$REQUEST_LOG" "_request_map_near $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_map_all(){
#Return all the known map information

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request map all
read -t ${TMOUT:-1} ANSWER
#for(y=0;y<the_map.y;++y)
#              for(x=0;x<the_map.x;++x)
#                 send_map(i,x,y)
#request map end\n
 _log "$REQUEST_LOG" "_request_map_all $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_map_x_y(){
#Return the information about square x,y in the current map

test "$*" || return 254
test "$1" || return 253
test "$2" || return 252

_empty_message_stream

unset ANSWER
echo request map $@
read -t ${TMOUT:-1} ANSWER
#if ( !*c ) return  /* No x specified */
#if ( !*c ) return; /* No y specified */
#send_map(i,x,y)

 _log "$REQUEST_LOG" "_request_map_x_y $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_skills(){

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request skills
read -t ${TMOUT:-1} ANSWER
#for (s = 0; s < CS_NUM_SKILLS; s++) {
#if (skill_names[s]) {
#sprintf(buf, "request skills %d %s\n", CS_STAT_SKILLINFO + s, skill_names[s])
#request skills end\n
 _log "$REQUEST_LOG" "_request_skills $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

_request_spells(){

#test "$*" || return 254

_empty_message_stream

unset ANSWER
echo request spells
read -t ${TMOUT:-1} ANSWER
#for (spell = cpl.spelldata; spell; spell = spell->next) {
#sprintf(buf, "request spells %d %d %d %d %d %d %d %d %s\n",
#spell->tag, spell->level, spell->sp, spell->grace,
#spell->skill_number, spell->path, spell->time,
#spell->dam, spell->name)
#request spells end\n
 _log "$REQUEST_LOG" "_request_spells $*:$ANSWER"
 _msg 7 "$ANSWER"

test "$ANSWER"
}

###END###
HAVE_FUNCS_REQUESTS=1
