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

  grep $QUIET -E 'TWO_HELP=|TWO_VERSION=|TWO_VERBOSE=|TWO_DEBUG=' "$file" && continue

  lineNR=`grep -n -m1 'ADD_HELP_MSG=' "$file" | awk -F'[ :]' '{print $1}'`
  [ "$lineNR" ] || continue
  [ "${lineNR//[[:digit:]]/}" ] && continue

  if test "$DRY"; then
   cat "$file" | sed "$lineNR i\TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)"
   #break
   sleep 1
  else
   sed -i".BAK" "$lineNR i\TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)" "$file"
   test $? = 0 && { rm "${file}.BAK"; } || break
   #geany "$file"
   #break
   sleep 1
  fi

done
