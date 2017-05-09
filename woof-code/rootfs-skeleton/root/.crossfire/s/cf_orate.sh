#!/bin/ash

exec 2>/tmp/cf_script.err

TIMEA=`/bin/date +%s`

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
 n|north)       DIR=north;     DIRN=1; readonly DIR DIRN;;
ne|norteast)    DIR=northeast; DIRN=2; readonly DIR DIRN;;
 e|east)        DIR=east;      DIRN=3; readonly DIR DIRN;;
se|southeast)   DIR=southeast; DIRN=4; readonly DIR DIRN;;
 s|south)       DIR=south;     DIRN=5; readonly DIR DIRN;;
sw|southwest)   DIR=southwest; DIRN=6; readonly DIR DIRN;;
 w|west)        DIR=west;      DIRN=7; readonly DIR DIRN;;
nw|northwest)   DIR=northwest; DIRN=8; readonly DIR DIRN;;
-h|*help)       _usage;;
-I|*infinite)   FOREVER=1;;
'')     :;;
*)      echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;
esac
sleep 1
shift
#echo draw "'$#'"

done

#readonly NUMBER DIR
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
echo issue 1 1 cast charisma # don't mind if mana too low, not capable or bungles for now
sleep 0.5
echo issue 1 1 fire ${DIRN:-0}
sleep 0.5
echo issue 1 1 fire_stop
sleep 0.5
#You are no easier to look at.
}
_cast_charisma

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

# ** use_skill oratory ** #

sleep 2
echo draw 7 "Now convincing..."

echo watch $DRAW_INFO
c=0; cc=0; TOGGLE=0
NUM=$NUMBER

while :;
do

_ping

echo issue 1 1 use_skill singing
sleep 0.5
echo issue 1 1 use_skill oratory

sleep 0.5 # delay answer from server since '' reply cased; 0.5 was too short

 while :; do
  sleep 0.1
  unset REPLY
  read -t 1
  echo "sing&orate:$REPLY" >>"$LOG_REPLY_FILE"
  case $REPLY in
  #*'There is no lock there.'*) :;; #break 2;;
  #*' no door'*)                :;; #break 2;;
  #*'You unlock'*)              :;; #break 2;;
  #*'You pick the lock.'*)      :;; #break 2;;
  #*'Your '*)       :;;  # Your monster beats monster
  #*'You killed '*) :;;
  #*'You find '*)   :;;
  #*'You pickup '*) :;;
  #*' tasted '*)    :;;  # food tasted good
  *'You sing'*)                :;; # sing
  *'You calm down the '*) CALMS=$((CALMS+1)) ;; # sing
  *'Unable to find skill '*)        break 2;;
  *'You orate to the '*)            :;;
  *'You convince the '*)    CONVS=$((CONVS+1)); [ "$FOREVER" ] && break || break 2;; #You convince the black dragon to become your follower.
  *'Your speach angers '*)             [ "$FOREVER" ] && break || break 2;;
  *'Your follower loves your speech'*) [ "$FOREVER" ] && break || break 2;;
  *'Too bad the '*) if test "$FOREVER"; then BADS=$((BADS+1)); test $BADS -gt $BAD_THRESH && { echo issue 0 0 $DIR; BADS=0; } ; fi;; # sing
  *'There is nothing to orate to.'*)   [ "$FOREVER" ] && break || break 2;;
  '')                                  [ "$FOREVER" ] && break || break 2;; # no answer @ NPC with msg
  *) break;;
  esac
 done #>"$LOG_REPLY_FILE"

#test "$NUMBER" && { NUM=$((NUM-1)); test "$NUM" -le 0 && break; } || { c=$((c+1)); test "$c" = $MAX_LOCKPICK && break; }
if test "$FOREVER"; then
 cc=$((cc+1))
 test "$cc" = $INF_THRESH && {
  { if test "$TOGGLE" = $INF_TOGGLE; then _cast_restoration; TOGGLE=0; else TOGGLE=$((TOGGLE+1)); fi; }
  _cast_charisma
  _cast_probe
  echo draw 3 "Infinite loop. Use 'scriptkill $0' to abort."; cc=0;
  }
elif test "$NUMBER"; then
 NUM=$((NUM-1)); test "$NUM" -gt 0 || break;
else
 c=$((c+1)); test "$c" -lt $MAX_ORATE || break;
fi

sleep 1

done


echo unwatch $DRAW_INFO



# *** Here ends program *** #
echo draw 7 "You calmed down '$CALMS' ."
echo draw 7 "You convinced   '$CONVS' ."
echo draw 2 "$0 is finished."
beep -f 700 -l 1000
