#!/bin/ash



DIRS=`find -type d`


while read onedir
do
[ "$onedir" ]    || continue
#hehe .. needs to filter '.' find
#since onedirS will get unset
[ "$onedir" = '.' ] && continue
#so we better filter too
[ "$onedir" = '..' ] && continue
[ -d "$onedir" ] || continue

onedirS=`echo "$onedir" | sed 's!^\.!!'`
echo " onedir=$onedir" >&2
echo "onedirS=$onedirS" >&2
#sleep 5

#in case of '.' unset onedirS will test wrong and cp . ""/ .. 
test -e "$onedirS" || { /bin/cp -v -ax --remove-destination "$onedir" "${onedirS%/*}/" || exit; continue; }

 while read oneFILE
 do
 echo "oneFILE=$oneFILE" >&2
 [ "$onedir/$oneFILE" ] || continue
 [ -f "$onedir/$oneFILE" ] || continue
 [ -d "$onedir/$oneFILE" ] && continue

 if test -L "$onedir/$oneFILE"; then
 /bin/cp -v -ax --remove-destination "$onedir/$oneFILE" "$onedirS"/ || : #exit
 else
 /bin/cp -v -ax --backup=numbered "$onedir/$oneFILE" "$onedirS"/ || : #exit
 fi
 
 #echo "onedir/oneFILE=$onedir/$oneFILE"
 #sleep 1
 done <<EoI
`ls -1A "$onedir"`
EoI

#sleep 1
done <<EoI
`echo "$DIRS"`
EoI

_remove_backups(){
#find backups and diff them. if identical to the original file
# remove them. this is in case of mutiple runs and multipe backups.
BUPS=`find / -xdev -name "*.~[0-9]~"`
for i in $BUPS; do 
file=${i%.~*}; 
echo $file; 
diff -qs $i $file && rm $i;
done
echo
find / -xdev -name "*.~[0-9]~"
}
_remove_backups
