#!/bin/ash


dryRUN=${dryRUN:-}

case $PWD in
*/rootfs-skeleton) :;;
*) echo "Needs to run inside rootfs-skeleton directory."; exit 1;;
esac

DIRS=`/bin/find -type d`


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
test -e "$onedirS" || {
  if test "$dryRUN"; then
   echo "Would now copy $onedir ${onedirS%/*}/"
  else
   /bin/cp $VERB -ax --remove-destination "$onedir" "${onedirS%/*}/" || exit;
  fi
    continue; }

 while read oneFILE
 do
 echo "oneFILE=$oneFILE" >&2
 [ "$onedir/$oneFILE" ] || continue
 [ -f "$onedir/$oneFILE" ] || continue
 [ -d "$onedir/$oneFILE" ] && continue

 if test -L "$onedir/$oneFILE"; then
  if test "$dryRUN"; then
   echo "Would now copy $onedir/$oneFILE $onedirS/"
  else
   /bin/cp $VERB -ax --remove-destination "$onedir/$oneFILE" "$onedirS"/ || : #exit
  fi
 else
  if test "$dryRUN"; then
   echo "Would now copy $onedir/$oneFILE $onedirS/"
  else
   /bin/cp $VERB -ax --backup=numbered "$onedir/$oneFILE" "$onedirS"/ || : #exit
  fi
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
BUPS=`/bin/find / -xdev -name "*.~[0-9]~"`
for i in $BUPS; do
file=${i%.~*};
echo $i $file;
diff $Q -s $i $file && rm $VERB $i;
done
echo
/bin/find / -xdev -name "*.~[0-9]~"
}
_remove_backups

#TODO: _mkfontdir
_mkfontdir(){
c=0
if test -s /etc/X11/xorg.conf; then
FP=`grep -i fontpath /etc/X11/xorg.conf | awk '{print $2}' | cut -f2 -d'"'`
 if test "$FP"; then
 for d in $FP; do
 test -L $d && continue
 test -d $d || continue
 c=$((c+1))
 echo $d
 mkfontdir $d
 done
 test "$c" = 0 || return #found some dirs
 fi
fi
# else fallback
 for d1 in /usr/share/fonts /usr/share/X11/fonts \
 /usr/local/share/fonts /usr/local/share/X11/fonts \
 /usr/X11R7/share/fonts /usr/X11R7/share/X11/fonts \
 /usr/lib/X11/fonts /usr/X11R7/lib/fonts /usr/X11R7/lib/X11/fonts
do
 test -L $d1 && continue
 test -d $d1 || continue
 for d2 in default TTF Type1 misc default/TTF default/Type1 default/misc
 do
 test -L $d1/$d2 && continue
 test -d $d1/$d2 || continue
 echo $d1/$d2
 mkfontdir $d1/$d2
 done
done
}
_mkfontdir
