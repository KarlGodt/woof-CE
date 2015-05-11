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
) >>update_git_files.lst

FILES=`find "$DIR" -type f`

while read -r gitFILE;
do
test "$gitFILE" || continue

case "$gitFILE" in
*/.gitignore) rm "$gitFILE" && git rm "$gitFILE"; continue;;
esac

#echo "gitFILE='$gitFILE'"

sysFILE=${gitFILE#*$DIR}

echo "$sysFILE"

gitDIR=${gitFILE%/*}
sysDIR=${sysFILE%/*}
test -d "$sysDIR" || mkdir -p "$sysDIR"

(
echo "gitDIR=$gitDIR"
echo "sysDIR=$sysDIR"
) >"$TTY"

ACCESS_RIGHTS_SYS=`stat -c %a "$sysDIR"`
test "`echo -n "$ACCESS_RIGHTS_SYS" | wc -c`" = 3 && ACCESS_RIGHTS_SYS="0$ACCESS_RIGHTS_SYS"
CAN_WRITE_TO_SYS=`echo "$ACCESS_RIGHTS_SYS" | cut -b2 | grep -E '2|3|6|7'`

ACCESS_RIGHTS_GIT=`stat -c %a "$gitDIR"`
test "`echo -n "$ACCESS_RIGHTS_GIT" | wc -c`" = 3 && ACCESS_RIGHTS_GIT="0$ACCESS_RIGHTS_GIT"
CAN_WRITE_TO_GIT=`echo "$ACCESS_RIGHTS_GIT" | cut -b2 | grep -E '2|3|6|7'`

if test -e ${sysFILE} ; then
#echo "$sysFILE exists" >"$TTY"
modSYS=`stat -c %y  "$sysFILE"`
modGIT=`stat -c %y  "$gitFILE"`
rightsSYS=`stat -c %a  "$sysFILE"`
rightsGIT=`stat -c %a  "$gitFILE"`

 if test "$modSYS" != "$modGIT"; then
  if test "$CAN_WRITE_TO_GIT"; then
  if test "$INTERACTIVE"; then
   if test "$TTY"; then
   cp -ia "$sysFILE" "$gitDIR" <"$TTY" || rmdir "$gitDIR"
   else
   echo "Need controlling terminal to copy interactively."
   fi
  else
   cp -a "$sysFILE" "$gitDIR"
  fi
  else
  echo "Having no write access for $gitDIR" >"$TTY"
  fi

 elif test "$rightsSYS" != "$rightsGIT"; then
  if test "$CAN_WRITE_TO_GIT"; then
  if test "$INTERACTIVE"; then
   if test "$TTY"; then
   cp -ia "$sysFILE" "$gitDIR" <"$TTY" || rmdir "$gitDIR"
   else
   echo "Need controlling terminal to copy interactively."
   fi
  else
   cp -a "$sysFILE" "$gitDIR"
  fi
  else
  echo "Having no write access for $gitDIR" >"$TTY"
  fi

 else
 diff -qs "$sysFILE" "$gitFILE" >"$TTY" && continue
 fi



else

:
#echo "$sysFILE missing" >"$TTY"

 __update_system__(){
 if test "$CAN_WRITE_TO"; then
 if test "$INTERACTIVE"; then
  if test "$TTY"; then
   cp -ia "$gitFILE" "$sysDIR" <"$TTY" || rmdir "$sysDIR"
  else
   echo "Need controlling terminal to copy interactively."
  fi
 else
   cp -a "$gitFILE" "$sysDIR"
 fi
 else
  echo "Having no write access for $sysDIR" >"$TTY"
 fi
 }

fi


done >>update_git_files.lst <<EoI
`echo "$FILES"`
EoI


