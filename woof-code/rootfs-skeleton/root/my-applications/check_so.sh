#/bin/sh

ERR=/dev/null
DIRS='/usr/lib /usr/local/lib'

for DIR in $DIRS
do
SO_FILES=`ls -1 "$DIR"/*.so 2>$ERR`
while read -r so_file
do
[ "$so_file" ] || continue
[ -L "$so_file" ] || continue
L_TGT=`readlink -e "$so_file"`
[ "$L_TGT" ] || continue
[ "$L_TGT" = "$so_file" ] && continue
echo "$L_TGT' '$so_file"
SO1_FILES=`ls -1 "$so_file".[0-9] 2>$ERR` #|busybox sort -g
 for so1_file in $SO1_FILES ; do
 echo "--${so1_file}--"
 [ -L "$so1_file" ] || continue
 L_TGT_1=`readlink -e "$so1_file"`
 echo "$L_TGT' '$L_TGT_1"
 [ "$L_TGT_1" ] || continue
 L_TGT_CHANGED=`readlink -e "$so_file"`
 echo " ----- CHANGED ? : '$L_TGT_CHANGED' ---"
 [ "$L_TGT_1" = "$L_TGT_CHANGED" ] && continue
 echo "$L_TGT_1' '$so1_file
 -- DIFFER --"
 ln -sf "$L_TGT_1" "$so_file"
 [ "$?" = 0 ] && echo "Yes" || echo "No"
 done
done<<EOI
$(echo "$SO_FILES")
EOI
done
