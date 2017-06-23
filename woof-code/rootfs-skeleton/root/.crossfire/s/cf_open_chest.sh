#!/bin/ash

exec 2>/tmp/cf_script.err

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
COL_VERB=$COL_ORANGE
COL_DBG=$COL_DORANGE

_draw(){
test "$*" || return
local lCOLOUR=${1:-0}
shift
while read -r line
do
test "$line" || continue
echo draw $lCOLOUR "$line"
sleep 0.1
done <<EoI
`echo "$@"`
EoI
}

_verbose(){
[ "$VERBOSE" ] || return 0
local lCOL_VERB=$COL_VERB
case $1 in [0-9]|[1[0-4]) lCOL_VERB=$1; shift;; esac
_draw ${lCOL_VERB:-12} "$*"
}

_debug(){
[ "$DEBUG" ] || return 0
local lCOL_DBG=$COL_DBG
case $1 in [0-9]|[1[0-4]) lCOL_DBG=$1; shift;; esac
_draw ${lCOL_DBG:-11} "$*"
}

_log(){
[ "$LOGGING" ] || return 0
echo "$*" >>"$LOG_REPLY_FILE"
}

# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to open chests."
_draw 5 "Syntax:"
_draw 5 "script $0 [number]"
_draw 5 "For example: 'script $0 5'"
_draw 5 "will issue 5 times search, disarm, apply and get."
_draw 4 "Options:"
_draw 3 "-f force going if traps triggered"
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
           _draw 3 "Only :digit: numbers as optional option allowed."; exit 1; }
           readonly NUMBER
           _debug 2 "NUMBER=$NUMBER"
           ;;
-h|*help|*usage)  _usage;;
-f|*force)     FORCE=$((FORCE+1));;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac

sleep 1
shift
done

# TODO : check if available space to walk in DIRB

# ** set pickup  0 and drop chests

#Can't find any matching item.
#echo issue 0 0 lock bomb  ##+++2017-06-23 TODO:toggles

_verbose "Setting pickup 0 .."
echo issue 0 0 pickup 0
sleep 1
_verbose "Dropping chest .."
echo issue 0 0 drop chest
sleep 1
_verbose "Leaving place .. $DIRB"
echo issue 1 1 $DIRB
sleep 1
_verbose "Returning to place .. $DIRF"
echo issue 1 1 $DIRF
sleep 1

# TODO : check if on chest

_handle_spell_errors(){
local RV=0
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
 *'You feel more agile.'*)             :;;
 *'The effects of your dexterity are draining out.'*)    :;;
 *'The effects of your dexterity are about to expire.'*) :;;
 *'You feel clumsy!'*) :;;
 *) RV=1;;
esac
return ${RV:-3}
}

_cast_dexterity(){
# ** cast DEXTERITY ** #

local REPLY c

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_draw 5 "casting dexterity.."

_verbose "cast dexterity .."
echo issue 1 1 cast dexterity # don't mind if mana too low, not capable or bungles for now
sleep 0.5
_verbose "fire center .."
echo issue 1 1 fire center   # better 0, 1 (north) ..clockwise.. 8 (northwest)
sleep 0.5
_verbose "fire_stop .."
echo issue 1 1 fire_stop
sleep 0.5

while :;
do
unset REPLY
sleep 0.1
 read -t 1
 _log "_cast_dexterity:$REPLY"
 _debug "REPLY='$REPLY'" #debug

 case $REPLY in
 '') break;;
 *)  _handle_spell_errors || _handle_spell_msgs || {
 c=$((c+1)); test "$c" = 9 && break; } ;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}
CAST_DEX=_cast_dexterity
$CAST_DEX


_find_traps(){
# ** search or use_skill find traps ** #

local NUM=${NUMBER:-$DEF_SEARCH}
local TRAPS=0 TRAPS_BACKUP=0 TRAPS_NUM=0

_draw 6 "find traps '$NUM' times.."

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

#local c=0

while :;
do

#unset TRAPS
TRAPS=0

_verbose "$NUM:search .."
echo issue 1 1 search
#You spot a diseased needle!
#You spot a Rune of Paralysis!
#You spot a Rune of Fireball!
#You spot a Rune of Confusion!
#You spot a diseased needle!
#You spot a Rune of Blasting!
#You spot a Rune of Magic Draining!

 while :; do read -t 1
 _log "_find_traps:$REPLY"
 _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Unable to find skill '*)   break 2;;
   *'You spot a '*) TRAPS=$((TRAPS+1))
    ;;
   *'You search the area.'*) :;;
  '') break;;
  esac
  sleep 0.1
  unset REPLY
 done

test "$TRAPS" -ge "$TRAPS_BACKUP" && TRAPS_BACKUP=$TRAPS

NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1


TRAPS=${TRAPS:-$TRAPS_BACKUP}
test "$TRAPS_BACKUP" -ge "$TRAPS" && TRAPS=$TRAPS_BACKUP
TRAPS_NUM=${TRAPS:-0}

echo $TRAPS_NUM >/tmp/cf_pipe.$$
}

_cure_disease(){
# echo issue 1 1 apply scroll of cure disease
echo issue 1 1 invoke "cure disease"
}

_cure_poison(){
# echo issue 1 1 apply scroll of cure poison
echo issue 1 1 invoke "cure poison"
}

_cure(){
test "$*" || return 3
case $2 in
scroll) echo issue 1 1 apply scroll of cure $1;;
*)      echo issue 1 1 invoke "cure $1";;
esac
}

_skip_noise(){
local RV=0

case $REPLY in

  # msgs from cast dexterity
  *'You lack the skill '*) :;;
  *'You can no longer use the skill:'*)     :;;
  *'You ready'*)                            :;;  #You ready talisman of sorcery *. the spell holy symbol of Probity *.
  *'You can now use the skill:'*)           :;;  # praying.
  *'You grow no more agile'*)               :;;
  *'You recast the spell while in effect'*) :;;
  *'The effects'*'are draining out'*)       :;;
  *'The effects'*'are about to expire'*)    :;;
  *'You feel'*)                             :;; # clumsy. stronger. more agile. healthy. smarter.

  # msgs from cure disease
  *'You stop using the'*) :;; # talisman of Frost *.
  *'You cure'*)           :;; # a disease!
  *'You no longer feel'*) :;; # diseased.

  #msgs from cure poison
  *'Your body feels'*) :;; # cleansed

  *' entered '*|*' leaves '*|*' left '*) :;; # the game
  *' chats:'*|*' tells you:'*)           :;;

   *'You feel full'*) :;;  # , but what a waste of food!
   *' tasted '*)      :;;  # food tasted good
   *' your '*)        :;;  #
   *'Your '*)         :;;  # Your monster beats monster
   *'You killed '*)   :;;

 #*) _debug "_skip_noise:Ignoring REPLY";;
  *)  RV=1;;

esac

return ${RV:-4}
}

_handle_trap_event(){

local SECONDLINE=''

  case $REPLY in
   *'You search'*) :;;
   *'You spot'*)   :;;

   *You*feel*very*ill*) _cure poison;;
   *You*feel*ill*)      _cure disease;;
   *You*feel*confused*) _cure confusion;;
   *You*feel*sick*)     :;; # _cure poison;;

   *'Unable to find skill '*)   break 2;;
   *'You fail to disarm '*) :;;

   *'You successfully disarm '*)
      NUM=$((NUM-1));
      ;;

   *'In fact, you set it off!'*)
      NUM=$((NUM-1));
      ;;

   #You detonate a Rune of Mass Confusion!
   *of*Confusion*|*'of Paralysis'*) # these multiplify
      read -t 1 SECONDLINE
      if [ "$FORCE" ]; then
      break  # at low level better exit with beep
      else _draw 3 "Quitting - multiplifying trap."
       _draw 2 "Use -f option to ignore."
       return 112
      fi;;

   #You detonate a Rune of Fireball!
   *of*Fireball*|*of*Burning*Hands*|*of*Dragon*Breath*|*Firebreath*)
      read -t 1 SECONDLINE  #
      _draw 3 "Quitting - Fireball."
      return 112;;  # enable to pick up chests before they get burned

   #You set off a fireball!
   *of*fireball*)  ## rune_fireball.arc
      read -t 1 SECONDLINE  #
      _draw 3 "Quitting - fireball."
      return 112;; # enable to pick up chests before they get burned

   *of*Ball*Lightning*) ## rune_blightning.arc
      read -t 1 SECONDLINE
      _draw 3 "Quitting - Ball Lightning."
      return 112;;

   #You detonate a Rune of Large Icestorm!
   #You detonate a Rune of Icestorm
   *of*Icestorm*)  # wrapps chests in icecube container
      read -t 1 SECONDLINE
      _draw 3 "Quitting - icecube."
      return 112;;

   *'You detonate '*|*'You are pricked '*|*'You are stabbed '*|*'You set off '*|*'You feel depleted of psychic energy!'*)
      read -t 1 SECONDLINE
      break;;

   *"RUN!  The timer's ticking!"*)
      read -t 1 SECONDLINE
      if [ "$FORCE" ]; then
      break # usually better to exit with beep
      else _draw 3 "Quitting - Bomb!"
       _draw 2 "Use -f option to ignore."
       return 113
      fi;;

   *'A portal opens up, and screaming hordes pour'*)
      read -t 1 SECONDLINE
      beep -f 800 -l 100
      beep -f 900 -l 100
      beep -f 800 -l 100
      if [ "$FORCE" ]; then
      break # always better to exit with beep
      else _draw "Quitting - surrounded by monsters."
       _draw 2 "Use -f option to ignore."
       return 112
      fi;;

   *'transfers power to you'*|*'You feel powerful'*)  ## rune_transfer.arc, rune_sp_restore.arc
      break;;

  '') CNT=$((CNT+1)); break;;

  #*) _skip_noise;;
  esac

}

_disarm_traps(){
# ** disarm use_skill disarm traps ** #

local NUM
unset NUM

    touch /tmp/cf_pipe.$$
read NUM </tmp/cf_pipe.$$
    rm -f /tmp/cf_pipe.$$

NUM=${NUM:-$DEF_DISARM}

_draw 6 "disarm traps '$NUM' times.."

test "$NUM" -gt 0 || return 0

_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

local CNT=1

while :;
do

_verbose "$NUM:$CNT:use_skill disarm traps"
echo issue 1 1 use_skill "disarm traps"
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
   _debug $COL_GREEN "REPLY='$REPLY'" #debug

   _skip_noise && continue
   _handle_trap_event || return 112

 done

test "$CNT" -gt 9 && break
test "$NUM" -gt 0 || break

_verbose "search .."
echo issue 1 1 search # add additional search
sleep 1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

sleep 1
}

_open_chest(){
# ** open chest apply and get ** #

_draw 6 "apply and get .."

CHESTS_ALL=0
NUM=${NUMBER:-90} # 90 * 50kg -> 4500@Str 30, should be enough
CNT=0  # _handle_trap_event() uses CNT and NUM

while :;
do

# TODO : food level, hit points


_debug "watch $DRAW_INFO"
echo watch $DRAW_INFO

_verbose "apply"
echo issue 9 1 apply  # handle trap release, being killed
sleep 0.5

_verbose "get all"
echo issue 0 0 get all
CHESTS=0
sleep 0.5


_verbose "drop chest"
echo issue 0 0 drop chest # Nothing to drop.

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  _log "_open_chest:$REPLY"
  _debug $COL_GREEN "REPLY='$REPLY'" #debug

  case $REPLY in
   *'Nothing to drop'*) break 2;;
   *'Nothing to take'*)  :;;    # chest as steady container
   *'You open chest'*)   :;;    #
   *'You close chest'*)  :;;    # (open) (active).
   *'was empty'*)        :;;

   *'You find '*) :;;

   *'You pick up '*chest*) CHESTS=$((CHESTS+1));;
   *'You pick up '*)              :;;
   *'You were unable to take '*)  :;; # one of the items.
   *'too heavy'*)                 :;;

  '') break;;

  # undetected traps could be triggered ..
  *) _handle_trap_event || return 112
     _skip_noise || break;;
  esac

 done


_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
sleep 1

test $CHESTS_ALL -gt ${CHESTS:-0} || CHESTS_ALL=${CHESTS:-0}

_verbose "$DIRB"
echo issue 1 1 $DIRB
sleep 0.1
_verbose "$DIRF"
echo issue 1 1 $DIRF
sleep 0.1

done

_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO
}

_cleanup_bomb(){
echo issue 0 0 get all   # pickup chests if bomb
echo issue 0 0 drop bomb # :)
echo issue 0 0 get flametome
echo issue 0 0 get wand
echo issue 0 0 get scroll
}

_cleanup_trap(){
echo issue 0 0 get all   # pick up chests if icestorm, fireball, etc.
}

_flee(){
for n in `seq 1 1 ${*:-9}`
do
echo issue 1 1 $DIRB
done
}

_identify(){
set - "sense curse" "sense magic" alchemy bowyer jeweler literacy smithery thaumaturgy woodsman
for skill in "$@"; do
echo issue 0 0 use_skill "$skill"
done
}

_find_traps
_disarm_traps
case $? in 0)
 TIMEB=`/bin/date +%s`
 _open_chest
 case $? in 0) _identify;;
 112) _cleanup_trap;;
 113) _cleanup_bomb; _flee 9;;
 esac;;
112) _cleanup_trap;;
113) _cleanup_bomb; _flee 9;;
esac

_count_time(){

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


_compute_minutes_seconds $TIMEZ $TIMEB && \
 _draw 5 "Whole loop took $TIMEXM:$TIMEXS minutes."

_compute_minutes_seconds $TIMEZ $TIMEA && \
 _draw 4 "Whole script took $TIMEXM:$TIMEXS minutes."

}

_count_time

test "$CHESTS_ALL" && _draw 5 "You opened $((CHESTS_ALL+1)) chest(s)."


# *** Here ends program *** #
_debug "unwatch $DRAW_INFO"
echo unwatch $DRAW_INFO

_draw 2 "$0 is finished."
beep -f 700 -l 1000
