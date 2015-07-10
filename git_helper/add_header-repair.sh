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

  if test "$DRY"; then
   cat "$file" | sed 's%for oneSHIFT in.*do shift\; done\; \}%for oneSHIFT in \`seq 1 1 \$DO_SHIFT\`\; do shift\; done\; \}%'
   #break
   sleep 1
  else
   sed -i".BAK" 's%for oneSHIFT in.*do shift\; done\; \}%for oneSHIFT in \`seq 1 1 \$DO_SHIFT\`\; do shift\; done\; \}%' "$file"
   test $? = 0 && { rm "${file}.BAK"; } || break
   #geany "$file"
   #break
   sleep 1
  fi

done
