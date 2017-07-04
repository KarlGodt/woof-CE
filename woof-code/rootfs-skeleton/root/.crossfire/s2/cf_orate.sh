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
echo draw 2 "$0 is started.."

# *** Check for parameters *** #

# *** implementing 'help' option *** #
_usage() {

echo draw 5 "Script to use_skill oratory."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <direction> <<number>>"
echo draw 5 "For example: 'script $0 5 west'"
echo draw 5 "will issue 5 use_skill oratory in west."
echo draw 6 "Abbr. for north:n, northeast:ne .."
echo draw 5 "Options:"
echo draw 6 "Use -I --infinite to run forever."
echo draw 5 "-d  to turn on debugging."
echo draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
}

echo draw 3 "'$#' Parameters: '$*'"

until test $# = 0;
do

PARAM_1="$1"
case $PARAM_1 in
[0-9]*) NUMBER=$PARAM_1; test "${NUMBER//[[:digit:]]/}" && {
           echo draw 3 "Only :digit: numbers as first option allowed."; exit 1; }
           readonly NUMBER
       #echo draw 2 "NUMBER=$NUMBER"
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

'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 0.1
shift
#echo draw "'$#'"

done

readonly NUMBER DIR DIRN
echo draw 3 "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'" # DEBUG


# TODO: check for near doors and direct to them

if test "$DIR"; then
 :
else
 echo draw 3 "Need direction as parameter."
 exit 1
fi

_ping(){
test "$PING_DO" || return 0
while :;
do
ping -c1 -w10 -W10 "$URL" && break
sleep 1
done >/dev/null
}

_cast_charisma(){
# ** cast CHARISMA ** #

local REPLY c

echo watch $DRAW_INFO

echo issue 1 1 cast charisma # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
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

echo issue 1 1 cast pacify # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
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

echo issue 1 1 cast probe # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
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

echo issue 1 1 cast restoration # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
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
echo issue 1 1 $DIR
sleep 0.2
done
}

# ** use_skill oratory ** #

sleep 2
echo draw 7 "Now convincing..."

#echo watch $DRAW_INFO
c=0; cc=0; TOGGLE=1
NUM=$NUMBER

while :;
do

_ping

echo watch $DRAW_INFO

echo issue 1 1 use_skill singing
sleep 0.5
#echo issue 1 1 use_skill stealing
#sleep 0.5

#echo watch $DRAW_INFO

echo issue 1 1 use_skill oratory

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
     BADS=$((BADS+1)); test "$BADS" -gt $BAD_THRESH && { echo issue 0 0 $DIR; BADS=0;
     echo draw 3 "Attacked in $DIR .."; sleep 1; };
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
  echo draw 3 "Infinite loop $TOGGLE."
  echo draw 4 "You calmed down '$CALMS' ."
  echo draw 5 "You convinced   '$CONVS' ."
  echo draw 2 "Use 'scriptkill $0' to abort.";
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


#echo unwatch $DRAW_INFO



# *** Here ends program *** #
echo draw 7 "You calmed down '$CALMS' ."
echo draw 7 "You convinced   '$CONVS' ."
echo draw 2 "$0 is finished."
_beep
