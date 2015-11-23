#!/bin/ash



DIRS=`find -type d`


while read onedir
do
[ "$onedir" ]    || continue
[ -d "$onedir" ] || continue

onedirS=`echo "$onedir" | sed 's!^\.!!'`
echo "$onedir"

test -e "$onedirS" || { /bin/cp -v -ax --remove-destination "$onedir" "${onedirS%/*}/" || exit; continue; }

 while read oneFILE
 do
 echo "oneFILE=$oneFILE"
 [ "$onedir/$oneFILE" ] || continue
 [ -f "$onedir/$oneFILE" ] || continue
 [ -d "$onedir/$oneFILE" ] && continue

 /bin/cp -v -ax --backup=numbered --remove-destination "$onedir/$oneFILE" "$onedirS"/ || exit
 #echo "onedir/oneFILE=$onedir/$oneFILE"

 done <<EoI
`ls -1A "$onedir"`
EoI


done <<EoI
`echo "$DIRS"`
EoI
