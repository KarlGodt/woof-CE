#!/bin/ash

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep -viE 'perl|python' || continue

   grep '# New header by Karl Reimer Godt, September 2014' "$file" || continue

   PERM=`stat -c %a "$file"`
   [ "${PERM//[0-6]/}" ] || continue
   echo "$file"

   sed '/# New header by Karl Reimer Godt, September 2014/,/# End new header/ d' "$file" >/tmp/${file##*/}
   sed -i '2,3 d' /tmp/${file##*/}

   mv /tmp/${file##*/} "$file"
   chmod $PERM "$file"
done
