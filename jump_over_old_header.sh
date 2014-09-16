#!/bin/ash

{ echo "FIX ME"; exit 1; }
QUIET=-q

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep -i text | grep $QUIET -viE 'ISO-8859|murga\-lua\-dynamic|perl|python|pascal|bacon|ASCII C program|C++ program|HTML document|X pixmap image|PNG image data' || { echo "$file is not a shell script file by detection";continue; }
   case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat|*.pupdev|*.gs|*Help) echo "$file is not a shell script file by EXT"; continue;;
   esac

   grep $QUIET '__old_default_info_header__(){' "$file" && continue
   grep $QUIET 'f4puppy5' "$file" || { echo "$file has no f4puppy5";continue; }

   test "`grep -m2 '_TITLE_=' "$file" | wc -l`" -ge 2 || continue

   echo "$file"
   #geany "$file" && sleep 1

   lineNR1=`grep -n -m2 '_TITLE_=' "$file" | tail -n1 | awk -F'[: ]' '{print $1}'`
   [ "$lineNR1" ] || continue
   [ "${lineNR1//[0-9]/}" ] && continue
   [ "`echo "$lineNR1" | wc -l`" != 1 ] && continue
   sed -i".bak$$" "$lineNR1 i\__orig_default_header__(){" "$file" || break
   sleep 0.2
   lineNR2=`grep -n -m2 '#\*\*\*\*\*\*\*\*\*\*\*\*' "$file" |tail -n1 | awk -F'[: ]' '{print $1}'`
   [ "$lineNR2" ] || continue
   [ "${lineNR2//[0-9]/}" ] && continue
   [ "`echo "$lineNR2" | wc -l`" != 1 ] && continue
   sed -i".bak2$$" "$lineNR2 a\}" "$file" || break

done
