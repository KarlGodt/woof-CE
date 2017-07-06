#!/bin/ash

TIMEA=`/bin/date +%s`

tmpDIR=/tmp/crossfire-client-scripts
mkdir -p "$tmpDIR"

LOG_REPLY_FILE="$tmpDIR"/cf_animate_weapon.log

# *** Here begins program *** #
echo draw 2 "$0 is started with pid $$ $PPID"
echo draw 3 "with '$*' as arguments ."

# *** Check for parameters *** #
#[ "$*" ] && {
if test "$*"; then :
else
echo draw 3 "Script needs weapon to mark as argument."
        exit 1

fi

until [ $# = 0 ]; do
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help|*usage)

echo draw 5 "Script to animate weapon"
echo draw 5 "given on parameter line."
echo draw 2 "Syntax:"
echo draw 7 "$0 Bonecrusher"
#echo draw 2 ":space: ( ) needs to be replaced by underscore (_)"
#echo draw 5 "for ex. sword of gnarg to sword_of_gnarg ."
echo draw 5 "-d set debug"
echo draw 5 "-L log to $LOG_REPLY_FILE"
echo draw 5 "-v set verbosity"
        exit 0
;;

#-f|*force)     FORCE=$((FORCE+1));;
-d|*debug)     DEBUG=$((DEBUG+1));;
-L|*log*)    LOGGING=$((LOGGING+1));;
-v|*verbose) VERBOSE=$((VERBOSE+1));;

-*) echo draw 3 "Incorrect parameter '$PARAM_1' ."; exit 1;;

*) break;;
esac

shift
done

test "$1" || {
echo draw 3 "Need <weapon> ie: script $0 club +3 ."
        exit 1
}

WEAPONS_TO_MARK=`echo "$*" | tr '[;,:.| ]' '|' | tr '_' ' '`


echo request items inv

rm -f "$tmpDIR"/cf_inv.inv
while [ 1 ]
do
read -t 1 ANSWER
echo "$ANSWER" >>"$tmpDIR"/cf_inv.inv

test "$ANSWER" || break
#test "$ANSWER" = "$ANSWER_OLD" && A=$((A+1))
test "$ANSWER" = "$ANSWER_OLD" && break
ANSWER_OLD="$ANSWER"
#test $A -gt 6 && break
ANSWER=
done

cut -f9- -d ' ' "$tmpDIR"/cf_inv.inv >"$tmpDIR"/cf_inv.cut

rm -f "$tmpDIR"/cf_inv.new

while read number rest
do

case $number in
[1-9]*)
          echo "$number $rest" >>"$tmpDIR"/cf_inv.new;;

two)      echo "2 $rest"  >>"$tmpDIR"/cf_inv.new;;
three)    echo "3 $rest"  >>"$tmpDIR"/cf_inv.new;;
four)     echo "4 $rest"  >>"$tmpDIR"/cf_inv.new;;
five)     echo "5 $rest"  >>"$tmpDIR"/cf_inv.new;;
six)      echo "6 $rest"  >>"$tmpDIR"/cf_inv.new;;
seven)    echo "7 $rest"  >>"$tmpDIR"/cf_inv.new;;
eight)    echo "8 $rest"  >>"$tmpDIR"/cf_inv.new;;
nine)     echo "9 $rest"  >>"$tmpDIR"/cf_inv.new;;
ten)      echo "10 $rest" >>"$tmpDIR"/cf_inv.new;;
eleven)   echo "11 $rest" >>"$tmpDIR"/cf_inv.new;;
twelve)   echo "12 $rest" >>"$tmpDIR"/cf_inv.new;;
thirteen) echo "13 $rest" >>"$tmpDIR"/cf_inv.new;;
fourteen) echo "14 $rest" >>"$tmpDIR"/cf_inv.new;;
fifteen)  echo "15 $rest" >>"$tmpDIR"/cf_inv.new;;
sixteen)  echo "16 $rest" >>"$tmpDIR"/cf_inv.new;;
seventeen)echo "17 $rest" >>"$tmpDIR"/cf_inv.new;;
eighteen) echo "18 $rest" >>"$tmpDIR"/cf_inv.new;;
nineteen) echo "19 $rest" >>"$tmpDIR"/cf_inv.new;;
twenty)
echo "20 $rest" >>"$tmpDIR"/cf_inv.new
;;
''):;;
*)
echo "1 $number $rest" >>"$tmpDIR"/cf_inv.new
;;
esac

done<"$tmpDIR"/cf_inv.cut

sort -k2 -t' ' "$tmpDIR"/cf_inv.new >"$tmpDIR"/cf_inv.srt

_wait_for_end(){

#sleep 20
sleep 1
while :;
do
unset REQUEST_ANSWER
echo request range
read -t 1 REQUEST_ANSWER
echo draw 5 "request ANSWER='$REQUEST_ANSWER'"
case $REQUEST_ANSWER in
*golem*) echo draw 5 "SLEEP"; sleep 1;;
*$w*)    echo draw 5 "SLEEP"; sleep 1;;
*) echo draw 5 "BREAK";break;;
esac
done

}

TIMEB=`/bin/date +%s`

while read -r aWEAPON
do
echo "draw 3 DBG:aWEAPON=$aWEAPON"
#grep -q -i -w "$aWEAPON" "$tmpDIR"/cf_inv.srt || continue
WEAPON=`grep -i -w "$aWEAPON" "$tmpDIR"/cf_inv.srt`
echo draw 3 "DBG:WEAPON="$WEAPON
 #while read -r aWLINE
  while read -r nr w
  do
  echo "draw 3 DBG:$nr:$w:"
  for i in `seq 1 1 $nr`
  do
   echo "draw 3 DBG:$nr:$w:$i"
   echo "issue 0 0 mark $w"
   echo "issue 0 0 cast animate weapon"
   echo "issue 0 0 fire"
   sleep 1
   #_wait_for_end
   sleep 1
   #while :;
    while [ 1 ];
    do
    #unset REQUEST_ANSWER
    #echo watch request range
    #echo watch request
    echo watch scripttell
    sleep 1
    echo request range
     read -t 5 REQUEST_ANSWER
     echo draw 5 "request ANSWER=$REQUEST_ANSWER"
    case $REQUEST_ANSWER in
    *scripttell*) echo draw 5 "SLEEP"; sleep 5;;
    *golem*) echo draw 5 "SLEEP"; sleep 5;;
    *$w*)    echo draw 5 "SLEEP"; sleep 5;;
    #'')      echo draw 5 "SLEEP"; sleep 5;;
    *) echo draw 5 "BREAK 1";break 1;;
    esac
   done

   sleep 1
   #echo unwatch request range
   echo unwatch scripttell
   sleep 1
  done
 sleep 1
 echo issue 1 1 fire_stop

 done <<EoI
`echo "$WEAPON"`
EoI

sleep 1
echo issue 1 1 fire_stop

done <<EoI
`echo "$WEAPONS_TO_MARK" | tr '|' '\n'`
EoI

echo draw 7 "WEAPONS_TO_MARK=$WEAPONS_TO_MARK"
echo draw 6 "aWEAPON=$aWEAPON"
echo draw 5 "WEAPON="$WEAPON
echo draw 4 "w=$w"
echo issue 1 1 fire_stop

# *** Here ends program *** #

_test_integer(){
test "$*" || return 3
test ! "${*//[0-9]/}"
}

_count_time(){

test "$*" || return 3
_test_integer "$*" || return 4

TIMEE=`/bin/date +%s` || return 5

TIMEX=$((TIMEE - $*)) || return 6
TIMEM=$((TIMEX/60))
TIMES=$(( TIMEX - (TIMEM*60) ))

case $TIMES in [0-9]) TIMES="0$TIMES";; esac

return 0
}

_count_time $TIMEB && echo draw 7 "Looped for $TIMEM:$TIMES minutes"
_count_time $TIMEA && echo draw 7 "Script ran $TIMEM:$TIMES minutes"

echo draw 2 "$0 is finished."
beep -f 700 -l 1000
