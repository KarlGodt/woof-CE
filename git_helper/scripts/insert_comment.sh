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
   file "$file" | grep -i text | grep $QUIET -viE 'ISO-8859|murgaLua_Dynamic|perl|python|pascal|bacon|ASCII C program|C++ program|HTML document|X pixmap image|PNG image data' || { [ "$VERBOSE" ] && echo "$file is not a shell script file by detection"; continue; }
   case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat|*.pupdev|*.gs|*Help)
   [ "$VERBOSE" ] && echo "$file is not a shell script file by EXT"; continue;;
   esac


   _COM_=`grep -m1 '_COMMENT_=' "$file"`
   [ "$_COM_" ] || continue

   _COM_="${_COM_#*=}"

   echo "$_COM_" | grep $QUIET -o '"' && {
    test "`echo "$_COM_" | grep -o '"' | wc -w`" = 1 && { #'geany
     _COM_="$_COM_"'"'
    }
   }
   eval "_COM_=$_COM_"  || { geany "$file"; break; }

   [ "$VERBOSE" ] && echo "$file: _COM_=$_COM_'"
   [ "$_COM_" ] && continue

   if [ ! "$DRY" ]; then
   sed -i".bak" "s%_COMMENT_=.*%_COMMENT_=\"\$_TITLE_:Puppy Linux shell script \[to TODO here\]\"%" "$file"
   [ $? = 0 ] && rm "${file}.bak" || {
   defaulttexteditor "$file"
   break
   }

   #defaulttexteditor "$file"
   #break
   fi

done
