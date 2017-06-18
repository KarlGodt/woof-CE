#!/bin/ash

# *** diff marker 1
# ***
# ***

exec 2>/tmp/cf_script.err

#DEBUG=1   # unset to disable, set to anything to enable
#LOGGING=1 # unset to disable, set to anything to enable

DRAW_INFO=drawinfo  # drawinfo (old servers or clients compiled by confused compiler)
                    # OR drawextinfo (new servers)
                    # used for catching msgs watch/unwatch $DRAW_INFO

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


# ***
# ***
# *** diff marker 2
# *** diff marker 3
# ***
# ***


# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to open chests."
_draw 5 "Syntax:"
_draw 5 "script $0 <<number>>"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times search, disarm, apply and get."
_draw 4 "Options:"
_draw 4 "-f force running even if bad traps triggered."
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
     *help)  _usage;;
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


_is 0 0 pickup 0
sleep 1

_is 0 0 drop chest
sleep 1

_is 1 1 $DIRB
sleep 1

_is 1 1 $DIRF
sleep 1

# TODO : check if on chest


# ***
# ***
# *** diff marker 4
# *** diff marker 5
# ***
# ***


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

 case $REPLY in
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
CAST_DEX=_cast_dexterity
$CAST_DEX

_handle_trap_event(){

  case $REPLY in
   *'You search'*|*'You spot'*) :;;

   *'Unable to find skill '*)  return 112;;
                #SKILL_DISARM=no; break 2;;

   *'You fail to disarm '*)
     : break # break 1 tries again to disarm
      ;;
   *'You successfully disarm '*)
     : break # break 1 disarms further if more traps already spotted
     ;;

   *'In fact, you set it off!'*)
     : break
     ;;

  *'transfers power to you'*|*'You feel powerful'*)  ## rune_transfer.arc, rune_sp_restore.arc
     : break
    ;;

   *off*fireball*)
      if [ "$FORCE" ]; then
      : break  # at low level better exit with beep
      else return 112
      fi
    ;;

   *'You are pricked '*|*'You are stabbed '*|*'You set off '*)
     : break
     ;; # poisoned / diseased needle, spikes, blades
   *'You feel depleted of psychic energy!'*)
     : break
     ;; # ^harmless^

   #You detonate a Rune of Mass Confusion!
   *of*Confusion*|*'of Paralysis'*) # these multiplify
      if [ "$FORCE" ]; then
      : break  # at low level better exit with beep
      else return 112
      fi
    ;;

   *of*Icestorm*)  # here needs exit, since traps will
    return 112     # not be disarmed anymore and infinite
    ;;             # attempts to disarm will loop onto icecube

   #You detonate a Rune of Fireball!
   *of*Fireball*|*of*Burning*Hands*|*of*Dragon*Breath*|*Firebreath*)
      if [ "$FORCE" ]; then
      : break # always better to exit with beep
      else return 112
      fi
    ;;

   *of*Ball*Lightning*)  ## rune_blightning.arc
      if [ "$FORCE" ]; then
      : break # always better to exit with beep
      else return 112
      fi
    ;;

   *'You detonate '*)
      : break
      ;;

   *"RUN!  The timer's ticking!"*)
      if [ "$FORCE" ]; then
      : break  # at low level better exit with beep
      else return 112
      fi;;

   *'A portal opens up, and screaming hordes pour'*)
      if [ "$FORCE" ]; then
      : break # always better to exit with beep
      else return 112
      fi;;
  '')
      break ${BREAK_CNT:-1};;

  esac
return 0
}


# ***
# ***
# *** diff marker 6
# *** diff marker 7
# ***
# ***


_disarm_traps(){
# ** disarm by use_skill disarm traps ** #
[ "$SKILL_DISARM" = no ] && return 3

local NUM=${*:-1}
local CNT=0 SCNT=0 XCNT=0

BREAK_CNT=1  #global for use in _handle_trap_event() empty line break

_draw 6 "disarming '$NUM' traps ..."

while :;
do

CNT=$((CNT+1))

case $CNT in *[0-9]0) _is 1 1 search
;;
esac

_verbose "Attempt '$CNT' ..."
_is 1 1 use_skill "disarm traps"
# You successfully disarm the Rune of Paralysis!
#You fail to disarm the Rune of Fireball.
#In fact, you set it off!
#You set off a fireball!
#You detonate

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_disarm_traps:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*)  return 112;;
  *'times You search'*) XCNT=`echo $REPLY | awk '{print $4}'`; SCNT=$((SCNT+XCNT));;
  *'You search'*)  SCNT=$((SCNT+1));;  # read  next line
  *'You spot'*)                :;;     # read next line
  *'You fail to disarm '*)     :;;     # read next line
  *'In fact, you set it off!'*) NUM=$((NUM-1));; # read next line to _handle_trap_event
  *'You successfully disarm '*) NUM=$((NUM-1));; # read next line for more disarm messages if more spotted traps to come
  '') break;;
  *) _handle_trap_event || return 112;;
  esac
 done

test "$NUM" -gt 0 || break
_debug "SCNT='$SCNT' XCNT='$XCNT'"
test "$SCNT" -gt $DEF_SEARCH && return 11

sleep 0.1

done

sleep 0.1
}


# ***
# ***
# *** diff marker 8
# *** diff marker 9
# ***
# ***


_find_traps(){
# ** search to find traps ** #
[ "$SKILL_FIND" = no ] && return 3

local NUM=${1:-$DEF_SEARCH}
NUM=${NUM:-1}

local TRAPS=0 CNT=0

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

while :;
do

TRAPS=0
CNT=$((CNT+1))
_verbose "Search '$CNT' ..."
_is 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
 _log "_find_traps:$REPLY"
 _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Unable to find skill '*) return 112;;
                #SKILL_FIND=no;  break 2;;

    *'You spot a '*) TRAPS=$((TRAPS+1));;

   *'You search the area'*) :;;
  '') break;;
  esac

  sleep 0.1
  unset REPLY
 done

if test "$TRAPS" != 0; then
 _verbose "Found '$TRAPS' traps"
 _disarm_traps $TRAPS
 case $? in 112) return 112;; esac
fi

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
sleep 0.1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 0.1
}


# ***
# ***
# *** diff marker 10
# *** diff marker 11
# ***
# ***


_open_chest(){
# ** open chest, apply, get ** #

_draw 6 "apply and get .."

BREAK_CNT=1

while :;
do

# TODO : food level, hit points


_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_is 1 1 apply  # handle trap release, being killed
#sleep 1


_is 0 0 get all
#sleep 1

_is 0 0 drop chest # Nothing to drop.

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_open_chest:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
   *'Nothing to drop'*) break 2;;
   *'Nothing to take'*) break;; # chest could be a permanent container

   *'You search '*)  :;;
   *'The effects of your dexterity are draining out'*)    :;;
   *'The effects of your dexterity are about to expire'*) :;;

   *'You find '*)    :;;
   #*'You find '*) _handle_trap_event || return 112  ;;
   *'You pick up '*) :;;
   *'The chest was empty.'*)      :;;
   *'You were unable to take '*)  :;; #You were unable to take one of the items.

   *'Your '*)        :;;  # Your monster beats monster
   *'You killed '*)  :;;
   *' tasted '*)     :;;  # food tasted good
   '') break;;
  *) _handle_trap_event || return 112 ; break;;
  esac
 done


_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
sleep 1


_is 1 1 $DIRB
sleep 0.1

_is 1 1 $DIRF
sleep 0.1

done
}


_find_traps $NUMBER
case $? in 112) :;;
*)    _open_chest;;
esac

_is 0 0 get all

# *** Here ends program *** #
_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

_draw 2 "$0 is finished."
_beep


# ***
# ***
# *** diff marker 12
