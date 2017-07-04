#!/bin/ash

exec 2>/tmp/cf_script.err

# Now count the whole script time
TIMEA=`date +%s`

DRAW_INFO=drawinfo # drawextinfo

# FOREVER mode
INF_THRESH=30 # threshold to cast charisma and probe
INF_TOGGLE=4  # threshold to cast restoration (INF_THRESH * INF_TOGGLE)
BAD_THRESH=3  # threshold to attack in DIR

MAX_ORATE=9

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

# ** to brace or not to brace ** #
#BRACE=1  # brace reduces the AC considerably ( -10 -> -4 too low in a swarm of ogres )
#            # when orate failed BAD_THRESH times,
#            # attacking could move player if not braced

# ** if attacking to have new monster to orate to ** #
MAX_ATTACK=1   # how many times to attack ( small monster few, bigger monster several )

# ** if CAST_REST fails, fallback apply FOOD_EAT ** #
FOOD_EAT=waybread

# ** ping if bad connection ** #
PING_DO=1
URL=crossfire.metalforge.net

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

_ping(){
test "$PING_DO" || return 0
while :;
do
ping -c1 -w10 -W10 "$URL" && break
sleep 1
done >/dev/null
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

COL_VERB=$COL_TAN  # verbose
COL_DBG=$COL_GOLD  # debug

_draw(){
    local lCOLOUR="$1"
    lCOLOUR=${lCOLOUR:-1} #set default
    shift
    local MSG="$*"
    echo draw $lCOLOUR "$MSG"
}

_log(){
    test "$LOGGING" || return 0
    local lFILE
    test "$2" && {
    lFILE="$1"; shift; } || lFILE="$LOG_FILE"
   echo "$*" >>"${lFILE:-/tmp/cf_script.log}"
}

_debug(){
test "$DEBUG" || return 0
    _draw ${COL_DEB:-3} "DEBUG:$*"
}

_verbose(){
test "$VERBOSE" || return 0
_draw ${COL_VERB:-12} "VERBOSE:$*"
}

_is(){
    _verbose "$*"
    echo issue "$*"
    sleep 0.2
}

# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** Check for parameters *** #

# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to use_skill oratory."
_draw 5 "Syntax:"
_draw 5 "script $0 <direction> <<number>>"
_draw 5 "For example: 'script $0 5 west'"
_draw 5 "will issue 5 use_skill oratory in west."
_draw 6 "Abbr. for north:n, northeast:ne .."
_draw 5 "Options:"
_draw 6 "Use -I --infinite to run forever."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
}

_draw 3 "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
           _draw 3 "Only :digit: numbers as first option allowed."; exit 1; }
           readonly NUMBER
       #_draw 2 "NUMBER=$NUMBER"
           ;;
 n|north)       DIR=north;     DIRN=1;; #readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2;; #readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3;; #readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4;; #readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5;; #readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6;; #readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7;; #readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8;; #readonly DIR DIRN;;

-h|*help)       _usage;;
-I|*infinite)   FOREVER=$((FOREVER+1));;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

--*) case $PARAM_1 in
     *brace) BRACE=$((BRACE+1));;
     *debug) DEBUG=$((DEBUG+1));;
#    *force) FORCE=$((FORCE+1));;
     *help|*usage)  _usage;;
     *infinite) FOREVER=$((FOREVER+1));;
     *log*)     LOGGING=$((LOGGING+1));;
     *verbose)  VERBOSE=$((VERBOSE+1));;
     *) _draw 3 "Ignoring unhandled option '$PARAM_1'";;
     esac
;;

-*) OPTS=`printf '%s' $PARAM_1 | sed -r 's/^-*//;s/(.)/\1\n/g'`
    for oneOP in $OPTS; do
     case $oneOP in
      B) BRACE=$((BRACE+1));;
      d) DEBUG=$((DEBUG+1));;
#     f) FORCE=$((FORCE+1));;
      h) _usage;;
      I) FOREVER=$((FOREVER+1));;
      L) LOGGING=$((LOGGING+1));;
      v) VERBOSE=$((VERBOSE+1));;
      *) _draw 3 "Ignoring unhandled option '$oneOP'";;
     esac
   done
;;

'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 0.1
shift
#_draw "'$#'"  #DEBUG

done

readonly NUMBER DIR DIRN
_draw 3 "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'" # DEBUG


# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 _draw 3 "Need direction as parameter."
 exit 1
fi


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
 *'You lack the skill '*)                     RV=2;;
 *'You lack the proper attunement to cast '*) RV=2;;
 *'That spell path is denied to you.'*)       RV=2;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *'You bungle the spell'*)  RV=3;;  # because you have too much heavy equipment in use.
 *'You fumble the spell'*)  RV=3;;
 *' grants your prayer'*)      :;;  # , though you are unworthy.
 *) RV=1;;
esac

test "$UNSET_MAGI" = 1 && unset CAST_CHA CAST_PROBE
test "$UNSET_PRAY" = 1 && unset CAST_PACY CAST_REST

return ${RV:-4}
}

_cast_spell_and_fire(){  # direction number, count, spell
test "$*" || return 3

local lf=''
local lD=$1
shift
local lN=$1
shift

_draw 5 "Casting $* ..."

for lf in `seq 1 1 $lN`
do
 _verbose "Casting $* $lf .."
 _is 1 1 cast "$*"
 sleep 0.5
 _is 1 1 fire ${lD:-$DIRN}
 sleep 0.5
 _is 1 1 fire_stop
 sleep 0.5
done
}

_invoke_spell(){
test "$*" || return 3

local lf=''
local lN=$1
shift

_draw 5 "Invoking $* ..."

for lf in `seq 1 1 $lN`
do
 _verbose "Invoking $* $lf .."
 _is 1 1 invoke "$*"
 sleep 0.5
done
}


_cast_charisma(){
# ** cast CHARISMA ** #

local REPLY c

echo watch $DRAW_INFO

_is 1 1 cast charisma # don't mind if mana too low, not capable or bungles for now
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
 _log "_cast_charisma:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_CHA CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_CHA CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_CHA CAST_PROBE;;
 *'This ground is unholy!'*)                  unset CAST_REST;;
 *'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     unset CAST_CHA;;
 *'You lack the proper attunement to cast '*) unset CAST_CHA;;
 *'That spell path is denied to you.'*)       unset CAST_CHA;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO
#You are no easier to look at.
}

CAST_PROBE=_cast_probe
CAST_REST=_cast_resoration # prayer
CAST_PACY=_cast_pacify     # prayer, unused
CAST_CHA=_cast_charisma
$CAST_CHA
#_cast_charisma

__cast_pacify(){  # unused
# ** cast PACIFY ** #
# pacified monsters do not respond to oratory
return 0

local REPLY c

echo watch $DRAW_INFO

_is 1 1 cast pacify # don't mind if mana too low, not capable or bungles for now
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
 _log "_cast_pacify:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_PACY CAST_REST;;
 '*Something blocks the magic of your scroll.'*) unset CAST_PACY CAST_REST;;
 *'Something blocks your spellcasting.'*)        unset CAST_PACY CAST_REST;;
 *'This ground is unholy!'*)                     unset CAST_PACY CAST_REST;;
 #*'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     unset CAST_PACY;;
 *'You lack the proper attunement to cast '*) unset CAST_PACY;;
 *'That spell path is denied to you.'*)       unset CAST_PACY;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO
}
#CAST_PACY

## ** use_skill singing ** ##

_cast_probe(){
# ** cast PROBE ** #

local REPLY c

echo watch $DRAW_INFO

_is 1 1 cast probe # don't mind if mana too low, not capable or bungles for now
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
 _log "_cast_probe:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_CHA CAST_PROBE;;
 '*Something blocks the magic of your scroll.'*) unset CAST_CHA CAST_PROBE;;
 *'Something blocks your spellcasting.'*)        unset CAST_CHA CAST_PROBE;;
 *'This ground is unholy!'*)                  unset CAST_REST CAST_PACY;;
 #*'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     unset CAST_PROBE;;
 *'You lack the proper attunement to cast '*) unset CAST_PROBE;;
 *'That spell path is denied to you.'*)       unset CAST_PROBE;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO

}
$CAST_PROBE

_cast_restoration(){
# ** if infinite loop, needs food ** #

local REPLY c

echo watch $DRAW_INFO

_is 1 1 cast restoration # don't mind if mana too low, not capable or bungles for now
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
 _log "_cast_restoration:$REPLY"
 _debug "REPLY='$REPLY'"

 case $REPLY in  # server/spell_util.c
 '*Something blocks the magic of your item.'*)   unset CAST_REST CAST_PACY;;
 '*Something blocks the magic of your scroll.'*) unset CAST_REST CAST_PACY;;
 *'Something blocks your spellcasting.'*)        unset CAST_REST CAST_PACY;;
 *'This ground is unholy!'*)                  unset CAST_REST CAST_PACY;;
 #*'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     unset CAST_REST CAST_PACY;;
 *'You lack the proper attunement to cast '*) unset CAST_REST;;
 *'That spell path is denied to you.'*)       unset CAST_REST;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO
}
$CAST_REST

_attack(){
local one
for one in `seq 1 1 $MAX_ATTACK`;
do
_is 1 1 $DIR
sleep 0.2
done
}

__brace(){
_is 1 1 brace
}

_brace(){
[ "$BRACE" ] || return 0
echo watch $DRAW_INFO
while :;
do
 _is 1 1 brace

 while :; do
 unset REPLY
 read -t 1
 case $REPLY in *'You are braced'*) break 2;;
 '') break;;
 *) :;;
 esac
 sleep 0.2
 done

done
echo unwatch $DRAW_INFO
}

_unbrace(){
[ "$BRACE" ] || return 0
echo watch $DRAW_INFO
while :;
do
 _is 1 1 brace

 while :; do
 unset REPLY
 read -t 1
 case $REPLY in  *'Not braced'*) break 2;;
 '') break;;
 *) :;;
 esac
 sleep 0.2
 done

done
echo unwatch $DRAW_INFO
}

_cure(){
test "$*" || return 3
_is 1 1 invoke cure $*
}

_count_time(){

test "$*" || return 3

TIMEE=`/bin/date +%s` || return 4

TIMEX=$((TIMEE - $*)) || return 5
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

_turn_direction_ready_skill(){
test "$*" || return 3

local lDIRN

case $1 in [0-8]) lDIRN=$1; shift;; esac

lDIRN=${lDIRN:-$DIRN}

_is 1 1 ready_skill "$1"
#sleep 0.5
_is 1 1 fire ${lDIRN:-0}
#sleep 0.5
_is 1 1 fire_stop
}

_use_skill(){
test "$*" || return 3
_is 1 1 use_skill "$*"
}

_sing_and_orate_use_skill(){

local lf=''

for lf in `seq 1 1 ${1:-1}`
do
_is 1 1 use_skill singing
sleep 0.5

_is 1 1 use_skill oratory
sleep 0.5 # delay answer from server since '' reply cased; 0.5 was too short
done
}

_hunger(){
if test "$CAST_REST"; then
 $CAST_REST
 :
else
 _is 1 1 apply ${FOOD_EAT:-waybread}
fi
}

_sing_and_orate_read_drawinfo(){

 while :; do
  unset REPLY
  sleep 0.1
  read -t 1
  _log "_sing_and_orate_read_drawinfo:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*)        break 2;;
  *'You sing'*)                :;; # sing
  *'You calm down the '*) CALMS=$((CALMS+1)); BADS=0 ; NOTHING=0;; # sing
  *'You orate to the '*)       :;; # orate
  *'You convince the '*)   CONVS=$((CONVS+1));
                           BADS=0; NOTHING=0;
       #break
       ;;  #You convince the black dragon to become your follower.
  *'Your speach angers '*) BADS=$((BADS+1)); NOTHING=0
       #break
       ;;
  *'Your follower loves your speech'*) BADS=0; NOTHING=0
       #break
       ;;
  *'There is nothing to orate to.'*)   BADS=0; NOTHING=$((NOTHING+1))
       #break
       ;;
  '')  NOTHING=$((NOTHING+1))
       break;; # no answer @ NPC with msg or pacyfied / sung
  *'Too bad the '*)   # sing + orate
     BADS=$((BADS+1)); NOTHING=0
     test "$BADS" -gt $BAD_THRESH && {
         _attack
         BADS=0;
     _draw 3 "Attacked in $DIR .."; sleep 1; };
    # break  # both singing and oratory can have this response
    ;;
  *'You look ugly!'*) $CAST_CHA ;;
  *feel*very*ill*) _cure poison ;;
  *feel*ill*)      _cure disease;;
  *) :;;
  # *'You withhold your attack'*)
  #You can no longer use the skill: oratory.
  #Readied skill: singing.
  esac
 done

echo unwatch $DRAW_INFO
}

_sing_and_orate_main(){
# ** use_skill oratory ** #

sleep 2
_draw 7 "Now convincing..."

#echo watch $DRAW_INFO
c=0; cc=0; TOGGLE=1
NUM=$NUMBER

while :;
do

_ping

echo watch $DRAW_INFO

_is 1 1 use_skill singing
sleep 0.5
#_is 1 1 use_skill stealing
#sleep 0.5

#echo watch $DRAW_INFO

_is 1 1 use_skill oratory

sleep 0.5 # delay answer from server since '' reply cased; 0.5 was too short

 while :; do
  unset REPLY
  sleep 0.1
  read -t 1
  _log "sing&orate:$REPLY"
  _debug "REPLY='$REPLY'"

  case $REPLY in
  *'Unable to find skill '*)        break 2;;
  *'You sing'*)                :;; # sing
  *'You calm down the '*) CALMS=$((CALMS+1)); BADS=0 ;; # sing
  *'You orate to the '*)       :;; # orate
  *'You convince the '*)  CONVS=$((CONVS+1));
                                       BADS=0  [ "$FOREVER" ] && break || break 2;; #You convince the black dragon to become your follower.
  *'Your speach angers '*)                     [ "$FOREVER" ] && break || break 2;;
  *'Your follower loves your speech'*) BADS=0; [ "$FOREVER" ] && break || break 2;;
  *'There is nothing to orate to.'*)   BADS=0; [ "$FOREVER" ] && break || break 2;;
  '')                                          [ "$FOREVER" ] && break || break 2;; # no answer @ NPC with msg or pacyfied / sung
  *'Too bad the '*) if test "$FOREVER"; then # sing + orate
     BADS=$((BADS+1)); test "$BADS" -gt $BAD_THRESH && { _is 0 0 $DIR; BADS=0;
     _draw 3 "Attacked in $DIR .."; sleep 1; };
    fi; break;;
  *) :;;
  #*) break;;
  esac
 done #>"$LOG_REPLY_FILE"

echo unwatch $DRAW_INFO

if test "$FOREVER"; then
 cc=$((cc+1))
 test "$cc" = $INF_THRESH && {
  #{ if test "$TOGGLE" = $INF_TOGGLE; then _cast_restoration; TOGGLE=1; fi; }
  $CAST_CHA
  #echo watch $DRAW_INFO
  $CAST_PROBE
  _draw 3 "Infinite loop $TOGGLE."
  _draw 4 "You calmed down '$CALMS' ."
  _draw 5 "You convinced   '$CONVS' ."
  _draw 2 "Use 'scriptkill $0' to abort.";
   if test "$TOGGLE" = $INF_TOGGLE; then
    $CAST_REST
    TOGGLE=0;
   fi
  cc=0; TOGGLE=$((TOGGLE+1))
  }

elif test "$NUMBER"; then
 NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
 c=$((c+1)); test "$c" -lt $MAX_ORATE || break;
fi

sleep 0.6

done
}


CAST_PROBE=_cast_probe
 CAST_REST=_invoke_restoration # prayer
  CAST_CHA=_invoke_charisma

$CAST_CHA
$CAST_PROBE
$CAST_REST

_brace
_sing_and_orate_main
_unbrace

#
echo unwatch $DRAW_INFO

_count_time $TIMEB && _draw 7 "Looped for $TIMEM:$TIMES minutes"
_count_time $TIMEA && _draw 7 "Script ran $TIMEM:$TIMES minutes"


# *** Here ends program *** #
_draw 7 "You calmed down '$CALMS' ."
_draw 7 "You convinced   '$CONVS' ."
_draw 2 "$0 is finished."
_beep
