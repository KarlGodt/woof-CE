#!/bin/ash


DRY=

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
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

  grep $QUIET 'HAVE_F4PUPPY5' "$file" && continue

  if test "$DRY"; then
   cat "$file" | sed 's%^source /etc/rc\.d/f4puppy5$%\[ "$HAVE_F4PUPPY5" \] || source /etc/rc\.d/f4puppy5%'
   break
   sleep 1
  else
   sed -i".BAK" 's%^source /etc/rc\.d/f4puppy5$%\[ "$HAVE_F4PUPPY5" \] || source /etc/rc\.d/f4puppy5%' "$file"
   test $? = 0 && { rm "${file}.BAK"; } || break
   #geany "$file"
   #break
   sleep 1
  fi

done
