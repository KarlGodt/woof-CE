#!/bin/ash

# *** Here begins program *** #
echo draw 2 "$0 is started with pid $$ $PPID"

rm -f /tmp/cf_inv.*


f_request(){

echo watch request

echo request items inv

A=1
ANSWER=
ANSWER_OLD=

while [ 1 ]
do
read -t 1 ANSWER
echo "$ANSWER" >>/tmp/cf_inv.inv

test "$ANSWER" || break
#test "$ANSWER" = "$ANSWER_OLD" && A=$((A+1))
test "$ANSWER" = "$ANSWER_OLD" && break
ANSWER_OLD="$ANSWER"
#test $A -gt 6 && break
ANSWER=
done

}

echo watch #drawinfo

echo "monitor 1 1 inv"

A=1
ANSWER=
ANSWER_OLD=

while [ 1 ]
do
read -t 1 ANSWER
echo "$ANSWER" >>/tmp/cf_inv.inv

test "$ANSWER" || break
#test "$ANSWER" = "$ANSWER_OLD" && A=$((A+1))
test "$ANSWER" = "$ANSWER_OLD" && break
ANSWER_OLD="$ANSWER"
#test $A -gt 6 && break
ANSWER=
done


f_sort(){

cut -f9- -d ' ' /tmp/cf_inv.inv >/tmp/cf_inv.cut

while read number rest
do

case $number in
[1-9]*|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty)
echo "$number $rest" >>/tmp/cf_inv.new
;;
''):;;
*)
echo "1 $number $rest" >>/tmp/cf_inv.new
;;
esac

done</tmp/cf_inv.cut

sort -k2 -t' ' /tmp/cf_inv.new >/tmp/cf_inv.srt

}

# *** Here ends program *** #
echo draw 2 "$0 is finished."
