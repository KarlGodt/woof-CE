#!/bin/bash

export PATH=/bin:/usr/bin

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}
test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
_set_global_variables
# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

# *** Here begins program *** #
_say_start_msg "$@"

_say_help_and_exit(){
echo draw 5 "Script to kill pets except the ones"
echo draw 5 "given on parameter line."
echo draw 2 "Syntax:"
echo draw 5 "$0 pet1 pet2 .."
echo draw 2 ":space: ( ) needs to be replaced by underscore (_)"
echo draw 5 "for ex. green slime to green_slime ."
exit 0
}

# *** Check for parameters *** #
case $* in
'')     echo draw 3 "Script needs pets to keep as argument."
        echo draw 3 "Need <pet_name> ie: script $0 nazgul,spectre ."
         _say_help_and_exit;;
h|*help) _say_help_and_exit;;
*) :;;
esac

echo "\$*='$*'" >>/tmp/cf_pets.rpl
keepPETS="`echo "$*" | sed 's/killer_bee/killer-bee/;s/dire_wolf_sire/dire-wolf-sire/;s/dire_wolf/dire-wolf/'`"
echo "keepPETS='$keepPETS'" >>/tmp/cf_pets.rpl
keepPETS="`echo "$keepPETS" | tr '[ ,]' '|'`"
echo "keepPETS='$keepPETS'" >>/tmp/cf_pets.rpl
keepPETS="`echo "$keepPETS" | tr '_' ' '`"
echo "keepPETS='$keepPETS'" >>/tmp/cf_pets.rpl
keepPETS="`echo "$keepPETS" | sed 's/killer-bee/killer_bee/;s/dire-wolf-sire/dire_wolf_sire/;s/dire-wolf/dire_wolf/'`"
echo "keepPETS='$keepPETS'" >>/tmp/cf_pets.rpl
PETS_KEEP=`echo "$keepPETS" | sed 's/^|*//;s/|*$//'`
echo "PETS_KEEP='$PETS_KEEP'" >>/tmp/cf_pets.rpl

# *** Actual script to kill unwanted pets *** #

OLD_REPLY="";
REPLY="";

echo watch drawinfo
sleep 1
echo "issue 1 1 showpets"

#while [ 1 ]; do
while :; do

read -t 1 REPLY
echo "watch drawinfo REPLY='$REPLY'" >>/tmp/cf_pets.rpl

case $REPLY in
#*" - level "*) # filter in case of disturbing drawinfos ie Y times killed
*-*level*)      # filter in case of disturbing drawinfos ie Y times killed
PETS_HAVE="$REPLY
$PETS_HAVE"
;;
esac

test "$REPLY" || break
test "$REPLY" = "$OLD_REPLY" && break
OLD_REPLY="$REPLY"

sleep 0.1s
done

echo unwatch drawinfo

echo "PETS_HAVE='$PETS_HAVE'" >>/tmp/cf_pets.rpl
echo "PETS_KEEP='$PETS_KEEP'" >>/tmp/cf_pets.rpl
PETS_KILL=`echo "$PETS_HAVE" | grep -v -E -i "$PETS_KEEP"`
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

[ "$DEBUG" ] && echo draw 3 "$PETS_KILL" #DEBUG

while read onePET
do

[ "$onePET" ] || continue # empty onePET would kill all pets

case $onePET in
*have*no*pet*) break;; # stop if we have no pets
esac

echo draw 3 "Killing $onePET .."
echo "issue 1 1 killpets $onePET"
sleep 1s

done<<EoI
`echo "$PETS_KILL"`
EoI




# *** Here ends program *** #
#echo draw 2 "$0 is finished."
_say_end_msg
