#!/bin/ash

oldIFS=$IFS
IFS=$'\012'  #\012 octal for NEWLINE ( \011 TAB, \040 SPACE )

[ "$VERBOSE" ] && echo "$0: '$*' '$#' $OPTIND"
OPTINDB=$OPTIND

source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST="-q -R -s -w"
ADD_PARAMETERS="
-d) KEEP_MODIFICATION_TIME=1
-e) KEEP_ESCAPE=1
-f) FORCE_OVERWRITE=1
-h) _usage 0           # implemented
-i) IGNORE_CASE=1
-L) _license 0
-p) PROMPT=1
-q) QUIET=-q           # implemented using grep
-R) RECURSE=1          # implemented
-s) SIMULATE_ONLY=1    # implemented
-t) TMPDIR=/tmp/rpl/
-v) VERBOSE=1;QUIET='' # implemented
-w) WORD=-w            # implemented using grep -w
-x) SUFFIX=\$OPTARG
"
_provide_basic_parameters

TWO_HELP=
ADD_HELP_MSG="$_COMMENT_"
_parse_basic_parameters "$@"
#[ "$DO_SHIFT" ] && [ ! "${DO_SHIFT//[[:digit:]]/}" ] && {
#  for oneSHIFT in 1; do shift; done; }

_trap

while getopts defhiLpqRstvwx: OPT_  #rpl options
do
[ "$VERBOSE" ] && echo "'$OPT_' '$OPTARG'"
case $OPT_ in
d) KEEP_MODIFICATION_TIME=1;;
e) KEEP_ESCAPE=1;;
f) FORCE_OVERWRITE=1;;
h) _usage 0;;            # implemented
i) IGNORE_CASE=1;;
L) _license 0;;
p) PROMPT=1;;
q) QUIET=-q;;           # implemented using grep
R) RECURSE=1;;          # implemented
s) SIMULATE_ONLY=1;;    # implemented
t) TMPDIR=/tmp/rpl/;;
v) VERBOSE=1;QUIET='';; # implemented
w) WORD=-w;;             # implemented using grep -w
x) SUFFIX="$OPTARG";;   #shift;;
esac
#shift
done

[ "$VERBOSE" ] && echo "$0: '$*' $OPTIND"
OPTINDE=$OPTIND
for i in `seq 1 1 $((OPTINDE-OPTINDB))`; do shift; done
[ "$VERBOSE" ] && echo "$0: '$*' '$#' $OPTIND"

[ "$#" = 3 ] || _usage 1 "OLD_PATTERN NEW_PATTERN FILENAME"

#echo "$*" | while read -r aLINE
while read -r aLINE
do c=$((c+1)); [ "$VERBOSE" ] && echo "c='$c' aLINE='$aLINE'"
case $c in
1) oldPATTERN="$aLINE";;
2) newPATTERN="$aLINE";;
3) FILENAME="$aLINE";;
esac
done <<EoI
`echo "$*"`
EoI

[ "$VERBOSE" ] && {
echo "oldPATTERN='$oldPATTERN'"
echo "newPATTERN='$newPATTERN'"
echo "FILENAME='$FILENAME'"
}

if [ ! "$RECURSE" ]; then
 test -e "$FILENAME" || _exit 1 "$FILENAME not existant"
 test -f "$FILENAME" || _exit 1 "$FILENAME not a regular file"
 test -w "$FILENAME" || _exit 1 "$FILENAME not writable"

test "$SIMULATE_ONLY" && {
 grep $WORD $QUIET "$oldPATTERN" "$FILENAME" && \
  echo "Would have changed '$FILENAME'" || \
  echo "$WORD '$oldPATTERN' not found in '$file_'";
 } || {
  grep $WORD $QUIET "$oldPATTERN" "$FILENAME" && \
  { [ "$VERBOSE" ] && echo -n "Changing '$FILENAME' .. "; } || \
  { [ "$VERBOSE" ] && echo "NOT Changing '$FILENAME'"; continue; }
  sed -i".${0##*/}BAK" "s%$oldPATTERN%$newPATTERN%" "$FILENAME"
  [ $? = 0 ] && {
  [ "$VERBOSE" ] && echo -e " \\033[1;32mOK\\033[0;39m"
  rm "${FILENAME}.${0##*/}BAK"
  } || {
  [ "$VERBOSE" ] && echo -e " \\033[1;31mfailed\\033[0;39m"
  cp -a "${FILENAME}.${0##*/}BAK" "$FILENAME"
  }
 }

else
 test -e "$FILENAME" || _exit 1 "$FILENAME not existant"
 test -d "$FILENAME" || _exit 1 "$FILENAME not a regular directory"
 test -w "$FILENAME" || _exit 1 "$FILENAME not writable"

 for file_ in "$FILENAME"/*
 do
  test -e "$file_" || { echo "$file_ not existant"; continue; }
  test -f "$file_" || { echo "$file_ not a regular file"; continue; }
  test -w "$file_" || { echo "$file_ not writable"; continue; }

 test "$SIMULATE_ONLY" && {
  grep $WORD $QUIET "$oldPATTERN" "$file_" && \
   echo "Would have changed '$file_'" || \
   echo "$WORD '$oldPATTERN' not found in '$file_'";
} || {
  grep $WORD $QUIET "$oldPATTERN" "$file_" && \
  { [ "$VERBOSE" ] && echo -n "Changing '$file_' .. "; } || \
  { [ "$VERBOSE" ] && echo "NOT Changing '$file_'"; continue; }
  sed -i".${0##*/}BAK" "s%$oldPATTERN%$newPATTERN%" "$file_"
  [ $? = 0 ] && {
  [ "$VERBOSE" ] && echo -e " \\033[1;32mOK\\033[0;39m"
  rm "${file_}.${0##*/}BAK"
  } || {
  [ "$VERBOSE" ] && echo -e " \\033[1;31mfailed\\033[0;39m"
  cp -a "${file_}.${0##*/}BAK" "$file_"
  }
 }
 done

fi

### END ###
