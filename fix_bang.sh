#!/bin/ash

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

# defaults
QUIET=-q # -q option for grep
GIT=1   # change bang in git repo
SYS=   # change bang in current OS
DRY=  #dry run - do not do actually change bang
while [ "$1" ]; do
case "$1" in
-D) DRY=1;;
-d) set -x;;
-S) GIT='';SYS=1;;
-v) VERBOSE=1;QUIET='';
*) echo "$0:Unrecognized option '$1'"; exit 1;;
esac
shift
done
echo "${0##*/}:GIT=$GIT' SYS=$SYS' DRY=$DRY'"

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ]  && continue
   [ -f "$file" ]  || continue
   [ -e "/$file" ] || continue
   [ -L "/$file" ] && continue
   [ -d "/$file" ] && continue
   [ -f "/$file" ] || continue
   file "$file"  | grep -i text | grep $QUIET -viE 'ISO-8859|murga\-lua\-dynamic|perl|python|pascal|bacon|ASCII C program|HTML document|X pixmap image|PNG image data' || continue
   file "/$file" | grep -i text | grep $QUIET -viE 'ISO-8859|murga\-lua\-dynamic|perl|python|pascal|bacon|ASCII C program|HTML document|X pixmap image|PNG image data' || continue
   case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat|*.pup*|*Help|*rc) continue;;
   esac

   gitBANG=`head -n1 "$file"`
   sysBANG=`head -n1 "/$file"`

   if test "$sysBANG" != "$gitBANG"; then
    echo "BANG of '$file' is '$gitBANG' and on system is '$sysBANG'"


    case "$sysBANG" in
    "") :
    #
    #sed -i "1 d" "$file" || break
    #
    ;;
    *)  [ "$DRY" ] || {
         if [ "$GIT" -a ! "$SYS" ]; then
         test -e "${file}.bak" && { echo "already backup file exists"; break; }
         sed -i".bak" "s,^$gitBANG,$sysBANG," "$file"
         [ $? = 0 ] && { sleep 0.3; rm "${file}.bak"; } || {
             cp -a "${file}.bak" "$file"
             echo "Something went wrong"
             geany "$file" "${file}.bak"
             break
            }

         elif [ "$SYS" -a ! "$GIT" ]; then
         test -e "/${file}.bak" && { echo "already backup file exists"; break; }
         sed -i".bak" "s,^$sysBANG,$gitBANG," "/$file"
         [ $? = 0 ] && {
             sleep 0.3;
             rm "/${file}.bak";
             } || {
             cp -a "/${file}.bak" "/$file"
             echo "Something went wrong"
             geany "/$file" "/${file}.bak"
             break
            }
         fi
        }
    esac
    sleep 1
   fi

done
