#!/bin/ash

INTERACTIVE=1

DIR=../woof-code/rootfs-skeleton

test -d "$DIR" || exit 1

TTY=`tty`
test -c "$TTY" || unset TTY

(
echo
date
echo
) >>missing_sys_files.lst

FILES=`find "$DIR" -type f`

while read -r gitFILE;
do
test "$gitFILE" || continue

case "$gitFILE" in
*/.gitignore) rm "$gitFILE" && git rm "$gitFILE"; continue;;
esac

#echo "gitFILE='$gitFILE'"

sysFILE=${gitFILE#*$DIR}
if test -e ${sysFILE} ; then
#echo "$sysFILE exists" >"$TTY"
:
else
#echo "$sysFILE missing" >"$TTY"
echo "$sysFILE"

__update_system__(){
sysDIR=${sysFILE%/*}
test -d "$sysDIR" || mkdir -p "$sysDIR"
ACCESS_RIGHTS=`stat -c %a "$sysDIR"`
test "`echo "$ACCESS_RIGHTS" | wc -c`" = 3 && ACCESS_RIGHTS="0$ACCESS_RIGHTS"
CAN_WRITE_TO=`echo "$ACCESS_RIGHTS" | cut -b2 | grep -E '2|3|6|7'`

 if test "$CAN_WRITE_TO"; then
 if test "$INTERACTIVE"; then
  if test "$TTY"; then
   cp -ia "$gitFILE" "$sysDIR" <"$TTY" || rmdir "$sysDIR"
  else
   :
  fi
 else
   cp -a "$gitFILE" "$sysDIR"
 fi
 else
  echo "Having no write access for $sysDIR" >"$TTY"
 fi
}

fi


done >>missing_sys_files.lst <<EoI
`echo "$FILES"`
EoI


