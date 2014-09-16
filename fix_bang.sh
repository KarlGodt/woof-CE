#!/bin/ash

pwd

cd `pwd`/woof-code/rootfs-skeleton/ || { echo "Could not change into `pwd`/woof-code/rootfs-skeleton/"; exit 1; }

for file in bin/* sbin/* usr/bin/* usr/sbin/* usr/local/*/*
do
   [ -L "$file" ] && continue
   [ -f "$file" ] || continue
   file "$file" | grep $QUIET -i text | grep -viE 'murga\-lua\-dynamic|perl|python|pascal|bacon|ASCII C program|HTML document|X pixmap image|PNG image data' || continue
   case "$file" in
   *.txt|*.TXT|*rc|*.xpm|*.svg|*.png|*.jpg|*.wav|*.au|*.bac|*.dat) continue;;
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
    *)  sed -i "s,$gitBANG,$sysBANG," "$file" || break
    esac
    sleep 1
   fi

done
