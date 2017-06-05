#!/bin/ash

exec 2>/tmp/cf_script.err

# Now count the whole script time
TIMEA=`date +%s`

DRAW_INFO=drawinfo # drawextinfo

# FOREVER mode
INF_THRESH=30 # threshold to cast charisma and probe
INF_TOGGLE=4  # threshold to cast restoration (INF_THRESH * INF_TOGGLE)
BAD_THRESH=3  # threshold to attack in DIR

DEF_ORATE=9

LOG_REPLY_FILE=/tmp/cf_script.rpl
rm -f "$LOG_REPLY_FILE"

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

if test "$URL"; then
ping -c1 -w10 -W10 "${URL:-bing.com}" && break
else
ping -c1 -w10 -W10 bing.com && break
fi

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

COL_VERB=$COL_TAN
COL_DBG=$COL_GOLD

_draw(){
test "$*" || return

case $1 in [0-9]|1[0-2])
COLOUR=${1:-0}
shift
;;
esac
local lCOLOUR=${COLOUR:-0}

while read -r line
do
test "$line" || continue
echo draw $lCOLOUR "$line"
sleep 0.1
done <<EoI
`echo "$*"`
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
echo "$*" >>"${LOG_REPLY_FILE:-/tmp/cf_script.log}"
}

_is(){
_verbose "$*"
echo issue "$@"
sleep 0.2
}


# *** Here begins program *** #
_draw 2 "$0 is started.."

# *** implementing 'help' option *** #
_usage() {

_draw 5 "Script to use_skill oratory."
_draw 5 "Syntax:"
_draw 5 "script $0 <direction> [number]"
_draw 5 "For example: 'script $0 5 west'"
_draw 5 "will issue 5 use_skill oratory in west."
_draw 6 "Abbr. for north:n, northeast:ne .."
_draw 5 "Options:"
_draw 6 "Use -I --infinite to run forever."
_draw 5 "-d  to turn on debugging."
_draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
}

# *** Check for parameters *** #
_debug "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[0-9]/}" && {
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

-h|*help|*usage) _usage;;
-I|*infinite)    FOREVER=$((FOREVER+1));;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;
'')     :;;
*)      _draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 0.1
shift
#_draw "'$#'"

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
 '*Something blocks the magic of your item.'*)   UNSET_MAGI=1;;
 '*Something blocks the magic of your scroll.'*) UNSET_MAGI=1;;
 *'Something blocks your spellcasting.'*)        UNSET_MAGI=1;;
 *'This ground is unholy!'*)                  UNSET_PRAY=1;;
 *'You are no easier to look at.'*)           unset CAST_CHA;;
 *'You lack the skill '*)                     RV=2;;
 *'You lack the proper attunement to cast '*) RV=2;;
 *'That spell path is denied to you.'*)       RV=2;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) RV=1;;
esac

test "$UNSET_MAGI" = 1 && unset CAST_CHA CAST_PROBE
test "$UNSET_PRAY" = 1 && unset CAST_PACY CAST_REST

return ${RV:-4}
}

_cast_charisma(){
# ** cast CHARISMA ** #

local REPLY c=0

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

# case $REPLY in  # server/spell_util.c
# '*Something blocks the magic of your item.'*)   unset CAST_CHA CAST_PROBE;;
# '*Something blocks the magic of your scroll.'*) unset CAST_CHA CAST_PROBE;;
# *'Something blocks your spellcasting.'*)        unset CAST_CHA CAST_PROBE;;
# *'This ground is unholy!'*)                  unset CAST_REST;;
# *'You are no easier to look at.'*)           unset CAST_CHA;;
# *'You lack the skill '*)                     unset CAST_CHA;;
# *'You lack the proper attunement to cast '*) unset CAST_CHA;;
# *'That spell path is denied to you.'*)       unset CAST_CHA;;
# *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
# *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
# esac

 _handle_spell_errors
 case $? in 1) c=$((c+1));;
 2) unset CAST_CHA;;
 esac
 test "$c" = 9 && break  # 9 is just chosen as threshold for spam in msg pane

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

local REPLY c=0

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
 _log "__cast_pacify:$REPLY"
 _debug "REPLY='$REPLY'"

# case $REPLY in  # server/spell_util.c
# '*Something blocks the magic of your item.'*)   unset CAST_PACY CAST_REST;;
# '*Something blocks the magic of your scroll.'*) unset CAST_PACY CAST_REST;;
# *'Something blocks your spellcasting.'*)        unset CAST_PACY CAST_REST;;
# *'This ground is unholy!'*)                     unset CAST_PACY CAST_REST;;
# #*'You are no easier to look at.'*)           unset CAST_CHA;;
# *'You lack the skill '*)                     unset CAST_PACY;;
# *'You lack the proper attunement to cast '*) unset CAST_PACY;;
# *'That spell path is denied to you.'*)       unset CAST_PACY;;
# *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
# *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
# esac

 _handle_spell_errors
 case $? in 1) c=$((c+1));;
 2) unset CAST_PACY;;
 esac
 test "$c" = 9 && break  # 9 is just chosen as threshold for spam in msg pane

done

echo unwatch $DRAW_INFO
}
#CAST_PACY

## ** use_skill singing ** ##

_cast_probe(){
# ** cast PROBE ** #

local REPLY c=0

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

# case $REPLY in  # server/spell_util.c
# '*Something blocks the magic of your item.'*)   unset CAST_CHA CAST_PROBE;;
# '*Something blocks the magic of your scroll.'*) unset CAST_CHA CAST_PROBE;;
# *'Something blocks your spellcasting.'*)        unset CAST_CHA CAST_PROBE;;
# *'This ground is unholy!'*)                  unset CAST_REST CAST_PACY;;
# #*'You are no easier to look at.'*)           unset CAST_CHA;;
# *'You lack the skill '*)                     unset CAST_PROBE;;
# *'You lack the proper attunement to cast '*) unset CAST_PROBE;;
# *'That spell path is denied to you.'*)       unset CAST_PROBE;;
# *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
# *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
# esac

 _handle_spell_errors
 case $? in 1) c=$((c+1));;
 2) unset CAST_PROBE;;
 esac
 test "$c" = 9 && break # 9 is just chosen as threshold for spam in msg pane

done

echo unwatch $DRAW_INFO

}
$CAST_PROBE

_cast_restoration(){
# ** if infinite loop, needs food ** #

local REPLY c=0

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

# case $REPLY in  # server/spell_util.c
# '*Something blocks the magic of your item.'*)   unset CAST_REST CAST_PACY;;
# '*Something blocks the magic of your scroll.'*) unset CAST_REST CAST_PACY;;
# *'Something blocks your spellcasting.'*)        unset CAST_REST CAST_PACY;;
# *'This ground is unholy!'*)                  unset CAST_REST CAST_PACY;;
# #*'You are no easier to look at.'*)           unset CAST_CHA;;
# *'You lack the skill '*)                     unset CAST_REST CAST_PACY;;
# *'You lack the proper attunement to cast '*) unset CAST_REST;;
# *'That spell path is denied to you.'*)       unset CAST_REST;;
# *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
# *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
# esac

 _handle_spell_errors
 case $? in 1) c=$((c+1));;
 2) unset CAST_REST;;
 esac
 test "$c" = 9 && break # 9 is just chosen as threshold for spam in msg pane

done

echo unwatch $DRAW_INFO
}
$CAST_REST

_attack(){  #unused
local one
for one in `seq 1 1 $MAX_ATTACK`;
do
_is 1 1 $DIR
sleep 0.2
done
}

# ** use_skill oratory ** #

sleep 2

TIMEB=`/bin/date +%s`

_draw 7 "Now convincing..."

#echo watch $DRAW_INFO
c=0; cc=0; TOGGLE=1; CONVS=0; CALMS=0
NUM=$NUMBER

while :;
do

_ping

echo watch $DRAW_INFO

_verbose "$NUMBER:$NUM:$c:$cc:$TOGGLE:$CALMS:$CONVS"

_is 1 1 use_skill singing
sleep 0.5

# cannot steal from pets
#_is 1 1 use_skill stealing
#sleep 0.5

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
 c=$((c+1)); test "$c" -lt $DEF_ORATE || break;
fi

sleep 0.6

done


#echo unwatch $DRAW_INFO

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
 echo draw 5 "Whole loop took $TIMEXM:$TIMEXS minutes."
fi

if test "$TIMEZ" -a "$TIMEA"; then
_compute_minutes_seconds $TIMEZ $TIMEA && \
 echo draw 4 "Whole script took $TIMEXM:$TIMEXS minutes."
fi

# *** Here ends program *** #
_draw 7 "You calmed down '$CALMS' ."
_draw 7 "You convinced   '$CONVS' ."
_draw 2 "$0 is finished."
_beep
