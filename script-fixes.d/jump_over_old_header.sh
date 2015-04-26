#!/bin/ash

#{ echo "FIX ME"; exit 1; }


# defaults
VERBOSE= # more diagnostic output
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
-h|*help) cat >&2 <<EoI
$0 [ option ]
-D) DRY=1 QUIET=-q
-d) set -x
-S) GIT= SYS=1
-v) VERBOSE=1 oQUIET=1
-h|*help)
EoI
exit 0;;
*) echo "$0:Unrecognized option '$1'"; exit 1;;
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

   gPATTERN1='__old_header__(){'
   grep $QUIET "$gPATTERN1" "$file" && { [ "$VERBOSE" ] && echo "$file has '$gPATTERN1'"; continue; }
   gPATTERN2='f4puppy5'
   grep $QUIET "$gPATTERN2" "$file" || { [ "$VERBOSE" ] && echo "$file has no '$gPATTERN2'"; continue; }

   #test "`grep -m2 '_TITLE_=' "$file" | wc -l`" -ge 2 || continue

   [ "$VERBOSE" ] && echo "$file"
   #geany "$file" && sleep 1

   unset lineNR1 lineNR2
   #gPATTERN90='^\#\#\#\K\R\G\ \F\r\ \3\1\.\ \A\u\g'
   #gPATTERN90='trap\ \"exit\ 1\"\ HUP\ INT\ QUIT\ KILL\ TERM'
   #lineNR1=`grep -n -m1 "$gPATTERN90" "$file" | tail -n1 | awk -F'[: ]' '{print $1}'`

   #gPATTERN90='###KRG Fr 31. Aug'
   gPATTERN90='trap "exit 1" HUP INT QUIT KILL TERM'
   lineNR1=`grep -n -m1 -F "$gPATTERN90" "$file" | tail -n1 | awk -F'[: ]' '{print $1}'`

   [ "$VERBOSE" ] && echo -e "\\033[1;31mlineNR1=$lineNR1'\\033[0;39m"
   [ "$lineNR1" ] || continue
   [ "${lineNR1//[0-9]/}" ] && continue
   [ "`echo "$lineNR1" | wc -l`" != 1 ] && continue

   defaulttexteditor "$file"
   sleep 1

   #gPATTERN91='^\#\#\#\K\R\G\ \F\r\ \3\1\.\ \A\u\g'
   #gPATTERN91='^\[\ \"\`echo\ \"\$1\"\ \|\ grep\ \-wE\ \"\-version\|\-V\"`\"\ \]\ '
   #lineNR2=`grep -n "$gPATTERN91" "$file" | tail -n1 | awk -F'[: ]' '{print $1}'`

   #gPATTERN91='###KRG Fr 31. Aug'
   gPATTERN91='[ "`echo "$1" | grep -Ewi "\-version|\-V"`" ] '
   lineNR2=`grep -n -F "$gPATTERN91" "$file" | tail -n1 | awk -F'[: ]' '{print $1}'`

   [ "$VERBOSE" ] && echo -e "\\033[1;33mlineNR2=$lineNR2'\\033[0;39m"
   [ "$lineNR2" ] || continue
   [ "${lineNR2//[0-9]/}" ] && continue
   [ "`echo "$lineNR2" | wc -l`" != 1 ] && continue

   [ "$lineNR1" -a "$lineNR2" ] || {
     echo "$file : One of lineNR missing"
    }
   [ "$lineNR1" = "$lineNR2" ] && { echo "lineNR1 is lineNR2"; continue; }



   [ "$DRY" ] && {
       echo -e "\\033[1;32mWould alter '$file'\\033[0;39m"
       } || {
        sPATTERN11="${gPATTERN1}  #BEGIN"
        sPATTERN1="$lineNR1 "'i \\'"$sPATTERN11"
        echo "'$sPATTERN1'"
       #sed -i".bak$$" "$lineNR1 i\__orig_default_header__(){" "$file" || break
       #sed -i".bak$$" "$lineNR1 i\\""$gPATTERN1" "$file"             #|| break
       [ "$VERBOSE" ] && cat "$file" | sed "$sPATTERN1" | head -n $((lineNR1+5)) | tail -n10

        sed -i".bak$$" "$sPATTERN1" "$file"
       [ $? = 0 ] || { echo "sed 1 : Failure"; break; }
       sleep 0.2
       }



   [ "$DRY" ] && {
       echo -e "\\033[1;32mWould alter '$file'\\033[0;39m"
       defaulttexteditor "$file"
       #break
       } || {
       sPATTERN2="$((lineNR2+1)) a \\}  ###${gPATTERN1} #END"
       echo "'$sPATTERN2'"
       [ "$VERBOSE" ] && cat "$file" | sed "$sPATTERN2" | head -n $((lineNR2+5)) | tail -n10

       #sed -i".bak2$$" "$((lineNR2+1)) a\}" "$file" || break
        sed -i".bak2$$" "$sPATTERN2" "$file"   #|| break
       [ $? = 0 ] && rm "${file}.bak"* || { echo "sed 2 : Failure"; break; }
       sleep 1
       defaulttexteditor "$file"
       #break
        }
done
