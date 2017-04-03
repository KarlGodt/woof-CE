#!/bin/ash

exec 2>/tmp/cf_script.err

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


# *** Here begins program *** #
echo draw 2 "$0 is started.."

# *** Check for parameters *** #

# *** implementing 'help' option *** #
_usage() {

echo draw 5 "Script to use_skill oratory."
echo draw 5 "Syntax:"
echo draw 5 "script $0 <direction> [number]"
echo draw 5 "For example: 'script $0 5 west'"
echo draw 5 "will issue 5 use_skill oratory in west."
echo draw 6 "Abbr. for north:n, northeast:ne .."
echo draw 6 "Use -I --infinite to run forever."
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
-I|*infinite)   FOREVER=1;;
'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 1
shift
#echo draw "'$#'"

done

readonly NUMBER DIR DIRN
echo draw 3 "NUMBER='$NUMBER' DIR='$DIR' DIRN='$DIRN'"


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
 echo "_cast_charisma:$REPLY" >>"$LOG_REPLY_FILE"
 echo draw 3 "REPLY='$REPLY'"
 case $REPLY in
 *'You are no easier to look at.'*) unset CAST_CHA;;
 *'You recast the spell while in effect.'*) INF_THRESH=$((INF_THRESH+1));;
 *) c=$((c+1)); test "$c" = 9 && break;; # 9 is just chosen as threshold for spam in msg pane
 esac

done

echo unwatch $DRAW_INFO
#You are no easier to look at.
}
CAST_CHA=_cast_charisma
$CAST_CHA
#_cast_charisma

__cast_pacify(){
# ** cast PACIFY ** #
# pacified monsters do not respond to oratory
return 0

echo issue 1 1 cast pacify # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5
}


## ** use_skill singing ** ##

_cast_probe(){
# ** cast PROBE ** #

echo issue 1 1 cast probe # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5
}
_cast_probe

_cast_restoration(){
# ** if infinite loop, needs food ** #

echo issue 1 1 cast restoration # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5

}

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
  echo "sing&orate:$REPLY" >>"$LOG_REPLY_FILE"
  #echo draw 3 "REPLY='$REPLY'"
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
  _cast_probe
  echo draw 3 "Infinite loop $TOGGLE."
  echo draw 4 "You calmed down '$CALMS' ."
  echo draw 5 "You convinced   '$CONVS' ."
  echo draw 2 "Use 'scriptkill $0' to abort.";
 { if test "$TOGGLE" = $INF_TOGGLE; then _cast_restoration; TOGGLE=0; fi; }
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
beep
