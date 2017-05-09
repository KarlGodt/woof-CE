#!/bin/bash
# uses <<<STREAM

# Now count the whole script time
TIMEA=`/bin/date +%s`

# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 3 "with '$*' as arguments ."

DRAW_INFO=drawinfo # drawextinfo (older clients)

LOG_REPLY_FILE=/tmp/cf_pets.rpl
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

# *** Check for parameters *** #

test "$*" || {
echo draw 3 "Need <pet_name> ie: script $0 nazgul spectre ."
        exit 1
}


for PARAM_1 in "$@"
do

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*"help")

echo draw 5 "Script to kill pets except the ones"
echo draw 5 "given on parameter line."
echo draw 2 "Syntax:"
echo draw 5 "$0 pet1 pet2 .."
echo draw 2 ":space: ( ) needs to be replaced by underscore (_)"
echo draw 5 "for ex. green slime to green_slime ."
echo draw 4 "Options:"
echo draw 5 "-d  to turn on debugging."
echo draw 5 "-L  to log to $LOG_REPLY_FILE ."

        exit 0
;;

-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*logging) LOGGING=$((LOGGING+1));;
'') :;;

*) :
;;
esac
sleep 0.1
done


#else
#echo draw 3 "Script needs pets to keep as argument."
#        exit 1
#fi




keepPETS="`echo "$*" | sed 's/killer_bee/killer-bee/;s/dire_wolf_sire/dire-wolf-sire/;s/dire_wolf/dire-wolf/'`"
keepPETS="`echo "$keepPETS" | tr ' ' '|'`"
keepPETS="`echo "$keepPETS" | tr '_' ' '`"
keepPETS="`echo "$keepPETS" | sed 's/killer-bee/killer_bee/;s/dire-wolf-sire/dire_wolf_sire/;s/dire-wolf/dire_wolf/'`"

PETS_KEEP=`echo "$keepPETS" | sed 's/^|*//;s/|*$//'`
echo "PETS_KEEP='$PETS_KEEP'" >>"$LOG_REPLY_FILE"


# *** Actual script to kill unwanted pets *** #

OLD_REPLY="";
REPLY="";

echo watch $DRAW_INFO
echo "issue 1 1 showpets"

while :; do

read -t 1 REPLY
[ "$LOGGING" ] && echo "$REPLY" >>"$LOG_REPLY_FILE"
[ "$DEBUG" ] && echo draw 3 "REPLY='$REPLY'"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break

PETS_HAVE="$REPLY
$PETS_HAVE"

#test "$REPLY" || break
#test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"

sleep 0.1s
done

echo unwatch $DRAW_INFO

PETS_KILL=`echo "$PETS_HAVE" | grep -v -E -i -e "$PETS_KEEP"`
echo "PETS_KILL='$PETS_KILL'" >>"$LOG_REPLY_FILE"


# *** example output :watch drawinfo 0 1  vampire - level 11

# *!* #PETS_KILL=`echo "$PETS_KILL" | awk '{print $5}' | sed '/^$/d'` # works not for "green slime"

# *?* #PETS_KILL=`echo "$PETS_KILL" | awk '{print $5" "$6" "$7}' | sed 's/ - .*$//' | sed '/^$/d'`

# *** #PETS_KILL=`echo "$PETS_KILL" | awk '{for(i=n;i<=NF;i++)$(i-(n-1))=$i;NF=NF-(n-1);print $0}' n=5 | sed 's/ - .*$//' | sed '/^$/d'`
# *** #PETS_KILL=`echo "$PETS_KILL" | awk '{$1=$2=$3=$4=""; print $0}'| sed 's/^ *//' | sed 's/ - .*$//' | sed '/^$/d'`
# *** #PETS_KILL=`echo "$PETS_KILL" | awk '{for(i=5;i<=NF;i++){printf "%s ", $i}; printf "\n"}'| sed 's/ - .*$//' | sed '/^$/d'`

#http://stackoverflow.com/questions/2961635/using-awk-to-print-all-columns-from-the-nth-to-the-last

#awk '{out=""; for(i=2;i<=NF;i++){out=$out" "$i}; print $out}'
#awk '{out=$2; for(i=3;i<=NF;i++){out=out" "$i}; print out}'


# *** Using cut with bash buildin <<< *** #
#PETS_KILL=`cut -f5- -d' '       <<<"$PETS_KILL"`
#PETS_KILL=`sed 's/ - level.*//' <<<"$PETS_KILL"`
#PETS_KILL=`sed '/^$/d'          <<<"$PETS_KILL"`
# *** Using cut with bash buildin <<< *** #

# *** Using while read with bash buildin <<< *** #
PETS_KILL=`while read a b c d PETNAME_REST; do echo "$PETNAME_REST";done<<<"$PETS_KILL"`
PETS_KILL=`sed 's/ - level.*//' <<<"$PETS_KILL"`
PETS_KILL=`sed '/^$/d'          <<<"$PETS_KILL"`
# *** Using while read with bash buildin <<< *** #

PETS_KILL=`echo "$PETS_KILL" | sort -u`
echo "$PETS_KILL" >>"$LOG_REPLY_FILE"


if test "$PETS_KILL"; then
while read onePET
do
test "$onePET" || continue

echo draw 3 "Killing $onePET .."
echo "issue 1 1 killpets $onePET"

sleep 1s

done<<EoI
`echo "$PETS_KILL"`
EoI
else
echo draw 2 "No killable pets found."
fi



# *** Here ends program *** #
echo draw 2 "$0 is finished."
_beep
