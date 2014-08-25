#!/bin/bash

[ -s bkscripts.lst ] || { echo need db file bkscripts.lst; exit 1; }

cut -f1 -d ':' bkscripts.lst | grep -v '^#' |sort -d >bkscripts.lst.sorted

while read line_is_wholepath;do
echo $line_is_wholepath
[ -L "$line_is_wholepath" ] && { echo is LINK;continue; }
[ -f "$line_is_wholepath" ] || { echo Not a FILE;continue; }
sed 's|=\("`\)\(.*\)\(`"\)|=`\2`|' $line_is_wholepath >${line_is_wholepath}.new
[ $? -eq 0 ] || { echo SED ERROR;exit 1; }
sleep 1
mv $line_is_wholepath ${line_is_wholepath}.orig
sleep 1
mv ${line_is_wholepath}.new $line_is_wholepath
chmod +x $line_is_wholepath
done<bkscripts.lst.sorted
