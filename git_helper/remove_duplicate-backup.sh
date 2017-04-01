#!/bin/ash

TTY=`tty`

rm -f /tmp/duplicates.lst

ls -1dv *.~[0-9]~ |

while read b
do

#echo "$b" >$TTY

bbase=${b%.~*}
echo "$bbase" >$TTY

grep -q "$bbase" /tmp/duplicates.lst >$TTY && continue
echo "$bbase"

done >/tmp/duplicates.lst



while read -r f
do

echo "$f"

b=`ls -1dv ${f}.~*`
echo "$b"
echo

test "`echo "$b" | wc -l`" -ge 2 || continue

b1=`echo "$b" | tac | sed '1d' | tac`
b2=`echo "$b" | sed '1 d'`

echo
echo "$b1"
echo
echo "$b2"
echo

 c=0
 for x in $b1
 do
 c=$((c+1))
 y=`echo "$b2" | sed -n "$c p"`

  test -e "$x" -a -e "$y" || continue
 diff -qs "$x" "$y" || continue

 echo "$x $y :Would remove one file" >$TTY
 test -e "$x" && rm "$x"

 done

echo

done </tmp/duplicates.lst >/tmp/remove_duplicates.log