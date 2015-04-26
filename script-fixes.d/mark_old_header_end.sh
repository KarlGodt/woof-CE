#!/bin/ash

usage(){
cat >&2 <<EoI
$0
-D) DRY=1 QUIET=-q
-d) set -x
-S) GIT='' SYS=1
-v) VERBOSE=1 oQUIET=1
-h|*help) usage 0
EoI
exit $1
}

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

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }



 for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep $QUIET -viE 'ISO-8859|murga\-lua\-dynamic|perl|python|pascal|bacon|ASCII C program|C++ program|HTML document|X pixmap image|PNG image data' || { [ "$VERBOSE" ] && echo "$file is not a shell script file by detection"; continue; }
   case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat|*.pupdev|*.gs|*Help)
   [ "$VERBOSE" ] && echo "$file is not a shell script file by EXT"; continue;;
   esac

   gPATTERN='__old_header__(){  #BEGIN'
   grep -F $QUIET "$gPATTERN" "$file" || { echo "$file has no '$gPATTERN'"; continue; }

   [ "$VERBOSE" ] && echo "$file has '$gPATTERN'"

   sPATTERN='###__old_header__(){  #END'
   grep -F $QUIET "$sPATTERN" "$file" && { echo "$file already has '$sPATTERN'"; continue; }


   oldHEADER=`sed "/$gPATTERN/,/###END###/p" "$file"`
   [ "$oldHEADER" ] || continue

   [ "$VERBOSE" ] && echo "$oldHEADER" | grep -n -m2 -e '^\}'
   lineNR2=`echo "$oldHEADER" | grep -n -m2 -e '^\}' | tail -n1 | awk -F'[: ]' '{print $1}'`
   [ "$VERBOSE" ] && echo "lineNR2='$lineNR2'"

   [ "$lineNR2" ] || continue
   [ "${lineNR2//[0-9]/}" ] && continue

   [ "$VERBOSE" ] && grep -n -A $lineNR2 "$gPATTERN" "$file" | grep -m2 -e '^[0-9]*[-:+]\}'
   lineNR1=`grep -n -A $lineNR2 "$gPATTERN" "$file" | grep -m2 -e '^[0-9]*[-:+]\}' | tail -n1 | awk -F'[-: +]' '{print $1}'`
   [ "$VERBOSE" ] && echo "lineNR1='$lineNR1'"

   [ "$lineNR1" ] || continue
   [ "${lineNR1//[0-9]/}" ] && continue

   [ "$DRY" ] && continue

   sed -i".bak" "$lineNR1 s,},}  $sPATTERN," "$file"
   [ $? = 0 ] && rm "${file}.bak" || {
   defaulttexteditor "$file"
   break
   }

   #defaulttexteditor "$file"
   #break
done

