#!/bin/ash


DRY=

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in usr/local/bin/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep -viE 'perl|python|murgaLua_Dynamic' || continue

   grep 'f4puppy5' "$file" || continue

   PERM=`stat -c %a "$file"`
   [ "${PERM//[0-6]/}" ] || continue
   echo "$file"

  SHELLBANG=`head -n1 "$file"`
  case "$SHELLBANG" in
  \#\!*) :;;
  *) continue;;
  esac

  grep $QUIET 'MY_SELF=.*' "$file" || continue
  grep $QUIET 'MY_SELF="/usr/local/bin/.*"' "$file" && continue
  grep $QUIET 'MY_SELF="\$0"' "$file" && continue

  if test "$DRY"; then
   cat "$file" | sed "s%MY_SELF=.*%MY_SELF=\"/$file\"%"
   break
   sleep 1
  else
   sed -i".BAK" "s%MY_SELF=.*%MY_SELF=\"/$file\"%" "$file"
   test $? = 0 && { rm "${file}.BAK"; } || break
   #geany "$file"
   #break
   sleep 1
  fi

done
