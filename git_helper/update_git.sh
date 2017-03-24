#!/bin/ash
_say_help_msg(){
	cat >&1 <<EoI
# updates the files in git from system
# interactive possible, set INTERACTIVE var
EoI
}

case $* in -h|*help) _say_help_msg; exit 0;; esac

INTERACTIVE=1

. /etc/rc.d/f4puppy5

MY_SELF=`realpath "$0"`
MY_DIR=${MY_SELF%/*}
echo "$MY_SELF $MY_DIR"
cd "$MY_DIR"
pwd



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
*etc/*)
 case $gitFILE in
 *etc/modprobe.d/*) continue;;
 *etc/*/*) :;;
 *) continue;;
 esac
esac

echo;echo >"$TTY"

#echo "gitFILE='$gitFILE'"

sysFILE=${gitFILE#*$DIR}

echo "$sysFILE"

gitDIR=${gitFILE%/*}
sysDIR=${sysFILE%/*}
test -d "$sysDIR" || mkdir $VERB -p "$sysDIR"

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
   echo;echo >"$TTY"
   echo "modSYS=$modSYS modGIT=$modGIT";echo "modSYS=$modSYS modGIT=$modGIT" >"$TTY"
   diff -qs "$gitFILE" "$sysFILE" && { touch $VERB "$gitFILE" "$sysFILE"; continue; }
   diff -up "$gitFILE" "$sysFILE";diff -up "$gitFILE" "$sysFILE" >"$TTY"
   diff -up "$gitFILE" "$sysFILE" >>/tmp/diff_all
   echo;echo >"$TTY"
   echo "modSYS=$modSYS modGIT=$modGIT";echo "modSYS=$modSYS modGIT=$modGIT" >"$TTY"
   echo;echo >"$TTY"
   cp $VERB -ia "$sysFILE" "$gitDIR" <"$TTY" || rmdir "$gitDIR"
   else
   echo "Need controlling terminal to copy interactively."
   fi
  else
   cp $VERB -a "$sysFILE" "$gitDIR"
  fi
  else
  echo "Having no write access for $gitDIR"
  echo "Having no write access for $gitDIR" >"$TTY"
  fi

 elif test "$rightsSYS" != "$rightsGIT"; then
  if test "$CAN_WRITE_TO_GIT"; then
  if test "$INTERACTIVE"; then
   if test "$TTY"; then
   echo;echo >"$TTY"
   #diff -up "$gitFILE" "$sysFILE"
   echo "rightsSYS=$rightsSYS rightsGIT=$rightsGIT";echo "rightsSYS=$rightsSYS rightsGIT=$rightsGIT" >"$TTY"
   echo;echo >"$TTY"
   cp $VERB -ia "$sysFILE" "$gitDIR" <"$TTY" || rmdir "$gitDIR"
   else
   echo "Need controlling terminal to copy interactively."
   fi
  else
   cp $VERB -a "$sysFILE" "$gitDIR"
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
   cp $VERB -ia "$gitFILE" "$sysDIR" <"$TTY" || rmdir "$sysDIR"
  else
   echo "Need controlling terminal to copy interactively."
  fi
 else
   cp $VERB -a "$gitFILE" "$sysDIR"
 fi
 else
  echo "Having no write access for $sysDIR" >"$TTY"
 fi
 }

fi


done >>update_git_files.lst <<EoI
`echo "$FILES"`
EoI

test -s /tmp/diff_all && geany /tmp/diff_all
