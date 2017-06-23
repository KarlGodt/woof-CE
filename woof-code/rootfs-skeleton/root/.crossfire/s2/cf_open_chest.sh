#!/bin/bash

exec 2>/tmp/cf_script.err

# Now count the whole script time
TIMEA=`date +%s`


DRAW_INFO=drawinfo # drawextinfo

DEF_SEARCH=9
DEF_DISARM=9

DIRB=west # need to leave pile of chests to be able to apply
case $DIRB in
west)  DIRF=east;;
east)  DIRF=west;;
north) DIRF=south;;
south) DIRF=north;;
northwest) DIRF=southeast;;
northeast) DIRF=southwest;;
southwest) DIRF=northeast;;
southeast) DIRF=northwest;;
esac

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

# beeping
BEEP_DO=1
BEEP_LENGTH=500
BEEP_FREQ=700

_beep(){
[ "$BEEP_DO" ] || return 0
test "$1" && { BEEP_L=$1; shift; }
test "$1" && { BEEP_F=$1; shift; }
BEEP_LENGTH=${BEEP_L:-$BEEP_LENGTH}
BEEP_FREQ=${BEEP_F:-$BEEP_FREQ}
beep -l $BEEP_LENGTH -f $BEEP_FREQ "$@"
}

# colours
COL_BLACK=0
COL_WHITE=1
COL_NAVY=2
COL_RED=3
COL_ORANGE=4
COL_BLUE=5
COL_DORANGE=6
COL_GREEN=7
COL_LGREEN=8
COL_GRAY=9
COL_BROWN=10
COL_GOLD=11
COL_TAN=12

_draw(){
test "$*" || return
local COLOUR=${1:-0}
shift
while read -r line
do
test "$line" || continue
echo draw $COLOUR "$line"
sleep 0.1
done <<EoI
`echo "$@"`
EoI
}

_verbose(){
[ "$VERBOSE" ] || return 0
_draw ${COL_VERB:-12} "$*"
}

_debug(){
[ "$DEBUG" ] || return 0
_draw ${COL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOG_REPLY_FILE"
}

_is(){
_verbose "$*"
echo issue "$*"
sleep 0.2
}

# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to open chests."
_draw 2 "Syntax:"
_draw 7 "script $0 <<number>>"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times search, disarm, apply and get."
_draw 2 "Options:"
_draw 3 "-f force running even if bad traps triggered."
_draw 5 "-d set debug"
_draw 5 "-L log to $LOG_REPLY_FILE"
_draw 5 "-v set verbosity"

        exit 0
}


# *** Here begins program *** #
_draw 2 "$0 is started.."


# *** Check for parameters *** #

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
       _draw 3 "Only :digit: numbers as number option allowed."; exit 1; }
       readonly NUMBER
           _debug "NUMBER=$NUMBER"
       ;;
*help|*usage)  _usage;;

--*) case $PARAM_1 in
     *debug) DEBUG=$((DEBUG+1));;
     *force) FORCE=$((FORCE+1));;
     *help|*usage)  _usage;;
     *logging) LOGGING=$((LOGGING+1));;
     *verbose) VERBOSE=$((VERBOSE+1));;
     *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;

-*) OPTS=`printf '%s' $PARAM_1 | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      d) DEBUG=$((DEBUG+1));;
      f) FORCE=$((FORCE+1));;
      h) _usage;;
      L) LOGGING=$((LOGGING+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
   done
;;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

sleep 1
shift
done

# TODO : check if available space to walk in DIRB

# ** set pickup  0 and drop chests

#_is 0 0 lock bomb ##+++2017-06-23 # TODO:toggles

_is 0 0 pickup 0
sleep 1

_is 0 0 drop chest
sleep 1

_is 1 1 $DIRB
sleep 1

_is 1 1 $DIRF
sleep 1

# TODO : check if on chest

_handle_spell_errors(){
local RV=0

UNSET_MAGI=0
UNSET_PRAY=0

case $REPLY in  # server/spell_util.c
 *'Something blocks your magic.'*)               UNSET_MAGI=1;;
 '*Something blocks the magic of your item.'*)   UNSET_MAGI=1;;
 '*Something blocks the magic of your scroll.'*) UNSET_MAGI=1;;
 *'Something blocks your spellcasting.'*)        UNSET_MAGI=1;;
 *'This ground is unholy!'*)                  UNSET_PRAY=1;;
 *'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You grow no more agile.'*)                 unset CAST_DEX;;
 *'You lack the skill '*)                     RV=2;;
 *'You lack the proper attunement to cast '*) RV=2;;
 *'That spell path is denied to you.'*)       RV=2;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) RV=1;;
esac

test "$UNSET_MAGI" = 1 && unset CAST_DEX CAST_CHA CAST_PROBE
test "$UNSET_PRAY" = 1 && unset CAST_PACY CAST_REST

return ${RV:-4}
}

_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_draw 5 "casting dexterity.."


_is 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5  # TODO: check if avail

_is 1 1 fire center   # better 0, 1 (north) ..clockwise.. 8 (northwest)
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

 case $REPLY in '') break;;
  *) _handle_spell_errors
        case $? in 1) c=$((c+1));;
        2) unset CAST_DEX;;
        esac;;
 esac
 test "$c" = 9 && break  # 9 is just chosen as threshold for spam in msg pane

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}
CAST_DEX=_cast_dexterity
$CAST_DEX

_cure(){
test "$*" || return 3
_is 1 1 invoke cure $*
}

_handle_trap_trigger_event(){
 read -t 1
      _log "_handle_trap_trigger_event:$REPLY"
      _debug "REPLY='$REPLY'"
      case $REPLY in
      *'In fact, you set it off!'*)
        read -t 1
        _log "_handle_trap_trigger_event:$REPLY"
        _debug "REPLY='$REPLY'"
      _handle_trap_detonation_event || return 112;;
      esac
return 0
}

_handle_trap_detonation_event(){

local SECONDLINE=''

#read -t 1
#        _log "_handle_trap_detonation_event:$REPLY"
#        _debug "REPLY='$REPLY'"

    case $REPLY in

     *feel*very*ill*) _cure poison;;
     *feel*ill*)      _cure disease;;
     *feel*confused*) _cure confusion;;

     *"RUN!  The timer's ticking!"*) # rune_bomb.arc
         read -t 1 SECONDLINE  #
         if [ "$FORCE" ]; then
          break  # at low level better exit with beep
         else _draw 3 "Quitting - triggered bomb."
          _draw 3 "Use -f otion to go on."
          return 113 # save chests from being destroyed
         fi;;

        #You detonate a Rune of Mass Confusion!
     *of*Confusion*|*'of Paralysis'*) # these multiplify
         read -t 1 SECONDLINE  #
         if [ "$FORCE" ]; then
          break  # at low level better exit with beep
         else _draw 3 "Quitting - multiplifying trap."
          _draw 3 "Use -f otion to go on."
          return 112
         fi;;

        #You detonate a Rune of Large Icestorm!
        #You detonate a Rune of Icestorm
     *of*Icestorm*)  # wrapps chests in icecube container
         read -t 1 SECONDLINE  #
         _draw 3 "Quitting - icecube."
         return 112;;

        #You detonate a Rune of Fireball!
     *of*Fireball*|*of*Burning*Hands*|*of*Dragon*Breath*|*Firebreath*)
         read -t 1 SECONDLINE  #
         _draw 3 "Quitting - Fireball."
         return 112;;  # enable to pick up chests before they get burned

        #You set off a fireball!
     *of*fireball*)  ## rune_fireball.arc
         read -t 1 SECONDLINE  #
         _draw 3 "Quitting - fireball."
         return 112;;

     *of*Ball*Lightning*) ## rune_blightning.arc
         read -t 1 SECONDLINE
         _draw 3 "Quitting - Ball Lightning."
         return 112;;

     *'You detonate '*)
         read -t 1 SECONDLINE  #
         if [ "$FORCE" ]; then
          break  # at low level better exit with beep
         else _draw 3 "Quitting - triggered trap."
          _draw 3 "Use -f otion to go on."
          return 112
         fi;;

     *'A portal opens up, and screaming hordes pour'*)
         read -t 1 SECONDLINE  # through
         if [ "$FORCE" ]; then
          break # always better to exit with beep
         else _draw "Quitting - surrounded by monsters."
          _draw 3 "Use -f otion to go on."
          return 112
         fi;;

     *'You are pricked '*|*'You are stabbed '*|*'You set off '*)
         read -t 1 SECONDLINE  #
         break ;; # poisoned / diseased needle, spikes, blades
                  # TODO: You suddenly feel ill.

     *'You feel depleted of psychic energy!'*)
         read -t 1 SECONDLINE  #
         break ;; # ^harmless^

     *'transfers power to you'*|*'You feel powerful'*)  ## rune_transfer.arc, rune_sp_restore.arc
         break;;

    esac

return 0
}

_disarm_traps(){
# ** disarm by use_skill disarm traps ** #
[ "$SKILL_DISARM" = no ] && return 1

local SECONDLINE

_draw 6 "disarming traps ..."

while :;
do

 _is 1 1 use_skill "disarm traps";  # 1 1 is able to disarm more than one trap

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_disarm_traps:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*)  return 112;;
                #SKILL_DISARM=no; break 2;;

   *'You fail to disarm '*)
    _handle_trap_trigger_event || return 112

      break;;  # break 1 tries again to disarm

   *'You successfully disarm '*)
        # break   ## break 1 disarms further if more traps already spotted
     :  # might be able to disarm more than one trap,
        # so one attempt could give several successes
    ;;

    *feel*very*ill*) _cure poison;;
    *feel*ill*)       _cure disease;;

  '') break 2;;
  *) _debug "_disarm_traps:Ignoring REPLY";;
  esac
 done

sleep 1

done

sleep 1
}

_find_traps(){
# ** search to find traps ** #
[ "$SKILL_FIND" = no ] && return 3

local NUM=${1:-$DEF_SEARCH}

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

while :;
do

_verbose "$NUM searches to go .."
_is 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!

 while :; do read -t 1
 _log "_find_traps:$REPLY"
 _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) return 112;;
                #SKILL_FIND=no;  break 2;;

    *'You spot a '*) _debug "Found Trap";
    _disarm_traps;
    case $? in 112) return 112;; esac
    break;;

   *'You search the area.'*) :;;

    *feel*very*ill*) _cure poison;;
    *feel*ill*)      _cure disease;;

  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}


__disarm_traps(){
# ** disarm use_skill disarm traps ** #

local CNT NUM SECONDLINE
unset     NUM SECONDLINE

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

_debug NUM=$NUM
NUM=${NUM:-$DEF_DISARM}
_debug NUM=$NUM

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

CNT=0

while :;
do

_is 1 1 use_skill "disarm traps"
#You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
   _log "__disarm_traps:$REPLY"
   _debug "REPLY='$REPLY'"
  _debug NUM=$NUM

  case $REPLY in

    *feel*very*ill*) _cure poison;;
    *feel*ill*)      _cure disease;;

   *'Unable to find skill '*)   break 2;;
#  *'You fail to disarm '*) continue;;

   *'You successfully disarm '*)
      NUM=$((NUM-1));
      test "$NUM" -gt 0 || break 2;
      break;;

   *'In fact, you set it off!'*)
      NUM=$((NUM-1));
      test "$NUM" -gt 0 || break 2;
      break ;;

   # ignore for now
   *'You are pricked '*) break;;   # needle.arc

   *"RUN!  The timer's ticking!"*) # rune_bomb.arc
      read -t 1 SECONDLINE  #
        if [ "$FORCE" ]; then
         break  # at low level better exit with beep
        else _draw 3 "Quitting - triggered bomb."
         _draw 3 "Use -f otion to go on."
         return 113 # save chests from being destroyed
        fi;;

   #You detonate a Rune of Mass Confusion!
   *of*Confusion*|*'of Paralysis'*) ## rune_confusion.arc, rune_paralysis.arc
      read -t 1 SECONDLINE  #
        if [ "$FORCE" ]; then
         break  # at low level better exit with beep
        else _draw 3 "Quitting - multiplifying trap."
         _draw 3 "Use -f otion to go on."
         return 112  # these multiplify
        fi;;

   #You detonate a Rune of Large Icestorm!
   #You detonate a Rune of Icestorm
   *of*Icestorm*)  ## rune_frost.arc
      read -t 1 SECONDLINE  #
      _draw 3 "Quitting - icecube."
      return 112;;  # wrapps chests in icecube container, no use for --force option

   #You detonate a Rune of Fireball!  ## rune_fire.arc
   *of*Fireball*|*of*Burning*Hands*|*of*Dragon*Breath*|*Firebreath*)
      read -t 1 SECONDLINE  #
      _draw 3 "Quitting - Fireball."
      return 112;;  # enable to pick up chests before they get burned

   #You set off a fireball!
   *of*fireball*)  ## rune_fireball.arc
      read -t 1 SECONDLINE  #
       _draw 3 "Quitting - fireball."
      return 112;;

   *of*Ball*Lightning*) ## rune_blightning.arc
     read -t 1 SECONDLINE
      _draw 3 "Quitting - Ball Lightning."
     return 112;;

   *'You detonate '*)  ## rune_blast.arc, rune_death.arc, rune_pcloud.arc, rune_shock.arc,
                       ## rune_frost.arc, rune_fireball.arc, rune_fire.arc
      read -t 1 SECONDLINE  #
        if [ "$FORCE" ]; then
         break  # at low level better exit with beep
        else _draw 3 "Quitting - detonated trap."
         _draw 3 "Use -f otion to go on."
         return 112
        fi;;

   *'A portal opens up, and screaming hordes pour'*)  ## rune_summon.arc
      read -t 1 SECONDLINE  # through
        if [ "$FORCE" ]; then
         break # always better to exit with beep
        else _draw "Quitting - surrounded by monsters."
          _draw 3 "Use -f otion to go on."
         return 112
        fi;;

   *'You are stabbed '*|*'You set off '*|*'You feel depleted of psychic energy!'*)
   # spikes.arc, spiked_pit.arc
   # trap.arc, blades.arc, falling_rocks.arc, rune_heal.arc, rune_lightning.arc, rune_restore.arc
   # drain_magic.arc
     read -t 1 SECONDLINE  #
       if [ "$FORCE" ]; then
         break  ## at low level better exit with beep
       else     # _draw 3 "Quitting - triggered bomb."
         break  # return 112
       fi;;

   *'transfers power to you'*|*'You feel powerful'*)  ## rune_transfer.arc, rune_sp_restore.arc
   break;;

  '') CNT=$((CNT+1)); break;;
  esac
 done

_debug NUM=$NUM
test "$CNT" -gt 9 && break
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}

_open_chest(){
# ** open chest, apply, get ** #

CHESTS_ALL=0
TIMEB=`/bin/date +%s`

_draw 6 "apply and get .."

while :;
do

# TODO : food level, hit points

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO
_is 1 1 apply  # handle trap release, being killed
               # spit out tooth, then eats it ...

_is 0 0 get all
CHESTS=0

_is 0 0 drop chest # Nothing to drop.

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_open_chest:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Nothing to drop'*)  break 2;;
   *'Nothing to take'*)  :;;
   *'You open chest'*)   :;;    #
   *'You close chest'*)  :;;    # (open) (active).
   *'was empty'*)        :;;

   *' your '*)       :;;  # The effects of your dexterity are about to expire. are draining out.
   *'Your '*)        :;;  # Your monster beats monster
   *'You killed '*)  :;;
   *' tasted '*)     :;;  # food tasted good
   *'the game'*)     :;;  # another player entered,leaves,left
   *'tells you'*)    :;;
   *'chats'*)        :;;

#  *'You find '*) _handle_trap_detonation_event || return 112;;
   *'You find '*)    :;;
   *'You pick up '*chest*) CHESTS=$((CHESTS+1));;
   *'You pick up '*) :;;
   *'You were unable to take '*)  :;; #You were unable to take one of the items.

  # msgs from cast dexterity
  *'You lack the skill '*) :;;
  *'You can no longer use the skill:'*)     :;;
  *'You ready talisman'*)                   :;;  #You ready talisman of sorcery *.
  *'You can now use the skill:'*)           :;;
  *'You ready the spell'*)                  :;;
  *'You feel more agile'*)                  :;;
  *'You grow no more agile'*)               :;;
  *'You recast the spell while in effect'*) :;;
  *'The effects'*'are draining out'*)       :;;
  *'The effects'*'are about to expire'*)    :;;
  *'You feel clumsy'*)                      :;;

  '') break;;
   *) _handle_trap_detonation_event || return 112
      break;;
  esac
 done


_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
sleep 0.5

test $CHESTS_ALL -gt ${CHESTS:-0} || CHESTS_ALL=${CHESTS:-0}

_is 1 1 $DIRB
sleep 0.1

_is 1 1 $DIRF
sleep 0.1

done
}


_cleanup_bomb(){
_is 0 0 get all   # pickup chests if bomb
_is 0 0 drop bomb # :)
_is 0 0 get flametome
_is 0 0 get wand
_is 0 0 get scroll
}

_cleanup_trap(){
_is 0 0 get all   # pick up chests if icestorm, fireball, etc.
}

_flee(){
for n in `seq 1 1 ${*:-9}`
do
_is 1 1 $DIRB
done
}

_identify(){
set - "sense curse" "sense magic" alchemy bowyer jeweler literacy smithery thaumaturgy woodsman
for skill in "$@"; do
_is 0 0 use_skill "$skill"
done
}


_find_traps $NUMBER
case $? in 0)
 _open_chest
 case $? in 0) _identify;;
 112) _cleanup_trap;;
 113) _cleanup_bomb; _flee 9;;
 esac;;
112) _cleanup_trap;;
113) _cleanup_bomb; _flee 9;;
esac


__main__(){
_find_traps $NUMBER
case $? in 112) :;;
*)    _open_chest;;
esac

_is 0 0 get all   #pickup chests if bomb, fire storm, dragon breath, etc
_is 0 0 drop bomb
_is 0 0 get flametome
_is 0 0 get wand
_is 0 0 get scroll
}

# *** Here ends program *** #
_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO


__count_time(){
 TIMEZ=`/bin/date +%s`

 _compute_minutes_seconds(){
 unset TIMEXM TIMEXS
 test "$1" -a "$2" || return 3

 local lTIMEX=$(( $1 - $2 ))

 case $lTIMEX in -*) lTIMEX=$(( $2 - $1 ));; esac
 case $lTIMEX in -*) return 4;; esac

 TIMEXM=$((lTIMEX/60))
 TIMEXS=$(( lTIMEX - (TIMEXM*60) ))
 case $TIMEXS in [0-9]) TIMEXS="0$TIMEXS";; esac
 }

if test "$TIMEZ" -a "$TIMEB"; then
_compute_minutes_seconds $TIMEZ $TIMEB && \
 _draw 5 "Whole loop took $TIMEXM:$TIMEXS minutes."
fi

if test "$TIMEZ" -a "$TIMEA"; then
_compute_minutes_seconds $TIMEZ $TIMEA && \
 _draw 4 "Whole script took $TIMEXM:$TIMEXS minutes."
fi

}

_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}

_count_time(){

test "$*" || return 3
_test_integer "$*" || return 4

TIMEE=`/bin/date +%s` || return 5

TIMEX=$((TIMEE - $*)) || return 6
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

_count_time $TIMEB && _draw 7 "Looped for $TIMEM:$TIMES minutes"
_count_time $TIMEA && _draw 7 "Script ran $TIMEM:$TIMES minutes"

test "$CHESTS_ALL" && _draw 5 "You opened $((CHESTS_ALL+1)) chest(s)."

_draw 2 "$0 is finished."
_beep
