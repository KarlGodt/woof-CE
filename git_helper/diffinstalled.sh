#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5

DIRS=`find -type d`


while read onedir
do
[ "$onedir" ]    || continue
[ -d "$onedir" ] || continue

onedirS=`echo "$onedir" | sed 's!^\.!!'`
echo "$onedir" >>/dev/null

 while read oneFILE
 do
 echo "oneFILE=$oneFILE" >>/dev/null
 [ "$onedir/$oneFILE" ] || continue
 [ -f "$onedir/$oneFILE" ] || continue
 [ -d "$onedir/$oneFILE" ] && continue
 [ -L "$onedir/$oneFILE" ] && continue

 echo "onedir/oneFILE=$onedir/$oneFILE" >>/dev/null

 [ -e "$onedirS/$oneFILE" ] || continue

 diff -qs "$onedir/$oneFILE" "$onedirS/$oneFILE" >>/dev/null && continue
 diff -qs "$onedir/$oneFILE" "$onedirS/$oneFILE"

 done <<EoI
`ls -1A "$onedir"`
EoI


done >diff_files.list 2>&1 <<EoI
`echo "$DIRS"`
EoI
