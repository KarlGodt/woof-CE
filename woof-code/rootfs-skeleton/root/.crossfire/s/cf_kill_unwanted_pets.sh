#!/bin/bash

# *** Here begins program *** #
echo draw 2 "$0 is started.."
echo draw 3 "with '$*' as arguments ."

# *** Check for parameters *** #
#[ "$*" ] && {
if test "$*"; then
PARAM_1="$1"

# *** implementing 'help' option *** #
test "$PARAM_1" = "help" && {

echo draw 5 "Script to kill pets except the ones"
echo draw 5 "given on parameter line."
echo draw 2 "Syntax:"
echo draw 5 "$0 pet1 pet2 .."
echo draw 2 ":space: ( ) needs to be replaced by underscore (_)"
echo draw 5 "for ex. green slime to green_slime ."
        exit 0
        }

#} || {
else
echo draw 3 "Script needs pets to keep as argument."
        exit 1
#}
fi

test "$1" || {
echo draw 3 "Need <pet_name> ie: script $0 nazgul spectre ."
        exit 1
}


keepPETS="`echo "$*" | sed 's/killer_bee/killer-bee/;s/dire_wolf_sire/dire-wolf-sire/;s/dire_wolf/dire-wolf/'`"
keepPETS="`echo "$keepPETS" | tr ' ' '|'`"
keepPETS="`echo "$keepPETS" | tr '_' ' '`"
keepPETS="`echo "$keepPETS" | sed 's/killer-bee/killer_bee/;s/dire-wolf-sire/dire_wolf_sire/;s/dire-wolf/dire_wolf/'`"

PETS_KEEP=`echo "$keepPETS" | sed 's/^|*//;s/|*$//'`
echo "PETS_KEEP='$PETS_KEEP'" >>/tmp/cf_pets.rpl

# *** Actual script to kill unwanted pets *** #

OLD_REPLY="";
REPLY="";

echo watch drawinfo
echo "issue 1 1 showpets"

while [ 1 ]; do

read -t 1 REPLY
echo "$REPLY" >>/tmp/cf_pets.rpl

PETS_HAVE="$REPLY
$PETS_HAVE"

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"

sleep 0.1s
done

echo unwatch drawinfo

PETS_KILL=`echo "$PETS_HAVE" | grep -v -E "$PETS_KEEP"`
echo "PETS_KILL='$PETS_KILL'" >>/tmp/cf_pets.rpl


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
echo "$PETS_KILL" >>/tmp/cf_pets.rpl

while read onePET
do

echo draw 3 "Killing $onePET .."
echo "issue 1 1 killpets $onePET"
sleep 1s

done<<EoI
`echo "$PETS_KILL"`
EoI




# *** Here ends program *** #
echo draw 2 "$0 is finished."
beep -l 500 -f 700
