#!/bin/sh

cd `dirname $0`

for d in *.desktop;do
echo $d
I=`grep -m1 '^Icon=.*' $d`
[ "$I" ] || continue
i=${I#*=}
[ "$i" ] || continue
[ "`echo "$i" |grep '/'`" ] && continue

ii=`basename $i`
[[ "$ii" =~ '.' ]] || continue
NEW=`find /usr -name "$ii" |head -n1`
[ "$NEW" ] || continue

sedP2=`echo "$NEW" | sed 's|\.|\\\\.|g'`
sed -i "s|^Icon=.*|Icon=$sedP2|" $d
echo $d
done
