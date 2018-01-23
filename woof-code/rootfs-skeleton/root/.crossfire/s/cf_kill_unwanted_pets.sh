#!/bin/bash
# uses read VAR <<< $VAR1

# 2018-01-10 : Code overhaul using the _log()
# function instead echo >>file
# Added -w option, reworked parameter processing
# Added case switch for drawextinfo/drawinfo sending
# different amounts of pre-pet number values

export PATH=/bin:/usr/bin

MY_SELF=`realpath "$0"`
MY_BASE=${MY_SELF##*/}

#test -f "${MY_SELF%/*}"/cf_functions.sh   && . "${MY_SELF%/*}"/cf_functions.sh
#_set_global_variables "$@"

test -f "${MY_SELF%/*}"/cf_funcs_common.sh   && . "${MY_SELF%/*}"/cf_funcs_common.sh
_set_global_variables "$@"

# *** Override any VARIABLES in cf_functions.sh *** #
test -f "${MY_SELF%/*}"/"${MY_BASE}".conf && . "${MY_SELF%/*}"/"${MY_BASE}".conf

# *** Here begins program *** #
_say_start_msg "$@"

_say_help_and_exit(){
_draw 5 "Script to kill pets except the ones"
_draw 5 "given on parameter line."
_draw 2 "Syntax:"
_draw 2 "$0 pet1 pet2 .."
_draw 5 ":space: ( ) needs to be replaced by underscore (_)"
_draw 5 "for ex. green slime to green_slime ."
_draw 2 "Options:"
_draw 5 "-w :Use grep -w (word) to be more exact (lich/demilich)"
_draw 2  "To be used in the crossfire roleplaying game client."
exit 0
}

_log "\$*='$*'"
# *** Check for parameters *** #
case $* in
'')     _draw 3 "Script needs pets to keep as argument."
        _draw 3 "Need <pet_name> ie: script $0 nazgul,spectre ."
        _say_help_and_exit;;
esac

while [ "$1" ];
do
case $1 in
-h|*-help) _say_help_and_exit;;
-w|*-word)  GREP_PARAM="$GREP_PARAM $1";;
*) keepPETS="$keepPETS $1";;
esac

shift
sleep 0.1
done

_log "\$*='$*'"
#keepPETS="`echo "$*" | sed 's/killer_bee/killer-bee/;s/dire_wolf_sire/dire-wolf-sire/;s/dire_wolf/dire-wolf/'`"
keepPETS="`echo "$keepPETS" | sed 's/killer_bee/killer-bee/;s/dire_wolf_sire/dire-wolf-sire/;s/dire_wolf/dire-wolf/'`"
_log "keepPETS='$keepPETS'"
keepPETS="`echo "$keepPETS" | tr '[ ,]' '|'`"
_log "keepPETS='$keepPETS'"
keepPETS="`echo "$keepPETS" | tr '_' ' '`"
_log "keepPETS='$keepPETS'"
keepPETS="`echo "$keepPETS" | sed 's/killer-bee/killer_bee/;s/dire-wolf-sire/dire_wolf_sire/;s/dire-wolf/dire_wolf/'`"
_log "keepPETS='$keepPETS'"
PETS_KEEP=`echo "$keepPETS" | sed 's/^|*//;s/|*$//'`
_log "PETS_KEEP='$PETS_KEEP'"

# *** Actual script to kill unwanted pets *** #

OLD_REPLY="";
REPLY="";

_watch
sleep 1
_is 1 1 "showpets"

while :; do

read -t 1 REPLY
_log "REPLY='$REPLY'"

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

_unwatch

_log "PETS_HAVE='$PETS_HAVE'"
_log "PETS_KEEP='$PETS_KEEP'"
PETS_KILL=`echo "$PETS_HAVE" | grep -v -E -i $GREP_PARAM "$PETS_KEEP"`
_log "PETS_KILL='$PETS_KILL'"


# *** example output :watch drawinfo 0 1  vampire - level 11
#                     watch drawextinfo 0 10 0 64  demilich - level 31
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
case $DRAWINFO in
drawextinfo)
   PETS_KILL=`while read a b c d e f PETNAME_REST; do echo "$PETNAME_REST";done<<<"$PETS_KILL"`
;;
*) PETS_KILL=`while read a b c d     PETNAME_REST; do echo "$PETNAME_REST";done<<<"$PETS_KILL"`
;;
esac

_log "PETS_KILL='$PETS_KILL'"
PETS_KILL=`sed 's/ - level.*//' <<<"$PETS_KILL"`
_log "PETS_KILL='$PETS_KILL'"
PETS_KILL=`sed '/^$/d'          <<<"$PETS_KILL"`
_log "PETS_KILL='$PETS_KILL'"
# *** Using while read with bash buildin <<< *** #

PETS_KILL=`echo "$PETS_KILL" | sort -u`
_log "PETS_KILL='$PETS_KILL'"

__debug "$PETS_KILL" #DEBUG

# MAIN
while read onePET
do

[ "$onePET" ] || continue # empty onePET would kill all pets

case $onePET in
*have*no*pet*) break;; # stop if we have no pets
esac

_draw 3 "Killing $onePET .."
_is 1 1 killpets "$onePET"
sleep 1s

done <<EoI
`echo "$PETS_KILL"`
EoI


# *** Here ends program *** #
_say_end_msg
###END###
