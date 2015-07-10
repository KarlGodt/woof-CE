#!/bin/ash

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep -viE 'perl|python|murgaLua_Dynamic' || continue

   grep 'f4puppy5' "$file" && continue

   PERM=`stat -c %a "$file"`
   [ "${PERM//[0-6]/}" ] || continue
   echo "$file"

  SHELLBANG=`head -n1 "$file"`
  case "$SHELLBANG" in
  \#\!*) :;;
  *) continue;;
  esac

   cat >/tmp/${file##*/} <<EoI
$HELLBANG
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_${file##*/}"
_VERSION_=1.0omega
_COMMENT_="\$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/$file"
MY_PID=\$\$

test -f /etc/rc.d/f4puppy5 && {
source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

ADD_HELP_MSG="\$_COMMENT_"
_parse_basic_parameters "\$@"
[ "\$DO_SHIFT" ] && [ ! "\${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in \`seq 1 1 \$DO_SHIFT\`; do shift; done; }

_trap

}
# End new header
#
EoI
   cat "$file" | sed '1d' >>/tmp/${file##*/}
   [ "$?" = 0 ] || continue
   if test ! "$DRY"; then
    rm "$file"
    mv /tmp/${file##*/} "$file"
    chmod $PERM "$file"
   fi

done
