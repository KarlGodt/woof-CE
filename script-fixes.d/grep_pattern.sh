#!/bin/ash

usage(){
cat >&2 <<EoI
$0 grep_PATTERN
EoI
exit $1
}

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

[ "$1" ] || usage 1

QUIET=-q # -q option for grep
GIT=1   # change bang in git repo
SYS=   # change bang in current OS
DRY=  #dry run - do not do actually change bang
while [ "$1" ]; do
case "$1" in
-D) DRY=1;QUIET=-q;;
-d) set -x;;
-S) GIT='';SYS=1;;
-v) VERBOSE=1;oQUIET=1;;
-h|*help) usage 0;;
*) [ "$PATTERN" ] && PATTERN="$PATTERN $1" || PATTERN="$1";; #echo "$0:Unrecognized option '$1'"; exit 1;;
esac
shift
done
[ "$oQUIET" ] && QUIET='';
echo "${0##*/}::Settings:GIT=$GIT' SYS=$SYS' DRY=$DRY' QUIET=$QUIET'"

#gPATTERN=`echo "$PATTERN" | sed -r 's%(.)%\\\\\1%g'`
gPATTERN=`echo "$PATTERN"`
echo "gPATTERN={$gPATTERN}"
#exit

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep $QUIET -viE 'ISO-8859|murga\-lua\-dynamic|perl|python|pascal|bacon|ASCII C program|C++ program|HTML document|X pixmap image|PNG image data' || { [ "$VERBOSE" ] && echo "$file is not a shell script file by detection"; continue; }
   case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat|*.pupdev|*.gs|*Help)
   [ "$VERBOSE" ] && echo "$file is not a shell script file by EXT"; continue;;
   esac

   echo "$file" "$gPATTERN"
   /bin/grep -B5 -A5 "$gPATTERN" "$file" && {
   defaulttexteditor "$file"
   sleep 1
    }


 done

