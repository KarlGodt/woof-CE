#!/bin/ash


if test -d "$*" ; then
MED="$@"
elif test -d "$PWD"; then
MED="$PWD"
else
MEE=`realpath "$0"`
MED=${MEE%/*}
fi

echo "MED=$MED"
cd "$MED" || exit 1


if test -f debian/patches/00list; then  #|| exit 1
 HAVE_LIST=debian/patches/00list

elif test -f debian/patches/series; then
   HAVE_LIST=debian/patches/series

fi

test "$HAVE_LIST" || exit 1

while read f;
do echo $f;
[ "$f" ] || continue
case $f in
*.patch)
if [ -f debian/patches/"$f" ]; then
patch -p1 <debian/patches/"$f"
fi
;;
*.diff)
if [ -f debian/patches/"$f" ]; then
patch -p1 <debian/patches/"$f"
fi
;;
*)
if [ -f debian/patches/"$f".dpatch ]; then #|| continue

chmod +x debian/patches/$f.dpatch;
./debian/patches/$f.dpatch -patch ;

elif [ -f debian/patches/"$f" ]; then

chmod +x debian/patches/$f;
./debian/patches/$f. -patch ;

fi
;;
esac

done <$HAVE_LIST
