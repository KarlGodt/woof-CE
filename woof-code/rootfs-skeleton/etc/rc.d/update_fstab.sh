#!/bin/ash

_check_tabs()
{
Chars=`echo -n "$@" | wc -c`
#echo "$@:""`echo "$@" | wc -c`"

if test $Chars -ge 48 ; then   #1
TAB='\t'
elif test $Chars -ge 40 ; then #2
TAB='\t\t'
elif test $Chars -ge 32 ; then #3
TAB='\t\t\t'
elif test $Chars -ge 24 ; then #4
TAB='\t\t\t\t'
elif test $Chars -ge 16 ; then #5
TAB='\t\t\t\t\t'
elif test $Chars -ge 8 ; then  #6
TAB='\t\t\t\t\t\t'
else                           #7
TAB='\t\t\t\t\t\t\t'
fi
#echo "TAB='$TAB'"
}

_check_tabs_short()
{
Chars=`echo -n "$@" | wc -c`
#echo "$@:""`echo "$@" | wc -c`"

if test $Chars -ge 24 ;   then #1
TAB='\t'
elif test $Chars -ge 16 ; then #2
TAB='\t\t'
elif test $Chars -ge 8 ;  then #3
TAB='\t\t\t'
else                           #4
TAB='\t\t\t\t'
fi
#echo "TAB='$TAB'"
}

while test $# != 0; do
case $1 in
force|-force|--forcce) FORCE=1;;
pretty|-pretty|--pretty) PRETTY=1;;
esac
shift
done

#test -e /etc/fstab  || touch /etc/fstab
test ! -f /etc/fstab -o "$FORCE" && {
rm -f /etc/fstab
echo -e "
none\t\t\t\t\t\t\t/proc\t\t\t\tproc\t\t\t\tdefaults\t\t\t0\t0
none\t\t\t\t\t\t\t/sys\t\t\t\tsysfs\t\t\t\tdefaults\t\t\t0\t0
none\t\t\t\t\t\t\t/dev/pts\t\t\tdevpts\t\t\t\tgid=2,mode=620\t\t\t0\t0
/dev/fd0\t\t\t\t\t\t/mnt/floppy\t\t\tauto\t\t\t\tnoauto,rw\t\t\t0\t0
" >/etc/fstab || exit 1
} || {
    sed -i".`date +%F`" 's!\ \ \ \ \ \ \ \ !\t!g' /etc/fstab
    test $? = 0 || mv /etc/fstab".`date +%F`" /etc/fstab
    sed -i".`date +%F`" 's!\( \)!\t!g' /etc/fstab
    test $? = 0 || mv /etc/fstab".`date +%F`" /etc/fstab
     }
#/dev/fd1\t\t\t\t\t\t/mnt/fd1\t\t\tauto\t\t\t\tnoauto,rw\t\t\t0 0

ROOTPART=`rdev | cut -f1 -d' '`

while read device label uuid sectype type
do
test "$device" || continue
#echo "$device '$label' '$uuid' '$sectype' '$type'" #debug

device=${device/:/}
mntp=/mnt/${device##*/}
test $device = $ROOTPART && device=/dev/root && mntp=/
grep -q -w $device /etc/fstab && continue

case $device in
*loop*|*ram*|*md*|*mtd*|*nbd*) continue;;
esac

test "`echo "$label" | grep '"$'`" || { label="${label}\\040${uuid}"; uuid=; } #'geany

case $label in
LABEL=*)    :;;
UUID=*)     uuid2="$label";   label=;;
SEC_TYPE=*) sectype2="$label";label=;;
TYPE=*)     type2="$label";   label=;;
esac

case $uuid in
UUID=*) :;;
SEC_TYPE=*) sectype3="$uuid";uuid=;;
TYPE=*)     type3="$uuid";   uuid=;;
esac

case $sectype in
SEC_TYPE=*) :;;
TYPE=*)     type4="$sectype";sectype=;;
esac

test "$type2" && type="$type2"
test "$type3" && type="$type3"
test "$type4" && type="$type4"

test "$sectype2" && sectype="$sectype2"
test "$sectype3" && sectype="$sectype3"

test "$uuid2" && uuid="$uuid2"

#mntp=/mnt/${device##*/}
#test $device = $ROOTPART && device=/dev/root && mntp=/

mntops=defaults
fstype=`echo "$type" | cut -f2 -d'"'`
case $fstype in
jfs)  mntops=quota;;
swap) mntp=none;;  #man fstab: For swap partitions, this field should be specified as `none'
esac

dump=0
fsck=2
case $device in
/dev/root) fsck=1;;
esac
case $fstype in
swap) fsck=0;;
esac

#echo $device $mntp $fstype $mntops 0 0
#grep -q -w $device /etc/fstab || echo -e "$device\t$mntp \t\t""$fstype"" \t\t$mntops\t0 0" >> /etc/fstab
if test "$devuíce" -a "$mntp" -a "$fstype" -a "$mntops"; then
_check_tabs "$device"
 if test ! "$PRETTY"; then
  echo -e "$device"$TAB"$mntp""\t\t\t""$fstype""\t\t\t""$mntops""\t\t\t""$dump\t$fsck" >> /etc/fstab
 else
  echo -en "$device"$TAB >>/etc/fstab
  _check_tabs_short "$mntp"
  echo -en "$mntp"$TAB >>/etc/fstab
  _check_tabs_short "$fstype"
  echo -en "$fstype"$TAB >>/etc/fstab
  _check_tabs_short "$mntops"
  echo -e "$mntops"$TAB"$dump\t$fsck" >> /etc/fstab
 fi
fi

if test "$fstype" != "swap"; then
echo "$device NOT SWAP .."
label=`echo "$label" | cut -f2 -d'"'`
if test "$label" -a "$mntp" -a "$fstype" -a "$mntops"; then
_check_tabs "$label"
 if test ! "$PRETTY"; then
  echo -e "$label"$TAB"$mntp""\t\t\t""$fstype""\t\t\t""$mntops""\t\t\t""$dump\t$fsck" >> /etc/fstab
 else
  echo -en "$label"$TAB >>/etc/fstab
  _check_tabs_short "$mntp"
  echo -en "$mntp"$TAB >>/etc/fstab
  _check_tabs_short "$fstype"
  echo -en "$fstype"$TAB >>/etc/fstab
  _check_tabs_short "$mntops"
  echo -e "$mntops"$TAB"$dump\t$fsck" >> /etc/fstab
 fi
fi

uuid=`echo "$uuid" | cut -f2 -d'"'`
if test "$uuid" -a "$mntp" -a "$fstype" -a "$mntops"; then
_check_tabs "$uuid"
 if test ! "$PRETTY"; then
  echo -e "$uuid"$TAB"$mntp""\t\t\t""$fstype""\t\t\t""$mntops""\t\t\t""$dump\t$fsck" >> /etc/fstab
 else
  echo -en "$uuid"$TAB >>/etc/fstab
  _check_tabs_short "$mntp"
  echo -en "$mntp"$TAB >>/etc/fstab
  _check_tabs_short "$fstype"
  echo -en "$fstype"$TAB >>/etc/fstab
  _check_tabs_short "$mntops"
  echo -e "$mntops"$TAB"$dump\t$fsck" >> /etc/fstab
 fi
fi
fi # not swap

unset type2 type3 type4 sectype2 sectype3 uuid2

done<<EoI
`blkid`
EoI

sed -i".`date +%F`" '/^$/d' /etc/fstab #delete empty lines, make .DATE backup
test $? = 0 || mv /etc/fstab".`date +%F`" /etc/fstab
sed -i".`date +%F`" 's!\ !\\040!g' /etc/fstab  #handle space in labels
test $? = 0 || mv /etc/fstab".`date +%F`" /etc/fstab
