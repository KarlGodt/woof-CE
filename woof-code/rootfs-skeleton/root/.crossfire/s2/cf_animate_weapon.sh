#!/bin/ash

tmpDIR=/tmp/crossfire-client-scripts
mkdir -p "$tmpDIR"

_draw(){
	test "$*" || return 3
case $1 in [0-9]|1[0-2])
lCOLOR=$1; shift;;
esac
	test "$*" || return 4
local lCOLOR=${COLOR:-$lCOLOR}
	  lCOLOR=${lCOLOR:-1}

while read -r line
do
	echo draw $lCOLOR "$line"
done <<EoI
`echo "$*"`
EoI
}

# ***
_log(){
# *** echo passed parameters to logfile if LOGGING is set to anything

test "$LOGGING" || return 0
echo "$*" >>"${LOG_FILE:-/tmp/cf_script.log}"
}

# ***
_verbose(){
# ***
test "$VERBOSE" || return 0
echo draw ${COL_VERB:-7} "$*"
sleep 0.1
}

# ***
_debug(){
# *** print passed parameters to window if DEBUG is set to anything

test "$DEBUG" || return 0
echo draw ${COL_DBG:-3} "$*"
sleep 0.1
}

_is(){
	_verbose "$*"
  echo issue "$*"
sleep 0.2
}

# *** Here begins program *** #
_draw 2 "$0 is started with pid $$ $PPID"
_draw 3 "with '$*' as arguments ."

# *** Check for parameters *** #
#[ "$*" ] && {
if test "$*"; then
PARAM_1="$1"

# *** implementing 'help' option *** #
case "$PARAM_1" in -h|*help|*usage)

_draw 5 "Script to animate weapon"
_draw 5 "given on parameter line."
_draw 2 "Syntax:"
_draw 5 "$0 Bonecrusher"
#_draw 2 ":space: ( ) needs to be replaced by underscore (_)"
#_draw 5 "for ex. sword of gnarg to sword_of_gnarg ."
        exit 0
;;
esac


else
_draw 3 "Script needs weapon to mark as argument."
        exit 1

fi

test "$1" || {
_draw 3 "Need <weapon> ie: script $0 club +3 ."
        exit 1
}

WEAPONS_TO_MARK=`echo "$*" | tr '[;,:.| ]' '|' | tr '_' ' '`


echo watch request
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

two)      echo "2 $rest" >>"$tmpDIR"/cf_inv.new;;
three)    echo "3 $rest" >>"$tmpDIR"/cf_inv.new;;
four)     echo "4 $rest" >>"$tmpDIR"/cf_inv.new;;
five)     echo "5 $rest" >>"$tmpDIR"/cf_inv.new;;
six)      echo "6 $rest" >>"$tmpDIR"/cf_inv.new;;
seven)    echo "7 $rest" >>"$tmpDIR"/cf_inv.new;;
eight)    echo "8 $rest" >>"$tmpDIR"/cf_inv.new;;
nine)     echo "9 $rest" >>"$tmpDIR"/cf_inv.new;;
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
_draw 5 "request ANSWER='$REQUEST_ANSWER'"
case $REQUEST_ANSWER in
*golem*) _draw 5 "SLEEP"; sleep 1;;
*$w*)    _draw 5 "SLEEP"; sleep 1;;
*) _draw 5 "BREAK";break;;
esac
done

}

while read -r aWEAPON
do
echo "draw 3 DBG:aWEAPON=$aWEAPON"
#grep -q -i -w "$aWEAPON" "$tmpDIR"/cf_inv.srt || continue
WEAPON=`grep -i -w "$aWEAPON" "$tmpDIR"/cf_inv.srt`
_draw 3 "DBG:WEAPON="$WEAPON
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
   #echo "issue 0 0 fire_stop"  #+++2017-03-23
   sleep 1
   #_wait_for_end
   sleep 1
   #while :;
    while [ 1 ];
    do
    #unset REQUEST_ANSWER
    #echo watch request range
    echo watch request
    echo watch scripttell
    sleep 1
    echo request range
     read -t 5 REQUEST_ANSWER
     _draw 5 "request ANSWER=$REQUEST_ANSWER"
    case $REQUEST_ANSWER in
    *scripttell*) _draw 5 "SLEEP"; sleep 5;;
    *golem*) _draw 5 "SLEEP"; sleep 5;;
    *$w*)    _draw 5 "SLEEP"; sleep 5;;
    #'')      _draw 5 "SLEEP"; sleep 5;;
    *) _draw 5 "BREAK 1";break 1;;
    esac
   done

   sleep 1
   echo unwatch request range
   echo unwatch scripttell
   sleep 1
  done
 sleep 1
 _is 1 1 fire_stop

 done <<EoI
`echo "$WEAPON"`
EoI

sleep 1
_is 1 1 fire_stop

done <<EoI
`echo "$WEAPONS_TO_MARK" | tr '|' '\n'`
EoI

_draw 7 "WEAPONS_TO_MARK=$WEAPONS_TO_MARK"
_draw 6 "aWEAPON=$aWEAPON"
_draw 5 "WEAPON="$WEAPON
_draw 4 "w=$w"
_is 1 1 fire_stop
# *** Here ends program *** #
_draw 2 "$0 is finished."
