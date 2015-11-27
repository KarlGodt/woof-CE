#!/bin/ash


if test -d "$@" ; then
MED="$@"
else
MEE=`realpath "$0"`
MED=${MEE%/*}
fi


cd "$MED" || exit 1


test -f debian/patches/00list || exit 1

while read f;
do echo $f;
[ "$f" ] || continue
[ -f debian/patches/"$f" ] || continue

chmod +x debian/patches/$f.dpatch;
./debian/patches/$f.dpatch -patch ;

done <debian/patches/00list



