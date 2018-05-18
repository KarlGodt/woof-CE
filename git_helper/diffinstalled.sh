#!/bin/ash
. /etc/DISTRO_SPECS
. /etc/rc.d/PUPSTATE
. /etc/rc.d/f4puppy5

MY_SELF=`realpath "$0"`
MY_DIR=${MY_SELF%/*}
cd $MY_DIR/..

DIRS=`find -type d | sort -d`


while read onedir
do
[ "$onedir" ]    || continue
[ -d "$onedir" ] || continue

case $onedir in *woof-code/rootfs-skeleton/*) :;; *) continue;; esac

#onedirS=`echo "$onedir" | sed 's!^\.!!'`
onedirS=${onedir##*rootfs-skeleton}
_debug "$onedirS" #>>/dev/null


 while read oneFILE
 do
 _debug "oneFILE=$oneFILE" #>>/dev/null
 [ "$onedir/$oneFILE" ] || continue
 [ -f "$onedir/$oneFILE" ] || continue
 [ -d "$onedir/$oneFILE" ] && continue
 [ -L "$onedir/$oneFILE" ] && continue

 _debug "onedir/oneFILE=$onedir/$oneFILE" #>>/dev/null
 _debug "onedirS/oneFILE=$onedirS/$oneFILE" #>>/dev/null
 
 [ -e "$onedirS/$oneFILE" ] || continue

 diff -qs "$onedir/$oneFILE" "$onedirS/$oneFILE" >>/dev/null && continue
 diff -qs "$onedir/$oneFILE" "$onedirS/$oneFILE"

 done <<EoI
`ls -1A "$onedir"`
EoI


done >/tmp/diff_files.list 2>&1 <<EoI
`echo "$DIRS"`
EoI

if test -s /tmp/diff_files.list; then 

  rm -rf /tmp/diff.d
mkdir -p /tmp/diff.d

while read f wooff a sysf rest;
do

test "$f" || continue
test -e "$wooff" -a -e "$sysf" || continue

echo $wooff $sysf
diff -up $wooff $sysf >/tmp/diff.d/${sysf//\//_}.diff

done </tmp/diff_files.list

else [ "$DEBUG" ] || rm -f /tmp/diff_files.list;
fi
