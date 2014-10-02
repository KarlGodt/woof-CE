#!/bin/sh
##
#
#





C=`find . -maxdepth 1 -type f -name "*.css"`

BLANKS=`echo "$C" | grep '[[:blank:]]'`

if [ -n "$BLANKS" ] ; then
C=`echo "$C" | tr ' ' '·'`
C=`echo "$C" | tr '\t' '→'`
fi

for file in $C ; do
file=`echo "$file" | tr '·' ' '`
file=`echo "$file" | tr '→' '\t'`

cat "$file" | sed 's/#/\n#/g' >"$file".1
cat "$file".1 | sed 's#;#;\n#g' >"$file".2
cat "$file".2 | sed 's#}#}\n#g' >"$file".3
done
