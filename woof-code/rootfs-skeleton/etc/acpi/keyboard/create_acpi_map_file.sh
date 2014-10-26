#!/bin/ash

case $1 in
-f|*force) have_force=1; shift;;
esac

test "$*" && MAP_FILE="$@"
test "$MAP_FILE" || MAP_FILE=/etc/acpi/keyboard/acpid-keyboard.map

test "$have_force" && rm "$MAP_FILE"

test -d ${MAP_FILE%/*} || mkdir -p ${MAP_FILE%/*}

_filter_keynumber(){

case $1 in
[0-9])

return 3
;;

[1-9][0-9])

return 3
;;

10[0-9]|11[0-2])
echo "Between 100 and 112" >&2
return 3
;;

[1-9][0-9][0-9])
echo OK >&2
return 0
;;

"")
echo "ERROR - no \$1" >&2
return 4
;;

*)
echo "ERROR - '$1' needs to be in range [113-999]" >&2
return 5
;;

esac
return 6

}

_create_map_file(){


if test ! -f "$MAP_FILE" ; then

 test -f /usr/include/linux/input.h \
 && _INPUT_H=/usr/include/linux/input.h
 test -f /usr/include/uapi/linux/input.h \
 && _INPUT_H=/usr/include/uapi/linux/input.h

 test -f "$_INPUT_H" || return 1

fi

KEYCODES_=`\
grep '^#define KEY_[[:alnum:]_]*[[:blank:]]*[0-9]*' "$_INPUT_H" |
 grep -oEe 'KEY_[[:alnum:]_]*[[:blank:]]*[[:digit:]]*$|\
KEY_[[:alnum:]_]*[[:blank:]]*[[:digit:]]??[[:blank:]]?.*' \
| grep -v '0x'`

 test "$KEYCODES_" || return 2

oldIFS="$IFS"
IFS=$'\n'
for oneLINE in $KEYCODES_
do

echo "$oneLINE" >&2

unset KEYname KEYnumber KEYcomment

KEYname=${oneLINE%%[[:blank:]]*}
echo "'$KEYname'" >&2
KEYnumber=`echo ${oneLINE} | awk '{print $2}'`
echo "'$KEYnumber'" >&2
KEYcomment=${oneLINE##*$KEYnumber}
echo "'$KEYcomment'" >&2

#
#test "${KEYcomment//[[:blank:]]/}" || \
#{       KEYcomment='/* '$KEYname" "$KEYnumber' */'; }
#
KEYcomment='/* '$KEYname" "$KEYnumber' */'

_filter_keynumber $KEYnumber || continue

if test "$KEYname" -a "$KEYnumber"; then
echo -e ${KEYname/KEY_/}"\t\t"0x01" $KEYname""\t\t""$KEYnumber""\t"' 1 '$KEYcomment
elif test "$KEYname"; then
echo -e '#'${KEYname/KEY_/}"\t\t"0x01" $KEYname""\t\t"'key_number'"\t"' 1 '$KEYcomment
elif test "$KEYnumber"; then
echo -e '#unique_label_here'"\t"0x01'KEY_keyname'"\t\t""$KEYnumber""\t"' 1 '$KEYcomment
else
echo -e '#unique_label_here'"\t"0x01'KEY_keyname'"\t\t"'key_number'"\t"" 1 "'description'
fi
done     >> "$MAP_FILE"
IFS=$"$oldIFS"

}

 _create_map_file

geany "$MAP_FILE"
