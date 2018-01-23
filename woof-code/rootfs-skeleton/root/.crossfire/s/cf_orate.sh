#!/bin/ash

VERSION=0.0 # Initial version, that did not process much messages
VERSION=1.0 # first "reliable" version 2018-01-23

# Log file path in /tmp
MY_SELF=`realpath "$0"` ## needs to be in main script
MY_BASE=${MY_SELF##*/}  ## needs to be in main script
LOGGING=1

# ATTACK_ATTEMPTS_DEFAULT=1
#ORATORY_ATTEMPTS_DEFAULT=1
#SINGING_ATTEMPTS_DEFAULT=1

. $HOME/cf/s/cf_funcs_common.sh || exit 4
. $HOME/cf/s/cf_funcs_food.sh   || exit 5
. $HOME/cf/s/cf_funcs_traps.sh  || exit 6
. $HOME/cf/s/cf_funcs_move.sh   || exit 7
. $HOME/cf/s/cf_funcs_chests.sh || exit 8

_say_help_stdalone(){
_draw 6  "$MY_BASE"
_draw 7  "Script to calm down monsters"
_draw 7  "by skill singing and then"
_draw 7  "making them pets by skill oratory."
_draw 2  "To be used in the crossfire roleplaying game client."
_draw 6  "Syntax:"
_draw 7  "$0 <<NUMBER>> <<Options>>"
_draw 8  "Options:"
_draw 10 "Simple number as first parameter:Just make NUMBER loop rounds."
_draw 10 "-C # :like above, just make NUMBER loop rounds."
_draw 9  "-O # :Number of oratory attempts." #, default $ORATORY_ATTEMPTS_DEFAULT"
_draw 9  "-S # :Number of singing attempts." #, default $SINGING_ATTEMPTS_DEFAULT"
_draw 8  "-D word :Direction to sing and orate to,"
_draw 8  " as n, ne, e, se, s, sw, w, nw."
_draw 8  " If no direction, turns clockwise all around on the spot."
_draw 11 "-V   :Print version information."
_draw 10 "-d   :Print debugging to msgpane."
exit ${1:-2}
}

_do_parameters_stdalone(){
_debug "_do_parameters_stdalone:$*"

# dont forget to pass parameters when invoking this function
test "$*" || return 0

case $1 in
*help)    _say_help_stdalone 0;;
*version) _say_version 0;;
--?*)  _exit 3 "No other long options than help and version recognized.";;
--*)   _exit 3 "Unhandled first parameter '$1' .";;
-?*) :;;
[0-9]*) NUMBER=$1
        test "${NUMBER//[[:digit:]]/}" && _exit 3 "NUMBER '$1' is not an integer digit."
        shift;;
*) _exit 3 "Unknown first parameter '$1' .";;
esac

# C # :Count loop rounds
# O # :Oratory attempts
# S # :Singing attempts
# d   :debugging output
while getopts C:O:S:D:dVhabdefgijklmnopqrstuvwxyzABEFGHIJKLMNPQRTUWXYZ oneOPT
do
case $oneOPT in
C) NUMBER=$OPTARG;;
D) DIRECTION_OPT=$OPTARG;;
O) ORATORY_ATTEMPTS=${OPTARG:-$ORATORY_ATTEMPTS_DEFAULT};;
S) SINGING_ATTEMPTS=${OPTARG:-$SINGING_ATTEMPTS_DEFAULT};;
d) DEBUG=$((DEBUG+1)); MSGLEVEL=7;;
h) _say_help_stdalone 0;;
V) _say_version 0;;

'') _draw 2 "FIXME: Empty positional parameter ...?";;
*) _draw 3 "Unrecognized parameter '$oneOPT' .";;
esac

sleep 0.1
done

}


_say_skill_oratory_code_(){
cat >&1 <<EoI
file : server/server/skills.c
/* players using this skill can 'charm' a monster --
 * into working for them. It can only be used on
 * non-special (see below) 'neutral' creatures.
 * -b.t. (thomas@astro.psu.edu)
 */

int use_oratory(object *pl, int dir, object *skill) {
    sint16 x=pl->x+freearr_x[dir],y=pl->y+freearr_y[dir];
    int mflags,chance;
    object *tmp;
    mapstruct *m;

    if(pl->type!=PLAYER) return 0;  /* only players use this skill */
    m = pl->map;
    mflags =get_map_flags(m, &m, x,y, &x, &y);
    if (mflags & P_OUT_OF_MAP) return 0;

    /* Save some processing - we have the flag already anyways
     */
    if (!(mflags & P_IS_ALIVE)) {
    new_draw_info(NDI_UNIQUE, 0, pl, "There is nothing to orate to.");
    return 0;
    }

    for(tmp=get_map_ob(m,x,y);tmp;tmp=tmp->above) {
        /* can't persuade players - return because there is nothing else
     * on that space to charm.  Same for multi space monsters and
     * special monsters - we don't allow them to be charmed, and there
     * is no reason to do further processing since they should be the
     * only monster on the space.
     */
        if(tmp->type==PLAYER) return 0;
        if(tmp->more || tmp->head) return 0;
    if(tmp->msg) return 0;

    if(QUERY_FLAG(tmp,FLAG_MONSTER)) break;
    }

    if (!tmp) {
    new_draw_info(NDI_UNIQUE, 0, pl, "There is nothing to orate to.");
    return 0;
    }

    new_draw_info_format(NDI_UNIQUE,
     0,pl, "You orate to the %s.",query_name(tmp));

    /* the following conditions limit who may be 'charmed' */

    /* it's hostile! */
    if(!QUERY_FLAG(tmp,FLAG_UNAGGRESSIVE) && !QUERY_FLAG(tmp, FLAG_FRIENDLY)) {
    new_draw_info_format(NDI_UNIQUE, 0,pl,
       "Too bad the %s isn't listening!\n",query_name(tmp));
    return 0;
    }

    /* it's already allied! */
    if(QUERY_FLAG(tmp,FLAG_FRIENDLY)&&(tmp->attack_movement==PETMOVE)){
    if(get_owner(tmp)==pl) {
        new_draw_info(NDI_UNIQUE, 0,pl,
              "Your follower loves your speech.\n");
        return 0;
    } else if (skill->level > tmp->level) {
        /* you steal the follower.  Perhaps we should really look at the
         * level of the owner above?
         */
        set_owner(tmp,pl);
        new_draw_info_format(NDI_UNIQUE, 0,pl,
         "You convince the %s to follow you instead!\n",
         query_name(tmp));
        /* Abuse fix - don't give exp since this can otherwise
         * be used by a couple players to gets lots of exp.
         */
        return 0;
    } else {
        /* In this case, you can't steal it from the other player */
        return 0;
    }
    } /* Creature was already a pet of someone */

    chance=skill->level*2+(pl->stats.Cha-2*tmp->stats.Int)/2;

    /* Ok, got a 'sucker' lets try to make them a follower */
    if(chance>0 && tmp->level<(random_roll(0, chance-1, pl, PREFER_HIGH)-1)) {
    new_draw_info_format(NDI_UNIQUE, 0,pl,
         "You convince the %s to become your follower.\n",
         query_name(tmp));

    set_owner(tmp,pl);
    tmp->stats.exp = 0;
    add_friendly_object(tmp);
    SET_FLAG(tmp,FLAG_FRIENDLY);
    tmp->attack_movement = PETMOVE;
    return calc_skill_exp(pl,tmp, skill);
    }
    /* Charm failed.  Creature may be angry now */
    else if((skill->level+((pl->stats.Cha-10)/2)) < random_roll(1, 2*tmp->level, pl, PREFER_LOW)) {
    new_draw_info_format(NDI_UNIQUE, 0,pl,
          "Your speech angers the %s!\n",query_name(tmp));
    if(QUERY_FLAG(tmp,FLAG_FRIENDLY)) {
        CLEAR_FLAG(tmp,FLAG_FRIENDLY);
        remove_friendly_object(tmp);
        tmp->attack_movement = 0;   /* needed? */
    }
    CLEAR_FLAG(tmp,FLAG_UNAGGRESSIVE);
    }
    return 0;   /* Fall through - if we get here, we didn't charm anything */
}
EoI
}

_say_skill_singing_code_(){
cat >&1 <<EoI

#define FLAG_MONSTER        14 /* Will attack players */
#define FLAG_FRIENDLY       15 /* Will help players */
#define FLAG_SPLITTING      32 /* Object splits into stats.food other objs */
#define FLAG_HITBACK        33 /* Object will hit back when hit */
#define FLAG_UNDEAD     36 /* Monster is undead */
#define FLAG_SCARED     37 /* Monster is scared (mb player in future)*/
#define FLAG_UNAGGRESSIVE   38 /* Monster doesn't attack players */
#define FLAG_NO_STEAL       96 /* Item can't be stolen */

file : server/server/skills.c
/* Singing() -this skill allows the player to pacify nearby creatures.
 * There are few limitations on who/what kind of
 * non-player creatures that may be pacified. Right now, a player
 * may pacify creatures which have Int == 0. In this routine, once
 * successfully pacified the creature gets Int=1. Thus, a player
 * may only pacify a creature once.
 * BTW, I appologize for the naming of the skill, I couldnt think
 * of anything better! -b.t.
 */

int singing(object *pl, int dir, object *skill) {
    int i,exp = 0,chance, mflags;
    object *tmp;
    mapstruct *m;
    sint16  x, y;

    if(pl->type!=PLAYER) return 0;    /* only players use this skill */

    new_draw_info_format(NDI_UNIQUE,0,pl, "You sing");
    for(i=dir;i<(dir+MIN(skill->level,SIZEOFFREE));i++) {
    x = pl->x+freearr_x[i];
    y = pl->y+freearr_y[i];
    m = pl->map;

    mflags =get_map_flags(m, &m, x,y, &x, &y);
    if (mflags & P_OUT_OF_MAP) continue;
    if (!(mflags & P_IS_ALIVE)) continue;

    for(tmp=get_map_ob(m, x, y); tmp;tmp=tmp->above) {
        if(QUERY_FLAG(tmp,FLAG_MONSTER)) break;
        /* can't affect players */
            if(tmp->type==PLAYER) break;
    }

    /* Whole bunch of checks to see if this is a type of monster that would
     * listen to singing.
     */
    if (tmp && QUERY_FLAG(tmp, FLAG_MONSTER) &&
        !QUERY_FLAG(tmp, FLAG_NO_STEAL) &&      /* Been charmed or abused before */
        !QUERY_FLAG(tmp, FLAG_SPLITTING) &&     /* no ears */
        !QUERY_FLAG(tmp, FLAG_HITBACK) &&       /* was here before */
        (tmp->level <= skill->level) &&
        (!tmp->head) &&
        !QUERY_FLAG(tmp, FLAG_UNDEAD) &&
        !QUERY_FLAG(tmp,FLAG_UNAGGRESSIVE) &&   /* already calm */
        !QUERY_FLAG(tmp,FLAG_FRIENDLY)) {       /* already calm */

        /* stealing isn't really related (although, maybe it should
         * be).  This is mainly to prevent singing to the same monster
         * over and over again and getting exp for it.
         */
        chance=skill->level*2+(pl->stats.Cha-5-tmp->stats.Int)/2;
        if(chance && tmp->level*2<random_roll(0, chance-1, pl, PREFER_HIGH)) {
        SET_FLAG(tmp,FLAG_UNAGGRESSIVE);
        new_draw_info_format(NDI_UNIQUE, 0,pl,
             "You calm down the %s\n",query_name(tmp));
        /* Give exp only if they are not aware */
        if(!QUERY_FLAG(tmp,FLAG_NO_STEAL))
            exp += calc_skill_exp(pl,tmp, skill);
        SET_FLAG(tmp,FLAG_NO_STEAL);
        } else {
                 new_draw_info_format(NDI_UNIQUE, 0,pl,
                    "Too bad the %s isn't listening!\n",query_name(tmp));
        SET_FLAG(tmp,FLAG_NO_STEAL);
        }
    }
    }
    return exp;
}

EoI
}


_check_skill_available_stdalone(){
_debug "_check_skill_available_stdalone:$*"

local lSKILL=${*:-"$SKILL"}
test "$lSKILL" || return 254

local lRV=

_empty_message_stream
_watch $DRAWINFO
_is 1 1 ready_skill punching  # force response, because when not changing
_is 1 1 ready_skill "$lSKILL" # range attack, no message is printed

while :; do unset REPLY
read -t $TMOUT
  _log "_check_skill_available_stdalone:$REPLY"
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
 *scripttell*exit*)    _exit 1;;
 *) :;;
 esac

sleep 0.01
done

_unwatch $DRAWINFO
_empty_message_stream

return ${lRV:-3}
}

_set_next_direction_stdalone(){
_debug "_set_next_direction_stdalone:$*:$DIRN"

DIRN=$((DIRN+1))
test "$DIRN" -ge 9 && DIRN=1

_number_to_direction $DIRN
_draw 2 "Will turn to direction $DIRECTION .."
}

_kill_monster_stdalone(){
_debug "_kill_monster_stdalone:$*"

local ATTACKS=${*:-$ATTACK_ATTEMPTS_DEF}

for i in `seq 1 1 ${ATTACKS:-1}`; do
_is 1 1 $DIRECTION
done
_empty_message_stream
}

_brace_stdalone(){
_debug "_brace_stdalone:$*"

_watch $DRAWINFO
while :
do
_is 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log "$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 2;;
 *'Not braced.'*)     break 1;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch $DRAWINFO
_empty_message_stream
}

_unbrace_stdalone(){
_debug "_unbrace_stdalone:$*"

_watch $DRAWINFO
while :
do
_is 1 1 brace
 while :; do unset REPLY
 read -t $TMOUT
 _log "$REPLY"
 _debug "$REPLY"
 case $REPLY in
 *'You are braced.'*) break 1;;
 *'Not braced.'*)     break 2;;
 '') :;;
 *) :;;
 esac

 sleep 0.01
 done

sleep 0.1
done
_unwatch $DRAWINFO
_empty_message_stream
}

_calm_down_monster_ready_skill_stdalone(){
_debug "_calm_down_monster_ready_skill_stdalone:$*"

# Return Possibilities :
# 0 : success calming down, go on with orate
# 1 : no success calming down
#     -> kill the monster and try next in DIRN
#     -> turn to next monster
# 3 : Monster does not respond
#     -> try again
#     -> it is already calmed, go on with orate
#     -> kill monster and try next in DIRN
#     -> turn to next monster

local TRY_OR= lRV=

_watch $DRAWINFO
 while :;
 do

  _is 1 1 fire_stop
  _is 1 1 ready_skill singing
  _empty_message_stream

  _is 1 1 fire $DIRN
  _is 1 1 fire_stop
  SINGING_ATTEMPTS_DONE=$((SINGING_ATTEMPTS_DONE+1))
  #_sleep

  while :; do unset REPLY
  read -t $TMOUT
  _log "_calm_down_monster_ready_skill_stdalone:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  # EMPTY response by !FLAG_MONSTER
  # FLAG_NO_STEAL, FLAG_SPLITTING, FLAG_HITBACK,
  # FLAG_UNDEAD, FLAG_UNAGGRESSIVE, FLAG_FRIENDLY
  '') break 2;; #!=PLAYER
  *'You sing'*) break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1;;
  *) :;;
  esac

  sleep 0.01
  #_sleep
  done

  while :; do unset REPLY
  read -t $TMOUT
  _log "_calm_down_monster_ready_skill_stdalone:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  '') lRV=0; break 2;;
  *'You calm down the '*) CALMS=$((CALMS+1)); lRV=0;;
  *"Too bad the "*"isn't listening!"*) _kill_monster_stdalone; break 1;;
  #*'You withhold your attack'*)  _set_next_direction_stdalone; break 1;;
  #*'You avoid attacking '*)      _set_next_direction_stdalone; break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1;;
  *) :;;
  esac

  sleep 0.01
  #_sleep
  done

 sleep 0.1
 done

_unwatch $DRAWINFO
_draw 5 "With ${SINGING_ATTEMPTS_DONE:-0} singings you calmed down ${CALMS:-0} monsters."
_sleep
_debug 3 "lRV=$lRV"
return ${lRV:-1}
}

_orate_to_monster_ready_skill_stdalone(){
_debug "_orate_to_monster_ready_skill_stdalone:$*"

local lRV=

#_watch $DRAWINFO
#while :;
#do

 while :;
 do

  _watch $DRAWINFO
  _is 1 1 fire_stop
  _is 1 1 ready_skill oratory
  _empty_message_stream   # todo : check if skill available

  _is 1 1 fire $DIRN
  _is 1 1 fire_stop
  ORATORY_ATTEMPTS_DONE=$((ORATORY_ATTEMPTS_DONE+1))
  #_sleep

  while :; do unset REPLY
  read -t $TMOUT
  _log "_orate_to_monster_ready_skill_stdalone:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  #PLAYER, more, head, msg
  '') lRV=0; break 2;; # monster does not respond at all, try next
  *'There is nothing to orate to.'*) lRV=0; break 2;; # next monster #!tmp
 #*'You orate to the '*) _got_orate_reply_stdalone && { lRV=0; break 2; } || break 2;; #tmp
  *'You orate to the '*) break 1;; #tmp
  *scripttell*break*)    break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1;;
  *) :;;
  esac

  #_sleep
  sleep 0.01
  done

  while :; do unset REPLY
  read -t $TMOUT
  _log "_orate_to_monster_ready_skill_stdalone:$REPLY"
  _debug "$REPLY"

  case $REPLY in
  #!FLAG_UNAGGRESSIVE && !FLAG_FRIENDLY
  *'Too bad '*) _draw 3 "Catched Too bad 1"; break 2;; # try again singing the kobold isn't listening!
  #FLAG_FRIENDLY && PETMOVE && get_owner(tmp)==pl
  *'Your follower loves '*)          lRV=0; break 2;; # next creature or exit
  #FLAG_FRIENDLY && PETMOVE && (skill->level > tmp->level)
  *"You convince the "*" to follow you instead!"*)   FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  *'You convince the '*' to become your follower.'*) FOLLOWS=$((FOLLOWS+1)); lRV=0; break 2;; # next monster
  #/* Charm failed. Creature may be angry now */ skill < random_roll
  *"Your speech angers the "*) _draw 3 "Catched Anger 1";   break 2;;
  #/* can't steal from other player */, /* Charm failed. Creature may not be angry now */
  '') break 1;;
  *scripttell*break*)     break ${REPLY##*?break};;
  *scripttell*exit*)    _exit 1;;
  *) :;;
  esac

  #_sleep
  sleep 0.01
  done

 #_sleep
 sleep 0.1
 done

#sleep 0.1
#done
_unwatch $DRAWINFO

_draw 5 "With ${ORATORY_ATTEMPTS_DONE:-0} oratings you conceived ${FOLLOWS:-0} followers."
return ${lRV:-1}
}

_sing_and_orate_around_stdalone(){
_debug "_sing_and_orate_around_stdalone:$*"

while :;
do

_sleep
one=$((one+1))

[ "$DIRECTION_OPT" ] || _set_next_direction_stdalone

_calm_down_monster_ready_skill_stdalone
case $? in
 0) _orate_to_monster_ready_skill_stdalone
  case $? in
  0) :;;
  *) _kill_monster_stdalone;;
  esac
 ;;
 *) :;;
esac

_draw 2 "You calmed ${CALMS:-0} and convinced ${FOLLOWS:-0} monsters."

case $NUMBER in $one) break;; esac
case $ORATORY_ATTEMPTS in $ORATORY_ATTEMPTS_DONE) break;; esac
case $SINGING_ATTEMPTS in $SINGING_ATTEMPTS_DONE) break;; esac

if _check_counter; then
_check_food_level
_check_hp_and_return_home $HP
fi

_say_script_time
_sleep
#_set_next_direction_stdalone

done
}




# MAIN

_main_orate_func(){
_set_global_variables $*
_say_start_msg $*
_do_parameters_stdalone $*

_direction_to_number $DIRECTION_OPT
_check_skill_available_stdalone singing || return 1
_check_skill_available_stdalone oratory || return 1

_brace_stdalone
_sing_and_orate_around_stdalone || return $?
}

_main_orate_func "$@"

_say_end_msg
###END###
