#!/bin/bash

#**********
#
#**********

[ -f bkscripts.lst ] || { echo "No bkscipts.lst file in $PWD. Run bkscripts_find.sh again|first";exit 0; }

while read line ; do
wp="${line%%\:*}"
echo "$wp"
[ "$wp" ] || continue
[ -L "$wp" ] && { echo "Is LINK"; continue; }
[ -f "$wp" ] || { echo "Not a FILE" ; continue; }

IS_EXE=`ls -l "$wp" |awk '{print $1}' | grep 'x'`
if [ "$IS_EXE" ] ;then
cp -a --backup=numbered "$wp" "${wp}.orig"
sed 's|=\("`\)\(.*\)\(`"\)|=`\2`|' "$wp" > "${wp}.new"
[ $? = 0 ] || { echo "sed error";exit 1; }
sleep 1
cp --remove-destination "${wp}.new" "$wp"
sleep 1
chmod +x "$wp"

else
echo "Not executable"
fi

done<bkscripts.lst

