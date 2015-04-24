#!/bin/ash


_test_file(){
[ "$*" ]    || return 1
[ -L "$*" ] && return 2
case "$*" in
*.pupdev|*.bac|*.diff|*.*patch)
return 3
;;
esac
test -f "$*" || return 4
#return 0
}

_get_rid_of_space_in_bang(){

for i in bin/* sbin/* usr/bin/* usr/sbin/*;
do

_test_file "$i" || continue
sed -n '1p' "$i" | grep '^#! ' || continue;

echo $i

sed -i '1 s% %%g' "$i" || break;

echo;

done
}

_insert_f4puppy5(){

for i in bin/* sbin/* usr/bin/* usr/sbin/*;
do

_test_file "$i" || continue
grep -n f4puppy5 "$i" && continue

echo $i;

H=`awk '/^#!\/bin/,/^$/ {print}' "$i"`;

sl=`echo "$H" | wc -l` ;
sl=$((sl+1))

echo "$H" ;
echo $sl;

sed -i "$sl i\\. /etc/rc.d/f4puppy5" "$i" || break;

echo;
done
}

_insert_batchmarker(){
for i in bin/* sbin/* usr/bin/* usr/sbin/*;
do

_test_file "$i" || continue
grep -n 'BATCH' "$i"   && continue;
grep -n 'f4pupy5' "$i" && continue;
echo $i;

H=`awk '/^#!\/bin/,/f4puppy5/ {print}' "$i"`;

sl=`echo "$H" | wc -l` ;
sl=$((sl+1));

echo "$H" ;
echo $sl;

sed -i "$sl i\# BATCHMARKER01 - Marker for Line-Position to bulk insert code into." "$i" || break;
echo;
done
}


_update_system(){
for i in bin/* sbin/* usr/bin/* usr/sbin/*;
do
_test_file "$i" || continue
grep -Hn BATCHMARKER "$i"
[ "`grep BATCHMARKER "$i" | wc -l`" -gt 1 ] && continue

INTO=${i%/*}
test -d /$INTO || break
echo $i
cp -a --backup=numbered --remove-destination "$i" /$INTO/

done

}

_remove_batchmarker(){

for i in bin/* sbin/* usr/bin/* usr/sbin/*;
do

_test_file "$i" || continue
grep -Hn BATCHMARKER "$i" || continue
#[ "`grep BATCHMARKER "$i" | wc -l`" -gt 1 ] || continue

sed -i '/^# BATCHMARKER/d' "$i"

done
}
