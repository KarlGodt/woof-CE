 #!/bin/ash

case $1 in
-f|*force) have_force=1; shift;;
esac

test "$1" && ACPI_DIR="$1"
test "$ACPI_DIR" || ACPI_DIR=/etc/acpi
shift

test "$1" && CONF_FILE="$1"
test "$CONF_FILE" || CONF_FILE=keyboard/acpid-keyboard.conf
shift

test "$1" && ACTION_DIR="$1"
test "$ACTION_DIR" || ACTION_DIR=keyboard/actions

test "$have_force" && { rm "$ACPI_DIR"/"$CONF_FILE";
rm -r "$ACPI_DIR"/"$ACTION_DIR"; }

mkdir -p "$ACPI_DIR"
mkdir -p "$ACPI_DIR"/"$CONF_FILE%/*}"
mkdir -p "$ACPI_DIR"/"$ACTION_DIR"

_check_input_h(){

if test -f "$ACPI_DIR"/"$CONF_FILE" ; then
:
else

 test -f /usr/include/linux/input.h \
 && _INPUT_H_=/usr/include/linux/input.h
 test -f /usr/include/uapi/linux/input.h \
 && _INPUT_H_=/usr/include/uapi/linux/input.h

fi

 test -f "$_INPUT_H_" && return 0 || return 1

}

_create_keycodes_variable(){

KEYCODES_=`\
grep '^#define KEY_[[:alnum:]_]*[[:blank:]]*[0-9]*' "$_INPUT_H_" |
 grep -oEe 'KEY_[[:alnum:]_]*[[:blank:]]*[[:digit:]]*$|\
KEY_[[:alnum:]_]*[[:blank:]]*[[:digit:]]??[[:blank:]]?.*' \
| grep -v '0x'`

 test "$KEYCODES_" || return 2

}

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

_create_conf_file(){

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

test "${KEYcomment//[[:blank:]]/}" || \
{       KEYcomment='/* '$KEYname" "$KEYnumber' */'; }

_filter_keynumber $KEYnumber || continue

if test "$KEYname" -a "$KEYnumber"; then

echo -e ${KEYname/KEY_/}"\t\t""$ACTION_DIR"/$KEYnumber

cat > "$ACPI_DIR"/"$ACTION_DIR"/$KEYnumber <<EoF
#!/bin/sh
echo "\$0: '\$*'"
echo UNHANDLED "$KEYname"
EoF
chmod $VERB 0754 "$ACPI_DIR"/"$ACTION_DIR"/$KEYnumber

fi

done  >> "$ACPI_DIR"/"$CONF_FILE"

IFS=$"$oldIFS"

}

 _check_input_h            || { echo fail _check_input_h ;exit 1; }
 _create_keycodes_variable || { echo fail _create_keycodes_variable;exit 2; }
 _create_conf_file

 geany "$ACPI_DIR"/"$CONF_FILE"
