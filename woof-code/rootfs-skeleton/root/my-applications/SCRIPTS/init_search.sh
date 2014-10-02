ALLDRIVES=`probedisk2`
ALLPARTS=`probepart2 | grep -viE "swap|Ext'd|Extended|none|not inserted"`
#FDISK=`fdisk -l | grep '^/dev/' | grep -vE "Ext'd|Extended"`

echo "Detected media devices :
$ALLDRIVES
" #>/dev/console

[ "$PMEDIA" ] && { echo "pmedia=$PMEDIA given."
case $PMEDIA in
cd|dvd|*cd|*dvd)  MEDIA_FIRST=`echo "$ALLDRIVES" | grep -iE 'cd|dvd|scd|sr|hd'` ;;
usb|usb*)   MEDIA_FIRST=`echo "$ALLDRIVES" | grep -iE 'ext|usb'`    ;;
*hd|*flash|*zip)  MEDIA_FIRST=`echo "$ALLDRIVES" | grep -i 'int|hd|sd|sata|ide'` ;;
esac
echo "Narrowing search first on
$MEDIA_FIRST
"
SEARCH_ON=`echo "$MEDIA_FIRST" |cut -f1 -d '|' |tr '\n' '|' |sed 's%|*$%%'`
SEARCH_PARTS=`echo "$ALLPARTS" | grep -E "${SEARCH_ON}"`
 }

[ "$SEARCH_PARTS" ] || SEARCH_PARTS="$ALLPARTS"

mount_and_find_function(){
#guess_fstype $partition; # echo $?
#[ $? = 0 ] || return 1   # no filesystem == not formatted -> mount would fail
#guess_fstype $partition | grep 'unknown' && return 1
blkid $partition | grep -e ' TYPE="[[:alnum:]]*"' || return 1
mount -o ro $partition /mnt/data
[ $? = 0 ] || return 1
if [ "$PSUBDIR" ] ; then
 #[ -d /mnt/data/$PSUBDIR ] && echo "Found $PSUBDIR" || {
 #    echo "NO $PSUBDIR on ${partition##*/}"
 #    return 170; }
 #[ -f /mnt/data/$PSUBDIR/"$PUPFILE" ] && echo "FOUND $PUPFILE" || {
 #    echo "NO $PUPFILE in $PSUBDIR on ${partition##*/}"
 #    return 171; }
 if [ -d /mnt/data/$PSUBDIR ]; then echo "Found $PSUBDIR"
 else echo "NO $PSUBDIR directory on ${partition##*/}";return 170;fi
 if [ -f /mnt/data/$PSUBDIR/"$PUPFILE" ]; then echo "FOUND $PUPFILE"
 else echo "NO $PUPFILE in $PSUBDIR on ${partition##*/}";return 171;fi
  RETURNVAL=0
else
FIND_PUPFILE=`find /mnt/data -maxdepth 2 -name "$PUPFILE"`
[ "$FIND_PUPFILE" ] && RETURNVAL=0 || RETURNVAL=2
fi
umount /mnt/data
return $RETURNVAL
}

everywhere_function(){
for partition in $ALLPARTS ; do
partition="${partition%%|*}"
mount_and_find_function $partition
case $? in
0) break;;
1) :;;
2) :;;
170)
#sync
umount -rl $partition;echo $?
[ $? = 0 ] || umount /mnt/data
;;
171)
#sync
umount -rl $partition;echo $?
[ $? = 0 ] || umount /mnt/data
;;
esac
done
}

ppart_function(){  #searches all partitions on all drives with partition number
ALLPARTSppart=`echo "${SEARCH_PARTS}" |cut -f1 -d'|' | grep "[[:alpha:]]${PPART1}$"`
[ "$ALLPARTSppart" ] || {
 echo "Sorry, no partitions found as $PPART1"
 return 160; }

for partition in $ALLPARTSppart ; do
echo "ppart_function: $partition"
# mount and search
mount_and_find_function $partition
case $? in
0) break;;
1) :;;
2) :;;
170)
#sync
umount -rl $partition;echo $?
[ $? = 0 ] || umount /mnt/data
;;
171)
#sync
umount -rl $partition;echo $?
[ $? = 0 ] || umount /mnt/data
;;
esac
done
}

pdev_function(){  #searches all partitions of the given drive
ALLPARTSpdev=`echo "$SEARCH_PARTS" | grep "^$PDEV"`
[ "$ALLPARTSppart" ] || {
 echo "Sorry, no devices found as $PDEV"
 return 161; }

for partition in $ALLPARTSppart ; do
echo "pdev_function: $partition"
# mount and search
mount_and_find_function $partition
case $? in
0) break;;
1) :;;
2) :;;
170)
#sync
umount -rl $partition;echo $?
[ $? = 0 ] || umount /mnt/data
;;
171)
#sync
umount -rl $partition;echo $?
[ $? = 0 ] || umount /mnt/data
;;
esac
done
}


pdevOne_function(){

#if [ "$PDEV1" ] ; then
 PDEV="${PDEV1//[[:digit:]]/}"
 PPART1="${PDEV1//[\/[:alpha:]]/}"
 echo "FOUND $PDEV ?"
 echo "$ALLPARTS" | grep "$PDEV" || { # >/dev/console
 echo "Sorry, no device recognized as $PDEV"

 return 150; }
 echo "FOUND $PDEV1 ?"
 echo "$ALLPARTS" | grep -w "$PDEV1" || { # >/dev/console
 echo "Sorry, partition not recognized as pdev1=$PDEV1"

 return 151; }

# mount and search
#fi
}

if [ "$PDEV1" ] ; then
pdevOne_function
case $? in
0) :;;
150)
ppart_function
    case $? in
    0) :;;
    160)  #need to search everywhere
    everywhere_function
    ;;
    esac

;;
151)
pdev_function
    case $? in
    0) :;;
    161)  #need to search everywhere
    everywhere_function
    ;;
    esac
;;
esac
elif [ "$PSUBDIR" ] ; then
everywhere_function
fi
