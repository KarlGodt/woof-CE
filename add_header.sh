#!/bin/ash

usage(){
cat >&2 <<EoI
$0
-D) DRY=1 QUIET=-q
-d) set -x
-O) ONCE=1
-G) GIT=1 SYS=''
-S) GIT='' SYS=1
-v) VERBOSE=1 oQUIET=1
-h|*help) usage 0
EoI
exit $1
}

VERBOSE= # give more messages about whats going on
VERB=    # Option passed to mv and chmod
QUIET=-q # -q option for grep
GIT=1   # change bang in git repo
SYS=   # change bang in current OS
DRY=  #dry run - do not do actually change bang
ONCE= #run only one time and show altered file in defaulttexteditor

while [ "$1" ]; do
case "$1" in
-D) DRY=1;QUIET=-q;;
-d) set -x;;
-O) ONCE=1;;
-G) GIT=1;SYS='';;
-S) GIT='';SYS=1;;
-v) VERBOSE=1;VERB=-v;oQUIET=1;;
-h|*help|*usage) usage 0;;
*) [ "$PATTERN" ] && PATTERN="$PATTERN $1" || PATTERN="$1";; #echo "$0:Unrecognized option '$1'"; exit 1;;
esac
shift
done
[ "$oQUIET" ] && QUIET='';
echo "${0##*/}::Settings:GIT=$GIT' SYS=$SYS' DRY=$DRY' QUIET=$QUIET'"


pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep $QUIET -viE 'ISO-8859|murgaLua_Dynamic|perl|python|pascal|bacon|ASCII C program|C++ program|HTML document|X pixmap image|PNG image data' || { [ "$VERBOSE" ] && echo "$file is not a shell script file by detection"; continue; }
  case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat|*.pupdev|*.gs|*Help)
   [ "$VERBOSE" ] && echo "$file is not a shell script file by EXT"; continue;;
   esac

   gPATTERN='f4puppy5'
   if [ "$GIT" -a ! "$SYS" ]; then
    grep "$gPATTERN" "$file" && continue
   elif [ "$SYS" -a ! "$GIT" ]; then
    grep "$gPATTERN" "/$file" && continue
   else break
   fi

   if [ "$GIT" -a ! "$SYS" ]; then
    PERM=`stat -c %a "$file"`
    [ "${PERM//[0-6]/}" ] || continue
   elif [ "$SYS" -a ! "$GIT" ]; then
    PERM=`stat -c %a "/$file"`
    [ "${PERM//[0-6]/}" ] || continue
   else break
   fi

    echo "$file"

  if [ "$GIT" -a ! "$SYS" ]; then
   SHELLBANG=`head -n1 "$file"`
   case "$SHELLBANG" in
   '#!'*) true;;
   *) echo "'$SHELLBANG' does not start with '!#'";continue;;
   esac
  elif [ "$SYS" -a ! "$GIT" ]; then
   SHELLBANG=`head -n1 "/$file"`
   case "$SHELLBANG" in
   '#!'*) true;;
   *) echo "'$SHELLBANG' does not start with '!#'";continue;;
   esac
  else break
  fi

   rm /tmp/${file##*/}

   cat >/tmp/${file##*/} <<EoI
${SHELLBANG}
#
# New header by Karl Reimer Godt, September 2014
  _TITLE_="Puppy_${file##*/}"
_VERSION_=1.0omega
_COMMENT_="\$_TITLE_:Puppy Linux shell script [to TODO here]"

MY_SELF="/$file"
MY_PID=\$\$

test -f /etc/rc.d/f4puppy5 && {
[ "\$HAVE_F4PUPPY5" ] || source /etc/rc.d/f4puppy5

ADD_PARAMETER_LIST=""
ADD_PARAMETERS=""
_provide_basic_parameters

TWO_HELP=''; TWO_VERSION=''; TWO_VERBOSE=''; TWO_DEBUG=''; ## Set to anything if code requires further down (ie. custom usage or version message)
ADD_HELP_MSG="\$_COMMENT_"
_parse_basic_parameters "\$@"
[ "\$DO_SHIFT" ] && [ ! "\${DO_SHIFT//[[:digit:]]/}" ] && {
  for oneSHIFT in \`seq 1 1 \$DO_SHIFT\`; do shift; done; }

_trap

}
# End new header
#
EoI

 if [ "$GIT" -a ! "$SYS" ]; then
  cat "$file" | sed '1d' >>/tmp/${file##*/}
 elif [ "$SYS" -a ! "$GIT" ]; then
  cat "/$file" | sed '1d' >>/tmp/${file##*/}
 else break
 fi

  if [ ! "$DRY" ]; then

   if [ "$GIT" -a ! "$SYS" ]; then
    rm "$file"
    mv $VERB /tmp/${file##*/} "$file"
    chmod $PERM "$file"
   elif [ "$SYS" -a ! "$GIT" ]; then
    rm "/$file"
    mv $VERB /tmp/${file##*/} "/$file"
    chmod $VERB $PERM "/$file"
   else break
   fi

  fi

_run_once(){
 if [ "$GIT" -a ! "$SYS" ]; then
  defaulttexteditor "$file"
  defaulttexteditor /tmp/${file##*/}
  break
 elif [ "$SYS" -a ! "$GIT" ]; then
  defaulttexteditor "/$file"
  defaulttexteditor /tmp/${file##*/}
  break
 else break
 fi
}
[ "$ONCE" ] && _run_once

sleep 1

done
